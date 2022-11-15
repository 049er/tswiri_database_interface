import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tswiri_database/tswiri_database.dart';

///Sets the appIsarDirectory.
///This is the directory where the isar database file's can be found.
Future<Directory> initiateSpaceDirectory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Get the last storage path used.
  String? storagePath = prefs.getString(isarDirectoryPref);

  //If it is a fresh install set the storage path to /main_space.
  if (storagePath == null) {
    storagePath = '${(await getApplicationSupportDirectory()).path}/main_space';
    prefs.setString(isarDirectoryPref, storagePath);
  }

  //Check if the storage path exisits, if not create it.
  if (!await Directory(storagePath).exists()) {
    spaceDirectory = await Directory(storagePath).create();
  } else {
    spaceDirectory = Directory(storagePath);
  }

  log(spaceDirectory!.path.toString());

  return spaceDirectory!;
}

///Sets the appPhotoDirectory.
///This is the directory where photo's from the isarDatabase is stored.
Future<Directory> initiatePhotoStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Get the latest storage path used.
  String photoStoragePath = '${prefs.getString(isarDirectoryPref)!}/photos';

  //Create photo directory if it doesnt exist.
  if (!await Directory(photoStoragePath).exists()) {
    photoDirectory = await Directory(photoStoragePath).create();
  } else {
    photoDirectory = Directory(photoStoragePath);
  }

  return photoDirectory!;
}

///Sets the isarDirectory.
///This is the directory where photo's from the isarDatabase is stored.
Future<Directory> initiateIsarStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Get the latest storage path used.
  String isarStoragePath = '${prefs.getString(isarDirectoryPref)!}/isar';

  //Create photo directory if it doesnt exist.
  if (!await Directory(isarStoragePath).exists()) {
    isarDirectory = await Directory(isarStoragePath).create();
  } else {
    isarDirectory = Directory(isarStoragePath);
  }

  return isarDirectory!;
}

///Sets the appPhotoDirectory.
///This is the directory where photo's from the isarDatabase is stored.
Future<Directory> initiateThumnailStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String thumbnailStoragePath =
      '${prefs.getString(isarDirectoryPref)!}/thumbnails';

  //Create photo directory if it doesnt exist.
  if (!await Directory(thumbnailStoragePath).exists()) {
    thumbnailDirectory = await Directory(thumbnailStoragePath).create();
  } else {
    thumbnailDirectory = Directory(thumbnailStoragePath);
  }
  return thumbnailDirectory!;
}

///Swap the isar database to the specified directory.
Future<void> swapSpace(Directory directory) async {
  //Set prefs.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(isarDirectoryPref, directory.path);

  //Close isar connection.
  await closeIsar();

  //Update the isarDirectory.
  spaceDirectory = directory;
  isarDirectory = Directory('${directory.path}/isar');
  photoDirectory = Directory('${directory.path}/photos');
  thumbnailDirectory = Directory('${directory.path}/thumbnails');

  //Wait a couple millis.
  await Future.delayed(const Duration(milliseconds: 250));

  //Initiate the isar connection again
  initiateMobileIsar(directory: directory.path, inspector: true);
}

///Create a new swap space.
Future<bool> createNewSpace(String spaceName) async {
  String storagePath =
      '${(await getApplicationSupportDirectory()).path}/${spaceName}_space';

  if (!Directory(storagePath).existsSync()) {
    Directory(storagePath).createSync();

    //Return true on success.
    return true;
  } else {
    return false;
  }
}

///Get the spaces on this device.
Future<List<String>> getSpacesOnDevice() async {
  List<String> existingSpaces = [];
  Directory directory = (await getApplicationSupportDirectory());
  for (var element in directory.listSync()) {
    if (element is Directory) {
      existingSpaces.add(element.path.split('/').last);
    }
  }
  return existingSpaces;
}

///Get the spaces on this device.
Future<List<Directory>> getSpacesDirectories() async {
  List<Directory> existingSpaces = [];
  Directory directory = (await getApplicationSupportDirectory());
  for (var element in directory.listSync()) {
    if (element is Directory &&
        element.path.split('/').last.split('_').last == 'space') {
      existingSpaces.add(element);
    }
  }
  return existingSpaces;
}
