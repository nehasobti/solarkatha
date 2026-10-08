import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:solarkatha/features/leads/data/leads_repository.dart';
import 'package:solarkatha/features/leads/domain/lead.dart';

/// In-memory stand-in for the PowerSync-backed repository.
class FakeLeadsRepository extends Mock implements LeadsRepository {
  FakeLeadsRepository({List<Lead> leads = const [], this.team = const []})
    : _leads = [...leads];

  final List<Lead> _leads;
  final List<TeamMember> team;
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  List<Lead> get leads => List.unmodifiable(_leads);

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Lead>> watchLeads([LeadFilter filter = const LeadFilter()]) =>
      _live(
        () => _leads.where((l) {
          final q = filter.query.toLowerCase();
          return (q.isEmpty ||
                  l.name.toLowerCase().contains(q) ||
                  l.phone.contains(q)) &&
              (filter.status == null || l.status == filter.status) &&
              (filter.assignedTo == null || l.assignedTo == filter.assignedTo);
        }).toList(),
      );

  @override
  Stream<Lead?> watchLead(String id) =>
      _live(() => _leads.where((l) => l.id == id).firstOrNull);

  @override
  Stream<Map<LeadStatus, int>> watchStatusCounts() => _live(
    () => {
      for (final s in LeadStatus.values)
        s: _leads.where((l) => l.status == s).length,
    },
  );

  @override
  Stream<List<Lead>> watchFollowUps(DateTime until) => _live(
    () => _leads
        .where(
          (l) =>
              l.status.isOpen &&
              l.nextFollowUpAt != null &&
              !l.nextFollowUpAt!.isAfter(until),
        )
        .toList(),
  );

  @override
  Stream<int> watchCreatedSince(DateTime since) => _live(
    () => _leads
        .where((l) => l.createdAt != null && !l.createdAt!.isBefore(since))
        .length,
  );

  /// Every fake lead counts as "not yet synced".
  @override
  Stream<Set<String>> watchPendingIds() =>
      _live(() => _leads.map((l) => l.id).toSet());

  @override
  Stream<List<TeamMember>> watchTeam() => Stream.value(team);

  @override
  Stream<List<LeadPhoto>> watchPhotos(String leadId) => Stream.value(const []);

  @override
  Future<String> createLead({
    required LeadInput input,
    required String companyId,
    required String userId,
  }) async {
    final id = 'lead-${++_seq}';
    final now = DateTime.now();
    _leads.insert(
      0,
      Lead(
        id: id,
        companyId: companyId,
        assignedTo: input.assignedTo ?? userId,
        createdBy: userId,
        name: input.name.trim(),
        phone: input.phone,
        district: input.district.isEmpty ? null : input.district,
        pincode: input.pincode.isEmpty ? null : input.pincode,
        stateCode: input.stateCode,
        source: input.source,
        consentAt: input.consent ? now : null,
        nextFollowUpAt: input.nextFollowUpAt,
        createdAt: now,
        updatedAt: now,
      ),
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> setStatus(
    String id,
    LeadStatus status, {
    String? lostReason,
  }) async {
    final i = _leads.indexWhere((l) => l.id == id);
    _leads[i] = _leads[i].copyWith(status: status, lostReason: lostReason);
    _changes.add(null);
  }

  @override
  Future<void> deleteLead(String id) async {
    _leads.removeWhere((l) => l.id == id);
    _changes.add(null);
  }

  @override
  Future<String> addPhoto({
    required Lead lead,
    required PhotoKind kind,
    required Uint8List jpeg,
    required String userId,
  }) async => 'photo-1';
}
