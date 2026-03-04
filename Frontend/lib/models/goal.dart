class GoalDay {
  final int id;
  final int goalId;
  final int dayNumber;
  final bool isCompleted;
  final DateTime? completedAt;

  GoalDay({
    required this.id,
    required this.goalId,
    required this.dayNumber,
    required this.isCompleted,
    this.completedAt,
  });

  factory GoalDay.fromJson(Map<String, dynamic> json) {
    return GoalDay(
      id: json['id'],
      goalId: json['goal_id'],
      dayNumber: json['day_number'],
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'day_number': dayNumber,
      'is_completed': isCompleted,
    };
  }
}

class Goal {
  final int id;
  final int userId;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final bool isActive;
  final DateTime? createdAt;
  final List<GoalDay> goalDays;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetDays,
    required this.startDate,
    required this.isActive,
    this.createdAt,
    this.goalDays = const [],
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      targetDays: json['target_days'],
      startDate: DateTime.parse(json['start_date']),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      goalDays: json['goal_days'] != null
          ? (json['goal_days'] as List).map((e) => GoalDay.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_days': targetDays,
      'start_date': startDate.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    int? targetDays,
    DateTime? startDate,
    bool? isActive,
    List<GoalDay>? goalDays,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      goalDays: goalDays ?? this.goalDays,
    );
  }
}
