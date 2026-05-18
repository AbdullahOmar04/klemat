import 'package:klemat/custom_level_map/bg_image.dart';
import 'package:klemat/custom_level_map/image_details.dart';

class ImagesToPaint {
  final List<BGImage>? bgImages;
  final ImageDetails? startLevelImage;
  final ImageDetails completedLevelImage;
  final ImageDetails currentLevelImage;
  final ImageDetails lockedLevelImage;
  final ImageDetails? pathEndImage;

  ImagesToPaint({
    required this.completedLevelImage,
    required this.currentLevelImage,
    required this.lockedLevelImage,
    this.bgImages,
    this.startLevelImage,
    this.pathEndImage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagesToPaint &&
          runtimeType == other.runtimeType &&
          _listEquals(bgImages, other.bgImages) &&
          startLevelImage == other.startLevelImage &&
          currentLevelImage == other.currentLevelImage &&
          pathEndImage == other.pathEndImage &&
          lockedLevelImage == other.lockedLevelImage &&
          completedLevelImage == other.completedLevelImage;

  @override
  int get hashCode =>
      _listHash(bgImages) ^
      startLevelImage.hashCode ^
      currentLevelImage.hashCode ^
      pathEndImage.hashCode ^
      lockedLevelImage.hashCode ^
      completedLevelImage.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHash<T>(List<T>? list) {
    if (list == null) return 0;
    return list.fold(0, (hash, item) => hash ^ item.hashCode);
  }
}
