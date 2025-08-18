import 'dart:convert';
import 'dart:ui';
import 'package:brain_road/constants/rewards_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/rewards_screen.dart';

/// Сервіс для роботи з користувацькими налаштуваннями
class UserPreferences {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';
  static const String _userAgeKey = 'user_age';
  static const String _registrationCompletedKey = 'registration_completed';
  static const String _rewardsKey = 'rewards';

  static SharedPreferences? _preferences;

  /// Ініціалізація SharedPreferences
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Перевірка чи це перший запуск програми
  static bool get isFirstLaunch {
    return _preferences?.getBool(_isFirstLaunchKey) ?? true;
  }

  /// Встановити що програма була запущена
  static Future<void> setFirstLaunchCompleted() async {
    await _preferences?.setBool(_isFirstLaunchKey, false);
  }

  /// Перевірка чи реєстрація завершена
  static bool get isRegistrationCompleted {
    return _preferences?.getBool(_registrationCompletedKey) ?? false;
  }

  /// Зберегти дані користувача після реєстрації
  static Future<void> saveUserData({
    required String name,
    required String avatar,
    required String age,
  }) async {
    await Future.wait([
      _preferences?.setString(_userNameKey, name) ?? Future.value(),
      _preferences?.setString(_userAvatarKey, avatar) ?? Future.value(),
      _preferences?.setString(_userAgeKey, age) ?? Future.value(),
      _preferences?.setBool(_registrationCompletedKey, true) ?? Future.value(),
    ]);
  }

  /// Отримати ім'я користувача
  static String get userName {
    return _preferences?.getString(_userNameKey) ?? '';
  }

  /// Отримати аватар користувача
  static String get userAvatar {
    return _preferences?.getString(_userAvatarKey) ?? '🐔';
  }

  /// Отримати вік користувача
  static String get userAge {
    return _preferences?.getString(_userAgeKey) ?? '';
  }

  /// Отримати лейбл вікового діапазону
  static String get userAgeLabel {
    final age = userAge;
    switch (age) {
      case '5-7':
        return '5-7 years';
      case '8-10':
        return '8-10 years';
      case '11-13':
        return '11-13 years';
      default:
        return 'Unknown';
    }
  }

  /// Перевірка чи всі дані користувача збережені
  static bool get hasUserData {
    return userName.isNotEmpty && 
           userAvatar.isNotEmpty && 
           userAge.isNotEmpty &&
           isRegistrationCompleted;
  }

 

  /// Оновити окремі дані користувача
  static Future<void> updateUserName(String name) async {
    await _preferences?.setString(_userNameKey, name);
  }

  static Future<void> updateUserAvatar(String avatar) async {
    await _preferences?.setString(_userAvatarKey, avatar);
  }

  static Future<void> updateUserAge(String age) async {
    await _preferences?.setString(_userAgeKey, age);
  }

  static Future<List<RewardData>> getRewards() async {
    try {
      final rewardsJson = _preferences?.getString(_rewardsKey);
      if (rewardsJson == null) return [];
      
      final List<dynamic> rewardsList = json.decode(rewardsJson);
      return rewardsList.map((json) => RewardData.fromJson(json)).toList();
    } catch (e) {
      print('Error loading rewards: $e');
      return [];
    }
  }

  static Future<void> addReward(RewardData reward) async {
    try {
      final currentRewards = await getRewards();
      currentRewards.add(reward);
      
      final rewardsJson = json.encode(
        currentRewards.map((r) => r.toJson()).toList()
      );
      
      await _preferences?.setString(_rewardsKey, rewardsJson);
    } catch (e) {
      print('Error adding reward: $e');
    }
  }

  static Future<void> updateReward(String rewardId, bool claimed) async {
    try {
      final currentRewards = await getRewards();
      final updatedRewards = currentRewards.map((reward) {
        if (reward.id == rewardId) {
          return reward.copyWith(claimed: claimed);
        }
        return reward;
      }).toList();
      
      final rewardsJson = json.encode(
        updatedRewards.map((r) => r.toJson()).toList()
      );
      
      await _preferences?.setString(_rewardsKey, rewardsJson);
    } catch (e) {
      print('Error updating reward: $e');
    }
  }

  static Future<void> clearRewards() async {
    try {
      await _preferences?.remove(_rewardsKey);
    } catch (e) {
      print('Error clearing rewards: $e');
    }
  }


  /// Отримати всі дані користувача як Map
  static Map<String, String> get userData {
    return {
      'name': userName,
      'avatar': userAvatar,
      'age': userAge,
      'ageLabel': userAgeLabel,
    };
  }

  /// Debugging метод для перегляду всіх збережених даних
  static Map<String, dynamic> get allStoredData {
    return {
      'isFirstLaunch': isFirstLaunch,
      'isRegistrationCompleted': isRegistrationCompleted,
      'userName': userName,
      'userAvatar': userAvatar,
      'userAge': userAge,
      'hasUserData': hasUserData,
    };
  }

  static Future<void> addRewardForCertificate(String certificateName) async {
    try {
      // Отримуємо винагороду з констант
      final reward = RewardsConstants.getRandomRewardForCategory(certificateName);
      
      if (reward != null) {
        await addReward(reward);
        print('✅ Reward added for certificate: $certificateName');
      } else {
        print('⚠️ No reward found for category: $certificateName');
        
        // Створюємо загальну винагороду якщо категорія не знайдена
        final fallbackReward = RewardData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Special Achievement Reward',
          partner: 'Brain Road Academy',
          description: 'Congratulations on your achievement!',
          emoji: '🏆',
          gradient: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
          claimed: false,
          certificateTrigger: certificateName,
        );
        
        await addReward(fallbackReward);
      }
      
    } catch (e) {
      print('❌ Error adding reward for certificate: $e');
    }
  }

  // Новий метод: отримання винагород по категоріях
  static Future<Map<String, List<RewardData>>> getRewardsByCategory() async {
    try {
      final allRewards = await getRewards();
      final Map<String, List<RewardData>> categorizedRewards = {};
      
      for (final reward in allRewards) {
        final category = reward.certificateTrigger;
        if (!categorizedRewards.containsKey(category)) {
          categorizedRewards[category] = [];
        }
        categorizedRewards[category]!.add(reward);
      }
      
      return categorizedRewards;
    } catch (e) {
      print('Error categorizing rewards: $e');
      return {};
    }
  }

  // Новий метод: отримання невикористаних винагород
  static Future<List<RewardData>> getUnclaimedRewards() async {
    try {
      final allRewards = await getRewards();
      return allRewards.where((reward) => !reward.claimed).toList();
    } catch (e) {
      print('Error getting unclaimed rewards: $e');
      return [];
    }
  }

  // Новий метод: отримання винагород за останній місяць
  static Future<List<RewardData>> getRecentRewards({int days = 30}) async {
    try {
      final allRewards = await getRewards();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      return allRewards.where((reward) {
        // Припускаємо, що ID містить timestamp
        try {
          final timestamp = int.parse(reward.id.split('_').last);
          final rewardDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return rewardDate.isAfter(cutoffDate);
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error getting recent rewards: $e');
      return [];
    }
  }

  // Новий метод: отримання статистики винагород
  static Future<Map<String, dynamic>> getRewardsStatistics() async {
    try {
      final allRewards = await getRewards();
      final unclaimedRewards = await getUnclaimedRewards();
      final recentRewards = await getRecentRewards();
      
      final partnerCounts = <String, int>{};
      for (final reward in allRewards) {
        partnerCounts[reward.partner] = (partnerCounts[reward.partner] ?? 0) + 1;
      }
      
      return {
        'total': allRewards.length,
        'unclaimed': unclaimedRewards.length,
        'claimed': allRewards.length - unclaimedRewards.length,
        'recent': recentRewards.length,
        'partners': partnerCounts.keys.length,
        'topPartner': partnerCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key,
        'partnerCounts': partnerCounts,
      };
    } catch (e) {
      print('Error getting rewards statistics: $e');
      return {
        'total': 0,
        'unclaimed': 0,
        'claimed': 0,
        'recent': 0,
        'partners': 0,
        'topPartner': 'None',
        'partnerCounts': <String, int>{},
      };
    }
  }

  // Новий метод: масове оновлення винагород
  static Future<void> updateMultipleRewards(List<String> rewardIds, bool claimed) async {
    try {
      final currentRewards = await getRewards();
      final updatedRewards = currentRewards.map((reward) {
        if (rewardIds.contains(reward.id)) {
          return reward.copyWith(claimed: claimed);
        }
        return reward;
      }).toList();
      
      final rewardsJson = json.encode(
        updatedRewards.map((r) => r.toJson()).toList()
      );
      
      await _preferences?.setString(_rewardsKey, rewardsJson);
    } catch (e) {
      print('Error updating multiple rewards: $e');
    }
  }

  // Новий метод: видалення старих винагород
  static Future<void> cleanupOldRewards({int daysToKeep = 365}) async {
    try {
      final allRewards = await getRewards();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final rewardsToKeep = allRewards.where((reward) {
        // Зберігаємо невикористані винагороди та нові
        if (!reward.claimed) return true;
        
        try {
          final timestamp = int.parse(reward.id.split('_').last);
          final rewardDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return rewardDate.isAfter(cutoffDate);
        } catch (e) {
          return true; // Зберігаємо якщо не можемо визначити дату
        }
      }).toList();
      
      final rewardsJson = json.encode(
        rewardsToKeep.map((r) => r.toJson()).toList()
      );
      
      await _preferences?.setString(_rewardsKey, rewardsJson);
      
      final removedCount = allRewards.length - rewardsToKeep.length;
      if (removedCount > 0) {
        print('🧹 Cleaned up $removedCount old rewards');
      }
      
    } catch (e) {
      print('Error cleaning up old rewards: $e');
    }
  }

  static Future<void> clearUserData() async {
    try {
      await _preferences?.clear();
      print('✅ All user data cleared');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }

  // Метод для експорту даних (для бекапу)
  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final rewards = await getRewards();
      final userName = await getUserName();
      final userAvatar = await getUserAvatar();
      final userAge = await getUserAge();
      
      return {
        'user': {
          'name': userName,
          'avatar': userAvatar,
          'age': userAge,
        },
        'rewards': rewards.map((r) => r.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  // Метод для імпорту даних (для відновлення)
  static Future<bool> importUserData(Map<String, dynamic> data) async {
    try {
      // Імпорт користувача
      if (data['user'] != null) {
        final user = data['user'];
        if (user['name'] != null) await saveUserData(
          name: user['name'],
          avatar: user['avatar'] ?? '🧠',
          age: user['age'] ?? '8-10',
        );
      }
      
      // Імпорт винагород
      if (data['rewards'] != null) {
        final rewardsData = data['rewards'] as List;
        final rewards = rewardsData.map((r) => RewardData.fromJson(r)).toList();
        
        final rewardsJson = json.encode(
          rewards.map((r) => r.toJson()).toList()
        );
        await _preferences?.setString(_rewardsKey, rewardsJson);
      }
      
      print('✅ User data imported successfully');
      return true;
    } catch (e) {
      print('❌ Error importing user data: $e');
      return false;
    }
  }
}
