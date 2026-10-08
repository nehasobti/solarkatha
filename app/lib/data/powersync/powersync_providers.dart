import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/env.dart';
import '../../features/auth/application/app_session.dart';
import '../../features/auth/application/session_controller.dart';
import '../supabase/supabase_providers.dart';
import 'attachment_storage.dart';
import 'photo_remote_storage.dart';
import 'schema.dart';
import 'supabase_connector.dart';

part 'powersync_providers.g.dart';

final _log = Logger('Sync');

/// The opened local database and photo storage. Created in `main()`.
class LocalData {
  LocalData(this.db, this.photoStorage);

  final PowerSyncDatabase db;
  final LocalStorage photoStorage;

  static Future<LocalData> open() async {
    final db = PowerSyncDatabase(schema: appSchema, path: await databasePath());
    await db.initialize();
    final storage = await createAttachmentStorage();
    await storage.initialize();
    return LocalData(db, storage);
  }
}

@Riverpod(keepAlive: true)
LocalData localData(Ref ref) =>
    throw UnimplementedError('localDataProvider must be overridden');

@Riverpod(keepAlive: true)
PowerSyncDatabase powerSyncDb(Ref ref) => ref.watch(localDataProvider).db;

@Riverpod(keepAlive: true)
AttachmentQueue photoQueue(Ref ref) {
  final local = ref.watch(localDataProvider);
  final db = local.db;
  return AttachmentQueue(
    db: db,
    remoteStorage: SupabasePhotoStorage(ref.watch(supabaseClientProvider)),
    localStorage: local.photoStorage,
    watchAttachments: () => db
        .watch(
          'SELECT id, company_id FROM $leadPhotosTable WHERE deleted_at IS NULL',
        )
        .map(
          (rows) => [
            for (final r in rows)
              WatchedAttachmentItem(
                id: r['id'] as String,
                fileExtension: 'jpg',
                metaData: r['company_id'] as String?,
              ),
          ],
        ),
  );
}

/// Whether this build syncs at all (a PowerSync URL is configured).
bool get syncConfigured => Env.powersyncUrl.isNotEmpty;

/// Connects sync and the photo queue while someone is signed in; clears the
/// device when they sign out.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  String? _connectedUser;

  @override
  void build() {
    ref.listen(sessionControllerProvider, (_, next) {
      final session = next.value;
      if (session is Ready) {
        _connect(session.profile.id);
      } else if (session is SignedOut) {
        _disconnect();
      }
    }, fireImmediately: true);
  }

  Future<void> _connect(String userId) async {
    if (_connectedUser == userId) return;
    _connectedUser = userId;
    final db = ref.read(powerSyncDbProvider);
    if (syncConfigured) {
      await db.connect(
        connector: SupabaseConnector(ref.read(supabaseClientProvider)),
      );
    } else {
      _log.warning('POWERSYNC_URL not set: data stays on this device only.');
    }
    await ref.read(photoQueueProvider).startSync();
  }

  Future<void> _disconnect() async {
    if (_connectedUser == null) return;
    _connectedUser = null;
    await ref.read(photoQueueProvider).stopSyncing();
    await ref.read(photoQueueProvider).clearQueue();
    await ref.read(powerSyncDbProvider).disconnectAndClear();
    await ref.read(localDataProvider).photoStorage.clear();
    if (kDebugMode) _log.info('Signed out: local data cleared.');
  }
}

/// Live sync status for the offline banner and settings.
@riverpod
Stream<SyncStatus> syncStatus(Ref ref) {
  final db = ref.watch(powerSyncDbProvider);
  return db.statusStream.startWith(db.currentStatus);
}

extension<T> on Stream<T> {
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}
