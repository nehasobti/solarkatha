import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company.dart';
import '../models/profile.dart';
import '../supabase/supabase_providers.dart';

part 'profile_repository.g.dart';

/// Profiles and companies. Phase 2 moves reads to the PowerSync local
/// database; until then these go straight to Supabase.
class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  Future<Profile?> fetchProfile(String userId) async {
    final row = await _db
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<Company> fetchCompany(String companyId) async {
    final row = await _db
        .from('companies')
        .select()
        .eq('id', companyId)
        .single();
    return Company.fromJson(row);
  }

  /// Claims a pending team invite for the signed-in user's phone or email.
  /// Returns true when a profile now exists.
  Future<bool> claimInvite() async {
    final result = await _db.rpc<dynamic>('claim_invite');
    return result != null;
  }

  Future<void> createCompany({
    required String companyName,
    required String stateCode,
    required String ownerName,
    required String language,
  }) async {
    await _db.rpc<dynamic>(
      'create_company',
      params: {
        'p_company_name': companyName,
        'p_state_code': stateCode,
        'p_owner_name': ownerName,
        'p_language': language,
      },
    );
  }

  Future<void> updateProfile(
    String userId, {
    String? name,
    String? language,
  }) async {
    final changes = <String, dynamic>{'name': ?name, 'language': ?language};
    if (changes.isEmpty) return;
    await _db.from('profiles').update(changes).eq('id', userId);
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(supabaseClientProvider));
