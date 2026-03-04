import 'package:flutter/foundation.dart';
import '../../data/services/goal_service.dart';
import '../../domain/models/goal.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService;

  GoalProvider(this._goalService);

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGoals({bool activeOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _goalService.getGoals(activeOnly: activeOnly);
    } catch (e) {
      _errorMessage = 'Failed to load goals';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal(
    String title,
    int targetDays,
    DateTime startDate,
  ) async {
    try {
      final goal = await _goalService.createGoal(title, targetDays, startDate);
      _goals.insert(0, goal);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create goal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleGoalDay(
    int goalId,
    int dayNumber,
    bool isCompleted,
  ) async {
    try {
      final updatedGoal = await _goalService.toggleGoalDay(
        goalId,
        dayNumber,
        isCompleted,
      );
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update goal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(int id) async {
    try {
      await _goalService.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete goal';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
