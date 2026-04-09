import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message = "";

  final String baseUrl = "http://140.245.214.250:8001/";

  Future<void> handleLogin() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );

      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        if (data["role"] == "security") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyHomePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfficerScreen(),
            ),
          );
        }
      } else {
        setState(() {
          message = "Invalid login";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text("Login"),
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class OfficerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Officer Dashboard")),
      body: const Center(child: Text("Officer View Coming Soon")),
    );
  }
}

class SecurityDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security Dashboard')),
      body: Center(child: Text('Welcome Security')),
    );
  }
}

class OfficerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Officer Dashboard')),
      body: Center(child: Text('Welcome Officer')),
    );
  }
}