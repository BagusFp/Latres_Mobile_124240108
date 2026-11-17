import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'storage/favorite_storage.dart';
import 'storage/auth_storage.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/root_page.dart';

void main() async {
  // Memastikan binding Flutter terinisialisasi sebelum async storage
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk local database favorit (Materi Modul 6)
  await Hive.initFlutter();
  await Hive.openBox(FavoriteStorage.boxName);

  // Inisialisasi Local Notification secara aman (Materi Modul 7)
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notifikasi tidak diaktifkan pada platform ini: $e');
  }

  // Cek session login dari SharedPreferences (Materi Modul 6)
  final bool loggedIn = await AuthStorage.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NontonSkuy - TVMaze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.redAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      // Jika sudah login, langsung ke RootPage, jika belum ke LoginPage
      home: isLoggedIn ? const RootPage() : const LoginPage(),
    );
  }
}
