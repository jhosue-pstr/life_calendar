class Activity {
  final int id;
  final int userId;
  final String title;
  final bool isDone;
  final DateTime date;
  final DateTime? createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.title,
    required this.isDone,
    required this.date,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      isDone: json['is_done'] ?? false,
      date: DateTime.parse(json['date']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'is_done': isDone,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  Activity copyWith({
    int? id,
    int? userId,
    String? title,
    bool? isDone,
    DateTime? date,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
