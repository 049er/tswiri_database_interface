// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tswiri_database/tswiri_database.dart';

class GoogleDriveManager {
  GoogleDriveManager({
    required this.driveApi,
  });

  drive.DriveApi driveApi;

  ///Returns the backup folder ID of this app.
  Future<String?> getSunbirdFolderID() async {
    const mimeType = "application/vnd.google-apps.folder";
    String folderName = "sunbird_backup";

    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );

      final files = found.files;

      if (files == null) {
        log("Sign-in first Error");
        return null;
      }

      // The folder already exists
      if (files.isNotEmpty) {
        return files.first.id;
      }

      // Create a folder
      drive.File folder = drive.File();
      folder.name = folderName;
      folder.mimeType = mimeType;

      final folderCreation = await driveApi.files.create(folder);

      return folderCreation.id;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  ///Returns the backup folder ID of this app.
  Future<String?> getSpaceFolderID() async {
    String sunbirdFolderID = (await getSunbirdFolderID())!;

    const mimeType = "application/vnd.google-apps.folder";
    String folderName = spaceDirectory!.path.split('/').last;

    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName' and '$sunbirdFolderID' in parents and trashed = false",
        $fields: "files(id, name)",
      );

      final files = found.files;

      if (files == null) {
        log("Sign-in first Error");
        return null;
      }

      // The folder already exists
      if (files.isNotEmpty) {
        return files.first.id;
      }

      // Create a folder
      drive.File folder = drive.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      folder.parents = [sunbirdFolderID];

      final folderCreation = await driveApi.files.create(folder);

      return folderCreation.id;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<List<String>?> getSpaces() async {
    String? sunbirdFolderId = await getSunbirdFolderID();
    const mimeType = "application/vnd.google-apps.folder";
    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and '$sunbirdFolderId' in parents and trashed = false",
        $fields: "files(id, name)",
      );

      final files = found.files;

      if (files == null) {
        log("Sign-in first Error");
        return null;
      } else {
        List<String> spaces = [];
        for (var file in found.files!) {
          spaces.add(file.name!);
        }
        return spaces;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  ///Returns the latest backup file.
  Future<drive.File?> getLatestBackup() async {
    log('getting latest');
    String? sunbirdFolderId = await getSpaceFolderID();

    drive.FileList fileList = await driveApi.files.list(
        spaces: 'drive',
        q: "'$sunbirdFolderId' in parents and trashed = false",
        orderBy: "createdTime",
        $fields: "files(id, name, createdTime, size)");

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.last;
    } else {
      return null;
    }
  }

  Future<bool> uploadFile(
    File file,
    Function(String) eventCallback,
  ) async {
    String? folderId = await getSpaceFolderID();

    if (folderId == null) {
      return false;
    } else {
      log('file size: ${file.lengthSync()}', name: 'Upload');

      drive.File fileToUpload = drive.File();
      fileToUpload.parents = [folderId];
      fileToUpload.name = p.basename(file.absolute.path);

      eventCallback('Uploading 0%');
      int totalSize = file.lengthSync();
      int byteCount = 0;

      var completer = Completer<bool>();

      await driveApi.files.create(
        fileToUpload,
        uploadMedia: drive.Media(
            file.openRead().transform(
                  StreamTransformer.fromHandlers(handleData: (data, sink) {
                    byteCount += data.length;
                    double uploadProgress = (byteCount / totalSize) * 100;
                    eventCallback(
                        'Uploading: ${uploadProgress.toStringAsFixed(2)}%');
                    sink.add(data);
                  }, handleError: (error, stackTrace, sink) {
                    //  print(error.toString());
                  }, handleDone: (sink) {
                    sink.close();
                    completer.complete(true);
                  }),
                ),
            file.lengthSync()),
      );
      return completer.future;
    }
  }

  Future<File?> downloadFile(
    drive.File file,
    Function(String) eventCallback,
  ) async {
    drive.Media selectedFile = await driveApi.files.get(file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    log('file size: ${selectedFile.length ?? 0 * 0.000001} mb',
        name: 'Download');

    File downloadedFile =
        File('${(await getTemporaryDirectory()).path}/download/${file.name}');

    if (!downloadedFile.existsSync()) {
      downloadedFile.createSync(recursive: true);
    }

    eventCallback('Downloading: 0%');
    int totalSize = selectedFile.length ?? 0;
    int byteCount = 0;

    List<int> dataStore = [];

    var completer = Completer<File?>();

    log(selectedFile.length.toString());

    selectedFile.stream.listen((data) {
      log("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
      byteCount += data.length;
      double progress = (byteCount / totalSize) * 100;
      eventCallback('Downloading: ${progress.toStringAsFixed(2)}%');
    }, onDone: () {
      // log("Task Done");
      downloadedFile.writeAsBytes(dataStore);
      // log("File saved at ${downloadedFile.path}");
      completer.complete(downloadedFile);
    }, onError: (error) {
      // log("Some Error");
      completer.complete(null);
    });

    return completer.future;
  }
}

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'https://www.googleapis.com/auth/drive.file',
  ],
);

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
