class BadHabit {
  final int id;
  final int userId;
  final String name;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastRelapseDate;
  final DateTime? createdAt;

  BadHabit({
    required this.id,
    required this.userId,
    required this.name,
    required this.currentStreak,
    required this.longestStreak,
    this.lastRelapseDate,
    this.createdAt,
  });

  factory BadHabit.fromJson(Map<String, dynamic> json) {
    return BadHabit(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastRelapseDate: json['last_relapse_date'] != null
          ? DateTime.parse(json['last_relapse_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  BadHabit copyWith({
    int? id,
    int? userId,
    String? name,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastRelapseDate,
  }) {
    return BadHabit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastRelapseDate: lastRelapseDate ?? this.lastRelapseDate,
      createdAt: createdAt,
    );
  }
}
