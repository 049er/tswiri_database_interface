import 'package:flutter/material.dart';
import 'package:tswiri_database/embedded/embedded_color/embedded_color.dart';
import 'package:tswiri_database/embedded/embedded_icon_data/embedded_icon_data.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/embedded/get_color.dart';
import 'package:tswiri_database_interface/functions/embedded/get_icon_data.dart';

///Creates a new CatalogedContainer.
///
/// (required)
/// - containerUID    [String]
/// - barcodeUID      [String]
/// - containerTypeID [int]
///
/// (optional)
/// - name        [String]
/// - description [String]
CatalogedContainer createNewCatalogedContainer({
  required String containerUID,
  required String barcodeUID,
  required int containerTypeID,
  String? name,
  String? description,
}) {
  //New Container Entry.
  CatalogedContainer newCatalogedContainer = CatalogedContainer()
    ..barcodeUID = barcodeUID
    ..containerTypeID = containerTypeID
    ..containerUID = containerUID
    ..description = description
    ..name = name;

  isar!.writeTxnSync(
    () => isar!.catalogedContainers.putSync(newCatalogedContainer),
  );

  return isar!.catalogedContainers
      .filter()
      .containerUIDMatches(newCatalogedContainer.containerUID)
      .findFirstSync()!;
}

///Creates a containerRelationship from parentContainerUID and containerUID.
createContainerRelationship({
  required String parentContainerUID,
  required String containerUID,
}) {
  ContainerRelationship relationship = ContainerRelationship()
    ..parentUID = parentContainerUID
    ..containerUID = containerUID;

  isar!.writeTxnSync(() => isar!.containerRelationships.putSync(relationship));
}
