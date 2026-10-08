import 'dart:typed_data';

import 'package:powersync_core/attachments/attachments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const sitePhotosBucket = 'site-photos';

/// Storage path for a photo. [Attachment.metaData] carries the company id.
String photoStoragePath(Attachment attachment) =>
    'company/${attachment.metaData}/lead-photos/${attachment.filename}';

/// Uploads/downloads photo files to the private Supabase Storage bucket.
class SupabasePhotoStorage implements RemoteStorage {
  SupabasePhotoStorage(this._client);

  final SupabaseClient _client;

  StorageFileApi get _bucket => _client.storage.from(sitePhotosBucket);

  @override
  Future<void> uploadFile(
    Stream<Uint8List> fileData,
    Attachment attachment,
  ) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in fileData) {
      builder.add(chunk);
    }
    await _bucket.uploadBinary(
      photoStoragePath(attachment),
      builder.takeBytes(),
      fileOptions: FileOptions(
        contentType: attachment.mediaType ?? 'image/jpeg',
        upsert: true,
      ),
    );
  }

  @override
  Future<Stream<List<int>>> downloadFile(Attachment attachment) async {
    final bytes = await _bucket.download(photoStoragePath(attachment));
    return Stream.value(bytes);
  }

  @override
  Future<void> deleteFile(Attachment attachment) async {
    await _bucket.remove([photoStoragePath(attachment)]);
  }
}
