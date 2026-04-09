import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'local_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
void initState() {
  super.initState();
  syncPendingData();
}

  TextEditingController vehicleController = TextEditingController();
  TextEditingController partyController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController docController = TextEditingController();

  String selectedType = "IN";

  String result = "";

  final String baseUrl = "http://140.245.214.250:8001/";

  // Submit Data


Future<bool> hasInternet() async {
  var result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}

Future<void> submitData() async {
  Map<String, dynamic> data = {
    "type": selectedType,
    "vehicle_no": vehicleController.text,
    "party": partyController.text,
    "item": itemController.text,
    "quantity": quantityController.text,
    "document_no": docController.text,
    "image_path": "",
    "timestamp": DateTime.now().toString(),
  };

  // ✅ Always save locally first
  await saveEntry(data);

  if (await hasInternet()) {
    await syncPendingData();

    setState(() {
      result = "Synced with server ✅";
    });
  } else {
    setState(() {
      result = "Saved Offline ⚠️";
    });
  }
}

  // Fetch Data
  Future<void> fetchData() async {
  try {
    final response = await http.get(
      Uri.parse("${baseUrl}data"),
    );

    print("Fetch Status: ${response.statusCode}");
    print("Fetch Body: ${response.body}");

    final data = jsonDecode(response.body);

    String temp = "";

    for (var item in data["data"]) {
      temp += "Name: ${item["name"]}\n";
      temp += "Message: ${item["message"]}\n\n";
    }

    setState(() {
      result = temp;
    });
  } catch (e) {
    print("Error: $e");
    setState(() {
      result = "Error: $e";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Field App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(labelText: "Vehicle Number"),
            ),
            TextField(
              controller: partyController,
              decoration: const InputDecoration(labelText: "Party Name"),
            ),
            TextField(
              controller: itemController,
              decoration: const InputDecoration(labelText: "Item Description"),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: ["IN", "OUT"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            TextField(
              controller: docController,
              decoration: const InputDecoration(labelText: "Document No"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: const Text("Submit"),
            ),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Fetch Data"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(result),
              ),
            )
          ],
        ),
      ),
    );
  }
}