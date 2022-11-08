// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:tswiri_database/embedded/embedded_size/embedded_size.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/embedded/get_size.dart';

///ImageData this is used to display an image with all its labels aswell as editing it.
///
/// - Photo             [File]
///
/// - Photo Size        [Size]
///
/// - InputImageRotaion [InputImageRotation]
///
/// - MLPhotoLabel      [MLPhotoLabel]
///
/// - MLObject          [MLObject]
///
/// - MLObjectLabel     [MLObjectLabel]
///
/// - MLTextBlock       [MLTextBlock]
///
/// - MLTextLine        [MLTextLine]
///
/// - MLTextElement     [MLTextElement]
///
///
class ImageData {
  ImageData({
    this.photo,
    required this.photoFile,
    required this.size,
    required this.rotation,
    required this.photoLabels,
    required this.mlPhotoLabels,
    required this.objectLabels,
    required this.mlObjects,
    required this.mlObjectLabels,
    required this.mlTextBlocks,
    required this.mlTextLines,
    required this.mlTextElements,
  }) {
    //1. Find all the mlDetectedLabelTexts.
    Set<int> mlDetectedLabelTextIDs = {};
    mlDetectedLabelTextIDs
        .addAll(mlObjectLabels.map((e) => e.detectedLabelTextID));
    mlDetectedLabelTextIDs
        .addAll(mlPhotoLabels.map((e) => e.detectedLabelTextID));

    mlDetectedLabelTexts = [];
    if (mlDetectedLabelTextIDs.isNotEmpty) {
      mlDetectedLabelTexts = isar!.mLDetectedLabelTexts
          .filter()
          .anyOf(
              mlDetectedLabelTextIDs, (q, int element) => q.idEqualTo(element))
          .findAllSync();
    }

    //2. Find all the mLDetectedElementTexts.
    Set<int> mLDetectedElementTextIDs =
        mlTextElements.map((e) => e.detectedElementTextID).toSet();

    mLDetectedElementTexts = [];
    if (mLDetectedElementTextIDs.isNotEmpty) {
      mLDetectedElementTexts = isar!.mLDetectedElementTexts
          .filter()
          .allOf(mLDetectedElementTextIDs,
              (q, int element) => q.idEqualTo(element))
          .findAllSync();
    }

    //3. find all the textTags.
    Set<int> tagTextIDs = {};
    tagTextIDs.addAll(objectLabels.map((e) => e.tagTextID));
    tagTextIDs.addAll(photoLabels.map((e) => e.tagTextID));

    tagTexts = [];
    if (mLDetectedElementTexts.isNotEmpty) {
      tagTexts = isar!.tagTexts
          .filter()
          .allOf(tagTextIDs, (q, int element) => q.idEqualTo(element))
          .findAllSync();
    }
  }

  ///Photo File.
  File photoFile;

  ///Photo size.
  Size size;

  Photo? photo;

  //Photo Rotation
  InputImageRotation rotation;

  ///List of PhotoLabel.
  List<PhotoLabel> photoLabels;

  ///List of ObjectLabel.
  List<ObjectLabel> objectLabels;

  ///List of detected MLPhotoLabels.
  List<MLPhotoLabel> mlPhotoLabels;

  ///List of detected MLObjects.
  List<MLObject> mlObjects;

  ///List of detected MLObjectLabels.
  List<MLObjectLabel> mlObjectLabels;

  ///List of MLTextBlock.
  List<MLTextBlock> mlTextBlocks;

  ///List of MLTextLines.
  List<MLTextLine> mlTextLines;

  ///List of MLTextElements.
  List<MLTextElement> mlTextElements;

  List<MLDetectedLabelText> mlDetectedLabelTexts = [];
  List<MLDetectedElementText> mLDetectedElementTexts = [];
  List<TagText> tagTexts = [];

  ///This creates relevant isarEntries for the specified container.
  ///
  /// - Photo Entry
  ///
  /// - ImageLabels
  ///
  /// - ObjectLabels
  ///
  /// - Recognized Text
  Future<void> savePhoto(String containerUID) async {
    //1. Photo Extention.
    String extention = photoFile.path.split('.').last;
    //2. Photo Name.
    int photoName = DateTime.now().millisecondsSinceEpoch;
    //3. Create the image file path.
    String photoFilePath = '${photoDirectory!.path}/$photoName.$extention';
    //4. Create image thumbnail path.
    String photoThumbnailPath =
        '${thumbnailDirectory!.path}/${photoName}_thumbnail.$extention';
    //5. Load Image in memory.
    img.Image referenceImage = img.decodeJpg(photoFile.readAsBytesSync())!;
    //6. Create Thumbnail.
    img.Image thumbnailImage = img.copyResize(referenceImage, width: 120);
    //7. Save the Thumbnail.
    File(photoThumbnailPath).writeAsBytesSync(img.encodePng(thumbnailImage));
    //8. Save the Image.
    photoFile.copySync(photoFilePath);

    log(photoFilePath.toString(), name: 'Photo Path');
    log(photoThumbnailPath.toString(), name: 'thumbnail Path');

    //9. Create Photo Entry
    Photo newPhoto = Photo()
      ..containerUID = containerUID
      ..extention = extention
      ..photoName = photoName
      ..thumbnailExtention = extention
      ..thumbnailName = '${photoName}_thumbnail'
      ..photoSize = EmbeddedSize.fromSize(size);

    int photoID = 0;
    isar!.writeTxnSync(() {
      photoID = isar!.photos.putSync(newPhoto);
    });

    isar!.writeTxnSync(() {
      ///Write Photo Labels to Isar.
      for (MLPhotoLabel mlPhotoLabel in mlPhotoLabels) {
        isar!.mLPhotoLabels.putSync(
          MLPhotoLabel()
            ..confidence = mlPhotoLabel.confidence
            ..detectedLabelTextID = mlPhotoLabel.detectedLabelTextID
            ..photoID = photoID
            ..userFeedback = mlPhotoLabel.userFeedback,
        );
      }

      for (PhotoLabel photoLabel in photoLabels) {
        isar!.photoLabels.putSync(PhotoLabel()
          ..photoID = photoID
          ..tagTextID = photoLabel.tagTextID);
      }

      ///Write Objects to Isar.
      for (MLObject mlObject in mlObjects) {
        int objectID = isar!.mLObjects.putSync(
          MLObject()
            ..boundingBox = mlObject.boundingBox
            ..photoID = photoID,
        );

        ///Write Object Labels to Isar.
        for (MLObjectLabel mlObjectLabel in mlObjectLabels
            .where((element) => element.objectID == mlObject.id)) {
          isar!.mLObjectLabels.putSync(
            MLObjectLabel()
              ..confidence = mlObjectLabel.confidence
              ..detectedLabelTextID = mlObjectLabel.detectedLabelTextID
              ..objectID = objectID
              ..userFeedback = mlObjectLabel.userFeedback,
          );
        }

        for (ObjectLabel objectLabel in objectLabels
            .where((element) => element.objectID == mlObject.id)) {
          isar!.objectLabels.putSync(ObjectLabel()
            ..objectID = objectID
            ..tagTextID = objectLabel.tagTextID);
        }
      }

      ///Write Text Blocks to isar.
      for (MLTextBlock mlTextBlock in mlTextBlocks) {
        int textBlockID = isar!.mLTextBlocks.putSync(
          MLTextBlock()
            ..cornerPoints = mlTextBlock.cornerPoints
            ..recognizedLanguages = mlTextBlock.recognizedLanguages,
        );

        ///Write Text Lines to isar.
        for (MLTextLine mlTextLine in mlTextLines
            .where((element) => element.blockID == mlTextBlock.id)) {
          int lineID = isar!.mLTextLines.putSync(
            MLTextLine()
              ..blockID = textBlockID
              ..blockIndex = mlTextLine.blockIndex
              ..cornerPoints = mlTextLine.cornerPoints
              ..recognizedLanguages = mlTextLine.recognizedLanguages,
          );

          ///Write Text Elements to isar.
          for (MLTextElement e in mlTextElements
              .where((element) => element.lineID == mlTextLine.id)) {
            isar!.mLTextElements.putSync(
              MLTextElement()
                ..cornerPoints = e.cornerPoints
                ..detectedElementTextID = e.detectedElementTextID
                ..lineID = lineID
                ..lineIndex = e.lineIndex
                ..photoID = photoID
                ..userFeedback = e.userFeedback,
            );
          }
        }
      }
    });
  }

  ///Build an ImageData from a photo.
  factory ImageData.fromPhoto(Photo photo) {
    File photoFile = File(photo.getPhotoPath());

    //1. Find all the objects in the photo.
    List<MLObject> mlObject =
        isar!.mLObjects.filter().photoIDEqualTo(photo.id).findAllSync();

    //2. Find all the mlObject labels.
    List<MLObjectLabel> mlObjectLabels = isar!.mLObjectLabels
        .filter()
        .allOf(mlObject, (q, MLObject element) => q.objectIDEqualTo(element.id))
        .findAllSync();

    //3. Find all the object labels.
    List<ObjectLabel> objectLabels = isar!.objectLabels
        .filter()
        .allOf(mlObject, (q, MLObject element) => q.objectIDEqualTo(element.id))
        .findAllSync();

    //4. Find all the mlTextElements.
    List<MLTextElement> mlTextElements =
        isar!.mLTextElements.filter().photoIDEqualTo(photo.id).findAllSync();

    // log(mlTextElements.length.toString(), name: 'MLTextElements');

    List<MLTextLine> mlTextLines = [];
    List<MLTextBlock> mlTextBlocks = [];

    if (mlTextElements.isNotEmpty) {
      //5. Find all the mlTextLines.
      mlTextLines = isar!.mLTextLines
          .filter()
          .anyOf(mlTextElements,
              (q, MLTextElement element) => q.idEqualTo(element.lineID))
          .findAllSync();

      // log(mlTextLines.length.toString(), name: 'MLTextLines');

      if (mlTextLines.isNotEmpty) {
        //6. Find all the mlTextBlocks.
        mlTextBlocks = isar!.mLTextBlocks
            .filter()
            .anyOf(mlTextLines,
                (q, MLTextLine element) => q.idEqualTo(element.blockID))
            .findAllSync();

        // log(mlTextBlocks.length.toString(), name: 'MLTextBlock');
      }
    }

    //7. Find all the mlPhotoLabels.
    List<MLPhotoLabel> mlPhotoLabels =
        isar!.mLPhotoLabels.filter().photoIDEqualTo(photo.id).findAllSync();

    //8. Find all the photoLabels.
    List<PhotoLabel> photoLabels =
        isar!.photoLabels.filter().photoIDEqualTo(photo.id).findAllSync();

    // log(tagTextIDs.toString());

    // log('mlPhotoLabels: ${mlPhotoLabels.length}');
    // log('mlObject: ${mlObject.length}');
    // log('objectLabels: ${objectLabels.length}');
    // log('mlObjectLabels: ${mlObjectLabels.length}');
    // log('mlTextBlocks: ${mlTextBlocks.length}');
    // log('mlTextLines: ${mlTextLines.length}');
    // log('mlTextElements: ${mlTextElements.length}');
    // log('photoLabels: ${photoLabels.length}');

    // log(photo.getPhotoSize().toString());

    return ImageData(
      photoFile: photoFile,
      size: getSize(photo.photoSize.data!),
      rotation: InputImageRotation.rotation0deg,
      photoLabels: photoLabels,
      mlPhotoLabels: mlPhotoLabels,
      mlObjects: mlObject,
      objectLabels: objectLabels,
      mlObjectLabels: mlObjectLabels,
      mlTextBlocks: mlTextBlocks,
      mlTextLines: mlTextLines,
      mlTextElements: mlTextElements,
    );
  }

  ///Add a photoLabel for an existing photo.
  void addPhotoLabel(TagText tagText) {
    PhotoLabel newPhotoLabel = PhotoLabel()
      ..photoID = photo!.id
      ..tagTextID = tagText.id;

    photoLabels.add(newPhotoLabel);
    if (!tagTextsContain(tagText)) {
      tagTexts.add(tagText);
    }

    isar!.photoLabels.putSync(newPhotoLabel);
  }

  ///Remove a photoLabel for an existing photo.
  void removePhotoLabel(PhotoLabel photoLabel) {}

  ///Add a objectLabel for an existing photo.
  void addObjectLabel(TagText tagText, int objectID) {
    ObjectLabel newObjectLabel = ObjectLabel()
      ..objectID = objectID
      ..tagTextID = tagText.id;
  }

  ///Remove a objectLabel for an existing photo.
  void removeObjectLabel(ObjectLabel objectLabel) {}

  ///Add a MLPhotoLabel for an existing photo.
  void addMLPhotoLabel(TagText tagText) {}

  ///Remove a MLPhotoLabel for an existing photo.
  void removeMLPhotoLabel(MLPhotoLabel tagText) {}

  ///Add a MLObjectLabel for an existing photo.
  void addMLObjectLabel(TagText tagText) {}

  ///Remove a MLObjectLabel for an existing photo.
  void removeMLObjectLabel(MLObjectLabel mlObjectLabel) {}

  bool tagTextsContain(TagText tagText) {
    if (tagTexts.any((element) => element.id == tagText.id) == true) {
      return true;
    } else {
      return false;
    }
  }
}
