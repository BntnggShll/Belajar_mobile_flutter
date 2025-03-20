import 'package:flutter/material.dart';
import './login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Gunakan super parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/': (context) => const LoginScreen()}, // Tambahkan const
    );
  }
}
