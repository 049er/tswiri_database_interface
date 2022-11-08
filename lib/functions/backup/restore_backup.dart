// ignore_for_file: depend_on_referenced_packages, unused_local_variable
import 'dart:developer';

import 'package:archive/archive_io.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;

///Restores a backup zip file.
@pragma('vm:entry-point')
Future<void> restoreBackupIsolate(List init) async {
  //1. InitalMessage.
  SendPort sendPort = init[0]; //[0] SendPort.
  String spacePath = init[1]; //[1] Isar Directory.
  String isarDirectoryPath = init[2];
  String photoDirectoryPath = init[3];
  String tempDirectoryPath = init[4]; //[2] Backup folder.
  String isarVersion = init[5]; //[3] isarVersion.
  String selectedFilePath = init[6]; //[5] selectedFilePath.

  // await restoreBackupZipFile(
  //   spacePath: spacePath,
  //   temporaryDirectoryPath: temporaryDirectoryPath,
  //   selectedFilePath: selectedFilePath,
  //   isarVersion: isarVersion,
  // eventCallback: (event) {
  //   sendPort.send(event);
  // },
  // );

  await importBackup(
    spaceDirectory: Directory(spacePath),
    tempDirectory: Directory(tempDirectoryPath),
    photoDirectory: Directory(photoDirectoryPath),
    isarDirectory: Directory(isarDirectoryPath),
    selectedFilePath: selectedFilePath,
    isarVersion: isarVersion,
    eventCallback: (event) {
      sendPort.send(event);
    },
  );
}

@pragma('vm:entry-point')
Future<void> importBackup({
  required Directory spaceDirectory,
  required Directory tempDirectory,
  required Directory photoDirectory,
  required Directory isarDirectory,
  required String selectedFilePath,
  required String isarVersion,
  required Function(List<String> event) eventCallback,
}) async {
  //Check if the selected file is zip.
  if (selectedFilePath.split('.').last != 'zip') {
    eventCallback([
      'error',
      'file_error',
    ]);
    return;
  }

  //File to restore.
  File zipFile = File(selectedFilePath);

  //Extracted Directory
  Directory destinationDir = getUnzippedDirectory(tempDirectory, zipFile);

  eventCallback([
    'progress',
    'Unzipping',
  ]);

  //Extract Zip file
  final inputStream = InputFileStream(zipFile.path);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  extractArchiveToDisk(archive, destinationDir.path);

  eventCallback([
    'progress',
    'Done',
  ]);

  //Check isar version.
  Directory extIsarDir = Directory('${destinationDir.path}/isar');

  //Check if isar files are present in extracted zip.
  if (extIsarDir.listSync().length != 2) {
    eventCallback([
      'error',
      'file_error',
    ]);
    return;
  }

  eventCallback([
    'progress',
    'Restoring Database',
  ]);

  //Detele all files in the current isarDirectory
  final list = isarDirectory.listSync();
  for (var element in list) {
    element.deleteSync();
  }

  File mdbxDAT = File('${extIsarDir.path}/mdbx.dat');
  File mdbxLCK = File('${extIsarDir.path}/mdbx.lck');

  //Isar 2.5.0
  if (mdbxDAT.existsSync() && mdbxLCK.existsSync()) {
    mdbxDAT.copySync('${isarDirectory.path}/default.isar');
    mdbxLCK.copySync('${isarDirectory.path}/default.isar.lock');
  }

  File defaultIsar = File('${extIsarDir.path}/default.isar');
  File defaultIsarLck = File('${extIsarDir.path}/default.isar.lock');
  //Isar 3.0.0
  if (defaultIsar.existsSync() && defaultIsarLck.existsSync()) {
    defaultIsar.copySync('${isarDirectory.path}/default.isar');
    defaultIsarLck.copySync('${isarDirectory.path}/default.isar.lock');
  }

  //Check if extracted photos folder exists.
  Directory extPhotosDir = Directory('${destinationDir.path}/photos');
  if (!extPhotosDir.existsSync()) {
    eventCallback([
      'done',
    ]);
    return;
  }

  Directory thumbnailDirectory = Directory('${spaceDirectory.path}/thumbnails');
  if (thumbnailDirectory.existsSync()) {
    thumbnailDirectory.deleteSync(recursive: true);
  }

  photoDirectory.deleteSync(recursive: true);
  photoDirectory = await photoDirectory.create(recursive: true);
  thumbnailDirectory = await thumbnailDirectory.create(recursive: true);

  //List of all the photos.
  List<FileSystemEntity> photoFiles =
      extPhotosDir.listSync(recursive: true, followLinks: false);

  int numberOfFiles = photoFiles.length + 2;
  int x = 2;

  eventCallback([
    'progress',
    'Restoring Photos',
  ]);

  //Restore Photos and thumbnails.
  for (var photo in photoFiles) {
    File photoFile = File(photo.path);

    String photoName = extractPhotoName(photoFile);

    photoFile
        .copySync('${photoDirectory.path}/${photoFile.path.split('/').last}');

    String photoThumbnailPath =
        constructPhotoThumnailPath(thumbnailDirectory, photoName);

    img.Image referenceImage = img.decodeImage(photoFile.readAsBytesSync())!;

    img.Image thumbnailImage = img.copyResize(referenceImage, width: 240);

    File(photoThumbnailPath).writeAsBytesSync(img.encodeJpg(thumbnailImage));

    x++;

    eventCallback([
      'progress',
      'Restoring: ${((x / numberOfFiles) * 100).toStringAsFixed(2)}%',
    ]);
  }
  eventCallback([
    'progress',
    'Deleting old files.',
  ]);

  destinationDir.deleteSync(recursive: true);

  eventCallback([
    'done',
  ]);
}

///Get the unzipped directory.
Directory getUnzippedDirectory(
    Directory temporaryDirectory, File fileToRestore) {
  return Directory(
      '${temporaryDirectory.path}/${fileToRestore.path.split('/').last.split('.').first}');
}

///Checks if file is a zip file.
bool isFileZip(File restoreFile) =>
    restoreFile.path.split('/').last.split('.').last == 'zip';

///Extract photo name.
String extractPhotoName(File photoFile) =>
    photoFile.path.split('/').last.split('.').first;

///Construct photo tumbnai path.
String constructPhotoThumnailPath(
        Directory thumbnailDirectory, String photoName) =>
    '${thumbnailDirectory.path}/${photoName}_thumbnail.jpg';
