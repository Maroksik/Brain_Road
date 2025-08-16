import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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

  late PageController _pageController;
  late ScrollController _scrollController;
  
  String _selectedCategory = 'All';
  int _currentPartnerIndex = 0;

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
    _pageController = PageController(viewportFraction: 0.85);
    _scrollController = ScrollController();
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
    _pageController.dispose();
    _scrollController.dispose();
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : screenSize.width * 0.9,
            maxHeight: isLandscape ? screenSize.height * 0.9 : screenSize.height * 0.8,
          ),
          padding: EdgeInsets.all(isTablet ? 30 : 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Partner icon with gradient background
                Container(
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
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
                      style: TextStyle(fontSize: isTablet ? 50 : 40),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 24 : 20),
                
                // Partner name and type
                Text(
                  partner.name,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: isTablet ? 24 : 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isTablet ? 12 : 8),
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: partner.gradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    partner.type,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.white,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.yellow,
                      size: isTablet ? 24 : 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      partner.rating.toString(),
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' / 5.0',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: isTablet ? 18 : 16,
                        color: AppColors.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 24 : 20),
                
                // Description
                Text(
                  partner.description,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: isTablet ? 18 : 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isTablet ? 24 : 20),
                
                // Benefits section
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🎁',
                            style: TextStyle(fontSize: isTablet ? 28 : 24),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Text(
                            'Your Benefits',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: isTablet ? 20 : 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      ...partner.benefits.map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.green,
                              size: isTablet ? 24 : 20,
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Expanded(
                              child: Text(
                                benefit,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                
                SizedBox(height: isTablet ? 32 : 24),
                
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                        ),
                        child: Text(
                          'Get Certificate',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 450 : screenSize.width * 0.85,
          ),
          padding: EdgeInsets.all(isTablet ? 30 : 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
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
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
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
                    style: TextStyle(fontSize: isTablet ? 40 : 32),
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              Text(
                'How to get certificate? 🎯',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: isTablet ? 22 : 20,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 12 : 8),
              
              Text(
                'Complete tasks and quizzes to earn certificates for ${partner.name}!',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: isTablet ? 18 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Steps container
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.yellow.withOpacity(0.1),
                      AppColors.green.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  border: Border.all(
                    color: AppColors.yellow.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    _buildStep('1', 'Complete quizzes', '🧩', isTablet),
                    SizedBox(height: isTablet ? 16 : 12),
                    _buildStep('2', 'Earn points', '⭐', isTablet),
                    SizedBox(height: isTablet ? 16 : 12),
                    _buildStep('3', 'Get certificate', '🎫', isTablet),
                  ],
                ),
              ),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppButtonStyles.primaryButton.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
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

  Widget _buildStep(String number, String text, String emoji, bool isTablet) {
    return Row(
      children: [
        Container(
          width: isTablet ? 40 : 32,
          height: isTablet ? 40 : 32,
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
                fontSize: isTablet ? 18 : 14,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Text(
          emoji,
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(top: safeAreaTop > 0 ? 0 : 10),
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
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
                    width: isTablet ? 50 : 44,
                    height: isTablet ? 50 : 44,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.grey,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: isTablet ? 16 : 12),
                  
                  // Partners icon with glow effect
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 3 * _floatAnimation.value),
                        child: Container(
                          width: isTablet ? 70 : 60,
                          height: isTablet ? 70 : 60,
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
                                fontSize: isTablet ? 35 : 30,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(width: isTablet ? 16 : 12),
                  
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Partners 🤝',
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: isTablet ? 24 : 20,
                          ),
                        ),
                        
                        SizedBox(height: 4),
                        
                        Text(
                          'Places where you can use certificates',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 20 : 16),
              
              // Info card
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.yellow.withOpacity(0.1),
                      AppColors.green.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  border: Border.all(
                    color: AppColors.yellow.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text('🎁', style: TextStyle(fontSize: isTablet ? 32 : 28)),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free certificates!',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: isTablet ? 18 : 16,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          Text(
                            'Complete quizzes to earn visits to amazing places',
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: isTablet ? 16 : 14,
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: isTablet ? 60 : 50,
        margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isTablet ? 12 : 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = category;
                    _currentPartnerIndex = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 12 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.yellow : AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
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
                        fontSize: isTablet ? 16 : 14,
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

  Widget _build3DPartnersScroll() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final filteredPartners = _filteredPartners;
    
    if (filteredPartners.isEmpty) {
      return _buildEmptyState();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: isTablet ? 420 : 360,
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPartnerIndex = index;
            });
            HapticFeedback.selectionClick();
          },
          itemCount: filteredPartners.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - index;
                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                }
                
                return Center(
                  child: SizedBox(
                    height: Curves.easeOut.transform(value) * (isTablet ? 420 : 360),
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY((1 - value) * 0.3),
                        child: _build3DPartnerCard(filteredPartners[index], index, value),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _build3DPartnerCard(PartnerData partner, int index, double animValue) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isActive = index == _currentPartnerIndex;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 20 : 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPartnerTap(partner),
          borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
              border: Border.all(
                color: isActive 
                    ? partner.gradient[0] 
                    : partner.gradient[0].withOpacity(0.2),
                width: isActive ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: partner.gradient[0].withOpacity(isActive ? 0.3 : 0.15),
                  blurRadius: isActive ? 30 : 20,
                  offset: Offset(0, isActive ? 15 : 8),
                  spreadRadius: isActive ? 3 : 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top section with icon and info
                Row(
                  children: [
                    // 3D Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isTablet ? 80 : 70,
                      height: isTablet ? 80 : 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: partner.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                        boxShadow: [
                          BoxShadow(
                            color: partner.gradient[0].withOpacity(0.4),
                            blurRadius: isActive ? 15 : 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scale: isActive ? 1.1 : 1.0,
                        child: Center(
                          child: Text(
                            partner.icon,
                            style: TextStyle(fontSize: isTablet ? 40 : 35),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: isTablet ? 16 : 12),
                    
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
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? partner.gradient[0] : AppColors.darkBlue,
                                  ),
                                ),
                              ),
                              if (partner.isPopular) ...[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 10 : 8,
                                    vertical: isTablet ? 4 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                                    boxShadow: isActive ? [
                                      BoxShadow(
                                        color: AppColors.yellow.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ] : [],
                                  ),
                                  child: Text(
                                    'Popular',
                                    style: TextStyle(
                                      color: AppColors.darkBlue,
                                      fontSize: isTablet ? 12 : 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          SizedBox(height: isTablet ? 8 : 6),
                          
                          Text(
                            partner.type,
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: isTablet ? 16 : 14,
                              color: partner.gradient[0],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 8 : 6),
                          
                          // Rating with animated stars
                          Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                final filled = starIndex < partner.rating.floor();
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300 + (starIndex * 100)),
                                  margin: EdgeInsets.only(right: 2),
                                  child: Icon(
                                    filled ? Icons.star : Icons.star_border,
                                    color: AppColors.yellow,
                                    size: isTablet ? 18 : 16,
                                  ),
                                );
                              }),
                              SizedBox(width: isTablet ? 8 : 6),
                              Text(
                                partner.rating.toString(),
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 20 : 16),
                
                // Description with animated text
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isTablet ? 60 : 50,
                  child: Text(
                    partner.description,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: isTablet ? 16 : 14,
                      color: AppColors.grey.withOpacity(isActive ? 1.0 : 0.8),
                      height: 1.4,
                    ),
                    maxLines: isTablet ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                // Benefits section with 3D effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        partner.gradient[0].withOpacity(isActive ? 0.1 : 0.05),
                        partner.gradient[1].withOpacity(isActive ? 0.1 : 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                    border: Border.all(
                      color: partner.gradient[0].withOpacity(isActive ? 0.3 : 0.2),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()
                              ..scale(isActive ? 1.2 : 1.0),
                            child: Icon(
                              Icons.card_giftcard,
                              color: partner.gradient[0],
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Text(
                              'Benefits included',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: isTablet ? 16 : 14,
                                color: partner.gradient[0],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : 8,
                              vertical: isTablet ? 4 : 3,
                            ),
                            decoration: BoxDecoration(
                              color: partner.gradient[0].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                            ),
                            child: Text(
                              '${partner.benefits.length}',
                              style: TextStyle(
                                color: partner.gradient[0],
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (isActive) ...[
                        SizedBox(height: isTablet ? 12 : 8),
                        ...partner.benefits.take(isTablet ? 3 : 2).map((benefit) => 
                          Padding(
                            padding: EdgeInsets.only(bottom: isTablet ? 6 : 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: isTablet ? 16 : 14,
                                ),
                                SizedBox(width: isTablet ? 8 : 6),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                // Action button with 3D effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: partner.gradient),
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                    boxShadow: [
                      BoxShadow(
                        color: partner.gradient[0].withOpacity(isActive ? 0.4 : 0.2),
                        blurRadius: isActive ? 15 : 8,
                        offset: Offset(0, isActive ? 8 : 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _onPartnerTap(partner),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.white,
                          size: isTablet ? 20 : 18,
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
    
  }

  Widget _buildEmptyState() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: isTablet ? 300 : 250,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔍',
              style: TextStyle(fontSize: isTablet ? 60 : 50),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'No partners found',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: isTablet ? 22 : 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              'Try selecting a different category',
              style: AppTextStyles.caption.copyWith(
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final filteredPartners = _filteredPartners;
    
    if (filteredPartners.length <= 1) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(filteredPartners.length, (index) {
            final isActive = index == _currentPartnerIndex;
            final partner = filteredPartners[index];
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 3),
              width: isActive ? (isTablet ? 32 : 24) : (isTablet ? 12 : 8),
              height: isTablet ? 12 : 8,
              decoration: BoxDecoration(
                color: isActive ? partner.gradient[0] : AppColors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: partner.gradient[0].withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    
    return Positioned(
      top: screenSize.height * 0.15,
      right: isTablet ? 30 : 20,
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
                padding: EdgeInsets.all(isTablet ? 16 : 12),
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
                  style: TextStyle(fontSize: isTablet ? 50 : 40),
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
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final isTablet = screenSize.shortestSide >= 600;
    final isLandscape = screenSize.width > screenSize.height;
    
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
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height - safeArea.top - safeArea.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: isLandscape && !isTablet ? 8 : 16),
                      
                      // Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                        child: _buildHeader(),
                      ),
                      
                      SizedBox(height: isLandscape && !isTablet ? 12 : 20),
                      
                      // Category filter
                      _buildCategoryFilter(),
                      
                      SizedBox(height: isTablet ? 16 : 12),
                      
                      // Partners count
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isTablet ? 10 : 8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.white,
                                  size: isTablet ? 20 : 18,
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Text(
                                '${_filteredPartners.length} partners',
                                style: AppTextStyles.bodyTextWhite.copyWith(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: isTablet ? 8 : 6),
                              if (_selectedCategory != 'All') ...[
                                Text(
                                  'in $_selectedCategory',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 24 : 20),
                      
                      // 3D Partners scroll
                      _build3DPartnersScroll(),
                      
                      // Page indicator
                      _buildPageIndicator(),
                      
                      SizedBox(height: isTablet ? 20 : 16),
                      
                      // Footer
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white.withOpacity(0.1),
                                AppColors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '🎪',
                                style: TextStyle(fontSize: isTablet ? 40 : 32),
                              ),
                              SizedBox(width: isTablet ? 16 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Discover amazing places',
                                      style: AppTextStyles.bodyTextWhite.copyWith(
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 6 : 4),
                                    Text(
                                      'Complete quizzes and earn free visits to our partner locations!',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: isTablet ? 16 : 14,
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
                      SizedBox(height: math.max(safeArea.bottom, isTablet ? 24 : 20)),
                    ],
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