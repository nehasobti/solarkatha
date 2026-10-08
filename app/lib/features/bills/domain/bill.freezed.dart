// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Bill {

 String get id; String get companyId; String get leadId; String? get photoId; String? get discom; String? get consumerNumber; String? get customerName; String? get tariffCategory; double? get sanctionedLoadKw; String? get billingPeriod; Map<String, double> get unitsMonthly; double? get avgMonthlyUnits; double? get billAmount; Map<String, FieldConfidence> get aiConfidence; String get source; DateTime? get confirmedAt; DateTime? get createdAt;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Bill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.companyId, _this.companyId) || other.companyId == _this.companyId)&&(identical(other.leadId, _this.leadId) || other.leadId == _this.leadId)&&(identical(other.photoId, _this.photoId) || other.photoId == _this.photoId)&&(identical(other.discom, _this.discom) || other.discom == _this.discom)&&(identical(other.consumerNumber, _this.consumerNumber) || other.consumerNumber == _this.consumerNumber)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.tariffCategory, _this.tariffCategory) || other.tariffCategory == _this.tariffCategory)&&(identical(other.sanctionedLoadKw, _this.sanctionedLoadKw) || other.sanctionedLoadKw == _this.sanctionedLoadKw)&&(identical(other.billingPeriod, _this.billingPeriod) || other.billingPeriod == _this.billingPeriod)&&const DeepCollectionEquality().equals(other.unitsMonthly, _this.unitsMonthly)&&(identical(other.avgMonthlyUnits, _this.avgMonthlyUnits) || other.avgMonthlyUnits == _this.avgMonthlyUnits)&&(identical(other.billAmount, _this.billAmount) || other.billAmount == _this.billAmount)&&const DeepCollectionEquality().equals(other.aiConfidence, _this.aiConfidence)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.confirmedAt, _this.confirmedAt) || other.confirmedAt == _this.confirmedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as Bill;
  return Object.hash(runtimeType,_this.id,_this.companyId,_this.leadId,_this.photoId,_this.discom,_this.consumerNumber,_this.customerName,_this.tariffCategory,_this.sanctionedLoadKw,_this.billingPeriod,const DeepCollectionEquality().hash(_this.unitsMonthly),_this.avgMonthlyUnits,_this.billAmount,const DeepCollectionEquality().hash(_this.aiConfidence),_this.source,_this.confirmedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as Bill;
  return 'Bill(id: ${_this.id}, companyId: ${_this.companyId}, leadId: ${_this.leadId}, photoId: ${_this.photoId}, discom: ${_this.discom}, consumerNumber: ${_this.consumerNumber}, customerName: ${_this.customerName}, tariffCategory: ${_this.tariffCategory}, sanctionedLoadKw: ${_this.sanctionedLoadKw}, billingPeriod: ${_this.billingPeriod}, unitsMonthly: ${_this.unitsMonthly}, avgMonthlyUnits: ${_this.avgMonthlyUnits}, billAmount: ${_this.billAmount}, aiConfidence: ${_this.aiConfidence}, source: ${_this.source}, confirmedAt: ${_this.confirmedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String leadId, String? photoId, String? discom, String? consumerNumber, String? customerName, String? tariffCategory, double? sanctionedLoadKw, String? billingPeriod, Map<String, double> unitsMonthly, double? avgMonthlyUnits, double? billAmount, Map<String, FieldConfidence> aiConfidence, String source, DateTime? confirmedAt, DateTime? createdAt
});




}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? leadId = null,Object? photoId = freezed,Object? discom = freezed,Object? consumerNumber = freezed,Object? customerName = freezed,Object? tariffCategory = freezed,Object? sanctionedLoadKw = freezed,Object? billingPeriod = freezed,Object? unitsMonthly = null,Object? avgMonthlyUnits = freezed,Object? billAmount = freezed,Object? aiConfidence = null,Object? source = null,Object? confirmedAt = freezed,Object? createdAt = freezed,}) {
  return _then(Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,leadId: null == leadId ? _self.leadId : leadId // ignore: cast_nullable_to_non_nullable
as String,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,discom: freezed == discom ? _self.discom : discom // ignore: cast_nullable_to_non_nullable
as String?,consumerNumber: freezed == consumerNumber ? _self.consumerNumber : consumerNumber // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,tariffCategory: freezed == tariffCategory ? _self.tariffCategory : tariffCategory // ignore: cast_nullable_to_non_nullable
as String?,sanctionedLoadKw: freezed == sanctionedLoadKw ? _self.sanctionedLoadKw : sanctionedLoadKw // ignore: cast_nullable_to_non_nullable
as double?,billingPeriod: freezed == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as String?,unitsMonthly: null == unitsMonthly ? _self.unitsMonthly : unitsMonthly // ignore: cast_nullable_to_non_nullable
as Map<String, double>,avgMonthlyUnits: freezed == avgMonthlyUnits ? _self.avgMonthlyUnits : avgMonthlyUnits // ignore: cast_nullable_to_non_nullable
as double?,billAmount: freezed == billAmount ? _self.billAmount : billAmount // ignore: cast_nullable_to_non_nullable
as double?,aiConfidence: null == aiConfidence ? _self.aiConfidence : aiConfidence // ignore: cast_nullable_to_non_nullable
as Map<String, FieldConfidence>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String leadId,  String? photoId,  String? discom,  String? consumerNumber,  String? customerName,  String? tariffCategory,  double? sanctionedLoadKw,  String? billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> aiConfidence,  String source,  DateTime? confirmedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.companyId,_that.leadId,_that.photoId,_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.aiConfidence,_that.source,_that.confirmedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String leadId,  String? photoId,  String? discom,  String? consumerNumber,  String? customerName,  String? tariffCategory,  double? sanctionedLoadKw,  String? billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> aiConfidence,  String source,  DateTime? confirmedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.companyId,_that.leadId,_that.photoId,_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.aiConfidence,_that.source,_that.confirmedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String leadId,  String? photoId,  String? discom,  String? consumerNumber,  String? customerName,  String? tariffCategory,  double? sanctionedLoadKw,  String? billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> aiConfidence,  String source,  DateTime? confirmedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.companyId,_that.leadId,_that.photoId,_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.aiConfidence,_that.source,_that.confirmedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Bill extends Bill {
  const _Bill({required this.id, required this.companyId, required this.leadId, this.photoId, this.discom, this.consumerNumber, this.customerName, this.tariffCategory, this.sanctionedLoadKw, this.billingPeriod,  Map<String, double> unitsMonthly = const {}, this.avgMonthlyUnits, this.billAmount,  Map<String, FieldConfidence> aiConfidence = const {}, this.source = 'manual', this.confirmedAt, this.createdAt}): _unitsMonthly = unitsMonthly,_aiConfidence = aiConfidence,super._();
  

@override final  String id;
@override final  String companyId;
@override final  String leadId;
@override final  String? photoId;
@override final  String? discom;
@override final  String? consumerNumber;
@override final  String? customerName;
@override final  String? tariffCategory;
@override final  double? sanctionedLoadKw;
@override final  String? billingPeriod;
 final  Map<String, double> _unitsMonthly;
@override@JsonKey() Map<String, double> get unitsMonthly {
  if (_unitsMonthly is EqualUnmodifiableMapView) return _unitsMonthly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unitsMonthly);
}

@override final  double? avgMonthlyUnits;
@override final  double? billAmount;
 final  Map<String, FieldConfidence> _aiConfidence;
@override@JsonKey() Map<String, FieldConfidence> get aiConfidence {
  if (_aiConfidence is EqualUnmodifiableMapView) return _aiConfidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_aiConfidence);
}

@override@JsonKey() final  String source;
@override final  DateTime? confirmedAt;
@override final  DateTime? createdAt;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.leadId, leadId) || other.leadId == leadId)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.discom, discom) || other.discom == discom)&&(identical(other.consumerNumber, consumerNumber) || other.consumerNumber == consumerNumber)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.tariffCategory, tariffCategory) || other.tariffCategory == tariffCategory)&&(identical(other.sanctionedLoadKw, sanctionedLoadKw) || other.sanctionedLoadKw == sanctionedLoadKw)&&(identical(other.billingPeriod, billingPeriod) || other.billingPeriod == billingPeriod)&&const DeepCollectionEquality().equals(other.unitsMonthly, _unitsMonthly)&&(identical(other.avgMonthlyUnits, avgMonthlyUnits) || other.avgMonthlyUnits == avgMonthlyUnits)&&(identical(other.billAmount, billAmount) || other.billAmount == billAmount)&&const DeepCollectionEquality().equals(other.aiConfidence, _aiConfidence)&&(identical(other.source, source) || other.source == source)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,companyId,leadId,photoId,discom,consumerNumber,customerName,tariffCategory,sanctionedLoadKw,billingPeriod,const DeepCollectionEquality().hash(_unitsMonthly),avgMonthlyUnits,billAmount,const DeepCollectionEquality().hash(_aiConfidence),source,confirmedAt,createdAt);
}

@override
String toString() {
    return 'Bill(id: $id, companyId: $companyId, leadId: $leadId, photoId: $photoId, discom: $discom, consumerNumber: $consumerNumber, customerName: $customerName, tariffCategory: $tariffCategory, sanctionedLoadKw: $sanctionedLoadKw, billingPeriod: $billingPeriod, unitsMonthly: $unitsMonthly, avgMonthlyUnits: $avgMonthlyUnits, billAmount: $billAmount, aiConfidence: $aiConfidence, source: $source, confirmedAt: $confirmedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String leadId, String? photoId, String? discom, String? consumerNumber, String? customerName, String? tariffCategory, double? sanctionedLoadKw, String? billingPeriod, Map<String, double> unitsMonthly, double? avgMonthlyUnits, double? billAmount, Map<String, FieldConfidence> aiConfidence, String source, DateTime? confirmedAt, DateTime? createdAt
});




}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? leadId = null,Object? photoId = freezed,Object? discom = freezed,Object? consumerNumber = freezed,Object? customerName = freezed,Object? tariffCategory = freezed,Object? sanctionedLoadKw = freezed,Object? billingPeriod = freezed,Object? unitsMonthly = null,Object? avgMonthlyUnits = freezed,Object? billAmount = freezed,Object? aiConfidence = null,Object? source = null,Object? confirmedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,leadId: null == leadId ? _self.leadId : leadId // ignore: cast_nullable_to_non_nullable
as String,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,discom: freezed == discom ? _self.discom : discom // ignore: cast_nullable_to_non_nullable
as String?,consumerNumber: freezed == consumerNumber ? _self.consumerNumber : consumerNumber // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,tariffCategory: freezed == tariffCategory ? _self.tariffCategory : tariffCategory // ignore: cast_nullable_to_non_nullable
as String?,sanctionedLoadKw: freezed == sanctionedLoadKw ? _self.sanctionedLoadKw : sanctionedLoadKw // ignore: cast_nullable_to_non_nullable
as double?,billingPeriod: freezed == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as String?,unitsMonthly: null == unitsMonthly ? _self._unitsMonthly : unitsMonthly // ignore: cast_nullable_to_non_nullable
as Map<String, double>,avgMonthlyUnits: freezed == avgMonthlyUnits ? _self.avgMonthlyUnits : avgMonthlyUnits // ignore: cast_nullable_to_non_nullable
as double?,billAmount: freezed == billAmount ? _self.billAmount : billAmount // ignore: cast_nullable_to_non_nullable
as double?,aiConfidence: null == aiConfidence ? _self._aiConfidence : aiConfidence // ignore: cast_nullable_to_non_nullable
as Map<String, FieldConfidence>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$BillInput {

 String get discom; String get consumerNumber; String get customerName; String get tariffCategory; double? get sanctionedLoadKw; String get billingPeriod; Map<String, double> get unitsMonthly; double? get avgMonthlyUnits; double? get billAmount; Map<String, FieldConfidence> get confidence; String? get photoId; String get source;
/// Create a copy of BillInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillInputCopyWith<BillInput> get copyWith => _$BillInputCopyWithImpl<BillInput>(this as BillInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BillInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillInput&&(identical(other.discom, _this.discom) || other.discom == _this.discom)&&(identical(other.consumerNumber, _this.consumerNumber) || other.consumerNumber == _this.consumerNumber)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.tariffCategory, _this.tariffCategory) || other.tariffCategory == _this.tariffCategory)&&(identical(other.sanctionedLoadKw, _this.sanctionedLoadKw) || other.sanctionedLoadKw == _this.sanctionedLoadKw)&&(identical(other.billingPeriod, _this.billingPeriod) || other.billingPeriod == _this.billingPeriod)&&const DeepCollectionEquality().equals(other.unitsMonthly, _this.unitsMonthly)&&(identical(other.avgMonthlyUnits, _this.avgMonthlyUnits) || other.avgMonthlyUnits == _this.avgMonthlyUnits)&&(identical(other.billAmount, _this.billAmount) || other.billAmount == _this.billAmount)&&const DeepCollectionEquality().equals(other.confidence, _this.confidence)&&(identical(other.photoId, _this.photoId) || other.photoId == _this.photoId)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as BillInput;
  return Object.hash(runtimeType,_this.discom,_this.consumerNumber,_this.customerName,_this.tariffCategory,_this.sanctionedLoadKw,_this.billingPeriod,const DeepCollectionEquality().hash(_this.unitsMonthly),_this.avgMonthlyUnits,_this.billAmount,const DeepCollectionEquality().hash(_this.confidence),_this.photoId,_this.source);
}

@override
String toString() {
  final _this = this as BillInput;
  return 'BillInput(discom: ${_this.discom}, consumerNumber: ${_this.consumerNumber}, customerName: ${_this.customerName}, tariffCategory: ${_this.tariffCategory}, sanctionedLoadKw: ${_this.sanctionedLoadKw}, billingPeriod: ${_this.billingPeriod}, unitsMonthly: ${_this.unitsMonthly}, avgMonthlyUnits: ${_this.avgMonthlyUnits}, billAmount: ${_this.billAmount}, confidence: ${_this.confidence}, photoId: ${_this.photoId}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $BillInputCopyWith<$Res>  {
  factory $BillInputCopyWith(BillInput value, $Res Function(BillInput) _then) = _$BillInputCopyWithImpl;
@useResult
$Res call({
 String discom, String consumerNumber, String customerName, String tariffCategory, double? sanctionedLoadKw, String billingPeriod, Map<String, double> unitsMonthly, double? avgMonthlyUnits, double? billAmount, Map<String, FieldConfidence> confidence, String? photoId, String source
});




}
/// @nodoc
class _$BillInputCopyWithImpl<$Res>
    implements $BillInputCopyWith<$Res> {
  _$BillInputCopyWithImpl(this._self, this._then);

  final BillInput _self;
  final $Res Function(BillInput) _then;

/// Create a copy of BillInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? discom = null,Object? consumerNumber = null,Object? customerName = null,Object? tariffCategory = null,Object? sanctionedLoadKw = freezed,Object? billingPeriod = null,Object? unitsMonthly = null,Object? avgMonthlyUnits = freezed,Object? billAmount = freezed,Object? confidence = null,Object? photoId = freezed,Object? source = null,}) {
  return _then(BillInput(
discom: null == discom ? _self.discom : discom // ignore: cast_nullable_to_non_nullable
as String,consumerNumber: null == consumerNumber ? _self.consumerNumber : consumerNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,tariffCategory: null == tariffCategory ? _self.tariffCategory : tariffCategory // ignore: cast_nullable_to_non_nullable
as String,sanctionedLoadKw: freezed == sanctionedLoadKw ? _self.sanctionedLoadKw : sanctionedLoadKw // ignore: cast_nullable_to_non_nullable
as double?,billingPeriod: null == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as String,unitsMonthly: null == unitsMonthly ? _self.unitsMonthly : unitsMonthly // ignore: cast_nullable_to_non_nullable
as Map<String, double>,avgMonthlyUnits: freezed == avgMonthlyUnits ? _self.avgMonthlyUnits : avgMonthlyUnits // ignore: cast_nullable_to_non_nullable
as double?,billAmount: freezed == billAmount ? _self.billAmount : billAmount // ignore: cast_nullable_to_non_nullable
as double?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as Map<String, FieldConfidence>,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BillInput].
extension BillInputPatterns on BillInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillInput value)  $default,){
final _that = this;
switch (_that) {
case _BillInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillInput value)?  $default,){
final _that = this;
switch (_that) {
case _BillInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String discom,  String consumerNumber,  String customerName,  String tariffCategory,  double? sanctionedLoadKw,  String billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> confidence,  String? photoId,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillInput() when $default != null:
return $default(_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.confidence,_that.photoId,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String discom,  String consumerNumber,  String customerName,  String tariffCategory,  double? sanctionedLoadKw,  String billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> confidence,  String? photoId,  String source)  $default,) {final _that = this;
switch (_that) {
case _BillInput():
return $default(_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.confidence,_that.photoId,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String discom,  String consumerNumber,  String customerName,  String tariffCategory,  double? sanctionedLoadKw,  String billingPeriod,  Map<String, double> unitsMonthly,  double? avgMonthlyUnits,  double? billAmount,  Map<String, FieldConfidence> confidence,  String? photoId,  String source)?  $default,) {final _that = this;
switch (_that) {
case _BillInput() when $default != null:
return $default(_that.discom,_that.consumerNumber,_that.customerName,_that.tariffCategory,_that.sanctionedLoadKw,_that.billingPeriod,_that.unitsMonthly,_that.avgMonthlyUnits,_that.billAmount,_that.confidence,_that.photoId,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _BillInput implements BillInput {
  const _BillInput({this.discom = '', this.consumerNumber = '', this.customerName = '', this.tariffCategory = '', this.sanctionedLoadKw, this.billingPeriod = '',  Map<String, double> unitsMonthly = const {}, this.avgMonthlyUnits, this.billAmount,  Map<String, FieldConfidence> confidence = const {}, this.photoId, this.source = 'manual'}): _unitsMonthly = unitsMonthly,_confidence = confidence;
  

@override@JsonKey() final  String discom;
@override@JsonKey() final  String consumerNumber;
@override@JsonKey() final  String customerName;
@override@JsonKey() final  String tariffCategory;
@override final  double? sanctionedLoadKw;
@override@JsonKey() final  String billingPeriod;
 final  Map<String, double> _unitsMonthly;
@override@JsonKey() Map<String, double> get unitsMonthly {
  if (_unitsMonthly is EqualUnmodifiableMapView) return _unitsMonthly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unitsMonthly);
}

@override final  double? avgMonthlyUnits;
@override final  double? billAmount;
 final  Map<String, FieldConfidence> _confidence;
@override@JsonKey() Map<String, FieldConfidence> get confidence {
  if (_confidence is EqualUnmodifiableMapView) return _confidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_confidence);
}

@override final  String? photoId;
@override@JsonKey() final  String source;

/// Create a copy of BillInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillInputCopyWith<_BillInput> get copyWith => __$BillInputCopyWithImpl<_BillInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillInput&&(identical(other.discom, discom) || other.discom == discom)&&(identical(other.consumerNumber, consumerNumber) || other.consumerNumber == consumerNumber)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.tariffCategory, tariffCategory) || other.tariffCategory == tariffCategory)&&(identical(other.sanctionedLoadKw, sanctionedLoadKw) || other.sanctionedLoadKw == sanctionedLoadKw)&&(identical(other.billingPeriod, billingPeriod) || other.billingPeriod == billingPeriod)&&const DeepCollectionEquality().equals(other.unitsMonthly, _unitsMonthly)&&(identical(other.avgMonthlyUnits, avgMonthlyUnits) || other.avgMonthlyUnits == avgMonthlyUnits)&&(identical(other.billAmount, billAmount) || other.billAmount == billAmount)&&const DeepCollectionEquality().equals(other.confidence, _confidence)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,discom,consumerNumber,customerName,tariffCategory,sanctionedLoadKw,billingPeriod,const DeepCollectionEquality().hash(_unitsMonthly),avgMonthlyUnits,billAmount,const DeepCollectionEquality().hash(_confidence),photoId,source);
}

@override
String toString() {
    return 'BillInput(discom: $discom, consumerNumber: $consumerNumber, customerName: $customerName, tariffCategory: $tariffCategory, sanctionedLoadKw: $sanctionedLoadKw, billingPeriod: $billingPeriod, unitsMonthly: $unitsMonthly, avgMonthlyUnits: $avgMonthlyUnits, billAmount: $billAmount, confidence: $confidence, photoId: $photoId, source: $source)';
}


}

/// @nodoc
abstract mixin class _$BillInputCopyWith<$Res> implements $BillInputCopyWith<$Res> {
  factory _$BillInputCopyWith(_BillInput value, $Res Function(_BillInput) _then) = __$BillInputCopyWithImpl;
@override @useResult
$Res call({
 String discom, String consumerNumber, String customerName, String tariffCategory, double? sanctionedLoadKw, String billingPeriod, Map<String, double> unitsMonthly, double? avgMonthlyUnits, double? billAmount, Map<String, FieldConfidence> confidence, String? photoId, String source
});




}
/// @nodoc
class __$BillInputCopyWithImpl<$Res>
    implements _$BillInputCopyWith<$Res> {
  __$BillInputCopyWithImpl(this._self, this._then);

  final _BillInput _self;
  final $Res Function(_BillInput) _then;

/// Create a copy of BillInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? discom = null,Object? consumerNumber = null,Object? customerName = null,Object? tariffCategory = null,Object? sanctionedLoadKw = freezed,Object? billingPeriod = null,Object? unitsMonthly = null,Object? avgMonthlyUnits = freezed,Object? billAmount = freezed,Object? confidence = null,Object? photoId = freezed,Object? source = null,}) {
  return _then(_BillInput(
discom: null == discom ? _self.discom : discom // ignore: cast_nullable_to_non_nullable
as String,consumerNumber: null == consumerNumber ? _self.consumerNumber : consumerNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,tariffCategory: null == tariffCategory ? _self.tariffCategory : tariffCategory // ignore: cast_nullable_to_non_nullable
as String,sanctionedLoadKw: freezed == sanctionedLoadKw ? _self.sanctionedLoadKw : sanctionedLoadKw // ignore: cast_nullable_to_non_nullable
as double?,billingPeriod: null == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as String,unitsMonthly: null == unitsMonthly ? _self._unitsMonthly : unitsMonthly // ignore: cast_nullable_to_non_nullable
as Map<String, double>,avgMonthlyUnits: freezed == avgMonthlyUnits ? _self.avgMonthlyUnits : avgMonthlyUnits // ignore: cast_nullable_to_non_nullable
as double?,billAmount: freezed == billAmount ? _self.billAmount : billAmount // ignore: cast_nullable_to_non_nullable
as double?,confidence: null == confidence ? _self._confidence : confidence // ignore: cast_nullable_to_non_nullable
as Map<String, FieldConfidence>,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
