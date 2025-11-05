import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Subject> _subjects = [];
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _dbHelper.getSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _addSubject() async {
    if (_subjectController.text.isNotEmpty) {
      final subject = Subject(
        name: _subjectController.text,
        color: Colors.primaries[_subjects.length % Colors.primaries.length].value.toRadixString(16),
      );
      await _dbHelper.insertSubject(subject);
      _subjectController.clear();
      _loadSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'New Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubject,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(subject.color, radix: 16)),
                  ),
                  title: Text(subject.name),
                  subtitle: Text('Total: ${subject.totalStudyTime} mins'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to subject detail
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
