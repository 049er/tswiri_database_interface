import 'dart:io';

import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

///Deletes Multiple Containers and all referneces
void deleteMultipleContainers(List<CatalogedContainer> containerEntries) {
  for (var catalogedContainer in containerEntries) {
    List<Photo> photos =
        deleteContainer(catalogedContainer: catalogedContainer);

    for (Photo photo in photos) {
      File(photo.getPhotoPath()).deleteSync();
      File(photo.getPhotoThumbnailPath()).deleteSync();
    }
  }
}
