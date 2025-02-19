import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Map<String, dynamic>? dialogData;
  Map<String, dynamic>? currentNode;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _fetchDialogData();
  }

  Future<void> _fetchDialogData() async {
    final url = Uri.parse("https://candidate.ampassador.com/test-dialogs");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          dialogData = json.decode(response.body);
          // Start with the first node (assume node with id 1 is the start)
          currentNode = dialogData!["nodes"].firstWhere((node) => node["id"] == 1);
        });
      } else {
        print("Failed to load dialog data");
      }
    } catch (e) {
      print("Error fetching dialog data: $e");
    }
  }

  void _selectOption(Map<String, dynamic> option) {
    if (option.containsKey("points")) {
      totalScore += int.tryParse(option["points"].toString()) ?? 0;
    }
    final nextId = option["next"];
    final nodes = dialogData!["nodes"] as List;
    final nextNode = nodes.firstWhere(
      (node) => node["id"] == nextId,
      orElse: () => null,
    );
    if (nextNode != null) {
      setState(() {
        currentNode = nextNode;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Test Completed"),
            content: Text("Your test is completed. Your total score is: $totalScore"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dialogData == null || currentNode == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Test")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dialogData!["title"] ?? "Test"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentNode!["text"] ?? "",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ...((currentNode!["options"] as List).map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () => _selectOption(option),
                  child: Text(option["text"]),
                ),
              );
            })).toList(),
          ],
        ),
      ),
    );
  }
}
