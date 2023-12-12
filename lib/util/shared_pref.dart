import 'package:shared_preferences/shared_preferences.dart';

class LocalMemory {
  static Future setPlayerOScore(int score) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("oScore", score);
    });
  }

  static Future setPlayerXScore(int score) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("xScore", score);
    });
  }

  static Future<int> getPlayerOScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int score = prefs.getInt("oScore") ?? 0;
    return score;
  }

  static Future<int> getPlayerXScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int score = prefs.getInt("xScore") ?? 0;
    return score;
  }

  static Future resetScores() async {
    await setPlayerOScore(0);
    await setPlayerXScore(0);
  }
}
