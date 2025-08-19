import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/app_styles.dart';
import '../services/user_preferences.dart';

class MainMenuScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final String userAge;

  const MainMenuScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.userAge,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Menu items data
  final List<MenuItemData> _menuItems = [
    MenuItemData(
      icon: Icons.workspace_premium,
      title: 'My certificates',
      subtitle: 'View achievements',
      emoji: '🏆',
      gradient: [AppColors.yellow, AppColors.lightYellow],
      route: '/certificates',
    ),
    MenuItemData(
      icon: Icons.handshake,
      title: 'Our partners',
      subtitle: 'Where to visit',
      emoji: '🤝',
      gradient: [AppColors.green, AppColors.lightGreen],
      route: '/partners',
    ),
    MenuItemData(
      icon: Icons.quiz,
      title: 'Quizzes',
      subtitle: 'Develop your logic',
      emoji: '🧩',
      gradient: [AppColors.darkBlue, AppColors.lightBlue],
      route: '/quizzes',
    ),
    MenuItemData(
      icon: Icons.card_giftcard,
      title: 'Rewards',
      subtitle: 'Your prizes',
      emoji: '🎁',
      gradient: [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
      route: '/rewards',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bounceController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _floatController.repeat(reverse: true);
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBlue,
              AppColors.lightBlue.withOpacity(0.8),
              AppColors.darkBlue,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating background elements
            ...List.generate(6, (index) => _buildFloatingElement(index)),
            
            // Main content
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isLandscape ? AppSizes.paddingSmall : AppSizes.paddingLarge),
                    
                    // Header with user info
                    _buildModernHeader(),
                    
                    SizedBox(height: isLandscape ? AppSizes.paddingLarge : AppSizes.paddingXXLarge),
                    
                    // Menu title with modern styling
                    _buildMenuTitle(),
                    
                    SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),
                    
                    // Menu items grid with modern cards
                    Expanded(
                      child: _buildModernMenuGrid(),
                    ),
                    
                    SizedBox(height: safeAreaBottom > 0 ? safeAreaBottom : AppSizes.paddingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final positions = [
      {'top': 0.1, 'left': 0.1},
      {'top': 0.2, 'right': 0.1},
      {'top': 0.4, 'left': 0.05},
      {'top': 0.6, 'right': 0.05},
      {'top': 0.8, 'left': 0.15},
      {'top': 0.3, 'left': 0.8},
    ];
    
    final position = positions[index % positions.length];
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          top: (position['top'] as double) * MediaQuery.of(context).size.height +
              (math.sin(_floatAnimation.value * 2 * math.pi + index) * 10),
          left: position.containsKey('left')
              ? (position['left'] as double) * screenWidth
              : null,
          right: position.containsKey('right')
              ? (position['right'] as double) * screenWidth
              : null,
          child: Opacity(
            opacity: 0.1,
            child: Container(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // User avatar with modern styling
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    constraints: const BoxConstraints(
                      minWidth: 60,
                      maxWidth: 80,
                      minHeight: 60,
                      maxHeight: 80,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.yellowGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.userAvatar,
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(width: AppSizes.paddingLarge),
            
            // User info with modern typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.userName}! 👋',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: screenWidth * 0.045,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.005),
                  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.userAge,
                      style: AppTextStyles.captionBold?.copyWith(
                        color: AppColors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.01),
                  
                  Text(
                    'Ready to develop your logic? 🧠',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Modern settings button
            Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSettingsDialog();
                },
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.white,
                  size: screenWidth * 0.06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTitle() {
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.apps_rounded,
                color: AppColors.darkBlue,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: AppSizes.paddingMedium),
            Text(
              'Main menu',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape ? 4 : 2,
        crossAxisSpacing: AppSizes.paddingLarge,
        mainAxisSpacing: AppSizes.paddingLarge,
        childAspectRatio: isLandscape ? 0.9 : 1.0,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            final delay = index * 0.2;
            final adjustedValue = (_bounceAnimation.value - delay).clamp(0.0, 1.0);
            
            return Transform.scale(
              scale: 0.8 + (0.2 * adjustedValue),
              child: Opacity(
                opacity: adjustedValue,
                child: _buildModernMenuItem(_menuItems[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernMenuItem(MenuItemData item, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () => _onMenuItemTap(item),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: item.gradient[0].withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
              child: Stack(
                children: [
                  // Gradient background effect
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.gradient[0].withOpacity(0.1),
                            item.gradient[1].withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Main content
                  Padding(
                    padding: EdgeInsets.all(
                      screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with modern styling
                        Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          constraints: const BoxConstraints(
                            minWidth: 60,
                            maxWidth: 70,
                            minHeight: 60,
                            maxHeight: 70,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.gradient[0].withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: TextStyle(fontSize: screenWidth * 0.07),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: AppSizes.paddingMedium),
                        
                        Text(
                          item.title,
                          style: AppTextStyles.cardTitle?.copyWith(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: AppSizes.paddingSmall),
                        
                        Text(
                          item.subtitle,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.032,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMenuItemTap(MenuItemData item) {
    HapticFeedback.lightImpact();
    
    // Navigate to the appropriate screen
    if (item.route == '/partners') {
      Navigator.of(context).pushNamed('/partners');
    } else if (item.route == '/quizzes') {
      Navigator.of(context).pushNamed('/quizzes');
    } else if (item.route == '/certificates') {
      Navigator.of(context).pushNamed('/certificates');
    } else if (item.route == '/rewards') { 
      Navigator.of(context).pushNamed('/rewards');
    } else {
      // Show coming soon dialog for other routes
      _showComingSoonDialog(item);
    }
  }

  void _showComingSoonDialog(MenuItemData item) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.85,
          ),
          padding: EdgeInsets.all(
            screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                constraints: const BoxConstraints(
                  minWidth: 60,
                  maxWidth: 80,
                  minHeight: 60,
                  maxHeight: 80,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: item.gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.gradient[0].withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: TextStyle(fontSize: screenWidth * 0.08),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                '${item.title} 🚀',
                style: AppTextStyles.sectionTitle?.copyWith(
                  fontSize: screenWidth * 0.05,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingSmall),
              
              Text(
                'Цей розділ скоро буде доступний!\nМи працюємо над його створенням.',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingXLarge),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppButtonStyles.primaryButton?.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical: screenWidth > 375 ? 15 : 12,
                      ),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.85,
          ),
          padding: EdgeInsets.all(
            screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppColors.darkBlue,
                size: screenWidth * 0.15,
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Settings ⚙️',
                style: AppTextStyles.sectionTitle?.copyWith(
                  fontSize: screenWidth * 0.05,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingSmall),
              
              Text(
                'Do you want to reset all your progress and start from the beginning?',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingXLarge),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth > 375 ? 15 : 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth > 375 ? 15 : 12,
                        ),
                      ),
                      child: Text(
                        'Yes, reset',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}

// Data class for menu items
class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final String route;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.route,
  });
}
