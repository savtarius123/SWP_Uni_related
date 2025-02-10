/// Enums for categorizing topics based on hardware or display group
///
/// Authors:
///   * Heye Hamadmad
library;

/// Categorize based on hardware
enum HwCategory implements Comparable<HwCategory> {
  board("Board"),
  pbr("Photobioreactor");

  const HwCategory(this.title);

  final String title;

  @override
  int compareTo(other) {
    return title.compareTo(other.title);
  }
}

/// Categorize based on display group
enum DisplayGroup implements Comparable {
  temp(HwCategory.board, "Temperature"),
  humid(HwCategory.board, "Humidity"),
  misc(HwCategory.board, "Miscellaneous"),
  inlet(HwCategory.pbr, "Inlet"),
  liquid(HwCategory.pbr, "Liquid"),
  outlet(HwCategory.pbr, "Outlet");

  const DisplayGroup(this.hwCategory, this.title);

  final HwCategory hwCategory;
  final String title;

  @override
  int compareTo(other) {
    return title.compareTo(other.title);
  }
}
