import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
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
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

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
      icon: Icons.card_giftcard, // Нова іконка для винагород
      title: 'Rewards',
      subtitle: 'Your prizes',
      emoji: '🎁',
      gradient: [const Color(0xFFE91E63), const Color(0xFFF48FB1)], // Рожевий градієнт
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
      duration: const Duration(milliseconds: 2500),
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
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
    
    // Start continuous floating animation
    _floatController.repeat(reverse: true);
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _showSettingsDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
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
              // Settings icon
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
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkBlue.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings,
                  color: AppColors.white,
                  size: screenWidth * 0.08,
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Settings ⚙️',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: screenWidth * 0.05,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // User info card
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(widget.userAvatar, style: TextStyle(fontSize: screenWidth * 0.08)),
                        SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                              Text(
                                widget.userAge,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showResetDialog();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth > 375 ? 15 : 12,
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Reset data',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppButtonStyles.primaryButton.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical: screenWidth > 375 ? 15 : 12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
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
              // Warning icon
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
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warning,
                  color: AppColors.white,
                  size: screenWidth * 0.08,
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Reset data? ⚠️',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: screenWidth * 0.05,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingSmall),
              
              Text(
                'This will delete all your data and return you to the welcome screen. Are you sure?',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingXLarge),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
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
                        _resetUserData();
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

  void _resetUserData() async {
    // Очищуємо всі дані користувача
    await UserPreferences.clearUserData();
    
    if (mounted) {
      // Навігуємо назад до splash screen, який потім перенаправить до welcome
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  void _onMenuItemTap(MenuItemData item) {
    HapticFeedback.lightImpact();
    
    // Navigate to the appropriate screen
    if (item.route == '/partners') {
      Navigator.of(context).pushNamed('/partners');
    }
    else if (item.route == '/quizzes') {
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
      barrierColor: Colors.black.withOpacity(0.7),
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
                style: AppTextStyles.sectionTitle.copyWith(
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
                  style: AppButtonStyles.primaryButton.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical: screenWidth > 375 ? 15 : 12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Зрозуміло',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(
            screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // User avatar with glow effect
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 3 * _floatAnimation.value),
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
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.green,
                          width: 3,
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
                            fontSize: screenWidth * 0.08,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(width: screenWidth * 0.04),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.userName}! 👋',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: screenWidth * 0.045,
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
                      ),
                      child: Text(
                        widget.userAge,
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.white,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    Text(
                      'Ready to develop your logic? 🧠',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showSettingsDialog();
                  },
                  icon: Icon(
                    Icons.settings,
                    color: AppColors.grey,
                    size: screenWidth * 0.06,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _bounceAnimation.value),
              child: Container(
                margin: EdgeInsets.only(
                  bottom: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onMenuItemTap(item),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(
                        screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                        border: Border.all(
                          color: item.gradient[0].withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.gradient[0].withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon container with gradient
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
                              gradient: LinearGradient(
                                colors: item.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color: item.gradient[0].withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    item.icon,
                                    color: AppColors.white,
                                    size: screenWidth * 0.07,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Text(
                                    item.emoji,
                                    style: TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: screenWidth * 0.04),
                          
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                SizedBox(height: screenWidth * 0.01),
                                
                                Text(
                                  item.subtitle,
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: screenWidth * 0.04,
                                    color: AppColors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Arrow icon
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: item.gradient[0].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: item.gradient[0],
                              size: screenWidth * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingBrainIcon() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      right: screenWidth * 0.05,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              10 * _floatAnimation.value,
              8 * _floatAnimation.value,
            ),
            child: Transform.rotate(
              angle: 0.1 * _floatAnimation.value,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
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
                child: Text(
                  '🧠',
                  style: TextStyle(fontSize: screenWidth * 0.1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
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
        child: Stack(
          children: [
            // Floating brain icon
            _buildFloatingBrainIcon(),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - safeAreaTop - safeAreaBottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isLandscape ? AppSizes.paddingSmall : AppSizes.paddingLarge),
                        
                        // Header with user info
                        _buildHeader(),
                        
                        SizedBox(height: isLandscape ? AppSizes.paddingLarge : AppSizes.paddingXXLarge),
                        
                        // Menu title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.025),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.yellowGradient,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: Icon(
                                  Icons.apps,
                                  color: AppColors.darkBlue,
                                  size: screenWidth * 0.06,
                                ),
                              ),
                              SizedBox(width: AppSizes.paddingMedium),
                              Text(
                                'Main menu',
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: AppColors.white,
                                  fontSize: screenWidth * 0.055,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),
                        
                        // Menu items
                        ...List.generate(_menuItems.length, (index) {
                          return AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              // Stagger the animations
                              final delay = index * 0.2;
                              final adjustedValue = (_bounceAnimation.value - delay).clamp(0.0, 1.0);
                              
                              return Transform.scale(
                                scale: 0.8 + (0.2 * adjustedValue),
                                child: Opacity(
                                  opacity: adjustedValue,
                                  child: _buildMenuItem(_menuItems[index], index),
                                ),
                              );
                            },
                          );
                        }),
                        
                        SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),
                        
                        // Footer
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(AppSizes.paddingLarge),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white.withOpacity(0.1),
                                  AppColors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '🚀',
                                  style: TextStyle(fontSize: screenWidth * 0.08),
                                ),
                                SizedBox(width: AppSizes.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Develop your brain',
                                        style: AppTextStyles.bodyTextWhite.copyWith(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Text(
                                        'Every day brings new challenges and achievements!',
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Bottom safe area padding
                        SizedBox(height: safeAreaBottom > 0 ? safeAreaBottom : AppSizes.paddingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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