import 'package:flutter/material.dart';
import '../models/show_model.dart';
import '../services/tvmaze_service.dart';
import '../widgets/show_card.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Show> _allShows = [];
  List<Show> _filteredShows = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchShows();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredShows = _allShows;
      } else {
        _filteredShows = _allShows.where((show) {
          return show.name.toLowerCase().contains(query) ||
              show.genres.any((g) => g.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  // Mengambil data show dari TVMaze menggunakan Service terpisah
  Future<void> _fetchShows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shows = await TvMazeService.getShows();
      if (mounted) {
        setState(() {
          _allShows = shows;
          _filteredShows = shows;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.tv, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Skuy Nonton!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchShows,
        color: Colors.redAccent,
        backgroundColor: const Color(0xFF1E1E1E),
        child: Column(
          children: [
            // Search Bar Sederhana
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari judul series / show...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white60),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Konten Utama: Loading / Error / Grid View
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'Memuat daftar series dari TVMaze...',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Gagal Mengambil Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchShows,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (jika hasil pencarian tidak ditemukan)
    if (_filteredShows.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, color: Colors.white38, size: 54),
            SizedBox(height: 12),
            Text(
              'Tidak ada show yang cocok.',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    // 4. GridView Data Shows (Sesuai Materi Modul 2 & Modul 5)
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredShows.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final show = _filteredShows[index];
        return ShowCard(
          show: show,
          onTap: () {
            // Navigasi ke DetailPage dengan passing ID show (Materi Modul 4)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  showId: show.id,
                  initialShow: show,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

