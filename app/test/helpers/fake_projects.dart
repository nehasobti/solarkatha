import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:solarkatha/features/admin/data/admin_repository.dart';
import 'package:solarkatha/features/projects/data/projects_repository.dart';
import 'package:solarkatha/features/projects/domain/project.dart';
import 'package:solarkatha/features/tracking/presentation/tracking_screen.dart';

/// A signed 3 kW project for lead `l1` with stage 1 done, stage 2 running.
Project sampleProject({String id = 'p1', String leadId = 'l1'}) => Project(
  id: id,
  companyId: '00000000-0000-4000-8000-000000000001',
  leadId: leadId,
  proposalId: 'pr1',
  currentStage: StageKind.discomFeasibility,
  systemKw: 3,
  netPrice: 102000,
  expectedSubsidy: 78000,
  signedAt: DateTime(2026, 10, 1),
);

List<StageRow> sampleStages(String projectId, String leadId) => [
  for (final (i, k) in StageKind.values.indexed)
    StageRow(
      id: '$projectId-s${i + 1}',
      projectId: projectId,
      leadId: leadId,
      kind: k,
      position: i + 1,
      status: i == 0
          ? StageStatus.done
          : i == 1
          ? StageStatus.inProgress
          : StageStatus.pending,
      doneAt: i == 0 ? DateTime(2026, 10, 2) : null,
      dueDate: DateTime.now().add(Duration(days: 7 * (i + 1))),
    ),
];

class FakeProjectsRepository extends Mock implements ProjectsRepository {
  FakeProjectsRepository({List<Project> projects = const []}) {
    for (final p in projects) {
      _projects[p.id] = p;
      _stages[p.id] = sampleStages(p.id, p.leadId);
    }
  }

  final _projects = <String, Project>{};
  final _stages = <String, List<StageRow>>{};
  final completed = <StageKind>[];
  final _changes = StreamController<void>.broadcast();

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  ProjectSummary _summary(Project p) {
    final stages = _stages[p.id]!;
    return ProjectSummary(
      project: p,
      customerName: 'Ramesh Gupta',
      doneCount: stages.where((s) => s.status == StageStatus.done).length,
      current: stages.where((s) => s.kind == p.currentStage).firstOrNull,
    );
  }

  @override
  Stream<List<ProjectSummary>> watchProjects() =>
      _live(() => _projects.values.map(_summary).toList());

  @override
  Stream<ProjectSummary?> watchProject(String id) =>
      _live(() => _projects[id] == null ? null : _summary(_projects[id]!));

  @override
  Stream<Project?> watchProjectForLead(String leadId) => _live(
    () => _projects.values.where((p) => p.leadId == leadId).firstOrNull,
  );

  @override
  Stream<List<StageRow>> watchStages(String projectId) =>
      _live(() => _stages[projectId] ?? const []);

  @override
  Stream<List<String>> watchAssignees(String projectId) =>
      Stream.value(const []);

  @override
  Stream<List<AppNotification>> watchNotifications(String profileId) =>
      Stream.value([
        AppNotification(
          id: 'n1',
          kind: 'stage_done',
          entityId: 'p1',
          data: const {'stage': 'portal_registration'},
          createdAt: DateTime(2026, 10, 2),
        ),
      ]);

  @override
  Future<String?> shareToken(String proposalId) async => 'a' * 48;

  @override
  Future<void> completeStage(StageRow stage, {required String userId}) async {
    completed.add(stage.kind);
    final list = _stages[stage.projectId]!;
    StageRow copy(StageRow s, StageStatus st) => StageRow(
      id: s.id,
      projectId: s.projectId,
      leadId: s.leadId,
      kind: s.kind,
      position: s.position,
      status: st,
      dueDate: s.dueDate,
      doneAt: st == StageStatus.done ? DateTime.now() : s.doneAt,
    );
    final i = list.indexWhere((s) => s.id == stage.id);
    list[i] = copy(list[i], StageStatus.done);
    final p = _projects[stage.projectId]!;
    if (i + 1 < list.length) {
      list[i + 1] = copy(list[i + 1], StageStatus.inProgress);
      _projects[p.id] = Project(
        id: p.id,
        companyId: p.companyId,
        leadId: p.leadId,
        proposalId: p.proposalId,
        currentStage: list[i + 1].kind,
        systemKw: p.systemKw,
        netPrice: p.netPrice,
        expectedSubsidy: p.expectedSubsidy,
        signedAt: p.signedAt,
      );
    }
    _changes.add(null);
  }
}

class FakeAdminRepository extends Mock implements AdminRepository {
  FakeAdminRepository({
    this.stats = const DashboardStats(),
    this.memberList = const [],
  });

  final DashboardStats stats;
  final List<Member> memberList;
  final activeChanges = <(String, bool)>[];

  @override
  Stream<DashboardStats> watchStats() => Stream.value(stats);

  @override
  Stream<List<Member>> watchMembers() => Stream.value(memberList);

  @override
  Future<List<Invite>> invites(String companyId) async => const [
    Invite(id: 'i1', role: 'installer', name: 'Raju', phone: '919800000000'),
  ];

  @override
  Future<void> setActive(String profileId, bool active) async =>
      activeChanges.add((profileId, active));
}

class FakeTrackingApi extends Mock implements TrackingApi {
  FakeTrackingApi(this.data);

  Map<String, dynamic>? data;
  final signatures = <String>[];

  @override
  Future<Map<String, dynamic>?> fetch(String token) async => data;

  @override
  Future<Map<String, dynamic>?> sign(String token, String pngDataUrl) async {
    signatures.add(pngDataUrl);
    return data = {...?data, 'signed': true};
  }
}

Map<String, dynamic> sampleTrackData({String language = 'en'}) => {
  'company': {
    'name': 'Surya Solar',
    'phone': '9999900001',
    'brand_color': '#1565C0',
  },
  'customer_first_name': 'Ramesh',
  'language': language,
  'system_kw': 3,
  'net_price': 102000,
  'subsidy': 78000,
  'status': 'sent',
  'signed': false,
  'pdf_url': 'https://example.com/p.pdf',
  'current_stage': null,
  'stages': <Map<String, dynamic>>[],
  'payment': {'amount': 20400, 'status': 'created', 'url': 'https://rzp.io/x'},
};
