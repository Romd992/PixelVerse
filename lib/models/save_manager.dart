import 'package:shared_preferences/shared_preferences.dart';

/// 存档管理器
///
/// 使用 shared_preferences 持久化：最高分、已解锁关卡数、总击杀数。
/// 在 main() 中调用 [init] 初始化后即可使用静态方法读写。
class SaveManager {
  static SharedPreferences? _prefs;

  static const String _keyHighScore = 'pv_high_score';
  static const String _keyUnlockedLevels = 'pv_unlocked_levels';
  static const String _keyTotalKills = 'pv_total_kills';
  static const String _keyVolume = 'pv_volume';

  /// 初始化（必须在 runApp 前调用）
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('SaveManager.init() 未调用');
    }
    return _prefs!;
  }

  // ==================== 最高分 ====================

  static int get highScore => _p.getInt(_keyHighScore) ?? 0;

  /// 如果超过历史最高分则更新，返回是否为新纪录
  static bool submitScore(int score) {
    if (score > highScore) {
      _p.setInt(_keyHighScore, score);
      return true;
    }
    return false;
  }

  // ==================== 关卡解锁 ====================

  /// 已解锁关卡数（1~3），默认解锁第1关
  static int get unlockedLevels => _p.getInt(_keyUnlockedLevels) ?? 1;

  /// 解锁指定关卡（index 从 0 开始），实际存储为关卡数
  static void unlockLevel(int index) {
    final levels = index + 1; // 解锁到第 index+1 关
    if (levels > unlockedLevels) {
      _p.setInt(_keyUnlockedLevels, levels.clamp(1, 3));
    }
  }

  /// 某关卡是否已解锁
  static bool isLevelUnlocked(int index) => index < unlockedLevels;

  // ==================== 总击杀 ====================

  static int get totalKills => _p.getInt(_keyTotalKills) ?? 0;

  static void addKills(int n) {
    _p.setInt(_keyTotalKills, totalKills + n);
  }

  // ==================== 设置（音量占位） ====================

  static double get volume => _p.getDouble(_keyVolume) ?? 0.7;

  static set volume(double v) => _p.setDouble(_keyVolume, v.clamp(0.0, 1.0));
}
