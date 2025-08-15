import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/registration_screen.dart';
import 'style/app_styles.dart';

void main() {
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
      
      // Better iOS performance
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
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// Beautiful splash screen with animations
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
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
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });
    
    // Start progress animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _progressController.forward();
    });
    
    // Navigate to registration after animations
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const RegistrationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
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
    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _logoRotateAnimation.value * 0.1,
                      child: Container(
                        width: 120,
                        height: 120,
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
                        child: const Icon(
                          Icons.psychology,
                          size: 60,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSizes.paddingXXLarge),
              
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
                          fontSize: 38,
                          letterSpacing: 2.0,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingMedium),
                      
                      Container(
                        height: 4,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.yellowGradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingLarge),
                      
                      Text(
                        'Develop Logic',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingSmall),
                      
                      Text(
                        'Earn Certificates',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingSmall),
                      
                      Text(
                        'Become Smarter!',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingXXLarge * 2),
              
              // Animated Progress Indicator
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 6,
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: AppColors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingMedium),
                      
                      Text(
                        'Loading...',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Temporary home screen (will be replaced later)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: const Text('Brain Road'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSizes.paddingLarge),
          padding: const EdgeInsets.all(AppSizes.paddingXLarge),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎉', style: TextStyle(fontSize: 60)),
              ),
              
              const SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Welcome!',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
              
              Text(
                'You have successfully registered for Brain Road! This will be the main screen of the app with quizzes and challenges.',
                style: AppTextStyles.bodyText.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingXLarge),
              
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    ),
                  );
                },
                style: AppButtonStyles.primaryButton,
                icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
                label: const Text(
                  'Back to Registration',
                  style: TextStyle(color: AppColors.darkBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}