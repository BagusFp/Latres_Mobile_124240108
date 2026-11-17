class Show {
  final int id;
  final String name;
  final String? imageUrl;
  final String? imageOriginalUrl;
  final double? rating;
  final List<String> genres;
  final String summary;
  final String? status;
  final String? premiered;
  final int? runtime;
  final String? language;

  Show({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageOriginalUrl,
    this.rating,
    this.genres = const [],
    this.summary = '',
    this.status,
    this.premiered,
    this.runtime,
    this.language,
  });

  // Helper untuk membersihkan tag HTML dari summary
  static String cleanHtml(String? html) {
    if (html == null || html.isEmpty) {
      return 'Tidak ada deskripsi tersedia.';
    }
    // Hapus semua tag HTML menggunakan RegExp
    final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // Bersihkan entitas HTML umum
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  // Factory constructor dari JSON API TVMaze
  factory Show.fromJson(Map<String, dynamic> json) {
    double? parsedRating;
    if (json['rating'] != null && json['rating']['average'] != null) {
      parsedRating = (json['rating']['average'] as num).toDouble();
    }

    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return Show(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Tanpa Judul',
      imageUrl: json['image']?['medium'] as String?,
      imageOriginalUrl: json['image']?['original'] as String?,
      rating: parsedRating,
      genres: parsedGenres,
      summary: cleanHtml(json['summary'] as String?),
      status: json['status'] as String?,
      premiered: json['premiered'] as String?,
      runtime: json['runtime'] as int?,
      language: json['language'] as String?,
    );
  }

  // Konversi ke Map untuk disimpan di Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'imageOriginalUrl': imageOriginalUrl,
      'rating': rating,
      'genres': genres,
      'summary': summary,
      'status': status,
      'premiered': premiered,
      'runtime': runtime,
      'language': language,
    };
  }

  // Factory constructor dari Map di Hive
  factory Show.fromMap(Map<dynamic, dynamic> map) {
    return Show(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'Tanpa Judul',
      imageUrl: map['imageUrl'] as String?,
      imageOriginalUrl: map['imageOriginalUrl'] as String?,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      genres: (map['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
      summary: map['summary'] as String? ?? 'Tidak ada deskripsi tersedia.',
      status: map['status'] as String?,
      premiered: map['premiered'] as String?,
      runtime: map['runtime'] as int?,
      language: map['language'] as String?,
    );
  }
}

