import '../../../../shared/core/api_client.dart';
import '../../domain/models/goal.dart';

class GoalService {
  final ApiClient _apiClient;

  GoalService(this._apiClient);

  Future<List<Goal>> getGoals({bool activeOnly = false}) async {
    final response = await _apiClient.get(
      '/goals',
      queryParameters: activeOnly ? {'active_only': true} : null,
    );
    return (response.data as List).map((e) => Goal.fromJson(e)).toList();
  }

  Future<Goal> createGoal(
    String title,
    int targetDays,
    DateTime startDate,
  ) async {
    final response = await _apiClient.post(
      '/goals',
      data: {
        'title': title,
        'target_days': targetDays,
        'start_date': startDate.toIso8601String().split('T')[0],
      },
    );
    return Goal.fromJson(response.data);
  }

  Future<Goal> updateGoal(int id, {String? title, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _apiClient.put('/goals/$id', data: data);
    return Goal.fromJson(response.data);
  }

  Future<Goal> toggleGoalDay(
    int goalId,
    int dayNumber,
    bool isCompleted,
  ) async {
    final response = await _apiClient.patch(
      '/goals/$goalId/days',
      data: {'day_number': dayNumber, 'is_completed': isCompleted},
    );
    return Goal.fromJson(response.data);
  }

  Future<void> deleteGoal(int id) async {
    await _apiClient.delete('/goals/$id');
  }
}
