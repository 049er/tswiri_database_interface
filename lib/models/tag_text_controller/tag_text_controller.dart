import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';

///A wrapper around the tag text database.
///
class TagTextController {
  TagTextController({
    required this.assignedTags,
  });

  ///The list of currently assigned tags.
  Set<int> assignedTags;

  ///The list of tags to display.
  List<TagText> displayTags = [];

  ///Add a new tag to assigned tags.
  void addTag(TagText tagText) {
    //Add to assigned tags.
    assignedTags.add(tagText.id);
  }

  ///Remove an assigned tag.
  void removeTag(int tagTextID) {
    //Remove from assigned tags.
    assignedTags.removeWhere((element) => element == tagTextID);
  }

  ///Search the tag text table for matching tagtexts.
  void searchTags(String? enteredKeyword) {
    displayTags = filterTagTexts(
            excludedTags: assignedTags.toList(), enteredKeyWord: enteredKeyword)
        .take(15)
        .toList();

    // if (enteredKeyword != null && enteredKeyword.isNotEmpty) {
    //   displayTags = isar!.tagTexts
    //       .filter()
    //       .textContains(enteredKeyword, caseSensitive: false)
    //       .and()
    //       .not()
    //       .group((q) => q.allOf(
    //           assignedTags, (q, int tagTextID) => q.idEqualTo(tagTextID)))
    //       .findAllSync()
    //       .take(15)
    //       .toList();
    // } else {
    //   displayTags = isar!.tagTexts
    //       .filter()
    //       .not()
    //       .group((q) => q.allOf(
    //           assignedTags, (q, int tagTextID) => q.idEqualTo(tagTextID)))
    //       .findAllSync()
    //       .take(15)
    //       .toList();
    // }
  }
}
