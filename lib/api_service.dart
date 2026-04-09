import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> login(String username, String password) async {
  try {
    var response = await http.post(
      Uri.parse("http://140.245.214.250:8001/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      return data["role"];
    }
  } catch (e) {
    print("Login error: $e");
  }

  return null;
}

Future<bool> sendToServer(Map<String, dynamic> entry) async {
  try {
    var response = await http.post(
      Uri.parse("http://140.245.214.250:8001/entry"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(entry),
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
