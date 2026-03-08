import 'package:think_and_solve/screens/brain_road_certificates_screen.dart';
import 'package:think_and_solve/screens/brain_road_quizzes_list_screen.dart';
import 'package:think_and_solve/screens/partners_screen.dart';
import 'package:think_and_solve/screens/registration_screen.dart';
import 'package:think_and_solve/screens/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_menu_screen.dart';
import 'styles/app_styles.dart';
import 'services/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  runApp(const BrainRoadApp());
}

class BrainRoadApp extends StatelessWidget {
  const BrainRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final Widget home;
    if (UserPreferences.hasUserData && UserPreferences.isRegistrationCompleted) {
      final userData = UserPreferences.userData;
      home = MainMenuScreen(
        userName: userData['name']!,
        userAvatar: userData['avatar']!,
        userAge: userData['ageLabel']!,
      );
    } else {
      home = const WelcomeScreen();
    }

    return MaterialApp(
      title: 'Think & Solve: Mind Puzzles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
      home: home,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/partners': (context) => const PartnersScreen(),
        '/certificates': (context) => const BrainRoadCertificatesScreen(),
        '/quizzes': (context) => const BrainRoadQuizzesListScreen(),
        '/rewards': (context) => const RewardsScreen(),
      },
    );
  }
}
