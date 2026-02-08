import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_model.dart';

class TimerService {
  static const String key = "activeTimers";

  static Future<List<RunningTimer>> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) return [];

    List<dynamic> list = jsonDecode(data);
    return list.map((e) => RunningTimer.fromJson(e)).toList();
  }

  static Future<void> saveTimers(List<RunningTimer> timers) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> list =
        timers.map((e) => e.toJson()).toList();

    await prefs.setString(key, jsonEncode(list));
  }

  static Future<void> addTimer(RunningTimer timer) async {
    final timers = await loadTimers();
    timers.add(timer);
    await saveTimers(timers);
  }

  static Future<void> clearTimers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> removeTimer(int index) async {
    final timers = await loadTimers();
    if (index >= 0 && index < timers.length) {
      timers.removeAt(index);
      await saveTimers(timers);
    }
  }

  static Future<void> removeTimerByRecipe(String recipeTitle, int stepIndex) async {
    final timers = await loadTimers();
    timers.removeWhere((t) => t.recipeTitle == recipeTitle && t.stepIndex == stepIndex);
    await saveTimers(timers);
  }
}
