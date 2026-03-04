class Contribution {
  final int id;
  final int userId;
  final DateTime date;
  final int level;

  Contribution({
    required this.id,
    required this.userId,
    required this.date,
    required this.level,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      level: json['level'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'level': level,
    };
  }
}
