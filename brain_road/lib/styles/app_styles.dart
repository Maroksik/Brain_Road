import 'package:flutter/material.dart';

/// Клас з кольорами додатку Brain Road
class AppColors {
  // Основні кольори
  static const Color darkBlue = Color(0xFF3E4464);
  static const Color yellow = Color(0xFFFCC317);
  static const Color green = Color(0xFF3DC55C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF363B57);
  
  // Додаткові кольори для градієнтів та акцентів
  static const Color lightBlue = Color(0xFF4A5174);
  static const Color lightYellow = Color(0xFFFDD55F);
  static const Color lightGreen = Color(0xFF5DD072);
  static const Color lightGrey = Color(0xFF4A5068);
  
  // Кольори для статусів
  static const Color success = green;
  static const Color warning = yellow;
  static const Color error = Color(0xFFE53E3E);
  static const Color info = darkBlue;
  static const Color primary = darkBlue;
}

/// Клас з текстовими стилями
class AppTextStyles {
  // Заголовки
  static const TextStyle mainTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.yellow,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.black26,
        offset: Offset(2.0, 2.0),
      ),
    ],
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlue,
  );
  
  // Основний текст
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.white,
    fontWeight: FontWeight.w300,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.grey,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle bodyTextWhite = TextStyle(
    fontSize: 16,
    color: AppColors.white,
    fontWeight: FontWeight.w400,
  );
  
  // Кнопки
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  // Інпути
  static TextStyle inputText = TextStyle(
    color: AppColors.darkBlue,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle inputHint = TextStyle(
    color: AppColors.grey.withOpacity(0.6),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  // Малий текст
  static TextStyle caption = TextStyle(
    color: AppColors.white.withOpacity(0.8),
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );
  
  static const TextStyle captionBold = TextStyle(
    color: AppColors.grey,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

/// Клас з розмірами та відступами
class AppSizes {
  // Радіуси
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 15.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 25.0;
  
  // Відступи
  static const double paddingXSmall = 5.0;
  static const double paddingSmall = 10.0;
  static const double paddingMedium = 15.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 25.0;
  static const double paddingXXLarge = 30.0;
  
  // Розміри елементів
  static const double buttonHeight = 55.0;
  static const double buttonHeightSmall = 40.0;
  static const double inputHeight = 55.0;
  static const double avatarSize = 60.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Тіні
  static const double elevationLow = 2.0;
  static const double elevationMedium = 8.0;
  static const double elevationHigh = 16.0;
}

/// Клас з декораціями та стилями контейнерів
class AppDecorations {
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  static final BoxDecoration smallCardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  // Інпути
  static InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.inputHint,
    filled: true,
    fillColor: AppColors.grey.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      borderSide: const BorderSide(color: AppColors.green, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingLarge,
      vertical: AppSizes.paddingMedium,
    ),
  );
  
  // Вибрані елементи
  static BoxDecoration selectedDecoration = BoxDecoration(
    color: AppColors.yellow,
    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    border: Border.all(
      color: AppColors.green,
      width: 2,
    ),
  );
  
  static BoxDecoration unselectedDecoration = BoxDecoration(
    color: AppColors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    border: Border.all(
      color: AppColors.grey.withOpacity(0.3),
      width: 2,
    ),
  );
  
  // Кнопки-чипи
  static BoxDecoration selectedChipDecoration = BoxDecoration(
    color: AppColors.green,
    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    border: Border.all(
      color: AppColors.green,
      width: 2,
    ),
  );
  
  static BoxDecoration unselectedChipDecoration = BoxDecoration(
    color: AppColors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    border: Border.all(
      color: AppColors.grey.withOpacity(0.3),
      width: 2,
    ),
  );
}

/// Клас з стилями кнопок
class AppButtonStyles {
  // Основна кнопка
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.yellow,
    foregroundColor: AppColors.darkBlue,
    elevation: AppSizes.elevationMedium,
    shadowColor: AppColors.yellow.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    ),
    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
  );
  
  // ДОДАЄМО secondaryButton (він був null!)
  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.grey.withOpacity(0.2),
    foregroundColor: AppColors.darkBlue,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    ),
    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
  );
  
  // Вимкнена кнопка
  static ButtonStyle disabledButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.grey.withOpacity(0.3),
    foregroundColor: AppColors.grey.withOpacity(0.6),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    ),
    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
  );
  
  // Зелена кнопка
  static ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.green,
    foregroundColor: AppColors.white,
    elevation: AppSizes.elevationMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    ),
  );
  
  // Мала кнопка
  static ButtonStyle smallButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.yellow,
    foregroundColor: AppColors.darkBlue,
    elevation: AppSizes.elevationLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    ),
    minimumSize: const Size(0, AppSizes.buttonHeightSmall),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingLarge,
      vertical: AppSizes.paddingSmall,
    ),
  );
}

/// Клас з анімаціями
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 1000);
  static const Duration verySlow = Duration(milliseconds: 1500);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
}

/// Допоміжні методи для роботи з темою
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'SF Pro Display',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.darkBlue,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
  );
  
  // Градієнти
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.darkBlue, AppColors.lightBlue],
  );
  
  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.yellow, AppColors.lightYellow],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.green, AppColors.lightGreen],
  );
}