class StudySession {
  final int? id;
  final int subjectId;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;

  StudySession({
    this.id,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      subjectId: map['subjectId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      duration: map['duration'],
    );
  }
}
