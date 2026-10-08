// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lead _$LeadFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Lead',
  json,
  ($checkedConvert) {
    final val = _Lead(
      id: $checkedConvert('id', (v) => v as String),
      companyId: $checkedConvert('company_id', (v) => v as String),
      assignedTo: $checkedConvert('assigned_to', (v) => v as String?),
      createdBy: $checkedConvert('created_by', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String),
      altPhone: $checkedConvert('alt_phone', (v) => v as String?),
      address: $checkedConvert('address', (v) => v as String?),
      district: $checkedConvert('district', (v) => v as String?),
      stateCode: $checkedConvert('state_code', (v) => v as String?),
      pincode: $checkedConvert('pincode', (v) => v as String?),
      lat: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
      lng: $checkedConvert('lng', (v) => (v as num?)?.toDouble()),
      source: $checkedConvert(
        'source',
        (v) => $enumDecodeNullable(_$LeadSourceEnumMap, v) ?? LeadSource.walkIn,
      ),
      status: $checkedConvert(
        'status',
        (v) =>
            $enumDecodeNullable(_$LeadStatusEnumMap, v) ?? LeadStatus.newLead,
      ),
      lostReason: $checkedConvert('lost_reason', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      nextFollowUpAt: $checkedConvert(
        'next_follow_up_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      consentAt: $checkedConvert(
        'consent_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'companyId': 'company_id',
    'assignedTo': 'assigned_to',
    'createdBy': 'created_by',
    'altPhone': 'alt_phone',
    'stateCode': 'state_code',
    'lostReason': 'lost_reason',
    'nextFollowUpAt': 'next_follow_up_at',
    'consentAt': 'consent_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$LeadToJson(_Lead instance) => <String, dynamic>{
  'id': instance.id,
  'company_id': instance.companyId,
  'assigned_to': instance.assignedTo,
  'created_by': instance.createdBy,
  'name': instance.name,
  'phone': instance.phone,
  'alt_phone': instance.altPhone,
  'address': instance.address,
  'district': instance.district,
  'state_code': instance.stateCode,
  'pincode': instance.pincode,
  'lat': instance.lat,
  'lng': instance.lng,
  'source': _$LeadSourceEnumMap[instance.source]!,
  'status': _$LeadStatusEnumMap[instance.status]!,
  'lost_reason': instance.lostReason,
  'notes': instance.notes,
  'next_follow_up_at': instance.nextFollowUpAt?.toIso8601String(),
  'consent_at': instance.consentAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$LeadSourceEnumMap = {
  LeadSource.walkIn: 'walk_in',
  LeadSource.referral: 'referral',
  LeadSource.call: 'call',
  LeadSource.campaign: 'campaign',
};

const _$LeadStatusEnumMap = {
  LeadStatus.newLead: 'new',
  LeadStatus.surveyed: 'surveyed',
  LeadStatus.proposalSent: 'proposal_sent',
  LeadStatus.won: 'won',
  LeadStatus.lost: 'lost',
};

_LeadInput _$LeadInputFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_LeadInput',
  json,
  ($checkedConvert) {
    final val = _LeadInput(
      name: $checkedConvert('name', (v) => v as String? ?? ''),
      phone: $checkedConvert('phone', (v) => v as String? ?? ''),
      altPhone: $checkedConvert('alt_phone', (v) => v as String? ?? ''),
      address: $checkedConvert('address', (v) => v as String? ?? ''),
      district: $checkedConvert('district', (v) => v as String? ?? ''),
      stateCode: $checkedConvert('state_code', (v) => v as String?),
      pincode: $checkedConvert('pincode', (v) => v as String? ?? ''),
      lat: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
      lng: $checkedConvert('lng', (v) => (v as num?)?.toDouble()),
      source: $checkedConvert(
        'source',
        (v) => $enumDecodeNullable(_$LeadSourceEnumMap, v) ?? LeadSource.walkIn,
      ),
      notes: $checkedConvert('notes', (v) => v as String? ?? ''),
      nextFollowUpAt: $checkedConvert(
        'next_follow_up_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      assignedTo: $checkedConvert('assigned_to', (v) => v as String?),
      consent: $checkedConvert('consent', (v) => v as bool? ?? false),
    );
    return val;
  },
  fieldKeyMap: const {
    'altPhone': 'alt_phone',
    'stateCode': 'state_code',
    'nextFollowUpAt': 'next_follow_up_at',
    'assignedTo': 'assigned_to',
  },
);

Map<String, dynamic> _$LeadInputToJson(_LeadInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'alt_phone': instance.altPhone,
      'address': instance.address,
      'district': instance.district,
      'state_code': instance.stateCode,
      'pincode': instance.pincode,
      'lat': instance.lat,
      'lng': instance.lng,
      'source': _$LeadSourceEnumMap[instance.source]!,
      'notes': instance.notes,
      'next_follow_up_at': instance.nextFollowUpAt?.toIso8601String(),
      'assigned_to': instance.assignedTo,
      'consent': instance.consent,
    };
