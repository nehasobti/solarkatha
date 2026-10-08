import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/app_session.dart';
import '../../auth/application/session_controller.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';

part 'leads_providers.g.dart';

@riverpod
Stream<List<Lead>> leadList(Ref ref, LeadFilter filter) =>
    ref.watch(leadsRepositoryProvider).watchLeads(filter);

@riverpod
Stream<Lead?> lead(Ref ref, String id) =>
    ref.watch(leadsRepositoryProvider).watchLead(id);

@riverpod
Stream<Map<LeadStatus, int>> leadStatusCounts(Ref ref) =>
    ref.watch(leadsRepositoryProvider).watchStatusCounts();

@riverpod
Stream<List<Lead>> todaysFollowUps(Ref ref) {
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(leadsRepositoryProvider).watchFollowUps(endOfDay);
}

@riverpod
Stream<int> leadsThisMonth(Ref ref) {
  final now = DateTime.now();
  return ref
      .watch(leadsRepositoryProvider)
      .watchCreatedSince(DateTime(now.year, now.month));
}

@riverpod
Stream<Set<String>> pendingSyncIds(Ref ref) =>
    ref.watch(leadsRepositoryProvider).watchPendingIds();

@riverpod
Stream<List<TeamMember>> team(Ref ref) =>
    ref.watch(leadsRepositoryProvider).watchTeam();

@riverpod
Stream<List<LeadPhoto>> leadPhotos(Ref ref, String leadId) =>
    ref.watch(leadsRepositoryProvider).watchPhotos(leadId);

/// The signed-in member (null while signed out).
@riverpod
Ready? currentMember(Ref ref) {
  final s = ref.watch(sessionControllerProvider).value;
  return s is Ready ? s : null;
}
