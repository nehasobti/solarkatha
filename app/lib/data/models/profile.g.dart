// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Profile', json, ($checkedConvert) {
      final val = _Profile(
        id: $checkedConvert('id', (v) => v as String),
        companyId: $checkedConvert('company_id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        phone: $checkedConvert('phone', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
        role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
        language: $checkedConvert('language', (v) => v as String? ?? 'en'),
        active: $checkedConvert('active', (v) => v as bool? ?? true),
      );
      return val;
    }, fieldKeyMap: const {'companyId': 'company_id'});

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'company_id': instance.companyId,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'language': instance.language,
  'active': instance.active,
};

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.sales: 'sales',
  UserRole.installer: 'installer',
};
