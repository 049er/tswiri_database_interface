import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/backup/create_backup.dart';
import 'package:tswiri_database_interface/functions/backup/restore_backup.dart';
import 'package:tswiri_database/mobile_database.dart';
import 'package:tswiri_database_interface/models/settings/global_settings.dart';

///Creates a backup (.zip) of the current Space.
///
/// - On success returns the file.
/// - On fails it returns null.
///
Future<File?> createBackupFile({
  required String fileName,
  required Function(String) progressCallback,
}) async {
  FlutterIsolate? isolate;
  ReceivePort uiPort = ReceivePort();

  //Temporary Directory.
  Directory temporaryDirectory = await getTemporaryDirectory();

  isolate = await FlutterIsolate.spawn(
    createBackupIsolate,
    [
      uiPort.sendPort,
      spaceDirectory!.path,
      temporaryDirectory.path,
      isarVersion.toString(),
      fileName,
    ],
  );

  var completer = Completer<File>();

  uiPort.listen((message) {
    switch (message[0]) {
      case 'done':
        killIsolate(isolate);
        openIsarIfClosed();
        break;
      case 'path':
        completer.complete(File(message[1].toString()));
        break;
      case 'progress':
        progressCallback(message[1]);
        break;
      default:
    }
  });

  return completer.future;
}

///Restores a backup file to the current Space.
Future<bool?> restoreBackupFile({
  required File backupFile,
  required Function(String) progressCallback,
}) async {
  FlutterIsolate? isolate;
  ReceivePort uiPort = ReceivePort();

  // log(photoDirectory!.path, name: 'Photo Directory');
  // log(spaceDirectory!.path, name: 'Isar Directory');

  if (isar!.isOpen) {
    await isar!.close();
  }

  //Temporary Directory.
  Directory temporaryDirectory = await getTemporaryDirectory();

  isolate = await FlutterIsolate.spawn(
    restoreBackupIsolate,
    [
      uiPort.sendPort,
      spaceDirectory!.path,
      isarDirectory!.path,
      photoDirectory!.path,
      temporaryDirectory.path,
      isarVersion.toString(),
      backupFile.path,
    ],
  );

  var completer = Completer<bool>();

  uiPort.listen((message) {
    if (message[0] == 'done') {
      completer.complete(true);
      killIsolate(isolate);
      openIsarIfClosed();
    } else if (message[0] == 'error') {
      switch (message[1]) {
        case 'file_error':
          killIsolate(isolate);
          openIsarIfClosed();
          completer.complete(false);
          break;
        default:
      }
    } else if (message[0] == 'progress') {
      progressCallback(message[1]);
    }
  });

  return completer.future;
}

///Kills an isolate and re-opens isar.
void killIsolate(FlutterIsolate? isolate) {
  if (isolate != null) {
    isolate.kill();
  }
}

///Opens isar if it is closed.
void openIsarIfClosed() {
  if (!isar!.isOpen) {
    isar = initiateMobileIsar(inspector: true, directory: isarDirectory!.path);
  }
}

String generateBackupFileName() {
  String spaceName = spaceDirectory!.path.split('/').last;
  String formattedDate = DateFormat('_yyyy_MM_dd').format(DateTime.now());
  return spaceName + formattedDate;
}
