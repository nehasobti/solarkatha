import 'dart:convert';

/// The PM Surya Ghar stages, in order (matches `public.project_stage`).
enum StageKind {
  portalRegistration('portal_registration'),
  discomFeasibility('discom_feasibility'),
  vendorSelected('vendor_selected'),
  installation('installation'),
  netMeterApplied('net_meter_applied'),
  netMeterInstalled('net_meter_installed'),
  inspection('inspection'),
  commissioningCertificate('commissioning_certificate'),
  subsidyClaimed('subsidy_claimed'),
  subsidyCredited('subsidy_credited');

  const StageKind(this.dbValue);
  final String dbValue;

  static StageKind fromDb(Object? v) => values.firstWhere(
    (s) => s.dbValue == v,
    orElse: () => portalRegistration,
  );
}

enum StageStatus { pending, inProgress, done, blocked }

extension StageStatusDb on StageStatus {
  String get dbValue => this == StageStatus.inProgress ? 'in_progress' : name;

  static StageStatus fromDb(Object? v) => switch (v) {
    'in_progress' => StageStatus.inProgress,
    'done' => StageStatus.done,
    'blocked' => StageStatus.blocked,
    _ => StageStatus.pending,
  };
}

double? _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

DateTime? _t(Object? v) => v is String ? DateTime.tryParse(v) : null;

class Project {
  const Project({
    required this.id,
    required this.companyId,
    required this.leadId,
    required this.proposalId,
    required this.currentStage,
    this.systemKw,
    this.netPrice,
    this.expectedSubsidy,
    this.signedAt,
    this.netMeterNumber,
    this.commissioningDate,
    this.subsidyAmountReceived,
    this.subsidyReceivedAt,
    this.completedAt,
  });

  final String id;
  final String companyId;
  final String leadId;
  final String proposalId;
  final StageKind currentStage;
  final double? systemKw;
  final double? netPrice;
  final double? expectedSubsidy;
  final DateTime? signedAt;
  final String? netMeterNumber;
  final DateTime? commissioningDate;
  final double? subsidyAmountReceived;
  final DateTime? subsidyReceivedAt;
  final DateTime? completedAt;

  bool get isComplete => completedAt != null;

  factory Project.fromRow(Map<String, Object?> r) => Project(
    id: r['id']! as String,
    companyId: r['company_id']! as String,
    leadId: r['lead_id']! as String,
    proposalId: r['proposal_id']! as String,
    currentStage: StageKind.fromDb(r['current_stage']),
    systemKw: _d(r['system_kw']),
    netPrice: _d(r['net_price']),
    expectedSubsidy: _d(r['expected_subsidy']),
    signedAt: _t(r['signed_at']),
    netMeterNumber: r['net_meter_number'] as String?,
    commissioningDate: _t(r['commissioning_date']),
    subsidyAmountReceived: _d(r['subsidy_amount_received']),
    subsidyReceivedAt: _t(r['subsidy_received_at']),
    completedAt: _t(r['completed_at']),
  );
}

class StageRow {
  const StageRow({
    required this.id,
    required this.projectId,
    required this.leadId,
    required this.kind,
    required this.position,
    required this.status,
    this.dueDate,
    this.startedAt,
    this.doneAt,
    this.note,
  });

  final String id;
  final String projectId;
  final String leadId;
  final StageKind kind;
  final int position;
  final StageStatus status;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? doneAt;
  final String? note;

  bool overdue(DateTime now) =>
      status != StageStatus.done &&
      dueDate != null &&
      DateTime(dueDate!.year, dueDate!.month, dueDate!.day + 1).isBefore(now);

  /// Days since this stage started (for "stuck" reports).
  int daysInStage(DateTime now) =>
      startedAt == null ? 0 : now.difference(startedAt!).inDays;

  factory StageRow.fromRow(Map<String, Object?> r) => StageRow(
    id: r['id']! as String,
    projectId: r['project_id']! as String,
    leadId: r['lead_id']! as String,
    kind: StageKind.fromDb(r['stage']),
    position: (r['position'] as num?)?.toInt() ?? 0,
    status: StageStatusDb.fromDb(r['status']),
    dueDate: _t(r['due_date']),
    startedAt: _t(r['started_at']),
    doneAt: _t(r['done_at']),
    note: r['note'] as String?,
  );
}

/// A project with its customer and current stage, for lists.
class ProjectSummary {
  const ProjectSummary({
    required this.project,
    required this.customerName,
    required this.doneCount,
    this.current,
  });

  final Project project;
  final String customerName;
  final int doneCount;
  final StageRow? current;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    this.entityId,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String kind;
  final String? entityId;
  final Map<String, Object?> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  factory AppNotification.fromRow(Map<String, Object?> r) {
    Map<String, Object?> data = const {};
    try {
      final d = jsonDecode((r['data'] as String?) ?? '{}');
      if (d is Map) data = d.cast<String, Object?>();
    } catch (_) {}
    return AppNotification(
      id: r['id']! as String,
      kind: (r['kind'] as String?) ?? '',
      entityId: r['entity_id'] as String?,
      data: data,
      readAt: _t(r['read_at']),
      createdAt: _t(r['created_at']),
    );
  }
}
