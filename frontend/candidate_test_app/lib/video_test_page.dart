import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:convert';

class VideoTestPage extends StatefulWidget {
  @override
  _VideoTestPageState createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  late VideoPlayerController _controller;
  Timer? _timer;
  List<DialogPoint> dialogPoints = [];
  DialogPoint? currentDialog;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    // Use asset video instead of a network link.
    _controller = VideoPlayerController.asset('assets/GAME4_o.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
          _checkDialogPoint();
        });
      });

    _loadDialogPoints();
  }

  Future<void> _loadDialogPoints() async {
    // For demonstration, we load a hard-coded list. In practice, you could fetch this from your backend.
    String jsonString = '''
    [
      {
        "time": 5,
        "question": "Do you want to play a game?",
        "options": [
          { "text": "Yes", "next": 10, "points": 1 },
          { "text": "No", "next": -1, "points": 0 }
        ]
      },
      {
        "time": 10,
        "question": "Great! Let’s start. Ready?",
        "options": [
          { "text": "Yes, I'm ready", "next": -1, "points": 2 },
          { "text": "Not yet", "next": -1, "points": 0 }
        ]
      }
    ]
    ''';
    List<dynamic> data = json.decode(jsonString);
    setState(() {
      dialogPoints = data.map((d) => DialogPoint.fromJson(d)).toList();
    });
  }

  void _checkDialogPoint() {
    if (!_controller.value.isInitialized) return;
    final currentTime = _controller.value.position.inSeconds;
    final point = dialogPoints.firstWhere(
      (dp) => (dp.time - currentTime).abs() <= 1,
      orElse: () => DialogPoint(time: -1, question: "", options: []),
    );
    if (point.time != -1 && currentDialog == null) {
      setState(() {
        currentDialog = point;
      });
    }
  }

  void _selectOption(DialogOption option) {
    totalScore += option.points;
    if (option.next > 0) {
      _controller.seekTo(Duration(seconds: option.next));
    }
    setState(() {
      currentDialog = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Video"),
      ),
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : CircularProgressIndicator(),
          ),
          if (currentDialog != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentDialog!.question,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    ...currentDialog!.options.map((option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            onPressed: () => _selectOption(option),
                            child: Text(option.text),
                          ),
                        ))
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class DialogPoint {
  final int time;
  final String question;
  final List<DialogOption> options;

  DialogPoint({required this.time, required this.question, required this.options});

  factory DialogPoint.fromJson(Map<String, dynamic> json) {
    var optionsJson = json['options'] as List;
    List<DialogOption> optionsList =
        optionsJson.map((o) => DialogOption.fromJson(o)).toList();
    return DialogPoint(
      time: json['time'],
      question: json['question'],
      options: optionsList,
    );
  }
}

class DialogOption {
  final String text;
  final int next;
  final int points;

  DialogOption({required this.text, required this.next, required this.points});

  factory DialogOption.fromJson(Map<String, dynamic> json) {
    return DialogOption(
      text: json['text'],
      next: json['next'],
      points: json['points'],
    );
  }
}
