import 'package:brain_road/screen/brain_road_certificates_screen.dart';
import 'package:brain_road/screen/brain_road_quizzes_list_screen.dart';
import 'package:brain_road/screen/partners_screen.dart';
import 'package:brain_road/screen/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/welcome_screen.dart';
import 'screen/main_menu_screen.dart';
import 'style/app_styles.dart';
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
        '/quizzes': (context) => const BrainRoadQuizzesScreen(),
      },
    );
  }
}

/// Beautiful splash screen with animations optimized for iOS
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() {
    // Start logo animation
    _logoController.forward();
    
    // Start text animation after delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
    
    // Start progress animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _progressController.forward();
    });
    
    // Navigate to appropriate screen after animations
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
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
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area for iOS notch handling
    final safeArea = MediaQuery.of(context).padding;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBlue,
              Color(0xFF2A3B5C),
              AppColors.darkBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: safeArea.top > 0 ? AppSizes.paddingMedium : AppSizes.paddingLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value * 0.1,
                        child: Container(
                          width: screenWidth * 0.25, // Responsive size
                          height: screenWidth * 0.25,
                          constraints: const BoxConstraints(
                            minWidth: 100,
                            maxWidth: 140,
                            minHeight: 100,
                            maxHeight: 140,
                          ),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppColors.yellow,
                                AppColors.yellow.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.yellow.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppColors.yellow.withOpacity(0.2),
                                blurRadius: 50,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: screenWidth * 0.12,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: screenHeight * 0.05),
                
                // Animated Text
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Brain Road',
                          style: AppTextStyles.mainTitle.copyWith(
                            fontSize: screenWidth * 0.09,
                            letterSpacing: 2.0,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                        
                        Container(
                          height: 4,
                          width: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            gradient: AppTheme.yellowGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        Text(
                          'Develop your logic',
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.01),
                        
                        Text(
                          'Receive certificates',
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.01),
                        
                        Text(
                          'Become smarter!',
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Animated Progress Indicator
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.5,
                          height: 6,
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: AppColors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellow),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                        
                        Text(
                          'Loading...',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                SizedBox(height: safeArea.bottom > 0 ? AppSizes.paddingLarge : AppSizes.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}