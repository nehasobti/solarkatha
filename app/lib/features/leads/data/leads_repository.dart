import 'dart:convert';
import 'dart:typed_data';

import 'package:powersync/powersync.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../domain/lead.dart';

part 'leads_repository.g.dart';

const _uuid = Uuid();

String _now() => DateTime.now().toUtc().toIso8601String();

String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

class LeadFilter {
  const LeadFilter({this.query = '', this.status, this.assignedTo});

  final String query;
  final LeadStatus? status;
  final String? assignedTo;

  @override
  bool operator ==(Object other) =>
      other is LeadFilter &&
      other.query == query &&
      other.status == status &&
      other.assignedTo == assignedTo;

  @override
  int get hashCode => Object.hash(query, status, assignedTo);
}

/// Leads and lead photos, read from and written to the on-device database.
/// PowerSync uploads the writes when online.
class LeadsRepository {
  LeadsRepository(this._db, this._photos);

  final PowerSyncDatabase _db;
  final AttachmentQueue _photos;

  static Lead _toLead(Map<String, dynamic> row) => Lead.fromJson(row);

  Stream<List<Lead>> watchLeads([LeadFilter filter = const LeadFilter()]) {
    final where = <String>['deleted_at IS NULL'];
    final args = <Object?>[];
    final q = filter.query.trim();
    if (q.isNotEmpty) {
      where.add('(name LIKE ? OR phone LIKE ? OR district LIKE ?)');
      args.addAll(['%$q%', '%$q%', '%$q%']);
    }
    if (filter.status != null) {
      where.add('status = ?');
      args.add(filter.status!.dbValue);
    }
    if (filter.assignedTo != null) {
      where.add('assigned_to = ?');
      args.add(filter.assignedTo);
    }
    return _db
        .watch(
          'SELECT * FROM $leadsTable WHERE ${where.join(' AND ')} '
          'ORDER BY COALESCE(updated_at, created_at) DESC',
          parameters: args,
        )
        .map((rows) => rows.map(_toLead).toList());
  }

  Stream<Lead?> watchLead(String id) => _db
      .watch(
        'SELECT * FROM $leadsTable WHERE id = ? AND deleted_at IS NULL',
        parameters: [id],
      )
      .map((rows) => rows.isEmpty ? null : _toLead(rows.first));

  Stream<Map<LeadStatus, int>> watchStatusCounts() => _db
      .watch(
        'SELECT status, COUNT(*) AS n FROM $leadsTable '
        'WHERE deleted_at IS NULL GROUP BY status',
      )
      .map((rows) {
        final counts = {for (final s in LeadStatus.values) s: 0};
        for (final r in rows) {
          final s = LeadStatus.values.where((v) => v.dbValue == r['status']);
          if (s.isNotEmpty) counts[s.first] = r['n'] as int;
        }
        return counts;
      });

  /// Open leads with a follow-up due before [until].
  Stream<List<Lead>> watchFollowUps(DateTime until) => _db
      .watch(
        'SELECT * FROM $leadsTable WHERE deleted_at IS NULL '
        "AND status NOT IN ('won', 'lost') "
        'AND next_follow_up_at IS NOT NULL AND next_follow_up_at <= ? '
        'ORDER BY next_follow_up_at',
        parameters: [until.toUtc().toIso8601String()],
      )
      .map((rows) => rows.map(_toLead).toList());

  Stream<int> watchCreatedSince(DateTime since) => _db
      .watch(
        'SELECT COUNT(*) AS n FROM $leadsTable '
        'WHERE deleted_at IS NULL AND created_at >= ?',
        parameters: [since.toUtc().toIso8601String()],
      )
      .map((rows) => rows.first['n'] as int);

  /// Ids of rows with local changes not yet uploaded ("not yet synced").
  Stream<Set<String>> watchPendingIds() => _db
      .watch(
        "SELECT json_extract(data, '\$.id') AS id FROM ps_crud",
        triggerOnTables: const {'ps_crud'},
      )
      .map((rows) => {for (final r in rows) ?r['id'] as String?});

  Stream<List<TeamMember>> watchTeam() => _db
      .watch(
        'SELECT id, name, role FROM profiles WHERE active = 1 ORDER BY name',
      )
      .map(
        (rows) => [
          for (final r in rows)
            TeamMember(
              id: r['id'] as String,
              name: (r['name'] as String?) ?? '',
              role: (r['role'] as String?) ?? '',
            ),
        ],
      );

  Map<String, Object?> _fields(LeadInput i) => {
    'name': i.name.trim(),
    'phone': i.phone.trim(),
    'alt_phone': _blank(i.altPhone),
    'address': _blank(i.address),
    'district': _blank(i.district),
    'state_code': i.stateCode,
    'pincode': _blank(i.pincode),
    'lat': i.lat,
    'lng': i.lng,
    'source': i.source.dbValue,
    'notes': _blank(i.notes),
    'next_follow_up_at': i.nextFollowUpAt?.toUtc().toIso8601String(),
    'assigned_to': i.assignedTo,
  };

  Future<String> createLead({
    required LeadInput input,
    required String companyId,
    required String userId,
  }) async {
    final id = _uuid.v4();
    final now = _now();
    final fields = {
      ..._fields(input),
      'id': id,
      'company_id': companyId,
      'created_by': userId,
      'assigned_to': input.assignedTo ?? userId,
      'status': LeadStatus.newLead.dbValue,
      'consent_at': input.consent ? now : null,
      'created_at': now,
      'updated_at': now,
    };
    await _db.execute(
      'INSERT INTO $leadsTable (${fields.keys.join(', ')}) '
      'VALUES (${List.filled(fields.length, '?').join(', ')})',
      fields.values.toList(),
    );
    return id;
  }

  Future<void> updateLead(String id, LeadInput input, {Lead? previous}) async {
    final fields = {
      ..._fields(input),
      'updated_at': _now(),
      if (input.consent && previous?.consentAt == null) 'consent_at': _now(),
    };
    await _update(id, fields);
  }

  Future<void> setStatus(String id, LeadStatus status, {String? lostReason}) =>
      _update(id, {
        'status': status.dbValue,
        'lost_reason': status == LeadStatus.lost
            ? _blank(lostReason ?? '')
            : null,
        'updated_at': _now(),
      });

  Future<void> deleteLead(String id) =>
      _update(id, {'deleted_at': _now(), 'updated_at': _now()});

  Future<void> _update(String id, Map<String, Object?> fields) => _db.execute(
    'UPDATE $leadsTable SET ${fields.keys.map((k) => '$k = ?').join(', ')} '
    'WHERE id = ?',
    [...fields.values, id],
  );

  // ---------------------------------------------------------------------------
  // Photos
  // ---------------------------------------------------------------------------

  Stream<List<LeadPhoto>> watchPhotos(String leadId) => _db
      .watch(
        'SELECT p.id, p.kind, a.state, a.local_uri FROM $leadPhotosTable p '
        'LEFT JOIN ${AttachmentsQueueTable.defaultTableName} a ON a.id = p.id '
        'WHERE p.lead_id = ? AND p.deleted_at IS NULL ORDER BY p.created_at',
        parameters: [leadId],
      )
      .map(
        (rows) => [
          for (final r in rows)
            LeadPhoto(
              id: r['id'] as String,
              kind: PhotoKind.fromDb(r['kind'] as String?),
              uploaded:
                  r['state'] == null ||
                  r['state'] != AttachmentState.queuedUpload.index,
              localUri: r['local_uri'] as String?,
            ),
        ],
      );

  /// Saves the photo on the device and queues it for upload.
  Future<String> addPhoto({
    required Lead lead,
    required PhotoKind kind,
    required Uint8List jpeg,
    required String userId,
  }) async {
    final saved = await _photos.saveFile(
      data: Stream.value(jpeg),
      mediaType: 'image/jpeg',
      fileExtension: 'jpg',
      metaData: lead.companyId,
      updateHook: (tx, attachment) async {
        await tx.execute(
          'INSERT INTO $leadPhotosTable '
          '(id, company_id, lead_id, kind, created_by, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [
            attachment.id,
            lead.companyId,
            lead.id,
            kind.dbValue,
            userId,
            _now(),
          ],
        );
      },
    );
    return saved.id;
  }

  Future<void> deletePhoto(String photoId) => _db.execute(
    'UPDATE $leadPhotosTable SET deleted_at = ? WHERE id = ?',
    [_now(), photoId],
  );
}

/// Draft form values, stored on the device so nothing is lost if the app
/// closes mid-form.
String encodeDraft(LeadInput input) => jsonEncode(input.toJson());

LeadInput? decodeDraft(String? raw) {
  if (raw == null) return null;
  try {
    return LeadInput.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

@Riverpod(keepAlive: true)
LeadsRepository leadsRepository(Ref ref) => LeadsRepository(
  ref.watch(powerSyncDbProvider),
  ref.watch(photoQueueProvider),
);
