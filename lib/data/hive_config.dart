import 'package:hive/hive.dart';

// Tên box lưu favorites
const String favoriteBoxName = 'favorite_products';

class HiveConfig {
  static Box? _favoriteBox;

  static Future<void> init() async {
    _favoriteBox = await Hive.openBox(favoriteBoxName);
  }

  static Box get favoriteBox {
    if (_favoriteBox == null || !_favoriteBox!.isOpen) {
      throw Exception(
        'Favorite box has not been opened or has already been closed.',
      );
    }
    return _favoriteBox!;
  }

  static Future<void> addFavorite(int productId) async {
    await favoriteBox.put(productId, true);
  }

  static Future<void> removeFavorite(int productId) async {
    await favoriteBox.delete(productId);
  }

  static bool isFavorite(int productId) {
    if (!favoriteBox.isOpen) {
      return false;
    }
    return favoriteBox.containsKey(productId);
  }

  static List<int> getFavoriteIds() {
    return favoriteBox.keys.cast<int>().toSet().toList();
  }

  static Map<int, dynamic> getAllFavorites() {
    return Map<int, dynamic>.from(favoriteBox.toMap());
  }
}
