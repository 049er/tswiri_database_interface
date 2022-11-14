import 'package:flutter/cupertino.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

class ContainerManager with ChangeNotifier {
  ContainerManager() {
    containerTypes = getContainerTypesSync();
  }

  late List<ContainerType> containerTypes;
}
