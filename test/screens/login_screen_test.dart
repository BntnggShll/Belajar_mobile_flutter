import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coba/login.dart';
import 'dart:convert';

import 'login_screen_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        '/admin': (context) => const Scaffold(body: Text('Admin Page')),
        '/pekerja': (context) => const Scaffold(body: Text('Pekerja Page')),
        '/': (context) => const Scaffold(body: Text('Home Page')),
        '/register': (context) => const Scaffold(body: Text('Register Page')),
      },
    );
  }

  testWidgets('Menampilkan tampilan awal LoginScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Memasukkan email dan password', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('Login sukses menyimpan token dan navigasi ke Admin',
      (WidgetTester tester) async {
    when(mockClient.post(
      Uri.parse('https://api.proyekutamami3a.biz.id/api/login'),
      body: anyNamed('body'),
    )).thenAnswer(
        (_) async => http.Response(jsonEncode({'token': 'mocked_token'}), 200));

    when(mockStorage.write(key: 'token', value: anyNamed('value')))
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'admin@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'admin1234');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockStorage.write(key: 'token', value: 'mocked_token')).called(1);
  });

  testWidgets('Login gagal menampilkan pesan kesalahan',
      (WidgetTester tester) async {
    when(mockClient.post(
      Uri.parse('https://api.proyekutamami3a.biz.id/api/login'),
      body: anyNamed('body'),
    )).thenAnswer(
        (_) async => http.Response('{"message": "Invalid credentials"}', 401));

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Login failed. Please check your email and password.'),
        findsOneWidget);
  });

  testWidgets(
      'Navigasi ke halaman Register saat klik "Don\'t have an account? Register"',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Register Page'), findsOneWidget);
  });
}
