import 'package:flutter/foundation.dart';
import '../services/contribution_service.dart';
import '../models/contribution.dart';

class ContributionProvider extends ChangeNotifier {
  final ContributionService _contributionService;

  ContributionProvider(this._contributionService);

  List<Contribution> _contributions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Contribution> get contributions => _contributions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, Contribution> get contributionsMap {
    final map = <String, Contribution>{};
    for (final c in _contributions) {
      final key =
          '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-${c.date.day.toString().padLeft(2, '0')}';
      map[key] = c;
    }
    return map;
  }

  Future<void> loadContributions({int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (year != null) {
        _contributions = await _contributionService.getContributionsByYear(
          year,
        );
      } else {
        _contributions = await _contributionService.getContributions();
      }
    } catch (e) {
      _errorMessage = 'Failed to load contributions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContributionsForYear(int year) async {
    await loadContributions(year: year);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
