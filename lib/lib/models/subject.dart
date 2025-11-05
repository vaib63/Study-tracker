class Subject {
  final int? id;
  final String name;
  final String color;
  final int totalStudyTime;

  Subject({
    this.id,
    required this.name,
    required this.color,
    this.totalStudyTime = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'totalStudyTime': totalStudyTime,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      totalStudyTime: map['totalStudyTime'],
    );
  }
}
