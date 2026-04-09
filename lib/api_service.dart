import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
final String baseUrl = "http://140.245.214.250:8001/";

Future<String?> login(String username, String password) async {
  try {
    var response = await http.post(
      Uri.parse("${baseUrl}login"),
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
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${baseUrl}entry"),
    );
    print("SENDING DATA:");
    print(entry);
    // Add fields
    request.fields['type'] = entry['type']?.toString() ?? '';
    request.fields['vehicle_no'] = entry['vehicle_no']?.toString() ?? '';
    request.fields['party'] = entry['party']?.toString() ?? '';
    request.fields['item'] = entry['item']?.toString() ?? '';
    request.fields['quantity'] = entry['quantity']?.toString() ?? '';
    request.fields['document_no'] = entry['document_no']?.toString() ?? '';
    request.fields['timestamp'] = entry['timestamp']?.toString() ?? '';

    // ✅ Add image if exists
    if (entry['image_path'] != null &&
        entry['image_path'].toString().isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        entry['image_path'],
      ));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      var respStr = await response.stream.bytesToString();
      print("Error response: $respStr");
    }
    return response.statusCode == 200;
  } catch (e) {
    print("Upload error: $e");
    return false;
  }
}