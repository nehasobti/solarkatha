import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// A team member of an installer company (`public.profiles`).
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String companyId,
    @Default('') String name,
    String? phone,
    String? email,
    required UserRole role,
    @Default('en') String language,
    @Default(true) bool active,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
