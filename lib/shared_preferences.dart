import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SharedPreferencesDemo(),
    );
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  @override
  _SharedPreferencesDemoState createState() => _SharedPreferencesDemoState();
}

class _SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  late SharedPreferences prefs;
  String savedText = "";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedText = prefs.getString("userText") ?? "No data saved!";
    });
  }

  Future<void> _saveData() async {
    await prefs.setString("userText", _controller.text);
    _loadSavedData(); // Refresh UI with new data
  }

  Future<void> _clearData() async {
    await prefs.remove("userText");
    _loadSavedData(); // Refresh UI after clearing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shared Preferences Demo")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter text to save"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveData,
              child: Text("Save Data"),
            ),
            ElevatedButton(
              onPressed: _clearData,
              child: Text("Clear Data"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            Text("Saved Data: $savedText", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
