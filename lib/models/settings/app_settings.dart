import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tswiri_database_interface/models/settings/global_settings.dart';

//TODO: create change notifier class.

//Camera Settings
List<CameraDescription> cameras = [];
ResolutionPreset cameraResolution = ResolutionPreset.high;

///Vibration on/off.
bool vibrate = true;
String vibratePref = 'vibrate';

///Is image labeling on.
bool imageLabeling = true;
String imageLabelingPref = 'imageLabeling';

///Image labeling confidence level.
double imageLabelingConfidence = 0.5;
String imageLabelingConfidencePref = 'imageLabelingConfidence';

///Is object detection on.
bool objectDetection = true;
String objectDetectionPref = 'objectDetection';

///Object detection confidence level.
double objectDetectionConfidence = 0.5;
String objectDetectionConfidencePref = 'objectDetectionConfidence';

///Is text detection on.
bool textDetection = true;
String textDetectionPref = 'textDetection';

///Camera focal length
double focalLength = 1;
String focalLengthPref = 'focalLength';

///Flash on/off during image capture.
bool flashOnPhotos = false;
String flashOnPhotosPref = 'flashOnPhotos';

///Flash on/off during barcode scanning.
bool flashOnBarcodes = false;
String flashOnBarcodesPref = 'flashOnBarcodes';

///Flash on/off during grid scanning.
bool flashOnGrids = false;
String flashOnGridsPref = 'flashOnGrids';

///Flash on/off during navigation.
bool flashOnNavigation = false;
String flashOnNavigationPref = 'flashOnNavigation';

///Has shown Beta Warning.
bool hasShownBetaWarning = false;
String hasShownBetaWarningPref = 'hasShownBetaWarning';

///Used to store the currently loaded space directory.
String? spaceDirectoryPath;
String spaceDirectoryPathPref = 'spaceDirectoryPathPref';

Future<void> loadAppSettings() async {
  //Get Camera descriptions.
  cameras = await availableCameras();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Default barcode size.
  defaultBarcodeSize =
      prefs.getDouble(defaultBarcodeSizePref) ?? defaultBarcodeSize;

  //Vibration.
  vibrate = prefs.getBool(vibratePref) ?? true;

  //Image Labeling.
  imageLabeling = prefs.getBool(imageLabelingPref) ?? true;
  imageLabelingConfidence = prefs.getDouble(imageLabelingConfidencePref) ?? 0.5;

  //Object Detection.
  objectDetection = prefs.getBool(objectDetectionPref) ?? true;
  objectDetectionConfidence =
      prefs.getDouble(objectDetectionConfidencePref) ?? 0.5;

  //Text Detection.
  textDetection = prefs.getBool(textDetectionPref) ?? true;

  //Focal Length.
  focalLength = prefs.getDouble(focalLengthPref) ?? 1.0;

  //Color Mode.
  colorModeEnabled = prefs.getBool(colorModeEnabledPref) ?? false;

  //Flash
  flashOnPhotos = prefs.getBool(flashOnPhotosPref) ?? false;
  flashOnBarcodes = prefs.getBool(flashOnBarcodesPref) ?? false;
  flashOnGrids = prefs.getBool(flashOnGridsPref) ?? false;
  flashOnNavigation = prefs.getBool(flashOnNavigationPref) ?? false;

  //Beta Warning.
  hasShownBetaWarning = prefs.getBool(hasShownBetaWarningPref) ?? false;
}
