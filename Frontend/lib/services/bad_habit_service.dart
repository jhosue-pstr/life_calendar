import 'api_client.dart';
import '../models/bad_habit.dart';

class BadHabitService {
  final ApiClient _apiClient;

  BadHabitService(this._apiClient);

  Future<List<BadHabit>> getBadHabits() async {
    final response = await _apiClient.get('/bad-habits');
    return (response.data as List).map((e) => BadHabit.fromJson(e)).toList();
  }

  Future<BadHabit> createBadHabit(String name) async {
    final response = await _apiClient.post('/bad-habits', data: {'name': name});
    return BadHabit.fromJson(response.data);
  }

  Future<BadHabit> updateBadHabit(int id, String name) async {
    final response = await _apiClient.put(
      '/bad-habits/$id',
      data: {'name': name},
    );
    return BadHabit.fromJson(response.data);
  }

  Future<BadHabit> triggerRelapse(int id) async {
    final response = await _apiClient.post('/bad-habits/$id/relapse');
    return BadHabit.fromJson(response.data);
  }

  Future<BadHabit> incrementStreak(int id) async {
    final response = await _apiClient.post('/bad-habits/$id/increment');
    return BadHabit.fromJson(response.data);
  }

  Future<void> deleteBadHabit(int id) async {
    await _apiClient.delete('/bad-habits/$id');
  }
}
