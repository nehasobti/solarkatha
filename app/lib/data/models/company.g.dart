// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Company _$CompanyFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Company',
  json,
  ($checkedConvert) {
    final val = _Company(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      stateCode: $checkedConvert('state_code', (v) => v as String),
      logoUrl: $checkedConvert('logo_url', (v) => v as String?),
      gstin: $checkedConvert('gstin', (v) => v as String?),
      address: $checkedConvert('address', (v) => v as String?),
      phone: $checkedConvert('phone', (v) => v as String?),
      brandColor: $checkedConvert('brand_color', (v) => v as String?),
      mnreVendorId: $checkedConvert('mnre_vendor_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'stateCode': 'state_code',
    'logoUrl': 'logo_url',
    'brandColor': 'brand_color',
    'mnreVendorId': 'mnre_vendor_id',
  },
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'state_code': instance.stateCode,
  'logo_url': instance.logoUrl,
  'gstin': instance.gstin,
  'address': instance.address,
  'phone': instance.phone,
  'brand_color': instance.brandColor,
  'mnre_vendor_id': instance.mnreVendorId,
};
