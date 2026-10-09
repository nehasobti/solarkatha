import 'dart:typed_data';

import 'package:powersync/powersync.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../domain/project.dart';

part 'projects_repository.g.dart';

const _uuid = Uuid();

typedef StageDocument = ({String stageId, String photoId, String? localUri});
String _now() => DateTime.now().toUtc().toIso8601String();

class ProjectsRepository {
  ProjectsRepository(this._db, this._photos);

  final PowerSyncDatabase _db;
  final AttachmentQueue _photos;

  static const _summarySql =
      'SELECT p.*, l.name AS customer_name, '
      "(SELECT COUNT(*) FROM project_stages s WHERE s.project_id = p.id AND s.status = 'done') AS done_count, "
      's.id AS s_id, s.project_id AS s_project_id, s.lead_id AS s_lead_id, s.stage AS s_stage, '
      's.position AS s_position, s.status AS s_status, s.due_date AS s_due_date, '
      's.started_at AS s_started_at, s.done_at AS s_done_at, s.note AS s_note '
      'FROM projects p JOIN leads l ON l.id = p.lead_id '
      'LEFT JOIN project_stages s ON s.project_id = p.id AND s.stage = p.current_stage '
      'WHERE p.deleted_at IS NULL';

  static ProjectSummary _summary(Map<String, Object?> r) => ProjectSummary(
    project: Project.fromRow(r),
    customerName: (r['customer_name'] as String?) ?? '',
    doneCount: (r['done_count'] as num?)?.toInt() ?? 0,
    current: r['s_id'] == null
        ? null
        : StageRow.fromRow({
            for (final k in [
              'id',
              'project_id',
              'lead_id',
              'stage',
              'position',
              'status',
              'due_date',
              'started_at',
              'done_at',
              'note',
            ])
              k: r['s_$k'],
          }),
  );

  Stream<List<ProjectSummary>> watchProjects() => _db
      .watch(
        '$_summarySql ORDER BY p.completed_at IS NOT NULL, p.signed_at DESC',
        triggerOnTables: const {'projects', 'project_stages', 'leads'},
      )
      .map((rows) => rows.map(_summary).toList());

  Stream<ProjectSummary?> watchProject(String id) => _db
      .watch(
        '$_summarySql AND p.id = ?',
        parameters: [id],
        triggerOnTables: const {'projects', 'project_stages', 'leads'},
      )
      .map((rows) => rows.isEmpty ? null : _summary(rows.first));

  Stream<Project?> watchProjectForLead(String leadId) => _db
      .watch(
        'SELECT * FROM projects WHERE lead_id = ? AND deleted_at IS NULL '
        'ORDER BY created_at DESC LIMIT 1',
        parameters: [leadId],
      )
      .map((rows) => rows.isEmpty ? null : Project.fromRow(rows.first));

  Stream<List<StageRow>> watchStages(String projectId) => _db
      .watch(
        'SELECT * FROM project_stages WHERE project_id = ? ORDER BY position',
        parameters: [projectId],
      )
      .map((rows) => rows.map(StageRow.fromRow).toList());

  /// Marks a stage done and starts the next one (the server does the same,
  /// so this works offline and stays consistent after sync).
  Future<void> completeStage(
    StageRow stage, {
    required String userId,
  }) => _db.writeTransaction((tx) async {
    final now = _now();
    await tx.execute(
      "UPDATE project_stages SET status = 'done', done_at = ?, done_by = ?, "
      'updated_at = ? WHERE id = ?',
      [now, userId, now, stage.id],
    );
    final next = await tx.getOptional(
      'SELECT id, stage FROM project_stages WHERE project_id = ? AND position = ?',
      [stage.projectId, stage.position + 1],
    );
    if (next != null) {
      await tx.execute(
        "UPDATE project_stages SET status = 'in_progress', "
        'started_at = COALESCE(started_at, ?), updated_at = ? '
        "WHERE id = ? AND status = 'pending'",
        [now, now, next['id']],
      );
      await tx.execute(
        'UPDATE projects SET current_stage = ?, updated_at = ? WHERE id = ?',
        [next['stage'], now, stage.projectId],
      );
    } else {
      await tx.execute(
        'UPDATE projects SET completed_at = ?, updated_at = ? WHERE id = ?',
        [now, now, stage.projectId],
      );
    }
  });

  Future<void> setStageStatus(
    StageRow stage,
    StageStatus status, {
    String? note,
  }) => _db.execute(
    'UPDATE project_stages SET status = ?, note = COALESCE(?, note), updated_at = ? '
    'WHERE id = ?',
    [status.dbValue, note, _now(), stage.id],
  );

  Future<void> setStageNote(StageRow stage, String note) => _db.execute(
    'UPDATE project_stages SET note = ?, updated_at = ? WHERE id = ?',
    [note.trim().isEmpty ? null : note.trim(), _now(), stage.id],
  );

  Future<void> setDueDate(StageRow stage, DateTime due) => _db.execute(
    'UPDATE project_stages SET due_date = ?, updated_at = ? WHERE id = ?',
    [due.toIso8601String().substring(0, 10), _now(), stage.id],
  );

  Future<void> updateProject(String id, Map<String, Object?> fields) =>
      _db.execute(
        'UPDATE projects SET ${fields.keys.map((k) => '$k = ?').join(', ')}, '
        'updated_at = ? WHERE id = ?',
        [...fields.values, _now(), id],
      );

  /// A document photo (e.g. DISCOM approval letter) on a stage.
  Future<void> addDocument({
    required StageRow stage,
    required String companyId,
    required String userId,
    required Uint8List jpeg,
  }) => _photos.saveFile(
    data: Stream.value(jpeg),
    mediaType: 'image/jpeg',
    fileExtension: 'jpg',
    metaData: companyId,
    updateHook: (tx, a) async {
      await tx.execute(
        'INSERT INTO $leadPhotosTable '
        '(id, company_id, lead_id, kind, created_by, created_at, project_stage_id) '
        "VALUES (?, ?, ?, 'document', ?, ?, ?)",
        [a.id, companyId, stage.leadId, userId, _now(), stage.id],
      );
    },
  );

  /// Stage documents with their local file (null until downloaded).
  Stream<List<StageDocument>> watchDocuments(String projectId) => _db
      .watch(
        'SELECT p.id, p.project_stage_id, a.local_uri FROM $leadPhotosTable p '
        'JOIN project_stages s ON s.id = p.project_stage_id '
        'LEFT JOIN ${AttachmentsQueueTable.defaultTableName} a ON a.id = p.id '
        'WHERE s.project_id = ? AND p.deleted_at IS NULL ORDER BY p.created_at',
        parameters: [projectId],
      )
      .map(
        (rows) => [
          for (final r in rows)
            (
              stageId: r['project_stage_id']! as String,
              photoId: r['id']! as String,
              localUri: r['local_uri'] as String?,
            ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Installers
  // ---------------------------------------------------------------------------

  Stream<List<String>> watchAssignees(String projectId) => _db
      .watch(
        'SELECT profile_id FROM project_assignees WHERE project_id = ?',
        parameters: [projectId],
      )
      .map((rows) => [for (final r in rows) r['profile_id']! as String]);

  Future<void> setAssigned({
    required Project project,
    required String profileId,
    required bool assigned,
  }) async {
    if (assigned) {
      await _db.execute(
        'INSERT INTO project_assignees (id, company_id, project_id, lead_id, profile_id, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          _uuid.v4(),
          project.companyId,
          project.id,
          project.leadId,
          profileId,
          _now(),
        ],
      );
    } else {
      await _db.execute(
        'DELETE FROM project_assignees WHERE project_id = ? AND profile_id = ?',
        [project.id, profileId],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Tracking link and notifications
  // ---------------------------------------------------------------------------

  Future<String?> shareToken(String proposalId) async {
    final r = await _db.getOptional(
      'SELECT share_token FROM $proposalsTable '
      'WHERE id = ? AND share_revoked_at IS NULL',
      [proposalId],
    );
    return r?['share_token'] as String?;
  }

  /// Turns the customer tracking link off (or back on).
  Future<void> setLinkRevoked(String proposalId, bool revoked) => _db.execute(
    'UPDATE $proposalsTable SET share_revoked_at = ? WHERE id = ?',
    [revoked ? _now() : null, proposalId],
  );

  Stream<List<AppNotification>> watchNotifications(String profileId) => _db
      .watch(
        'SELECT * FROM notifications WHERE profile_id = ? '
        'ORDER BY created_at DESC LIMIT 100',
        parameters: [profileId],
      )
      .map((rows) => rows.map(AppNotification.fromRow).toList());

  Future<void> markAllRead(String profileId) => _db.execute(
    'UPDATE notifications SET read_at = ? WHERE profile_id = ? AND read_at IS NULL',
    [_now(), profileId],
  );
}

@Riverpod(keepAlive: true)
ProjectsRepository projectsRepository(Ref ref) => ProjectsRepository(
  ref.watch(powerSyncDbProvider),
  ref.watch(photoQueueProvider),
);

@riverpod
Stream<List<ProjectSummary>> projectList(Ref ref) =>
    ref.watch(projectsRepositoryProvider).watchProjects();

@riverpod
Stream<ProjectSummary?> projectSummary(Ref ref, String id) =>
    ref.watch(projectsRepositoryProvider).watchProject(id);

@riverpod
Stream<List<StageRow>> projectStages(Ref ref, String projectId) =>
    ref.watch(projectsRepositoryProvider).watchStages(projectId);

@riverpod
Stream<Project?> leadProject(Ref ref, String leadId) =>
    ref.watch(projectsRepositoryProvider).watchProjectForLead(leadId);

@riverpod
Stream<List<String>> projectAssignees(Ref ref, String projectId) =>
    ref.watch(projectsRepositoryProvider).watchAssignees(projectId);
