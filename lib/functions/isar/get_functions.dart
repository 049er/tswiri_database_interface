import 'package:flutter/material.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/embedded/get_icondata.dart';
//TODO: finish comments.

int getTagTextID(String text) {
  int? tagTextID = isar!.tagTexts
      .filter()
      .textMatches(text.toLowerCase().trim())
      .findFirstSync()
      ?.id;

  if (tagTextID == null) {
    isar!.writeTxnSync(() {
      tagTextID =
          isar!.tagTexts.putSync(TagText()..text = text.toLowerCase().trim());
    });
  }
  return tagTextID!;
}

///Get textID from MLDetectedLabelText.
int getMLDetectedLabelTextID(String text) {
  //Check if it exists.
  int? mlLabelTextID = isar!.mLDetectedLabelTexts
      .filter()
      .detectedLabelTextMatches(text.toLowerCase().trim())
      .findFirstSync()
      ?.id;

  if (mlLabelTextID == null) {
    isar!.writeTxnSync(() {
      mlLabelTextID = isar!.mLDetectedLabelTexts.putSync(MLDetectedLabelText()
        ..detectedLabelText = text.toLowerCase().trim()
        ..hidden = false);
    });
  }

  return mlLabelTextID!;
}

String getMLDetectedLabelText(int detectedLabelTextID) {
  return isar!.mLDetectedLabelTexts
      .getSync(detectedLabelTextID)!
      .detectedLabelText;
}

///Get textID from MLDetectedLabelText.
int getMLDetectedElementTextID(String text) {
  //Check if it exists.
  int? detectedElementText = isar!.mLDetectedElementTexts
      .filter()
      .detectedTextMatches(text.toLowerCase().trim())
      .findFirstSync()
      ?.id;

  if (detectedElementText == null) {
    isar!.writeTxnSync(() {
      detectedElementText =
          isar!.mLDetectedElementTexts.putSync(MLDetectedElementText()
            ..detectedText = text.toLowerCase().trim()
            ..tagTextID = null);
    });
  }

  return detectedElementText!;
}

String getMLDetectedElementText(int detectedLabelTextID) {
  return isar!.mLDetectedElementTexts
      .getSync(detectedLabelTextID)!
      .detectedText;
}

IconData getContainerTypeIcon(int containerTypeID) {
  return getIconData(
      isar!.containerTypes.getSync(containerTypeID)!.iconData.data!);
}

bool canDeleteMarker(Marker marker) {
  CatalogedContainer? catalogedContainer = isar!.catalogedContainers
      .filter()
      .barcodeUIDMatches(marker.barcodeUID)
      .findFirstSync();

  if (catalogedContainer != null) {
    ContainerType containerType =
        isar!.containerTypes.getSync(catalogedContainer.containerTypeID)!;

    if (!containerType.moveable) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}
