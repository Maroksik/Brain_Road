import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
import '../services/user_preferences.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _logoScaleAnimation;
  
  int _currentPage = 0;
  late PageController _pageController;

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      icon: '🧠',
      title: 'Develop your logic',
      subtitle: 'Interesting and effective',
      description: 'Brain Road helps children develop logical thinking through engaging tasks and puzzles.',
      gradient: [AppColors.yellow, AppColors.lightYellow],
    ),
    WelcomePageData(
      icon: '🎯',
      title: 'Interesting tasks',
      subtitle: 'New challenges every day',
      description: 'A variety of logical tasks that adapt to the child\'s age and level.',
      gradient: [AppColors.green, AppColors.lightGreen],
    ),
    WelcomePageData(
      icon: '🏆',
      title: 'Get certificates',
      subtitle: 'Rewards for achievements',
      description: 'For good results, receive certificates in gaming centers from our partners!',
      gradient: [AppColors.darkBlue, AppColors.lightBlue],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));
    
    // Continuous floating animation
    _floatController.repeat(reverse: true);
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRegistration();
    }
    HapticFeedback.lightImpact();
  }

  void _navigateToRegistration() {
    // Позначаємо що перший запуск завершений
    UserPreferences.setFirstLaunchCompleted();
    
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
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _logoScaleAnimation,
        child: Column(
          children: [
            // Floating logo
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 5 * _floatAnimation.value),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.yellow.withOpacity(0.3),
                          AppColors.yellow.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.yellow.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 30,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: AppSizes.paddingLarge),
            
            Text(
              'Brain Road',
              style: AppTextStyles.mainTitle.copyWith(
                fontSize: 32,
                letterSpacing: 1.0,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingSmall),
            
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Expanded(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              HapticFeedback.selectionClick();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                          child: Column(
                            children: [
                              // Header with gradient
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: page.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    page.icon,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                              ),
                              
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        page.title,
                                        style: AppTextStyles.sectionTitle.copyWith(
                                          fontSize: 24,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      const SizedBox(height: AppSizes.paddingSmall),
                                      
                                      Text(
                                        page.subtitle,
                                        style: AppTextStyles.bodyText.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: page.gradient[0],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      const SizedBox(height: AppSizes.paddingLarge),
                                      
                                      Container(
                                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                        decoration: BoxDecoration(
                                          color: AppColors.grey.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                        ),
                                        child: Text(
                                          page.description,
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      
                                      // Special certificate highlight for last page
                                      if (index == _pages.length - 1) ...[
                                        const SizedBox(height: AppSizes.paddingLarge),
                                        Container(
                                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.yellow.withOpacity(0.1),
                                                AppColors.green.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                            border: Border.all(
                                              color: AppColors.yellow.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('🎁', style: TextStyle(fontSize: 24)),
                                              const SizedBox(width: AppSizes.paddingSmall),
                                              Expanded(
                                                child: Text(
                                                  'Free certificates for gaming centres!',
                                                  style: AppTextStyles.captionBold.copyWith(
                                                    color: AppColors.darkBlue,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index 
                  ? AppColors.yellow 
                  : AppColors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.paddingLarge,
          right: AppSizes.paddingLarge,
          bottom: MediaQuery.of(context).padding.bottom + AppSizes.paddingLarge,
        ),
        child: Row(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: _navigateToRegistration,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                    vertical: AppSizes.paddingMedium,
                  ),
                ),
                child: const Text('Skip'),
              )
            else
              const SizedBox(width: 80),
            
            const Spacer(),
            
            // Next/Start button
            Container(
              decoration: BoxDecoration(
                gradient: _currentPage == _pages.length - 1
                    ? AppTheme.greenGradient
                    : AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: (_currentPage == _pages.length - 1 
                        ? AppColors.green 
                        : AppColors.yellow).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXLarge,
                    vertical: AppSizes.paddingMedium,
                  ),
                ),
                icon: Icon(
                  _currentPage == _pages.length - 1 
                      ? Icons.rocket_launch 
                      : Icons.arrow_forward,
                ),
                label: Text(
                  _currentPage == _pages.length - 1 
                      ? 'Почати!' 
                      : 'Далі',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBlue,
              Color(0xFF2A3B5C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: AppSizes.paddingXLarge),
              
              // Page content
              _buildPageContent(),
              
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Page indicator
              _buildPageIndicator(),
              
              const SizedBox(height: AppSizes.paddingXLarge),
              
              // Bottom buttons
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePageData {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradient;

  WelcomePageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
  });
}