import 'api_client.dart';
import '../models/activity.dart';

class ActivityService {
  final ApiClient _apiClient;

  ActivityService(this._apiClient);

  Future<List<Activity>> getActivities({DateTime? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) {
      queryParams['date_filter'] = date.toIso8601String().split('T')[0];
    }

    final response = await _apiClient.get(
      '/activities',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List).map((e) => Activity.fromJson(e)).toList();
  }

  Future<Activity> createActivity(String title, DateTime date) async {
    final response = await _apiClient.post(
      '/activities',
      data: {'title': title, 'date': date.toIso8601String().split('T')[0]},
    );
    return Activity.fromJson(response.data);
  }

  Future<Activity> updateActivity(int id, {String? title, bool? isDone}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (isDone != null) data['is_done'] = isDone;

    final response = await _apiClient.put('/activities/$id', data: data);
    return Activity.fromJson(response.data);
  }

  Future<void> deleteActivity(int id) async {
    await _apiClient.delete('/activities/$id');
  }
}
