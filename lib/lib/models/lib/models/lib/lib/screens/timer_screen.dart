import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/study_session.dart';

class TimerScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const TimerScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _seconds = 0;
  bool _isRunning = false;
  late Stopwatch _stopwatch;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadTimer();
  }

  Future<void> _loadTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSeconds = prefs.getInt('timer_${widget.subjectId}') ?? 0;
    setState(() {
      _seconds = savedSeconds;
    });
  }

  Future<void> _saveTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_${widget.subjectId}', _seconds);
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _startTime = DateTime.now();
      });
      _stopwatch.start();
      _timerTick();
    }
  }

  void _stopTimer() {
    if (_isRunning) {
      setState(() {
        _isRunning = false;
      });
      _stopwatch.stop();
      _saveTimer();
      _saveSession();
    }
  }

  void _timerTick() {
    if (_isRunning) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRunning) {
          setState(() {
            _seconds++;
          });
          _timerTick();
        }
      });
    }
  }

  Future<void> _saveSession() async {
    if (_startTime != null) {
      final session = StudySession(
        subjectId: widget.subjectId,
        startTime: _startTime!,
        endTime: DateTime.now(),
        duration: _seconds ~/ 60,
      );
      await _dbHelper.insertStudySession(session);
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_seconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
