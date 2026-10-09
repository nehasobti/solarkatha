import '../../data/models/user_role.dart';

/// Route paths. Kept separate from the router so redirect rules can be tested
/// without Flutter.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const deactivated = '/deactivated';

  static const home = '/home';
  static const leads = '/leads';
  static const newLead = '/leads/new';
  static String lead(String id) => '/leads/$id';
  static String editLead(String id) => '/leads/$id/edit';
  static String newBill(String leadId, {String? scanId}) =>
      '/leads/$leadId/bill/new${scanId == null ? '' : '?scan=$scanId'}';
  static String editBill(String leadId, String billId) =>
      '/leads/$leadId/bill/$billId';
  static String sizing(String leadId) => '/leads/$leadId/sizing';
  static String survey(String leadId) => '/leads/$leadId/survey';
  static String newProposal(String leadId) => '/leads/$leadId/proposals/new';
  static String proposal(String leadId, String id) =>
      '/leads/$leadId/proposals/$id';
  static const projects = '/projects';
  static String project(String id) => '/projects/$id';
  static const notifications = '/notifications';
  static const settings = '/settings';

  static const dashboard = '/dashboard';
  static const subsidy = '/subsidy';
  static const team = '/team';
  static const products = '/products';
  static const config = '/config';
  static const branding = '/branding';

  /// Public customer tracking page: `/t/<share_token>`.
  static const trackingPrefix = '/t/';
  static String tracking(String token) => '$trackingPrefix$token';

  static const _authFlow = {splash, login, onboarding, deactivated};

  static const _allowedByRole = <UserRole, Set<String>>{
    UserRole.owner: {
      dashboard,
      leads,
      projects,
      subsidy,
      team,
      products,
      config,
      branding,
      settings,
      notifications,
    },
    UserRole.sales: {home, leads, settings, notifications},
    UserRole.installer: {projects, settings, notifications},
  };

  static String homeFor(UserRole role) => switch (role) {
    UserRole.owner => dashboard,
    UserRole.sales => home,
    UserRole.installer => projects,
  };

  static bool isAuthFlow(String path) => _authFlow.contains(path);

  static bool isPublic(String path) => path.startsWith(trackingPrefix);

  /// Whether [role] may open [path] (top-level section match).
  static bool isAllowed(UserRole role, String path) {
    final section =
        '/${path.split('/').where((s) => s.isNotEmpty).firstOrNull ?? ''}';
    return _allowedByRole[role]!.contains(section);
  }
}
