import 'package:flutter/cupertino.dart';
import 'package:tswiri_database/collections/container_type/container_type.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

class ContainerManager with ChangeNotifier {
  ContainerManager() {
    containerTypes = isar!.containerTypes.where().findAllSync();
  }

  late List<ContainerType> containerTypes;
}
