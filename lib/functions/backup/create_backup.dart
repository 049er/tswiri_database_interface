import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';

@pragma('vm:entry-point')
Future<void> createBackupIsolate(List init) async {
  //1. InitalMessage.
  SendPort sendPort = init[0]; //[0] SendPort.
  String spacePath = init[1]; //[1] Isar Directory.
  String outputDirectoryPath = init[2]; //[2] Backup folder.
  String isarVersion = init[3]; //[3] isarVersion.
  String fileName = init[4]; //[5] fileName.

  sendPort.send([
    'progress',
    'Starting',
  ]);

  File backupFile = await createBackupZipFile(
    spacePath: spacePath,
    temporaryDirectoryPath: outputDirectoryPath,
    outputFileName: fileName,
    isarVersion: isarVersion,
    eventCallback: (event) {
      sendPort.send(event);
    },
  );

  sendPort.send(['path', backupFile.path]);
  log(backupFile.path);

  sendPort.send(['done']);
}

//
///Create a zip file from:
/// - Isar Directory.
/// - Photos (Excludes photoThumbnails as they can be re-generated on import).
///
@pragma('vm:entry-point')
Future<File> createBackupZipFile({
  required String spacePath,
  required String temporaryDirectoryPath,
  required String outputFileName,
  required String isarVersion,
  required Function(List<String> event) eventCallback,
}) async {
  //Isar core direcotry.
  Directory isarCoreDirectory = Directory('$spacePath/isar');
  //Photos direcotry.
  Directory photoDirectory = Directory('$spacePath/photos');

  // Zip encoder.
  ZipFileEncoder encoder = ZipFileEncoder();

  eventCallback([
    'progress',
    'Creating Zip',
  ]);

  //Create the zip file.
  encoder.create('$temporaryDirectoryPath/${outputFileName}_V$isarVersion.zip');

  eventCallback([
    'progress',
    'Encoding database',
  ]);

  //Add isar core direcotry.
  await encoder.addDirectory(isarCoreDirectory);

  eventCallback([
    'progress',
    'Encoding photos',
  ]);

  //Add photos direcotry.
  await encoder.addDirectory(photoDirectory, followLinks: false);

  //Close encoder.
  encoder.close();

  return File('$temporaryDirectoryPath/${outputFileName}_V$isarVersion.zip');
}
