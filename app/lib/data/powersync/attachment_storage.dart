// Where photo files are kept on the device: the app's support directory on
// Android, memory on web (the owner dashboard is online).
export 'attachment_storage_web.dart'
    if (dart.library.io) 'attachment_storage_io.dart';
