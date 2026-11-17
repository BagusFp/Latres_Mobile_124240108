import 'package:flutter/material.dart';
import '../models/show_model.dart';
import '../storage/favorite_storage.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Show> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Memuat data favorit dari Hive menggunakan getAt()
  void _loadFavorites() {
    setState(() {
      final box = FavoriteStorage.getBox();
      final List<Show> list = [];
      for (int i = 0; i < box.length; i++) {
        // Menggunakan method getAt sesuai materi Modul 6
        final data = box.getAt(i);
        if (data is Map) {
          list.add(Show.fromMap(data));
        }
      }
      _favorites = list;
    });
  }

  /// Menghapus data favorit berdasarkan index menggunakan deleteAt()
  void _deleteFavorite(int index, Show show) async {
    // Menggunakan deleteAt sesuai materi Modul 6
    await FavoriteStorage.deleteFavoriteAt(index);
    // Langsung update UI dengan setState
    _loadFavorites();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${show.name} berhasil dihapus dari Favorit'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Daftar Favorit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: Colors.white.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada show favorit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan series yang kamu sukai dari halaman Home!',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final show = _favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      // Navigasi ke DetailPage dengan passing ID
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            showId: show.id,
                            initialShow: show,
                          ),
                        ),
                      );
                      // Update UI saat kembali dari DetailPage
                      _loadFavorites();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Poster Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 80,
                              color: const Color(0xFF2C2C2C),
                              child: show.imageUrl != null
                                  ? Image.network(
                                      show.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white38),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.movie, color: Colors.white38),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Judul & Rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  show.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      show.rating != null ? show.rating.toString() : 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Tombol Hapus Favorit (deleteAt)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Hapus dari favorit',
                            onPressed: () => _deleteFavorite(index, show),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
