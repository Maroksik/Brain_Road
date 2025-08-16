import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen>
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

  String _selectedCategory = 'All';

  // Partner categories
  final List<String> _categories = [
    'All',
    'Gaming Centers',
    'Educational',
    'Entertainment',
    'Sports',
  ];

  // Partner data with beautiful variety
  final List<PartnerData> _partners = [
    PartnerData(
      name: 'FunZone Arcade',
      type: 'Gaming Center',
      description: 'Ultimate gaming experience with VR, arcade games, and tournaments',
      icon: '🎮',
      gradient: [AppColors.yellow, AppColors.lightYellow],
      benefits: ['Free 2-hour gaming', 'VR experience', 'Tournament entry'],
      category: 'Gaming Centers',
      rating: 4.8,
      isPopular: true,
    ),
    PartnerData(
      name: 'KidsLearn Academy',
      type: 'Educational Center',
      description: 'Interactive learning programs and STEM workshops for children',
      icon: '📚',
      gradient: [AppColors.green, AppColors.lightGreen],
      benefits: ['Free coding class', 'Science workshop', 'Robotics session'],
      category: 'Educational',
      rating: 4.9,
      isPopular: false,
    ),
    PartnerData(
      name: 'Adventure Park',
      type: 'Family Entertainment',
      description: 'Outdoor adventures, climbing walls, and team building activities',
      icon: '🎢',
      gradient: [AppColors.darkBlue, AppColors.lightBlue],
      benefits: ['Free climbing session', 'Group activities', 'Safety gear included'],
      category: 'Entertainment',
      rating: 4.7,
      isPopular: true,
    ),
    PartnerData(
      name: 'Smart Sports Club',
      type: 'Sports Center',
      description: 'Modern sports facilities with professional training programs',
      icon: '⚽',
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
      benefits: ['Free trial training', 'Equipment rental', 'Coach consultation'],
      category: 'Sports',
      rating: 4.6,
      isPopular: false,
    ),
    PartnerData(
      name: 'TechnoLab',
      type: 'Innovation Hub',
      description: '3D printing, electronics, and digital creativity workshops',
      icon: '🔬',
      gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      benefits: ['3D printing session', 'Electronics kit', 'Digital art class'],
      category: 'Educational',
      rating: 4.8,
      isPopular: true,
    ),
    PartnerData(
      name: 'Cinema Plus',
      type: 'Entertainment',
      description: 'Premium cinema experience with latest movies and comfortable seating',
      icon: '🎬',
      gradient: [Color(0xFFFF9800), Color(0xFFFFB74D)],
      benefits: ['Free movie ticket', 'Popcorn & drink', 'Premium seating'],
      category: 'Entertainment',
      rating: 4.5,
      isPopular: false,
    ),
    PartnerData(
      name: 'GameMaster Arena',
      type: 'E-Sports Center',
      description: 'Professional gaming setup with high-end PCs and competitive tournaments',
      icon: '🏆',
      gradient: [AppColors.yellow, Color(0xFFFFD54F)],
      benefits: ['2-hour PC gaming', 'Tournament practice', 'Gaming accessories'],
      category: 'Gaming Centers',
      rating: 4.9,
      isPopular: true,
    ),
    PartnerData(
      name: 'AquaWorld',
      type: 'Water Park',
      description: 'Water slides, pools, and aquatic adventures for the whole family',
      icon: '🏊',
      gradient: [Color(0xFF2196F3), Color(0xFF64B5F6)],
      benefits: ['Free day pass', 'Swimming lessons', 'Water safety course'],
      category: 'Entertainment',
      rating: 4.7,
      isPopular: false,
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

  List<PartnerData> get _filteredPartners {
    if (_selectedCategory == 'All') {
      return _partners;
    }
    return _partners.where((partner) => partner.category == _selectedCategory).toList();
  }

  void _onPartnerTap(PartnerData partner) {
    HapticFeedback.lightImpact();
    _showPartnerDetails(partner);
  }

  void _showPartnerDetails(PartnerData partner) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Partner icon with gradient background
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 100,
                    minHeight: 80,
                    maxHeight: 100,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: partner.gradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: partner.gradient[0].withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      partner.icon,
                      style: TextStyle(fontSize: screenWidth * 0.1),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                // Partner name and type
                Text(
                  partner.name,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: screenWidth * 0.055,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingSmall),
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: partner.gradient),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Text(
                    partner.type,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.white,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingMedium),
                
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.yellow,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: AppSizes.paddingXSmall),
                    Text(
                      partner.rating.toString(),
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' / 5.0',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth * 0.04,
                        color: AppColors.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                // Description
                Text(
                  partner.description,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: screenWidth * 0.04,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                // Benefits section
                Container(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🎁',
                            style: TextStyle(fontSize: screenWidth * 0.06),
                          ),
                          SizedBox(width: AppSizes.paddingSmall),
                          Text(
                            'Your Benefits',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.paddingMedium),
                      ...partner.benefits.map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.green,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: AppSizes.paddingSmall),
                            Expanded(
                              child: Text(
                                benefit,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingXLarge),
                
                // Action buttons
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
                          'Close',
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
                          _showCertificateInfo(partner);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: partner.gradient[0],
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth > 375 ? 15 : 12,
                          ),
                        ),
                        child: Text(
                          'Get Certificate',
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

  void _showCertificateInfo(PartnerData partner) {
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
              // Certificate icon
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
                  gradient: AppTheme.yellowGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.yellow.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🏆',
                    style: TextStyle(fontSize: screenWidth * 0.08),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'How to get certificate? 🎯',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: screenWidth * 0.05,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingSmall),
              
              Text(
                'Complete tasks and quizzes to earn certificates for ${partner.name}!',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // Steps container
              Container(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
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
                child: Column(
                  children: [
                    _buildStep('1', 'Complete quizzes', '🧩'),
                    SizedBox(height: AppSizes.paddingMedium),
                    _buildStep('2', 'Earn points', '⭐'),
                    SizedBox(height: AppSizes.paddingMedium),
                    _buildStep('3', 'Get certificate', '🎫'),
                  ],
                ),
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
                    'Got it!',
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

  Widget _buildStep(String number, String text, String emoji) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Row(
      children: [
        Container(
          width: screenWidth * 0.08,
          height: screenWidth * 0.08,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.paddingMedium),
        Text(
          emoji,
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
        SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
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
          child: Column(
            children: [
              Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.grey,
                        size: screenWidth * 0.06,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: screenWidth * 0.04),
                  
                  // Partners icon with glow effect
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
                            color: AppColors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.yellow,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.green.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '🤝',
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
                  
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Partners 🤝',
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        
                        SizedBox(height: screenWidth * 0.01),
                        
                        Text(
                          'Places where you can use certificates',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // Info card
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
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
                    Text('🎁', style: TextStyle(fontSize: screenWidth * 0.08)),
                    SizedBox(width: AppSizes.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free certificates!',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          Text(
                            'Complete quizzes to earn visits to amazing places',
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: screenWidth * 0.035,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: screenWidth * 0.12,
        margin: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: AppSizes.paddingSmall),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.yellow : AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    border: Border.all(
                      color: isSelected ? AppColors.green : AppColors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected) BoxShadow(
                        color: AppColors.yellow.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? AppColors.darkBlue : AppColors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: screenWidth * 0.035,
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

  Widget _buildPartnerCard(PartnerData partner, int index) {
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
                    onTap: () => _onPartnerTap(partner),
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
                          color: partner.gradient[0].withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: partner.gradient[0].withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
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
                                    colors: partner.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  boxShadow: [
                                    BoxShadow(
                                      color: partner.gradient[0].withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    partner.icon,
                                    style: TextStyle(fontSize: screenWidth * 0.08),
                                  ),
                                ),
                              ),
                              
                              SizedBox(width: screenWidth * 0.04),
                              
                              // Partner info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            partner.name,
                                            style: AppTextStyles.cardTitle.copyWith(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (partner.isPopular) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSizes.paddingSmall,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.yellow,
                                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                            ),
                                            child: Text(
                                              'Popular',
                                              style: TextStyle(
                                                color: AppColors.darkBlue,
                                                fontSize: screenWidth * 0.03,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    
                                    SizedBox(height: screenWidth * 0.01),
                                    
                                    Text(
                                      partner.type,
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontSize: screenWidth * 0.04,
                                        color: partner.gradient[0],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    
                                    SizedBox(height: screenWidth * 0.02),
                                    
                                    // Rating
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: AppColors.yellow,
                                          size: screenWidth * 0.04,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          partner.rating.toString(),
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: AppSizes.paddingSmall),
                                        Expanded(
                                          child: Text(
                                            '${partner.benefits.length} benefits',
                                            style: AppTextStyles.bodyText.copyWith(
                                              fontSize: screenWidth * 0.035,
                                              color: AppColors.grey.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Arrow icon
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                decoration: BoxDecoration(
                                  color: partner.gradient[0].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: partner.gradient[0],
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: AppSizes.paddingMedium),
                          
                          // Description
                          Text(
                            partner.description,
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.grey.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: AppSizes.paddingMedium),
                          
                          // Benefits preview
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingMedium),
                            decoration: BoxDecoration(
                              color: partner.gradient[0].withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  color: partner.gradient[0],
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: AppSizes.paddingSmall),
                                Expanded(
                                  child: Text(
                                    partner.benefits.first,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                                if (partner.benefits.length > 1) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingSmall,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: partner.gradient[0].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                    ),
                                    child: Text(
                                      '+${partner.benefits.length - 1} more',
                                      style: TextStyle(
                                        color: partner.gradient[0],
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }

  Widget _buildFloatingIcon() {
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
                      AppColors.green.withOpacity(0.3),
                      AppColors.green.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '🎯',
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
            // Floating icon
            _buildFloatingIcon(),
            
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
                        
                        // Header
                        _buildHeader(),
                        
                        SizedBox(height: isLandscape ? AppSizes.paddingMedium : AppSizes.paddingLarge),
                        
                        // Category filter
                        _buildCategoryFilter(),
                        
                        SizedBox(height: AppSizes.paddingMedium),
                        
                        // Partners count
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.white,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                              SizedBox(width: AppSizes.paddingSmall),
                              Text(
                                '${_filteredPartners.length} partners',
                                style: AppTextStyles.bodyTextWhite.copyWith(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: AppSizes.paddingSmall),
                              if (_selectedCategory != 'All') ...[
                                Text(
                                  'in $_selectedCategory',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        SizedBox(height: AppSizes.paddingLarge),
                        
                        // Partners list
                        ...List.generate(_filteredPartners.length, (index) {
                          return AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              // Stagger the animations
                              final delay = index * 0.1;
                              final adjustedValue = (_bounceAnimation.value - delay).clamp(0.0, 1.0);
                              
                              return Transform.scale(
                                scale: 0.8 + (0.2 * adjustedValue),
                                child: Opacity(
                                  opacity: adjustedValue,
                                  child: _buildPartnerCard(_filteredPartners[index], index),
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
                                  '🎪',
                                  style: TextStyle(fontSize: screenWidth * 0.08),
                                ),
                                SizedBox(width: AppSizes.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Discover amazing places',
                                        style: AppTextStyles.bodyTextWhite.copyWith(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Text(
                                        'Complete quizzes and earn free visits to our partner locations!',
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

// Data class for partner information
class PartnerData {
  final String name;
  final String type;
  final String description;
  final String icon;
  final List<Color> gradient;
  final List<String> benefits;
  final String category;
  final double rating;
  final bool isPopular;

  PartnerData({
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.benefits,
    required this.category,
    required this.rating,
    required this.isPopular,
  });
}