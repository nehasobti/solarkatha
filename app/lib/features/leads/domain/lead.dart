import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

/// Matches `public.lead_status`.
enum LeadStatus {
  @JsonValue('new')
  newLead,
  @JsonValue('surveyed')
  surveyed,
  @JsonValue('proposal_sent')
  proposalSent,
  @JsonValue('won')
  won,
  @JsonValue('lost')
  lost;

  String get dbValue => switch (this) {
    newLead => 'new',
    surveyed => 'surveyed',
    proposalSent => 'proposal_sent',
    won => 'won',
    lost => 'lost',
  };

  bool get isOpen => this != won && this != lost;
}

/// Matches `public.lead_source`.
enum LeadSource {
  @JsonValue('walk_in')
  walkIn,
  @JsonValue('referral')
  referral,
  @JsonValue('call')
  call,
  @JsonValue('campaign')
  campaign;

  String get dbValue => switch (this) {
    walkIn => 'walk_in',
    referral => 'referral',
    call => 'call',
    campaign => 'campaign',
  };
}

/// Matches `public.photo_kind`. The first four are the survey checklist.
enum PhotoKind {
  @JsonValue('roof')
  roof,
  @JsonValue('meter')
  meter,
  @JsonValue('db_box')
  dbBox,
  @JsonValue('wiring_path')
  wiringPath,
  @JsonValue('bill')
  bill,
  @JsonValue('other')
  other;

  String get dbValue => switch (this) {
    roof => 'roof',
    meter => 'meter',
    dbBox => 'db_box',
    wiringPath => 'wiring_path',
    bill => 'bill',
    other => 'other',
  };

  static PhotoKind fromDb(String? v) =>
      values.firstWhere((k) => k.dbValue == v, orElse: () => other);
}

@freezed
abstract class Lead with _$Lead {
  const Lead._();

  const factory Lead({
    required String id,
    required String companyId,
    String? assignedTo,
    String? createdBy,
    required String name,
    required String phone,
    String? altPhone,
    String? address,
    String? district,
    String? stateCode,
    String? pincode,
    double? lat,
    double? lng,
    @Default(LeadSource.walkIn) LeadSource source,
    @Default(LeadStatus.newLead) LeadStatus status,
    String? lostReason,
    String? notes,
    DateTime? nextFollowUpAt,
    DateTime? consentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

  bool get hasConsent => consentAt != null;

  bool get hasLocation => lat != null && lng != null;

  String get shortAddress => [
    district,
    pincode,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
}

/// What the lead form edits.
@freezed
abstract class LeadInput with _$LeadInput {
  const factory LeadInput({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String altPhone,
    @Default('') String address,
    @Default('') String district,
    String? stateCode,
    @Default('') String pincode,
    double? lat,
    double? lng,
    @Default(LeadSource.walkIn) LeadSource source,
    @Default('') String notes,
    DateTime? nextFollowUpAt,
    String? assignedTo,
    @Default(false) bool consent,
  }) = _LeadInput;

  factory LeadInput.fromJson(Map<String, dynamic> json) =>
      _$LeadInputFromJson(json);

  factory LeadInput.fromLead(Lead l) => LeadInput(
    name: l.name,
    phone: l.phone,
    altPhone: l.altPhone ?? '',
    address: l.address ?? '',
    district: l.district ?? '',
    stateCode: l.stateCode,
    pincode: l.pincode ?? '',
    lat: l.lat,
    lng: l.lng,
    source: l.source,
    notes: l.notes ?? '',
    nextFollowUpAt: l.nextFollowUpAt,
    assignedTo: l.assignedTo,
    consent: l.hasConsent,
  );
}

class LeadPhoto {
  const LeadPhoto({
    required this.id,
    required this.kind,
    required this.uploaded,
    this.localUri,
  });

  final String id;
  final PhotoKind kind;

  /// The file has reached Supabase Storage.
  final bool uploaded;

  /// Path inside the device photo storage, once the file is on this device.
  final String? localUri;
}

class TeamMember {
  const TeamMember({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;
}
