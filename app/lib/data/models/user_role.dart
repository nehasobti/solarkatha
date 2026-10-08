import 'package:json_annotation/json_annotation.dart';

/// Matches the `public.user_role` Postgres enum.
enum UserRole {
  @JsonValue('owner')
  owner,
  @JsonValue('sales')
  sales,
  @JsonValue('installer')
  installer,
}
