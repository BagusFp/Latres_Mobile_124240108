import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login page displays title and inputs', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verify Title and Subtitle exist
    expect(find.text('NontonSkuy!'), findsOneWidget);
    expect(find.textContaining('124240108'), findsWidgets);

    // Verify TextField presence
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Login page shows error on empty inputs', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username dan Password tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Login page shows error on wrong credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'wrong_user');
    await tester.enterText(find.byType(TextField).at(1), 'wrong_pass');
    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('Login Gagal!'), findsOneWidget);
  });
}
