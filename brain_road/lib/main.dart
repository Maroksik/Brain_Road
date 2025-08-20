import 'package:brain_road/screens/brain_road_certificates_screen.dart';
import 'package:brain_road/screens/brain_road_quizzes_list_screen.dart';
import 'package:brain_road/screens/partners_screen.dart';
import 'package:brain_road/screens/registration_screen.dart';
import 'package:brain_road/screens/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_menu_screen.dart';
import 'styles/app_styles.dart';
import 'services/user_preferences.dart';

void main() async {
  // Забезпечуємо ініціалізацію Flutter widgets
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ініціалізуємо SharedPreferences
  await UserPreferences.init();
  
  runApp(const BrainRoadApp());
}

class BrainRoadApp extends StatelessWidget {
  const BrainRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    // iOS status bar configuration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Brain Road',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Better iOS performance and accessibility
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
      
      home: const SplashScreen(),
      
      // App routes
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

/// Простий splash screen тільки з фоновим зображенням
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Ініціалізуємо preferences
    await UserPreferences.init();
    
    // Чекаємо 2 секунди для показу splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Перевіряємо чи користувач вже зареєстрований
    if (UserPreferences.hasUserData && UserPreferences.isRegistrationCompleted) {
      // Якщо так - переходимо до головного меню
      final userData = UserPreferences.userData;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              MainMenuScreen(
                userName: userData['name']!,
                userAvatar: userData['avatar']!,
                userAge: userData['ageLabel']!,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // Якщо ні - переходимо до welcome screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}