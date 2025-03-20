import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // ✅ Menggunakan super parameter

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _handleLogin() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.proyekutamami3a.biz.id/api/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String token = responseData['token'];
        await _storage.write(key: 'token', value: token);

        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          debugPrint("Decoded Token: $decodedToken");
          String role = decodedToken['role'];

          Fluttertoast.showToast(msg: "Login successful");

          if (!mounted) return;
          if (role == 'Admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (role == 'Pekerja') {
            Navigator.pushReplacementNamed(context, '/pekerja');
          } else {
            Navigator.pushReplacementNamed(context, '/');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: "Error decoding token");
          debugPrint("Token decode error: $e");
        }
      } else {
        Fluttertoast.showToast(
            msg: "Login failed. Please check your email and password.");
        debugPrint("Login failed: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
      debugPrint("Request error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        debugPrint("Decoded Token during check: $decodedToken");
        String role = decodedToken['role'];

        if (!mounted) return;
        if (role == 'Admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'Pekerja') {
          Navigator.pushReplacementNamed(context, '/pekerja');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } catch (e) {
        await _storage.delete(key: 'token');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        debugPrint("Token validation error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: TextStyle(fontSize: 24)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Your Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Forgot Password"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Don't have an account? Register"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
