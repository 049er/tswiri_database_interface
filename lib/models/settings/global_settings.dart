//Color Mode
bool colorModeEnabled = false;
String colorModeEnabledPref = 'colorModeEnabled';

//Isar version
int isarVersion = 1;

// //Current Space.
// String? currentSpacePath;
// String currentSpacePathPref = 'currentSpacePath';

///Default Barcode Size.
double defaultBarcodeSize = 80;
String defaultBarcodeSizePref = 'defaultBarcodeSize';

///Barcode Filters.
List<String> barcodeFilters = ['Assigned', 'Unassigned'];

///Defualt barcode sizes.
final Map<String, double> barcodeSizes = {
  'Tiny': 10,
  'Extra Small': 20,
  'Small': 30,
  'Medium': 50,
  'Large': 60,
  'Extra Large': 75,
  'Custom': 100,
};

///Barcodes per A4 page.
final Map<String, int> barcodesPerPage = {
  'Tiny': 228,
  'Extra Small': 130,
  'Small': 56,
  'Medium': 20,
  'Large': 12,
  'Extra Large': 6,
  'Custom': 100,
};

List<String> searchFilters = [
  'Tags',
  'ML Labels',
  'Photo Labels',
  'Object Labels',
  'Name',
  'Description',
  'ML Text',
];

Map<String, String> filterTypes = {
  'Tags': 'Search by container tags',
  'ML Labels': 'Search by photo labels',
  'Photo Labels': 'Search by User Photo Labels',
  'Object Labels': 'Search by User Object Labels',
  'Name': 'Search by container Name',
  'Description': 'Search by container Description',
  'ML Text': 'Search by detected text',
};

///Container Filters
List<String> containerFilters = [
  'Area',
  'Drawer',
  'Shelf',
  'Box',
];
