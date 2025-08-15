import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  String? _selectedAvatar;
  String? _selectedAge;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _cardAnimation;

  // Beautiful avatars with more variety
  final List<String> avatars = [
    '🐔', '🐣', '🎯', '🚀', '🐓',
  ];

  // Age ranges
  final List<Map<String, String>> ageRanges = [
    {'label': '5-7 років', 'value': '5-7'},
    {'label': '8-10 років', 'value': '8-10'},
    {'label': '11-13 років', 'value': '11-13'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    _cardAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedAvatar != null &&
      _selectedAge != null;

  void _onRegister() {
    if (_isFormValid) {
      HapticFeedback.lightImpact();
      _showSuccessDialog();
    } else {
      _showErrorMessage();
    }
  }

  void _showSuccessDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(
            screenWidth > 375 ? AppSizes.paddingXLarge : AppSizes.paddingLarge,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar with glow effect
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  constraints: const BoxConstraints(
                    minWidth: 70,
                    maxWidth: 90,
                    minHeight: 70,
                    maxHeight: 90,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _selectedAvatar!,
                      style: TextStyle(fontSize: screenWidth * 0.08),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                Text(
                  'Welcome! 🎉',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: screenWidth * 0.06,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingSmall),
                
                Text(
                  'Hello ${_nameController.text.trim()}!',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                Container(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF8F9FA),
                        Color(0xFFE9ECEF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🚀', 
                        style: TextStyle(fontSize: screenWidth * 0.1),
                      ),
                      SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        'Ready to embark on your amazing journey into the world of logic and knowledge?',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingMedium),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Text(
                    'Age group: ${_getAgeRangeLabel()}',
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.green,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingXLarge),
                
                // iOS style buttons
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
                          'Back',
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
                          _navigateToMainApp();
                        },
                        style: AppButtonStyles.successButton.copyWith(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(
                              vertical: screenWidth > 375 ? 15 : 12,
                            ),
                          ),
                        ),
                        child: Text(
                          'Let\'s go!',
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
      ),
    );
  }

  void _showErrorMessage() {
    String message = '';
    if (_nameController.text.trim().isEmpty) {
      message = 'Please enter your name 📝';
    } else if (_selectedAvatar == null) {
      message = 'Select your avatar 🎭';
    } else if (_selectedAge == null) {
      message = 'Select your age 🎂';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: AppSizes.paddingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSizes.paddingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        action: SnackBarAction(
          label: 'Got it',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String _getAgeRangeLabel() {
    return ageRanges.firstWhere(
      (age) => age['value'] == _selectedAge,
      orElse: () => {'label': 'Unknown'},
    )['label']!;
  }

  void _navigateToMainApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: AppSizes.paddingSmall),
            Expanded(child: Text('Welcome ${_nameController.text.trim()}! 🎉')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSizes.paddingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Logo with glow effect
          Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.yellow.withOpacity(0.3),
                  AppColors.yellow.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
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
              child: Icon(
                Icons.psychology,
                size: screenWidth * 0.1,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          
          SizedBox(height: AppSizes.paddingLarge),
          
          Text(
            'Brain Road',
            style: AppTextStyles.mainTitle.copyWith(
              fontSize: screenWidth * 0.1,
              letterSpacing: 1.2,
            ),
          ),
          
          SizedBox(height: AppSizes.paddingSmall),
          
          Container(
            height: 4,
            width: screenWidth * 0.2,
            decoration: BoxDecoration(
              gradient: AppTheme.yellowGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          Text(
            'Develop your logic with us!',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                Icons.face,
                color: AppColors.darkBlue,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: AppSizes.paddingSmall),
            Text(
              'Select your avatar',
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSizes.paddingMedium),
        
        SizedBox(
          height: screenWidth * 0.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              final avatar = avatars[index];
              final isSelected = _selectedAvatar == avatar;
              final avatarSize = screenWidth * 0.18;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: screenWidth * 0.03),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.yellow : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: isSelected ? AppColors.green : AppColors.grey.withOpacity(0.2),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        if (isSelected) BoxShadow(
                          color: AppColors.yellow.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        avatar,
                        style: TextStyle(
                          fontSize: isSelected ? screenWidth * 0.08 : screenWidth * 0.07,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                Icons.edit,
                color: AppColors.green,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: AppSizes.paddingSmall),
            Text(
              'What is your name?',
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSizes.paddingMedium),
        
        TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTextStyles.inputHint,
            filled: true,
            fillColor: AppColors.grey.withOpacity(0.05),
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.green, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.2)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: screenWidth > 375 ? AppSizes.paddingMedium : AppSizes.paddingSmall,
            ),
          ),
          style: AppTextStyles.inputText.copyWith(
            fontSize: screenWidth * 0.04,
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            return Container();
          },
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) {
            if (_isFormValid) {
              _onRegister();
            }
          },
        ),
      ],
    );
  }

  Widget _buildAgeSelection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: AppColors.darkBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                Icons.cake,
                color: AppColors.darkBlue,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: AppSizes.paddingSmall),
            Text(
              'How old are you?',
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: screenWidth * 0.045,
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSizes.paddingMedium),
        
        Wrap(
          spacing: screenWidth * 0.03,
          runSpacing: screenWidth * 0.03,
          children: ageRanges.map((ageRange) {
            final isSelected = _selectedAge == ageRange['value'];
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedAge = ageRange['value'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenWidth * 0.03,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  border: Border.all(
                    color: isSelected ? AppColors.green : AppColors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    if (isSelected) BoxShadow(
                      color: AppColors.green.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  ageRange['label']!,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  children: [
                    SizedBox(height: AppSizes.paddingMedium),
                    
                    // Header
                    _buildHeader(),
                    
                    SizedBox(height: screenHeight * 0.05),
                    
                    // Main Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _cardAnimation,
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
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar Selection
                              _buildAvatarSelection(),
                              
                              SizedBox(height: screenHeight * 0.04),
                              
                              // Name Input
                              _buildNameInput(),
                              
                              SizedBox(height: screenHeight * 0.04),
                              
                              // Age Selection
                              _buildAgeSelection(),
                              
                              SizedBox(height: screenHeight * 0.05),
                              
                              // Register Button
                              ScaleTransition(
                                scale: _bounceAnimation,
                                child: Container(
                                  width: double.infinity,
                                  height: screenWidth > 375 ? AppSizes.buttonHeight : AppSizes.buttonHeight - 5,
                                  decoration: BoxDecoration(
                                    gradient: _isFormValid 
                                        ? AppTheme.yellowGradient
                                        : LinearGradient(
                                            colors: [
                                              AppColors.grey.withOpacity(0.3),
                                              AppColors.grey.withOpacity(0.2),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                                    boxShadow: [
                                      if (_isFormValid) BoxShadow(
                                        color: AppColors.yellow.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _onRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.rocket_launch,
                                          color: _isFormValid ? AppColors.darkBlue : AppColors.grey,
                                          size: screenWidth * 0.05,
                                        ),
                                        SizedBox(width: AppSizes.paddingSmall),
                                        Text(
                                          'Start Adventure!',
                                          style: AppTextStyles.buttonLarge.copyWith(
                                            color: _isFormValid ? AppColors.darkBlue : AppColors.grey,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppSizes.paddingXLarge),
                    
                    // Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Ready to get smarter? 🧠✨',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: screenWidth * 0.04,
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
      ),
    );
  }
}