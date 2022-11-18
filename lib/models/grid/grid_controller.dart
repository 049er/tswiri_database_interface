import 'dart:developer';
import 'dart:ui';

// ignore: depend_on_referenced_packages
import 'package:tswiri_database/embedded/embedded_vector_3/embedded_vector_3.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/data/data_processing.dart';
import 'package:tswiri_database_interface/models/display/display_point.dart';
import 'package:tswiri_database_interface/models/inter_barcode/inter_barcode_vector.dart';
import 'package:tswiri_database_interface/models/inter_barcode/on_image_inter_barcode_data.dart';
import 'package:tswiri_database_interface/models/settings/app_settings.dart';

// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart' as vm;

class GridController {
  GridController({
    required this.gridUID,
  });

  int gridUID;
  late CatalogedGrid catalogedGrid = getCatalogedGridSync(gridUID: gridUID)!;
  // isar!.catalogedGrids.getSync(gridUID)!;

  late List<Marker> markers = findGridMarkers();

  processData(List<dynamic> barcodeDataBatches) {
    //1. Get the Cataloged Barcodes.
    List<CatalogedBarcode> barcodeProperties = getCatalogedBarcodesSync();
    // isar!.catalogedBarcodes.where().findAllSync();

    //2. Create the onImageBarcodeData.
    List<OnImageInterBarcodeData> onImageInterBarcodeData =
        createOnImageBarcodeData(
      barcodeDataBatches,
    );

    //3. Create the InterBarcodeVectors.
    List<InterBarcodeVector> interBarcodeVectors = createInterbarcodeVectors(
      onImageInterBarcodeData,
      barcodeProperties,
      focalLength,
    );

    //4. Average the InterBarcodeVectors.
    List<InterBarcodeVector> finalRealInterBarcodeData =
        averageInterbarcodeData(
      interBarcodeVectors,
    );

    //5. Generate CatalogedCoordinates.
    List<CatalogedCoordinate> coordinates = generateCoordinates(
      gridUID,
      finalRealInterBarcodeData,
    );

    //6. Create/Update Coordinates.
    updateCoordinates(
      gridUID: gridUID,
      coordinates: coordinates,
    );
  }

  ///Calculates a list of [DisplayPoint] to draw.
  List<DisplayPoint> calculateDisplayPoints(
    Size size,
    String? selectedBarcodeUID,
  ) {
    //1. Find all the coordinates in the grid.
    List<CatalogedCoordinate> coordinates =
        getCatalogedCoordinatesSync(gridUID: gridUID);

    //2. Calcualte the unitOffset to use.
    Offset unitOffset = calculateUnitVectors(
      coordinateEntries: coordinates,
      width: size.width,
      height: size.height,
    );

    //3. List of all marker barcodeUIDs.
    List<String> markerBarcodeUIDs =
        getMarkers().map((e) => e.barcodeUID).toList();

    List<DisplayPoint> myPoints = [];

    for (var i = 0; i < coordinates.length; i++) {
      CatalogedCoordinate catalogedCoordinate = coordinates.elementAt(i);

      if (catalogedCoordinate.coordinate != null) {
        Offset barcodePosition = Offset(
            (catalogedCoordinate.coordinate!.vector.x * unitOffset.dx) +
                (size.width / 2) -
                (size.width / 8),
            (catalogedCoordinate.coordinate!.vector.y * unitOffset.dy) +
                (size.height / 2) -
                (size.height / 8));

        List<String> barcodeRealPosition = [
          catalogedCoordinate.coordinate!.vector.x.toStringAsFixed(4),
          catalogedCoordinate.coordinate!.vector.y.toStringAsFixed(4),
          catalogedCoordinate.coordinate!.vector.z.toStringAsFixed(4),
        ];

        DisplayPointType displayPointType = DisplayPointType.unkown;

        CatalogedContainer? container = getCatalogedContainerSync(
            barcodeUID: catalogedCoordinate.barcodeUID);
        if (container != null) {
          displayPointType = DisplayPointType.normal;
        }

        if (markerBarcodeUIDs.contains(catalogedCoordinate.barcodeUID)) {
          displayPointType = DisplayPointType.marker;
        }

        if (catalogedCoordinate.barcodeUID == selectedBarcodeUID) {
          displayPointType = DisplayPointType.selected;
        }

        myPoints.add(
          DisplayPoint(
            barcodeUID: catalogedCoordinate.barcodeUID,
            screenPosition: barcodePosition,
            realPosition: barcodeRealPosition,
            type: displayPointType,
          ),
        );
      }
    }
    return myPoints;
  }

  ///Finds all the markers of a given GridUID.
  List<Marker> findGridMarkers() {
    //If you have a grid id.
    List<CatalogedCoordinate> catalogedCoordinates =
        getCatalogedCoordinatesSync(gridUID: gridUID);

    if (catalogedCoordinates.isNotEmpty) {
      return getMarkersInCatalogedCoordinates(
          catalogedCoordinates: catalogedCoordinates);
    } else {
      //No Coordinates found so create a marker from the grid barcode.
      CatalogedCoordinate catalogedCoordinate = CatalogedCoordinate()
        ..barcodeUID = getCatalogedGridSync(gridUID: gridUID)!.barcodeUID
        ..coordinate = EmbeddedVector3.fromVector(vm.Vector3(0, 0, 0))
        ..gridUID = gridUID
        ..rotation = null
        ..timestamp = DateTime.now().millisecondsSinceEpoch;

      //Put catalogedCoordinate.
      isarPut(
        collection: Collections.CatalogedCoordinate,
        object: catalogedCoordinate,
      );

      Marker marker = getMarker(
          barcodeUID: getCatalogedGridSync(gridUID: gridUID)!.barcodeUID)!;

      return [marker];
    }
  }
}
