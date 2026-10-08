import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';
part 'company.g.dart';

/// An installer business (`public.companies`).
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    required String stateCode,
    String? logoUrl,
    String? gstin,
    String? address,
    String? phone,
    String? brandColor,
    String? mnreVendorId,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}
