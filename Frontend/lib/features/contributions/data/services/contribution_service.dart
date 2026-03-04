import '../../../../shared/core/api_client.dart';
import '../../domain/models/contribution.dart';

class ContributionService {
  final ApiClient _apiClient;

  ContributionService(this._apiClient);

  Future<List<Contribution>> getContributions({int? year}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) {
      queryParams['year'] = year;
    }

    final response = await _apiClient.get(
      '/contributions',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List)
        .map((e) => Contribution.fromJson(e))
        .toList();
  }

  Future<List<Contribution>> getContributionsByYear(int year) async {
    final response = await _apiClient.get('/contributions/year/$year');
    return (response.data['contributions'] as List)
        .map((e) => Contribution.fromJson(e))
        .toList();
  }
}
