import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

///Deletes Multiple Containers and all referneces
void deleteMultipleContainers(List<CatalogedContainer> containerEntries) {
  for (var catalogedContainer in containerEntries) {
    deleteContainer(catalogedContainer);
  }
}
