// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
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
        .addAll(mlObjectLabels.map((e) => e.detectedLabelTextUID));
    mlDetectedLabelTextIDs
        .addAll(mlPhotoLabels.map((e) => e.detectedLabelTextUID));

    mlDetectedLabelTexts = [];
    if (mlDetectedLabelTextIDs.isNotEmpty) {
      mlDetectedLabelTexts = getMlDetectedLabelTextsOnMlDetectedLabelTextIDs(
        mlDetectedLabelTextIDs: mlDetectedLabelTextIDs,
      );
      // isar!.mLDetectedLabelTexts
      //     .filter()
      //     .anyOf(
      //         mlDetectedLabelTextIDs, (q, int element) => q.idEqualTo(element))
      //     .findAllSync();
    }

    //2. Find all the mLDetectedElementTexts.
    Set<int> mLDetectedElementTextIDs =
        mlTextElements.map((e) => e.mlDetectedElementTextUID).toSet();

    mLDetectedElementTexts = [];
    if (mLDetectedElementTextIDs.isNotEmpty) {
      mLDetectedElementTexts = getAllMlDetectedLElementTexts(
          mLDetectedElementTextIDs: mLDetectedElementTextIDs);
      // isar!.mLDetectedElementTexts
      //     .filter()
      //     .allOf(mLDetectedElementTextIDs,
      //         (q, int element) => q.idEqualTo(element))
      //     .findAllSync();
    }

    //3. find all the textTags.
    Set<int> tagTextIDs = {};
    tagTextIDs.addAll(objectLabels.map((e) => e.tagTextUID));
    tagTextIDs.addAll(photoLabels.map((e) => e.tagTextUID));

    tagTexts = [];
    if (mLDetectedElementTexts.isNotEmpty) {
      tagTexts = getAllTagTexts(tagTextIDs: tagTextIDs);
      // isar!.tagTexts
      //     .filter()
      //     .allOf(tagTextIDs, (q, int element) => q.idEqualTo(element))
      //     .findAllSync();
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
      ..photoExtention = extention
      ..photoName = photoName
      ..thumbnailExtention = extention
      ..thumbnailName = '${photoName}_thumbnail'
      ..photoSize = photoSizeFromSize(size);

    createPhoto(
      photo: newPhoto,
      mlPhotoLabels: mlPhotoLabels,
      photoLabels: photoLabels,
      mlObjects: mlObjects,
      mlObjectLabels: mlObjectLabels,
      objectLabels: objectLabels,
      mlTextBlocks: mlTextBlocks,
      mlTextLines: mlTextLines,
      mlTextElements: mlTextElements,
    );
  }

  ///Build an ImageData from a photo.
  factory ImageData.fromPhoto(Photo photo) {
    File photoFile = File(photo.getPhotoPath());

    //1. Find all the objects in the photo.
    List<MLObject> mlObjects = getMlObjects(photoID: photo.id);

    //2. Find all the mlObject labels.
    List<MLObjectLabel> mlObjectLabels =
        getRelatedMLObjectLabels(mlObjects: mlObjects);

    //3. Find all the object labels.
    List<ObjectLabel> objectLabels =
        getRelatedObjectLabels(mlObjects: mlObjects);

    //4. Find all the mlTextElements.
    List<MLTextElement> mlTextElements = getMLTextElements(photoID: photo.id);

    // log(mlTextElements.length.toString(), name: 'MLTextElements');

    List<MLTextLine> mlTextLines = [];
    List<MLTextBlock> mlTextBlocks = [];

    if (mlTextElements.isNotEmpty) {
      //5. Find all the mlTextLines.
      mlTextLines = getRelatedMLTextLines(mlTextElements: mlTextElements);
      // isar!.mLTextLines
      //     .filter()
      //     .anyOf(mlTextElements,
      //         (q, MLTextElement element) => q.idEqualTo(element.lineID))
      //     .findAllSync();

      // log(mlTextLines.length.toString(), name: 'MLTextLines');

      if (mlTextLines.isNotEmpty) {
        //6. Find all the mlTextBlocks.
        mlTextBlocks = getRelatedTextBlocks(mlTextLines: mlTextLines);
        // isar!.mLTextBlocks
        //     .filter()
        //     .anyOf(mlTextLines,
        //         (q, MLTextLine element) => q.idEqualTo(element.blockID))
        //     .findAllSync();

        // log(mlTextBlocks.length.toString(), name: 'MLTextBlock');
      }
    }

    //7. Find all the mlPhotoLabels.
    List<MLPhotoLabel> mlPhotoLabels = getMLPhotoLabels(photoID: photo.id);
    // isar!.mLPhotoLabels.filter().photoIDEqualTo(photo.id).findAllSync();

    //8. Find all the photoLabels.
    List<PhotoLabel> photoLabels = getPhotoLabels(photoID: photo.id);
    // isar!.photoLabels.filter().photoIDEqualTo(photo.id).findAllSync();

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
      size: getSize(photo.photoSize),
      rotation: InputImageRotation.rotation0deg,
      photoLabels: photoLabels,
      mlPhotoLabels: mlPhotoLabels,
      mlObjects: mlObjects,
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
      ..photoUID = photo!.id
      ..tagTextUID = tagText.id;

    photoLabels.add(newPhotoLabel);
    if (!tagTextsContain(tagText)) {
      tagTexts.add(tagText);
    }

    isarPut(
      collection: Collections.PhotoLabel,
      object: newPhotoLabel,
    );
  }

  ///Remove a photoLabel for an existing photo.
  void removePhotoLabel(PhotoLabel photoLabel) {}

  ///Add a objectLabel for an existing photo.
  void addObjectLabel(TagText tagText, int objectID) {
    // ObjectLabel newObjectLabel = ObjectLabel()
    //   ..objectID = objectID
    //   ..tagTextID = tagText.id;
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
