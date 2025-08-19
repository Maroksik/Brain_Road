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
  late AnimationController _instructionsController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _instructionsAnimation;
  
  bool _isInstructionsExpanded = false;

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
      gradient: [AppColors.warning, AppColors.lightYellow],
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
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _instructionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      curve: Curves.elasticOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _instructionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _instructionsController,
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
    _instructionsController.dispose();
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
            
            // Main scrollable content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isLandscape ? AppSizes.paddingSmall : AppSizes.paddingLarge),
                    
                    // Header with user info
                    _buildModernHeader(),
                    
                    SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),
                    
                    // Instructions toggle button
                    _buildInstructionsToggle(),
                    
                    // Expandable instructions widget
                    _buildExpandableInstructions(),
                    
                    SizedBox(height: isLandscape ? AppSizes.paddingLarge : AppSizes.paddingXLarge),
                    
                    // Menu title with modern styling
                    _buildMenuTitle(),
                    
                    SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),

                    _buildMenuGrid(),

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

  Widget _buildInstructionsToggle() {
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isInstructionsExpanded = !_isInstructionsExpanded;
          });
          
          if (_isInstructionsExpanded) {
            _instructionsController.forward();
          } else {
            _instructionsController.reverse();
          }
          
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white.withOpacity(0.15),
                AppColors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            border: Border.all(
              color: AppColors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  gradient: AppTheme.yellowGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.yellow.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.darkBlue,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Text(
                  'How it works',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isInstructionsExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.white,
                  size: screenWidth * 0.06,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
  final screenWidth = MediaQuery.of(context).size.width;
  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isLandscape ? 4 : 2,
      crossAxisSpacing: AppSizes.paddingLarge,
      mainAxisSpacing: AppSizes.paddingLarge,
      childAspectRatio: isLandscape ? 0.9 : 1.1,
    ),
    itemCount: _menuItems.length,
    itemBuilder: (context, index) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.5 + (index * 0.1)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            0.2 + (index * 0.1),
            0.8 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        )),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: _bounceController,
            curve: Interval(
              0.3 + (index * 0.1),
              0.9 + (index * 0.1),
              curve: Curves.elasticOut,
            ),
          )),
          child: _buildModernMenuCard(_menuItems[index], index),
        ),
      );
    },
  );
}

  Widget _buildExpandableInstructions() {
    return SizeTransition(
      sizeFactor: _instructionsAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _instructionsAnimation,
        child: Container(
          margin: EdgeInsets.only(top: AppSizes.paddingMedium),
          child: _buildInstructionsContent(),
        ),
      ),
    );
  }

  Widget _buildInstructionsContent() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white.withOpacity(0.1),
            AppColors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(
          color: AppColors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Instructions steps
          _buildInstructionStep(
            '1',
            'Take quizzes with your child',
            '🧩',
            screenWidth,
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          _buildInstructionStep(
            '2',
            'Earn certificates and rewards',
            '🏆',
            screenWidth,
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          _buildInstructionStep(
            '3',
            'Visit our partner establishments',
            '🏪',
            screenWidth,
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          _buildInstructionStep(
            '4',
            'Activate your gifts',
            '🎁',
            screenWidth,
          ),
          
          SizedBox(height: AppSizes.paddingLarge),
          
          // Note about certificate verification
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.yellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '💡',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
                SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'Consultants may require certificate verification',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white,
                      fontSize: screenWidth * 0.033,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, String emoji, double screenWidth) {
    return Row(
      children: [
        // Step number
        Container(
          width: screenWidth * 0.07,
          height: screenWidth * 0.07,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.green,
                AppColors.lightGreen,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white,
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SizedBox(width: AppSizes.paddingMedium),
        
        // Emoji
        Text(
          emoji,
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
        
        SizedBox(width: AppSizes.paddingSmall),
        
        // Step text
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
            // User avatar with enhanced styling
            Container(
              width: isLandscape ? screenWidth * 0.1 : screenWidth * 0.15,
              height: isLandscape ? screenWidth * 0.1 : screenWidth * 0.15,
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: isLandscape ? 70 : 80,
                minHeight: 50,
                maxHeight: isLandscape ? 70 : 80,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.userAvatar,
                  style: TextStyle(
                    fontSize: isLandscape ? screenWidth * 0.05 : screenWidth * 0.08,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: AppSizes.paddingLarge),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingXSmall),
                  Text(
                    widget.userName,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.userAge} years old',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            
            // Settings button
            
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
        childAspectRatio: isLandscape ? 0.9 : 1.1,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.5 + (index * 0.1)),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Interval(
              0.2 + (index * 0.1),
              0.8 + (index * 0.1),
              curve: Curves.elasticOut,
            ),
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _bounceController,
              curve: Interval(
                0.3 + (index * 0.1),
                0.9 + (index * 0.1),
                curve: Curves.elasticOut,
              ),
            )),
            child: _buildModernMenuCard(_menuItems[index], index),
          ),
        );
      },
    );
  }

  Widget _buildModernMenuCard(MenuItemData item, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.gradient[0].withOpacity(0.9),
              item.gradient[1].withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji with enhanced styling
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                constraints: const BoxConstraints(
                  minWidth: 50,
                  maxWidth: 70,
                  minHeight: 50,
                  maxHeight: 70,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Title
              Text(
                item.title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: AppSizes.paddingXSmall),
              
              // Subtitle
              Text(
                item.subtitle,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: screenWidth * 0.032,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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