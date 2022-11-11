import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

bool changeParent({
  required CatalogedContainer currentContainer,
  required CatalogedContainer parentContainer,
}) {
  //1. Check if parent container is a child of the current container.
  List<ContainerRelationship> currentContainerChildrenRelationships =
      getContainerRelationshipsSync(parentUID: currentContainer.containerUID);
  // isar!.containerRelationships
  //     .filter()
  //     .parentUIDMatches(currentContainer.containerUID)
  //     .findAllSync();

  List<String> currentContainerChildren =
      currentContainerChildrenRelationships.map((e) => e.containerUID).toList();

  if (currentContainerChildren.contains(parentContainer.containerUID) &&
      currentContainer.containerUID != parentContainer.containerUID) {
    return false;
  } else {
    ContainerRelationship? containerRelationship = getContainerRelationshipSync(
        containerUID: currentContainer.containerUID);
    // isar!.containerRelationships
    //     .filter()
    //     .containerUIDMatches(currentContainer.containerUID)
    //     .findFirstSync();

    if (containerRelationship != null) {
      deleteContainerRelationship(id: containerRelationship.id);
      // isar!.writeTxnSync(
      //   () => isar!.containerRelationships.deleteSync(containerRelationship.id),
      // );
    }

    ContainerRelationship newContainerRelationship = ContainerRelationship()
      ..containerUID = currentContainer.containerUID
      ..parentUID = parentContainer.containerUID;

    putContainerRelationship(containerRelationship: newContainerRelationship);
    // isar!.writeTxnSync(
    //     () => isar!.containerRelationships.putSync(newContainerRelationship));

    return true;
  }
}
