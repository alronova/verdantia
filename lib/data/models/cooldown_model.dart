import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdantia/core/utils/garden_utils.dart';

class CooldownManager {
  static const _prefix = 'lastAction_';

  /// Save the last timestamp of a plant's action
  static Future<void> setLastActionTime(
      String plantName, PlantAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${plantName}_${action.name}';
    prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the last action timestamp
  static Future<DateTime?> getLastActionTime(
      String plantName, PlantAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${plantName}_${action.name}';
    final millis = prefs.getInt(key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Check if cooldown has passed (5 hours)
  static Future<bool> isOnCooldown(String plantName, PlantAction action) async {
    final last = await getLastActionTime(plantName, action);
    if (last == null) return false;
    return DateTime.now().difference(last) < const Duration(hours: 5);
  }

  /// Get remaining cooldown duration
  static Future<Duration?> getRemainingCooldown(
      String plantName, PlantAction action) async {
    final last = await getLastActionTime(plantName, action);
    if (last == null) return null;
    final passed = DateTime.now().difference(last);
    final remaining = const Duration(hours: 5) - passed;
    return remaining.isNegative ? null : remaining;
  }
}
