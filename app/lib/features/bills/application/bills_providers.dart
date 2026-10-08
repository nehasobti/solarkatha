import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/bills_repository.dart';
import '../domain/bill.dart';

part 'bills_providers.g.dart';

@riverpod
Stream<List<Bill>> leadBills(Ref ref, String leadId) =>
    ref.watch(billsRepositoryProvider).watchBills(leadId);

@riverpod
Stream<List<ScanJob>> leadScans(Ref ref, String leadId) =>
    ref.watch(billsRepositoryProvider).watchScans(leadId);
