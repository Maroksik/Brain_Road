import 'dart:convert';
import 'dart:ui';
import 'package:think_and_solve/constants/rewards_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:think_and_solve/models/reward_data.dart';

class UserPreferences {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';
  static const String _userAgeKey = 'user_age';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _registrationCompletedKey = 'registration_completed';
  static const String _rewardsKey = 'rewards';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

 

  static bool get isFirstLaunch {
    if (_preferences == null) return true;
    return _preferences!.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> setFirstLaunchCompleted() async {
    await init();
    await _preferences?.setBool(_isFirstLaunchKey, false);
  }

  static bool get isRegistrationCompleted {
    if (_preferences == null) return false;
    return _preferences!.getBool(_registrationCompletedKey) ?? false;
  }

  static Future<void> saveUserData({
    required String name,
    required String avatar,
    required String age,
    required String email,
    required String password,
  }) async {
    await Future.wait([
      _preferences?.setString(_userNameKey, name) ?? Future.value(),
      _preferences?.setString(_userAvatarKey, avatar) ?? Future.value(),
      _preferences?.setString(_userAgeKey, age) ?? Future.value(),
      _preferences?.setString(_userEmailKey, email) ?? Future.value(),
      _preferences?.setString(_userPasswordKey, password) ?? Future.value(),
      _preferences?.setBool(_registrationCompletedKey, true) ?? Future.value(),
    ]);
  }

  static String get userName {
    return _preferences?.getString(_userNameKey) ?? 'Young Learner';
  }

  static String get userAvatar {
    return _preferences?.getString(_userAvatarKey) ?? '🐔';
  }

  static String get userAge {
    return _preferences?.getString(_userAgeKey) ?? '6-8';
  }

  static String get userEmail {
    return _preferences?.getString(_userEmailKey) ?? '';
  }

  static String get userPassword {
    return _preferences?.getString(_userPasswordKey) ?? '';
  }

  static String get userAgeLabel {
    final age = userAge;
    switch (age) {
      case '4-6': return 'Preschool';
      case '6-8': return 'Early Elementary';
      case '8-10': return 'Elementary';
      case '10-12': return 'Middle School';
      default: return 'Elementary';
    }
  }

  static bool get hasUserData {
    return userName.isNotEmpty && userAge.isNotEmpty;
  }

  // ВИНАГОРОДИ - ВИПРАВЛЕНІ МЕТОДИ
  static Future<List<RewardData>> getRewards() async {
    try {
      if (_preferences == null) await init();
      
      final rewardsString = _preferences?.getString(_rewardsKey) ?? '[]';
      final rewardsJson = json.decode(rewardsString) as List;
      
      return rewardsJson.map((reward) => RewardData.fromJson(reward)).toList();
    } catch (e) {
      print('Error loading rewards: $e');
      return [];
    }
  }

  static Future<void> addReward(RewardData reward) async {
    try {
      if (_preferences == null) await init();
      
      final currentRewards = await getRewards();
      
      // Перевіряємо чи такої винагороди ще немає
      final isDuplicate = currentRewards.any((r) => 
        r.title == reward.title && 
        r.certificateTrigger == reward.certificateTrigger
      );
      
      if (!isDuplicate) {
        currentRewards.add(reward);
        
        final rewardsJson = json.encode(
          currentRewards.map((r) => r.toJson()).toList()
        );
        
        await _preferences?.setString(_rewardsKey, rewardsJson);
        print('✅ Reward successfully added: ${reward.title}');
      } else {
        print('⚠️ Duplicate reward prevented: ${reward.title}');
      }
    } catch (e) {
      print('Error adding reward: $e');
    }
  }

  static Future<void> updateReward(String rewardId, bool claimed) async {
    try {
      if (_preferences == null) await init();
      
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
      print('✅ Reward updated: $rewardId, claimed: $claimed');
    } catch (e) {
      print('Error updating reward: $e');
    }
  }

  static Future<void> clearRewards() async {
    try {
      if (_preferences == null) await init();
      await _preferences?.remove(_rewardsKey);
      print('✅ All rewards cleared');
    } catch (e) {
      print('Error clearing rewards: $e');
    }
  }

  // ГОЛОВНИЙ МЕТОД - додає винагороду за сертифікат
  static Future<void> addRewardForCertificate(String certificateName) async {
    try {
      if (_preferences == null) await init();
      
      print('🎯 Adding reward for certificate: $certificateName');
      
      // Отримуємо винагороду з констант
      final reward = RewardsConstants.getRandomRewardForCategory(certificateName);
      
      if (reward != null) {
        await addReward(reward);
        print('✅ Reward added for certificate: $certificateName');
        print('🎁 Reward details: ${reward.title} from ${reward.partner}');
      } else {
        print('⚠️ No reward template found for category: $certificateName');
        
        // Створюємо загальну винагороду
        final fallbackReward = RewardData(
          id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Special Achievement Reward',
          partner: 'Think & Solve Academy',
          description: 'Congratulations on completing $certificateName!',
          emoji: '🏆',
          gradient: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
          claimed: false,
          certificateTrigger: certificateName,
        );
        
        await addReward(fallbackReward);
        print('✅ Fallback reward created for: $certificateName');
      }
      
    } catch (e) {
      print('❌ Error adding reward for certificate: $e');
      // Додаємо мінімальну винагороду навіть при помилці
      try {
        final emergencyReward = RewardData(
          id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Achievement Unlocked!',
          partner: 'Think & Solve',
          description: 'Great job completing the quiz!',
          emoji: '🌟',
          gradient: [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
          claimed: false,
          certificateTrigger: certificateName,
        );
        await addReward(emergencyReward);
        print('✅ Emergency reward added');
      } catch (emergencyError) {
        print('❌ Emergency reward failed: $emergencyError');
      }
    }
  }

  // Отримання всіх даних користувача
  static Map<String, String> get userData {
    return {
      'name': userName,
      'avatar': userAvatar,
      'age': userAge,
      'ageLabel': userAgeLabel,
      'email': userEmail,
    };
  }

  // Отримання невикористаних винагород
  static Future<List<RewardData>> getUnclaimedRewards() async {
    try {
      final allRewards = await getRewards();
      return allRewards.where((reward) => !reward.claimed).toList();
    } catch (e) {
      print('Error getting unclaimed rewards: $e');
      return [];
    }
  }

  // Отримання винагород по категоріях
  static Future<Map<String, List<RewardData>>> getRewardsByCategory() async {
    try {
      final allRewards = await getRewards();
      final Map<String, List<RewardData>> categorizedRewards = {};
      
      for (final reward in allRewards) {
        final category = reward.certificateTrigger ?? 'Other';
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

  // Статистика винагород
  static Future<Map<String, dynamic>> getRewardsStatistics() async {
    try {
      final allRewards = await getRewards();
      final unclaimedRewards = await getUnclaimedRewards();
      
      final partnerCounts = <String, int>{};
      for (final reward in allRewards) {
        partnerCounts[reward.partner] = (partnerCounts[reward.partner] ?? 0) + 1;
      }
      
      return {
        'total': allRewards.length,
        'unclaimed': unclaimedRewards.length,
        'claimed': allRewards.length - unclaimedRewards.length,
        'partners': partnerCounts.keys.length,
        'topPartner': partnerCounts.isNotEmpty 
          ? partnerCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'None',
      };
    } catch (e) {
      print('Error getting rewards statistics: $e');
      return {
        'total': 0,
        'unclaimed': 0,
        'claimed': 0,
        'partners': 0,
        'topPartner': 'None',
      };
    }
  }

  
}

