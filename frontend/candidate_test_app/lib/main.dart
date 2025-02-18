import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CandidateTestApp());
}

class CandidateTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candidate Test Experience',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final url = Uri.parse("https://candidate.ampassador.com/login"); // Ensure this URL matches your backend endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        // Navigate to the HomePage on successful login
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: Invalid credentials")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Candidate Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  // Test instructions from Appendix A
  final String testInstructions = '''In each game you'll be playing a role. The character on the screen will engage you in an informal conversation. Your job is to listen and respond with your preferred choice. It is not a simple choice between right and wrong answers. The choices represent your preference concerning the subject of conversation.

At every moment you should listen to what the character on the screen says and try to understand the meaning and intent. You will not have the ability to repeat any of the answers or the speech of the character. Even if you are not sure you understand, you must use your judgement to choose one of the proposed answers. You will always have two opportunities to play each game. Your score will be based on your answers in the second round of each game. You can view the first one as essentially as a trial round.

The first dialogue is a demonstration game. It does not produce a score. Here's a tip: don’t try to be perfect. Choose the answers that seem to you the most natural, the most logical in the context and the best formulated.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Instructions')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: Text(testInstructions)),
      ),
    );
  }
}
