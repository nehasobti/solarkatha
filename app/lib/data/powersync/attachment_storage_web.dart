import 'package:powersync_core/attachments/attachments.dart';

Future<LocalStorage> createAttachmentStorage() async => LocalStorage.inMemory();

Future<String> databasePath() async => 'solarkatha.db';
