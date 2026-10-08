// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lead {

 String get id; String get companyId; String? get assignedTo; String? get createdBy; String get name; String get phone; String? get altPhone; String? get address; String? get district; String? get stateCode; String? get pincode; double? get lat; double? get lng; LeadSource get source; LeadStatus get status; String? get lostReason; String? get notes; DateTime? get nextFollowUpAt; DateTime? get consentAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadCopyWith<Lead> get copyWith => _$LeadCopyWithImpl<Lead>(this as Lead, _$identity);

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Lead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lead&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.companyId, _this.companyId) || other.companyId == _this.companyId)&&(identical(other.assignedTo, _this.assignedTo) || other.assignedTo == _this.assignedTo)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.altPhone, _this.altPhone) || other.altPhone == _this.altPhone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.stateCode, _this.stateCode) || other.stateCode == _this.stateCode)&&(identical(other.pincode, _this.pincode) || other.pincode == _this.pincode)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lostReason, _this.lostReason) || other.lostReason == _this.lostReason)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.nextFollowUpAt, _this.nextFollowUpAt) || other.nextFollowUpAt == _this.nextFollowUpAt)&&(identical(other.consentAt, _this.consentAt) || other.consentAt == _this.consentAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Lead;
  return Object.hashAll([runtimeType,_this.id,_this.companyId,_this.assignedTo,_this.createdBy,_this.name,_this.phone,_this.altPhone,_this.address,_this.district,_this.stateCode,_this.pincode,_this.lat,_this.lng,_this.source,_this.status,_this.lostReason,_this.notes,_this.nextFollowUpAt,_this.consentAt,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Lead;
  return 'Lead(id: ${_this.id}, companyId: ${_this.companyId}, assignedTo: ${_this.assignedTo}, createdBy: ${_this.createdBy}, name: ${_this.name}, phone: ${_this.phone}, altPhone: ${_this.altPhone}, address: ${_this.address}, district: ${_this.district}, stateCode: ${_this.stateCode}, pincode: ${_this.pincode}, lat: ${_this.lat}, lng: ${_this.lng}, source: ${_this.source}, status: ${_this.status}, lostReason: ${_this.lostReason}, notes: ${_this.notes}, nextFollowUpAt: ${_this.nextFollowUpAt}, consentAt: ${_this.consentAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $LeadCopyWith<$Res>  {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) _then) = _$LeadCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String? assignedTo, String? createdBy, String name, String phone, String? altPhone, String? address, String? district, String? stateCode, String? pincode, double? lat, double? lng, LeadSource source, LeadStatus status, String? lostReason, String? notes, DateTime? nextFollowUpAt, DateTime? consentAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$LeadCopyWithImpl<$Res>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._self, this._then);

  final Lead _self;
  final $Res Function(Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? assignedTo = freezed,Object? createdBy = freezed,Object? name = null,Object? phone = null,Object? altPhone = freezed,Object? address = freezed,Object? district = freezed,Object? stateCode = freezed,Object? pincode = freezed,Object? lat = freezed,Object? lng = freezed,Object? source = null,Object? status = null,Object? lostReason = freezed,Object? notes = freezed,Object? nextFollowUpAt = freezed,Object? consentAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Lead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,altPhone: freezed == altPhone ? _self.altPhone : altPhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,stateCode: freezed == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String?,pincode: freezed == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LeadSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,lostReason: freezed == lostReason ? _self.lostReason : lostReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,nextFollowUpAt: freezed == nextFollowUpAt ? _self.nextFollowUpAt : nextFollowUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consentAt: freezed == consentAt ? _self.consentAt : consentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Lead].
extension LeadPatterns on Lead {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lead value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lead value)  $default,){
final _that = this;
switch (_that) {
case _Lead():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lead value)?  $default,){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String? assignedTo,  String? createdBy,  String name,  String phone,  String? altPhone,  String? address,  String? district,  String? stateCode,  String? pincode,  double? lat,  double? lng,  LeadSource source,  LeadStatus status,  String? lostReason,  String? notes,  DateTime? nextFollowUpAt,  DateTime? consentAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.companyId,_that.assignedTo,_that.createdBy,_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.status,_that.lostReason,_that.notes,_that.nextFollowUpAt,_that.consentAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String? assignedTo,  String? createdBy,  String name,  String phone,  String? altPhone,  String? address,  String? district,  String? stateCode,  String? pincode,  double? lat,  double? lng,  LeadSource source,  LeadStatus status,  String? lostReason,  String? notes,  DateTime? nextFollowUpAt,  DateTime? consentAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Lead():
return $default(_that.id,_that.companyId,_that.assignedTo,_that.createdBy,_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.status,_that.lostReason,_that.notes,_that.nextFollowUpAt,_that.consentAt,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String? assignedTo,  String? createdBy,  String name,  String phone,  String? altPhone,  String? address,  String? district,  String? stateCode,  String? pincode,  double? lat,  double? lng,  LeadSource source,  LeadStatus status,  String? lostReason,  String? notes,  DateTime? nextFollowUpAt,  DateTime? consentAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.companyId,_that.assignedTo,_that.createdBy,_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.status,_that.lostReason,_that.notes,_that.nextFollowUpAt,_that.consentAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lead extends Lead {
  const _Lead({required this.id, required this.companyId, this.assignedTo, this.createdBy, required this.name, required this.phone, this.altPhone, this.address, this.district, this.stateCode, this.pincode, this.lat, this.lng, this.source = LeadSource.walkIn, this.status = LeadStatus.newLead, this.lostReason, this.notes, this.nextFollowUpAt, this.consentAt, this.createdAt, this.updatedAt}): super._();
  factory _Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String? assignedTo;
@override final  String? createdBy;
@override final  String name;
@override final  String phone;
@override final  String? altPhone;
@override final  String? address;
@override final  String? district;
@override final  String? stateCode;
@override final  String? pincode;
@override final  double? lat;
@override final  double? lng;
@override@JsonKey() final  LeadSource source;
@override@JsonKey() final  LeadStatus status;
@override final  String? lostReason;
@override final  String? notes;
@override final  DateTime? nextFollowUpAt;
@override final  DateTime? consentAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadCopyWith<_Lead> get copyWith => __$LeadCopyWithImpl<_Lead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.altPhone, altPhone) || other.altPhone == altPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.district, district) || other.district == district)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.lostReason, lostReason) || other.lostReason == lostReason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.nextFollowUpAt, nextFollowUpAt) || other.nextFollowUpAt == nextFollowUpAt)&&(identical(other.consentAt, consentAt) || other.consentAt == consentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,companyId,assignedTo,createdBy,name,phone,altPhone,address,district,stateCode,pincode,lat,lng,source,status,lostReason,notes,nextFollowUpAt,consentAt,createdAt,updatedAt]);
}

@override
String toString() {
    return 'Lead(id: $id, companyId: $companyId, assignedTo: $assignedTo, createdBy: $createdBy, name: $name, phone: $phone, altPhone: $altPhone, address: $address, district: $district, stateCode: $stateCode, pincode: $pincode, lat: $lat, lng: $lng, source: $source, status: $status, lostReason: $lostReason, notes: $notes, nextFollowUpAt: $nextFollowUpAt, consentAt: $consentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LeadCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$LeadCopyWith(_Lead value, $Res Function(_Lead) _then) = __$LeadCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String? assignedTo, String? createdBy, String name, String phone, String? altPhone, String? address, String? district, String? stateCode, String? pincode, double? lat, double? lng, LeadSource source, LeadStatus status, String? lostReason, String? notes, DateTime? nextFollowUpAt, DateTime? consentAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$LeadCopyWithImpl<$Res>
    implements _$LeadCopyWith<$Res> {
  __$LeadCopyWithImpl(this._self, this._then);

  final _Lead _self;
  final $Res Function(_Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? assignedTo = freezed,Object? createdBy = freezed,Object? name = null,Object? phone = null,Object? altPhone = freezed,Object? address = freezed,Object? district = freezed,Object? stateCode = freezed,Object? pincode = freezed,Object? lat = freezed,Object? lng = freezed,Object? source = null,Object? status = null,Object? lostReason = freezed,Object? notes = freezed,Object? nextFollowUpAt = freezed,Object? consentAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Lead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,altPhone: freezed == altPhone ? _self.altPhone : altPhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,stateCode: freezed == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String?,pincode: freezed == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LeadSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,lostReason: freezed == lostReason ? _self.lostReason : lostReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,nextFollowUpAt: freezed == nextFollowUpAt ? _self.nextFollowUpAt : nextFollowUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consentAt: freezed == consentAt ? _self.consentAt : consentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LeadInput {

 String get name; String get phone; String get altPhone; String get address; String get district; String? get stateCode; String get pincode; double? get lat; double? get lng; LeadSource get source; String get notes; DateTime? get nextFollowUpAt; String? get assignedTo; bool get consent;
/// Create a copy of LeadInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadInputCopyWith<LeadInput> get copyWith => _$LeadInputCopyWithImpl<LeadInput>(this as LeadInput, _$identity);

  /// Serializes this LeadInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeadInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadInput&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.altPhone, _this.altPhone) || other.altPhone == _this.altPhone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.stateCode, _this.stateCode) || other.stateCode == _this.stateCode)&&(identical(other.pincode, _this.pincode) || other.pincode == _this.pincode)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.nextFollowUpAt, _this.nextFollowUpAt) || other.nextFollowUpAt == _this.nextFollowUpAt)&&(identical(other.assignedTo, _this.assignedTo) || other.assignedTo == _this.assignedTo)&&(identical(other.consent, _this.consent) || other.consent == _this.consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeadInput;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.altPhone,_this.address,_this.district,_this.stateCode,_this.pincode,_this.lat,_this.lng,_this.source,_this.notes,_this.nextFollowUpAt,_this.assignedTo,_this.consent);
}

@override
String toString() {
  final _this = this as LeadInput;
  return 'LeadInput(name: ${_this.name}, phone: ${_this.phone}, altPhone: ${_this.altPhone}, address: ${_this.address}, district: ${_this.district}, stateCode: ${_this.stateCode}, pincode: ${_this.pincode}, lat: ${_this.lat}, lng: ${_this.lng}, source: ${_this.source}, notes: ${_this.notes}, nextFollowUpAt: ${_this.nextFollowUpAt}, assignedTo: ${_this.assignedTo}, consent: ${_this.consent})';
}


}

/// @nodoc
abstract mixin class $LeadInputCopyWith<$Res>  {
  factory $LeadInputCopyWith(LeadInput value, $Res Function(LeadInput) _then) = _$LeadInputCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String altPhone, String address, String district, String? stateCode, String pincode, double? lat, double? lng, LeadSource source, String notes, DateTime? nextFollowUpAt, String? assignedTo, bool consent
});




}
/// @nodoc
class _$LeadInputCopyWithImpl<$Res>
    implements $LeadInputCopyWith<$Res> {
  _$LeadInputCopyWithImpl(this._self, this._then);

  final LeadInput _self;
  final $Res Function(LeadInput) _then;

/// Create a copy of LeadInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? altPhone = null,Object? address = null,Object? district = null,Object? stateCode = freezed,Object? pincode = null,Object? lat = freezed,Object? lng = freezed,Object? source = null,Object? notes = null,Object? nextFollowUpAt = freezed,Object? assignedTo = freezed,Object? consent = null,}) {
  return _then(LeadInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,altPhone: null == altPhone ? _self.altPhone : altPhone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,stateCode: freezed == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String?,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LeadSource,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,nextFollowUpAt: freezed == nextFollowUpAt ? _self.nextFollowUpAt : nextFollowUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,consent: null == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeadInput].
extension LeadInputPatterns on LeadInput {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadInput() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadInput value)  $default,){
final _that = this;
switch (_that) {
case _LeadInput():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadInput value)?  $default,){
final _that = this;
switch (_that) {
case _LeadInput() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String altPhone,  String address,  String district,  String? stateCode,  String pincode,  double? lat,  double? lng,  LeadSource source,  String notes,  DateTime? nextFollowUpAt,  String? assignedTo,  bool consent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadInput() when $default != null:
return $default(_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.notes,_that.nextFollowUpAt,_that.assignedTo,_that.consent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String altPhone,  String address,  String district,  String? stateCode,  String pincode,  double? lat,  double? lng,  LeadSource source,  String notes,  DateTime? nextFollowUpAt,  String? assignedTo,  bool consent)  $default,) {final _that = this;
switch (_that) {
case _LeadInput():
return $default(_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.notes,_that.nextFollowUpAt,_that.assignedTo,_that.consent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String altPhone,  String address,  String district,  String? stateCode,  String pincode,  double? lat,  double? lng,  LeadSource source,  String notes,  DateTime? nextFollowUpAt,  String? assignedTo,  bool consent)?  $default,) {final _that = this;
switch (_that) {
case _LeadInput() when $default != null:
return $default(_that.name,_that.phone,_that.altPhone,_that.address,_that.district,_that.stateCode,_that.pincode,_that.lat,_that.lng,_that.source,_that.notes,_that.nextFollowUpAt,_that.assignedTo,_that.consent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeadInput implements LeadInput {
  const _LeadInput({this.name = '', this.phone = '', this.altPhone = '', this.address = '', this.district = '', this.stateCode, this.pincode = '', this.lat, this.lng, this.source = LeadSource.walkIn, this.notes = '', this.nextFollowUpAt, this.assignedTo, this.consent = false});
  factory _LeadInput.fromJson(Map<String, dynamic> json) => _$LeadInputFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String altPhone;
@override@JsonKey() final  String address;
@override@JsonKey() final  String district;
@override final  String? stateCode;
@override@JsonKey() final  String pincode;
@override final  double? lat;
@override final  double? lng;
@override@JsonKey() final  LeadSource source;
@override@JsonKey() final  String notes;
@override final  DateTime? nextFollowUpAt;
@override final  String? assignedTo;
@override@JsonKey() final  bool consent;

/// Create a copy of LeadInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadInputCopyWith<_LeadInput> get copyWith => __$LeadInputCopyWithImpl<_LeadInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadInput&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.altPhone, altPhone) || other.altPhone == altPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.district, district) || other.district == district)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.nextFollowUpAt, nextFollowUpAt) || other.nextFollowUpAt == nextFollowUpAt)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.consent, consent) || other.consent == consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,altPhone,address,district,stateCode,pincode,lat,lng,source,notes,nextFollowUpAt,assignedTo,consent);
}

@override
String toString() {
    return 'LeadInput(name: $name, phone: $phone, altPhone: $altPhone, address: $address, district: $district, stateCode: $stateCode, pincode: $pincode, lat: $lat, lng: $lng, source: $source, notes: $notes, nextFollowUpAt: $nextFollowUpAt, assignedTo: $assignedTo, consent: $consent)';
}


}

/// @nodoc
abstract mixin class _$LeadInputCopyWith<$Res> implements $LeadInputCopyWith<$Res> {
  factory _$LeadInputCopyWith(_LeadInput value, $Res Function(_LeadInput) _then) = __$LeadInputCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String altPhone, String address, String district, String? stateCode, String pincode, double? lat, double? lng, LeadSource source, String notes, DateTime? nextFollowUpAt, String? assignedTo, bool consent
});




}
/// @nodoc
class __$LeadInputCopyWithImpl<$Res>
    implements _$LeadInputCopyWith<$Res> {
  __$LeadInputCopyWithImpl(this._self, this._then);

  final _LeadInput _self;
  final $Res Function(_LeadInput) _then;

/// Create a copy of LeadInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? altPhone = null,Object? address = null,Object? district = null,Object? stateCode = freezed,Object? pincode = null,Object? lat = freezed,Object? lng = freezed,Object? source = null,Object? notes = null,Object? nextFollowUpAt = freezed,Object? assignedTo = freezed,Object? consent = null,}) {
  return _then(_LeadInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,altPhone: null == altPhone ? _self.altPhone : altPhone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,stateCode: freezed == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String?,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LeadSource,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,nextFollowUpAt: freezed == nextFollowUpAt ? _self.nextFollowUpAt : nextFollowUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,consent: null == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
