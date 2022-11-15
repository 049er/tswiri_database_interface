import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/functions/isar/find_functions.dart';

///Used to search containerEntries.
class ContainerSearchController {
  late List<CatalogedContainer> searchResults = [];

  late List<ContainerType> containerTypes = getContainerTypesSync();
  // isar!.containerTypes.where().findAllSync();

  ///Filters container entries using [ContainerType] and enteredKeyWord [String].
  void filterContainerEntries({
    required String? enteredKeyWord,
    required List<String> containerFilters,
  }) {
    searchResults.clear();
    if (enteredKeyWord != null && enteredKeyWord.isNotEmpty) {
      // searchResults.addAll(
      //   isar!.catalogedContainers
      //       .filter()
      //       .anyOf(
      //           containerTypes,
      //           (q, ContainerType containerType) => q.optional(
      //               containerFilters.contains(containerType.containerTypeName),
      //               (q) => q.containerTypeIDEqualTo(containerType.id)))
      //       .and()
      //       .nameContains(enteredKeyWord, caseSensitive: false)
      //       .findAllSync(),
      // );
    } else {
      // for (var containerType in containerTypes) {
      //   if (containerFilters.contains(containerType.containerTypeName)) {
      //     searchResults.addAll(
      //       isar!.catalogedContainers
      //           .filter()
      //           .containerTypeIDEqualTo(containerType.id)
      //           .findAllSync(),
      //     );
      //   }
      // }
    }
  }

  //Returns a list of container Search Types.
  List<String> filterTypes() {
    List<String> filterTypes = containerTypes.map((e) => e.name).toList();

    return filterTypes;
  }

  void filterWithExclusions({
    required String? enteredKeyWord,
    required List<String> containerFilters,
    required CatalogedContainer currentContainer,
    required CatalogedContainer? parentContainer,
  }) {
    searchResults.clear();

    List<CatalogedContainer> excludedContainers =
        findCatalogedContainerDecendants(currentContainer);

    if (enteredKeyWord != null && enteredKeyWord.isNotEmpty) {
      // List<CatalogedContainer> containers = isar!.catalogedContainers
      //     .filter()
      //     .group(
      //       (q) => q.anyOf(
      //         containerTypes,
      //         (q, ContainerType containerType) => q.optional(
      //           containerFilters.contains(containerType.containerTypeName),
      //           (q) => q.containerTypeIDEqualTo(containerType.id),
      //         ),
      //       ),
      //     )
      //     .and()
      //     .nameContains(enteredKeyWord, caseSensitive: false)
      //     .findAllSync();

      // searchResults.addAll(containers);
    } else {
      // for (var containerType in containerTypes) {
      //   if (containerFilters.contains(containerType.containerTypeName)) {
      //     List<CatalogedContainer> containers = isar!.catalogedContainers
      //         .filter()
      //         .containerTypeIDEqualTo(containerType.id)
      //         .findAllSync();
      //     searchResults.addAll(containers);
      //   }
      // }
    }

    searchResults.removeWhere((element) => element.id == currentContainer.id);
    for (var excludedContainer in excludedContainers) {
      searchResults
          .removeWhere((element) => element.id == excludedContainer.id);
    }
    if (parentContainer != null) {
      searchResults.removeWhere((element) => element.id == parentContainer.id);
    }
  }
}
