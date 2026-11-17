import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/show_model.dart';
import 'package:flutter_application_1/services/tvmaze_service.dart';

void main() {
  group('Show Model Tests', () {
    test('Show.cleanHtml strips HTML tags and entities properly', () {
      const html = '<p><b>Under the Dome</b> is a series &amp; show.</p>';
      final cleaned = Show.cleanHtml(html);
      expect(cleaned, 'Under the Dome is a series & show.');
    });

    test('Show.fromJson parses valid JSON properly', () {
      final json = {
        'id': 1,
        'name': 'Under the Dome',
        'rating': {'average': 6.6},
        'genres': ['Drama', 'Science-Fiction'],
        'summary': '<p>A small town.</p>',
        'image': {
          'medium': 'https://static.tvmaze.com/medium.jpg',
          'original': 'https://static.tvmaze.com/original.jpg',
        },
        'status': 'Ended',
        'premiered': '2013-06-24',
        'runtime': 60,
        'language': 'English',
      };

      final show = Show.fromJson(json);
      expect(show.id, 1);
      expect(show.name, 'Under the Dome');
      expect(show.rating, 6.6);
      expect(show.genres, ['Drama', 'Science-Fiction']);
      expect(show.summary, 'A small town.');
      expect(show.imageUrl, 'https://static.tvmaze.com/medium.jpg');
    });

    test('Show toMap and fromMap works seamlessly for Hive', () {
      final showOriginal = Show(
        id: 99,
        name: 'Flash',
        rating: 8.5,
        imageUrl: 'https://example.com/img.jpg',
        genres: ['Action', 'Hero'],
        summary: 'Speedster story.',
      );

      final map = showOriginal.toMap();
      final fromHive = Show.fromMap(map);

      expect(fromHive.id, 99);
      expect(fromHive.name, 'Flash');
      expect(fromHive.rating, 8.5);
      expect(fromHive.imageUrl, 'https://example.com/img.jpg');
      expect(fromHive.genres, ['Action', 'Hero']);
      expect(fromHive.summary, 'Speedster story.');
    });
  });

  group('TVMaze API Live Tests', () {
    test('getShows fetches list of shows successfully', () async {
      final shows = await TvMazeService.getShows();
      expect(shows.isNotEmpty, true);
      expect(shows.first.id, greaterThan(0));
      expect(shows.first.name.isNotEmpty, true);
    });

    test('getShowDetail fetches single show details', () async {
      final show = await TvMazeService.getShowDetail(1);
      expect(show.id, 1);
      expect(show.name, 'Under the Dome');
    });
  });
}

