import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/attachments/io.dart';

Future<LocalStorage> createAttachmentStorage() async {
  final dir = await getApplicationSupportDirectory();
  return IOLocalStorage(Directory(p.join(dir.path, 'attachments')));
}

Future<String> databasePath() async {
  final dir = await getApplicationSupportDirectory();
  return p.join(dir.path, 'solarkatha.db');
}
