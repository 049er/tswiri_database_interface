import 'package:shared_preferences/shared_preferences.dart';
import 'global_settings.dart';

//TODO: create change notifier class.

Future<void> loadDesktopSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //Default barcode size.
  defaultBarcodeSize =
      prefs.getDouble(defaultBarcodeSizePref) ?? defaultBarcodeSize;

  //Color Mode.
  colorModeEnabled = prefs.getBool(colorModeEnabledPref) ?? false;

  // //Spaces
  // currentSpacePath = prefs.getString(currentSpacePathPref) ??
  //     '${(await getApplicationSupportDirectory()).path}/main_space';
}
