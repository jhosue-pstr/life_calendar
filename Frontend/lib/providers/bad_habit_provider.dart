import 'package:flutter/foundation.dart';
import '../services/bad_habit_service.dart';
import '../models/bad_habit.dart';

class BadHabitProvider extends ChangeNotifier {
  final BadHabitService _badHabitService;

  BadHabitProvider(this._badHabitService);

  List<BadHabit> _badHabits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BadHabit> get badHabits => _badHabits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _badHabits = await _badHabitService.getBadHabits();
    } catch (e) {
      _errorMessage = 'Failed to load bad habits';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBadHabit(String name) async {
    try {
      final habit = await _badHabitService.createBadHabit(name);
      _badHabits.insert(0, habit);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create bad habit';
      notifyListeners();
      return false;
    }
  }

  Future<bool> triggerRelapse(int id) async {
    try {
      final updatedHabit = await _badHabitService.triggerRelapse(id);
      final index = _badHabits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _badHabits[index] = updatedHabit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to trigger relapse';
      notifyListeners();
      return false;
    }
  }

  Future<bool> incrementStreak(int id) async {
    try {
      final updatedHabit = await _badHabitService.incrementStreak(id);
      final index = _badHabits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _badHabits[index] = updatedHabit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to increment streak';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBadHabit(int id) async {
    try {
      await _badHabitService.deleteBadHabit(id);
      _badHabits.removeWhere((h) => h.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete bad habit';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
