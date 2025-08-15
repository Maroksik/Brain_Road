import 'package:shared_preferences/shared_preferences.dart';

/// Сервіс для роботи з користувацькими налаштуваннями
class UserPreferences {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';
  static const String _userAgeKey = 'user_age';
  static const String _registrationCompletedKey = 'registration_completed';

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

  /// Очистити всі дані користувача (для тестування або скидання)
  static Future<void> clearUserData() async {
    await Future.wait([
      _preferences?.remove(_userNameKey) ?? Future.value(),
      _preferences?.remove(_userAvatarKey) ?? Future.value(),
      _preferences?.remove(_userAgeKey) ?? Future.value(),
      _preferences?.remove(_registrationCompletedKey) ?? Future.value(),
      _preferences?.setBool(_isFirstLaunchKey, true) ?? Future.value(),
    ]);
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
}