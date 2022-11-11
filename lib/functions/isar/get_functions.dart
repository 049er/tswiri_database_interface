import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

int getTagTextID(String text) {
  //Check if it exists.
  int? tagTextID = getTagTextSync(text: text)?.id;
  //Put if not.
  tagTextID ??= putTagText(
    tagText: TagText()..text = text.toLowerCase().trim(),
  );
  return tagTextID!;
}

///Get textID from MLDetectedLabelText.
int getMLDetectedLabelTextID(String text) {
  //Check if it exists.
  int? mlLabelTextID = getMlDetectedLabelText(text: text)?.id;
  //Put if not.
  mlLabelTextID ??= putMlDetectedLabelText(
    mlDetectedLabelText: MLDetectedLabelText()
      ..detectedLabelText = text.toLowerCase().trim(),
  );

  return mlLabelTextID!;
}

///Get textID from MLDetectedLabelText.
int getMLDetectedElementTextID(String text) {
  //Check if it exists.
  int? detectedElementText =
      getMlDetectedElementTextSync(text: text.toLowerCase().trim())?.id;
  //Put if not.
  detectedElementText ??= putMLDetectedElementText(
      mlDetectedElementText: MLDetectedElementText()
        ..detectedText = text.toLowerCase().trim());

  return detectedElementText!;
}

// String getMLDetectedElementText(int detectedLabelTextID) {
//   return isar!.mLDetectedElementTexts
//       .getSync(detectedLabelTextID)!
//       .detectedText;
// }

// IconData getContainerTypeIcon(int containerTypeID) {
//   return getIconData(
//       isar!.containerTypes.getSync(containerTypeID)!.iconData.data!);
// }

// bool canDeleteMarker(Marker marker) {
//   CatalogedContainer? catalogedContainer = isar!.catalogedContainers
//       .filter()
//       .barcodeUIDMatches(marker.barcodeUID)
//       .findFirstSync();

//   if (catalogedContainer != null) {
//     ContainerType containerType =
//         isar!.containerTypes.getSync(catalogedContainer.containerTypeID)!;

//     if (!containerType.moveable) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//   return false;
// }
