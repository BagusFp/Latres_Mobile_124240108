import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/show_model.dart';

class TvMazeService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  /// Mengambil daftar semua TV shows dari API TVMaze
  /// Endpoint: GET https://api.tvmaze.com/shows
  static Future<List<Show>> getShows() async {
    final uri = Uri.parse('$_baseUrl/shows');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Show.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil data dari TVMaze (Status: ${response.statusCode})',
      );
    }
  }

  /// Mengambil detail satu TV show berdasarkan ID
  /// Endpoint: GET https://api.tvmaze.com/shows/{id}
  static Future<Show> getShowDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/shows/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Show.fromJson(data);
    } else {
      throw Exception(
        'Gagal mengambil detail show dengan ID $id (Status: ${response.statusCode})',
      );
    }
  }
}
