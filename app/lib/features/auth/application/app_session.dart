import '../../../data/models/company.dart';
import '../../../data/models/profile.dart';

/// Who is using the app right now, as far as routing is concerned.
sealed class AppSession {
  const AppSession();
}

/// No Supabase session.
final class SignedOut extends AppSession {
  const SignedOut();
}

/// Logged in, but not a member of any company and no invite was found.
final class NeedsCompany extends AppSession {
  const NeedsCompany({required this.userId, this.phone, this.email});

  final String userId;
  final String? phone;
  final String? email;
}

/// Logged in, but an owner has deactivated this member.
final class Deactivated extends AppSession {
  const Deactivated();
}

/// Logged in with an active profile.
final class Ready extends AppSession {
  const Ready({required this.profile, required this.company});

  final Profile profile;
  final Company company;
}
