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
    {'label': '5-7 years', 'value': '5-7'},
    {'label': '8-10 years', 'value': '8-10'},
    {'label': '11-13 years', 'value': '11-13'},
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
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      _bounceController.forward();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXLarge),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with glow effect
              Container(
                width: 80,
                height: 80,
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
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Welcome Aboard! 🎉',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingSmall),
              
              Text(
                'Hi ${_nameController.text.trim()}!',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingLarge),
              
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
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
                    const Text('🚀', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Ready to start your amazing journey into the world of logic and knowledge?',
                      style: AppTextStyles.bodyText.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
              
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
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingXLarge),
              
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToMainApp();
                      },
                      style: AppButtonStyles.successButton.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      child: const Text('Let\'s Start!'),
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

  void _showErrorMessage() {
    String message = '';
    if (_nameController.text.trim().isEmpty) {
      message = 'Please enter your name 📝';
    } else if (_selectedAvatar == null) {
      message = 'Choose your avatar 🎭';
    } else if (_selectedAge == null) {
      message = 'Select your age 🎂';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: AppSizes.paddingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.paddingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        action: SnackBarAction(
          label: 'OK',
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
            const SizedBox(width: AppSizes.paddingSmall),
            Expanded(child: Text('Welcome ${_nameController.text.trim()}! 🎉')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.paddingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Logo with glow effect
          Container(
            padding: const EdgeInsets.all(20),
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
                size: 40,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingLarge),
          
          Text(
            'Brain Road',
            style: AppTextStyles.mainTitle.copyWith(
              fontSize: 42,
              letterSpacing: 1.2,
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingSmall),
          
          Container(
            height: 4,
            width: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.yellowGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingMedium),
          
          Text(
            'Develop your logic with us!',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Icons.face,
                color: AppColors.darkBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              'Choose Your Avatar',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.paddingMedium),
        
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              final avatar = avatars[index];
              final isSelected = _selectedAvatar == avatar;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 70,
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
                          fontSize: isSelected ? 30 : 26,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              'What\'s Your Name?',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.paddingMedium),
        
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
          ),
          style: AppTextStyles.inputText,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Icons.cake,
                color: AppColors.darkBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              'How Old Are You?',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.paddingMedium),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
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
                    fontSize: 16,
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
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.paddingMedium),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // Main Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _cardAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingXLarge),
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
                            
                            const SizedBox(height: AppSizes.paddingXXLarge),
                            
                            // Name Input
                            _buildNameInput(),
                            
                            const SizedBox(height: AppSizes.paddingXXLarge),
                            
                            // Age Selection
                            _buildAgeSelection(),
                            
                            const SizedBox(height: 40),
                            
                            // Register Button
                            ScaleTransition(
                              scale: _bounceAnimation,
                              child: Container(
                                width: double.infinity,
                                height: AppSizes.buttonHeight,
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
                                      ),
                                      const SizedBox(width: AppSizes.paddingSmall),
                                      Text(
                                        'Start Adventure!',
                                        style: AppTextStyles.buttonLarge.copyWith(
                                          color: _isFormValid ? AppColors.darkBlue : AppColors.grey,
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
                  
                  const SizedBox(height: AppSizes.paddingXLarge),
                  
                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Ready to become smarter? 🧠✨',
                      style: AppTextStyles.caption.copyWith(fontSize: 16),
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
}