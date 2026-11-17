import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Mendapatkan koordinat lokasi (Latitude & Longitude) pengguna saat ini
  static Future<Position> getCurrentLocation() async {
    // 1. Cek apakah layanan GPS aktif di perangkat
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) sedang dinonaktifkan. Silakan aktifkan GPS perangkat Anda.');
    }

    // 2. Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Minta izin ke pengguna
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin akses lokasi ditolak permanen. Silakan ubah izin di Pengaturan aplikasi.');
    }

    // 3. Ambil posisi saat ini
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}

