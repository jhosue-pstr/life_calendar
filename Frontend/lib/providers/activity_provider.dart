import 'package:flutter/foundation.dart';
import '../services/activity_service.dart';
import '../models/activity.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;

  ActivityProvider(this._activityService);

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Activity> get todayActivities {
    final today = DateTime.now();
    return _activities.where((a) {
      return a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day;
    }).toList();
  }

  Future<void> loadActivities({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _activityService.getActivities(date: date);
    } catch (e) {
      _errorMessage = 'Failed to load activities';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createActivity(String title, DateTime date) async {
    try {
      final activity = await _activityService.createActivity(title, date);
      _activities.insert(0, activity);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create activity';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActivity(Activity activity) async {
    try {
      final updated = await _activityService.updateActivity(
        activity.id,
        isDone: !activity.isDone,
      );
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update activity';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteActivity(int id) async {
    try {
      await _activityService.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete activity';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
