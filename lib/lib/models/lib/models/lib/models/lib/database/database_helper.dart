import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subject.dart';
import '../models/study_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'study_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        totalStudyTime INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE study_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        FOREIGN KEY (subjectId) REFERENCES subjects (id)
      )
    ''');
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await _db;
    return await db.insert('subjects', subject.toMap());
  }

  Future<List<Subject>> getSubjects() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  Future<void> updateSubjectTotalTime(int subjectId, int duration) async {
    final db = await _db;
    await db.rawUpdate(
      'UPDATE subjects SET totalStudyTime = totalStudyTime + ? WHERE id = ?',
      [duration, subjectId],
    );
  }

  Future<int> insertStudySession(StudySession session) async {
    final db = await _db;
    final int id = await db.insert('study_sessions', session.toMap());
    await updateSubjectTotalTime(session.subjectId, session.duration);
    return id;
  }

  Future<List<StudySession>> getStudySessionsForSubject(int subjectId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db
        .query('study_sessions', where: 'subjectId = ?', whereArgs: [subjectId]);
    return List.generate(maps.length, (i) => StudySession.fromMap(maps[i]));
  }
}
