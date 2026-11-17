import 'package:hive/hive.dart';
import '../models/show_model.dart';

class FavoriteStorage {
  static const String boxName = 'favoritesBox';

  /// Mendapatkan box Hive yang sudah terbuka
  static Box getBox() {
    return Hive.box(boxName);
  }

  /// Menambahkan show ke Hive menggunakan method .add()
  static Future<void> addFavorite(Show show) async {
    final box = getBox();
    // Cek agar tidak duplikat
    if (!isFavorite(show.id)) {
      await box.add(show.toMap());
    }
  }

  /// Mengambil show berdasarkan index menggunakan method .getAt()
  static Show getFavoriteAt(int index) {
    final box = getBox();
    final data = box.getAt(index);
    return Show.fromMap(data as Map);
  }

  /// Menghapus show berdasarkan index menggunakan method .deleteAt()
  static Future<void> deleteFavoriteAt(int index) async {
    final box = getBox();
    await box.deleteAt(index);
  }

  /// Mengecek apakah sebuah show dengan ID tertentu sudah ada di favorit
  static bool isFavorite(int showId) {
    final box = getBox();
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item is Map && item['id'] == showId) {
        return true;
      }
    }
    return false;
  }

  /// Menghapus show berdasarkan ID (mencari index lalu memanggil .deleteAt)
  static Future<void> removeFavoriteById(int showId) async {
    final box = getBox();
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item is Map && item['id'] == showId) {
        await box.deleteAt(i);
        break;
      }
    }
  }

  /// Mengambil semua daftar show yang difavoritkan
  static List<Show> getAllFavorites() {
    final box = getBox();
    final List<Show> list = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data is Map) {
        list.add(Show.fromMap(data));
      }
    }
    return list;
  }
}

