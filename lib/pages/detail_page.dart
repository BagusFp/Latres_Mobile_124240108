import 'package:flutter/material.dart';
import '../models/show_model.dart';
import '../services/tvmaze_service.dart';
import '../storage/favorite_storage.dart';

class DetailPage extends StatefulWidget {
  final int showId;
  final Show? initialShow;

  const DetailPage({
    super.key,
    required this.showId,
    this.initialShow,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Show? _show;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _show = widget.initialShow;
    _checkFavoriteStatus();
    _fetchDetail();
  }

  void _checkFavoriteStatus() {
    setState(() {
      _isFavorite = FavoriteStorage.isFavorite(widget.showId);
    });
  }

  void _fetchDetail() async {
    setState(() {
      _isLoading = _show == null;
      _errorMessage = null;
    });

    try {
      final detail = await TvMazeService.getShowDetail(widget.showId);
      if (mounted) {
        setState(() {
          _show = detail;
          _isLoading = false;
          _isFavorite = FavoriteStorage.isFavorite(widget.showId);
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

  void _toggleFavorite() async {
    if (_show == null) return;

    if (_isFavorite) {
      // Hapus dari Hive
      await FavoriteStorage.removeFavoriteById(_show!.id);
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_show!.name} dihapus dari Favorit'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
    } else {
      // Tambahkan ke Hive
      await FavoriteStorage.addFavorite(_show!);
      if (mounted) {
        setState(() {
          _isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_show!.name} ditambahkan ke Favorit'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // Kirim result saat kembali
        ),
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            onPressed: _show != null ? _toggleFavorite : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _show == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    if (_errorMessage != null && _show == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    }

    final show = _show!;
    final imageDisplay = show.imageOriginalUrl ?? show.imageUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Poster Besar di bagian atas
          Stack(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                child: imageDisplay != null
                    ? Image.network(
                        imageDisplay,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.white38),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.movie, size: 80, color: Colors.white38),
                      ),
              ),
              // Gradient Overlay ke bawah agar transisi halus ke background gelap
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF121212),
                        const Color(0xFF121212).withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Show
                Text(
                  show.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating & Metadata
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      show.rating != null ? show.rating.toString() : 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (show.premiered != null) ...[
                      Text(
                        show.premiered!.split('-').first,
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (show.status != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          show.status!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Genre Chips / Text
                if (show.genres.isNotEmpty) ...[
                  Text(
                    show.genres.join(', '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Bar (Tombol Nonton & Tombol Favorit)
                Row(
                  children: [
                    // Tombol Nonton (Streaming feel)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Memulai pemutaran ${show.name}... (Simulasi)'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                        label: const Text(
                          'Nonton',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Favorit
                    OutlinedButton(
                      onPressed: _toggleFavorite,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _isFavorite ? Colors.redAccent : Colors.white38,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: _isFavorite
                            ? Colors.redAccent.withAlpha(30)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Overview / Summary Section
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  show.summary,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

