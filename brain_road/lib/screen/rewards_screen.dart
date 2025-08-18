import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
import '../services/user_preferences.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  List<RewardData> _rewards = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  
  RewardData? _newReward;
  bool _showNewRewardDialog = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRewards();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
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
  }

  void _loadRewards() async {
    // Load saved rewards from preferences
    final savedRewards = await UserPreferences.getRewards();
    if (mounted) {
      setState(() {
        _rewards = savedRewards;
      });
    }
  }

  void _addNewReward(String certificateName) async {
    final newRewards = [
      RewardData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Free Ice Cream Cone',
        partner: 'Sweet Dreams Gelato',
        description: 'Enjoy a delicious scoop of premium gelato',
        emoji: '🍦',
        gradient: [AppColors.yellow, AppColors.lightYellow],
        claimed: false,
        certificateTrigger: certificateName,
      ),
      RewardData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '1 Hour Gaming Zone',
        partner: 'GameHub Arena',
        description: 'Free hour in our premium gaming zone',
        emoji: '🎮',
        gradient: [AppColors.green, AppColors.lightGreen],
        claimed: false,
        certificateTrigger: certificateName,
      ),
      RewardData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Free Coffee & Pastry',
        partner: 'Café Central',
        description: 'Complimentary coffee and fresh pastry',
        emoji: '☕',
        gradient: [const Color(0xFFFF8A65), const Color(0xFFFFAB91)],
        claimed: false,
        certificateTrigger: certificateName,
      ),
      RewardData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '20% Off Shopping',
        partner: 'TechStore',
        description: '20% discount on any tech accessories',
        emoji: '🛍️',
        gradient: [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
        claimed: false,
        certificateTrigger: certificateName,
      ),
    ];
    
    final randomReward = newRewards[DateTime.now().millisecond % newRewards.length];
    
    setState(() {
      _rewards.add(randomReward);
      _newReward = randomReward;
      _showNewRewardDialog = true;
    });
    
    // Save to preferences
    await UserPreferences.addReward(randomReward);
    
    // Hide dialog after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNewRewardDialog = false;
          _newReward = null;
        });
      }
    });
  }

  void _claimReward(String rewardId) async {
    HapticFeedback.lightImpact();
    
    setState(() {
      _rewards = _rewards.map((reward) {
        if (reward.id == rewardId) {
          return reward.copyWith(claimed: true);
        }
        return reward;
      }).toList();
    });
    
    // Update in preferences
    await UserPreferences.updateReward(rewardId, true);
  }

  Map<String, int> get _stats {
    return {
      'total': _rewards.length,
      'available': _rewards.where((r) => !r.claimed).length,
      'claimed': _rewards.where((r) => r.claimed).length,
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(screenWidth),
                
                // Content
                Expanded(
                  child: _rewards.isEmpty 
                    ? _buildEmptyState(screenWidth)
                    : _buildRewardsList(screenWidth, safeAreaBottom),
                ),
              ],
            ),
          ),
          
          // New reward dialog
          if (_showNewRewardDialog && _newReward != null)
            _buildNewRewardDialog(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(AppSizes.paddingLarge),
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        decoration: AppDecorations.cardDecoration,
        child: Column(
          children: [
            // Back button and title
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
                ),
                Expanded(
                  child: Text(
                    'My Rewards',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: screenWidth * 0.06,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            // Reward icon
            ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.yellow, AppColors.lightYellow],
                  ),
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
                    '🎁',
                    style: TextStyle(fontSize: screenWidth * 0.08),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            Text(
              'Earn certificates, unlock amazing rewards',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.grey,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            // Stats
            SlideTransition(
              position: _slideAnimation,
              child: Row(
                children: [
                  _buildStatCard('Total', _stats['total']!, AppColors.darkBlue, screenWidth),
                  SizedBox(width: AppSizes.paddingSmall),
                  _buildStatCard('Available', _stats['available']!, AppColors.green, screenWidth),
                  SizedBox(width: AppSizes.paddingSmall),
                  _buildStatCard('Claimed', _stats['claimed']!, AppColors.grey, screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, double screenWidth) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.paddingMedium,
          horizontal: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: AppTextStyles.sectionTitle.copyWith(
                color: color,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.paddingXSmall),
            Text(
              label,
              style: AppTextStyles.bodyText.copyWith(
                color: color,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(double screenWidth, double safeAreaBottom) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _rewards.length + 1, // +1 for demo button
              itemBuilder: (context, index) {
                if (index == _rewards.length) {
                  // Demo button
                  return Padding(
                    padding: EdgeInsets.only(
                      top: AppSizes.paddingLarge,
                      bottom: safeAreaBottom > 0 ? safeAreaBottom : AppSizes.paddingLarge,
                    ),
                    child: _buildDemoButton(screenWidth),
                  );
                }
                
                final reward = _rewards[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.paddingMedium),
                  child: _buildRewardCard(reward, screenWidth),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(RewardData reward, double screenWidth) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        decoration: AppDecorations.cardDecoration.copyWith(
          color: reward.claimed ? AppColors.grey.withOpacity(0.1) : AppColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: reward.gradient),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: reward.gradient[0].withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      reward.emoji,
                      style: TextStyle(fontSize: screenWidth * 0.06),
                    ),
                  ),
                ),
                
                SizedBox(width: AppSizes.paddingMedium),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: reward.claimed ? AppColors.grey : AppColors.darkBlue,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingXSmall),
                      Text(
                        reward.partner,
                        style: AppTextStyles.bodyText.copyWith(
                          color: reward.claimed ? AppColors.grey : reward.gradient[0],
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status
                if (reward.claimed)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: AppSizes.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      'Claimed',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.green,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            Text(
              reward.description,
              style: AppTextStyles.bodyText.copyWith(
                color: reward.claimed ? AppColors.grey : AppColors.grey.withOpacity(0.8),
                fontSize: screenWidth * 0.035,
              ),
            ),
            
            SizedBox(height: AppSizes.paddingSmall),
            
            // Certificate info
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.yellow,
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: AppSizes.paddingXSmall),
                Text(
                  'Earned from: ${reward.certificateTrigger}',
                  style: AppTextStyles.bodyText.copyWith(
                    color: reward.claimed ? AppColors.grey : AppColors.grey.withOpacity(0.6),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ],
            ),
            
            if (!reward.claimed) ...[
              SizedBox(height: AppSizes.paddingLarge),
              
              // Claim button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _claimReward(reward.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reward.gradient[0],
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMedium,
                    ),
                  ),
                  child: Text(
                    'Claim Reward',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(double screenWidth) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _addNewReward('React Fundamentals'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.paddingLarge,
            ),
            elevation: 10,
            shadowColor: AppColors.yellow.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✨',
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
              SizedBox(width: AppSizes.paddingSmall),
              Text(
                'Earn Certificate (Demo)',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🎁',
                  style: TextStyle(fontSize: screenWidth * 0.15),
                ),
              ),
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            Text(
              'No Rewards Yet',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: screenWidth * 0.06,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            Text(
              'Complete courses and earn certificates to unlock amazing rewards from our partners!',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontSize: screenWidth * 0.04,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.paddingXLarge),
            
            _buildDemoButton(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRewardDialog(double screenWidth, double screenHeight) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              margin: EdgeInsets.all(AppSizes.paddingLarge),
              padding: EdgeInsets.all(AppSizes.paddingXLarge),
              decoration: AppDecorations.cardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated gift icon
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _newReward!.gradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _newReward!.gradient[0].withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '🎁',
                        style: TextStyle(fontSize: screenWidth * 0.1),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSizes.paddingLarge),
                  
                  Text(
                    'New Reward Unlocked! 🎉',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: screenWidth * 0.055,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppSizes.paddingMedium),
                  
                  Text(
                    'You\'ve earned: ${_newReward!.title}',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: _newReward!.gradient[0],
                      fontSize: screenWidth * 0.045,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppSizes.paddingSmall),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.yellow,
                        size: screenWidth * 0.04,
                      ),
                      SizedBox(width: AppSizes.paddingXSmall),
                      Text(
                        'From: ${_newReward!.certificateTrigger}',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
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

// Data model for rewards
class RewardData {
  final String id;
  final String title;
  final String partner;
  final String description;
  final String emoji;
  final List<Color> gradient;
  final bool claimed;
  final String certificateTrigger;

  RewardData({
    required this.id,
    required this.title,
    required this.partner,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.claimed,
    required this.certificateTrigger,
  });

  RewardData copyWith({
    String? id,
    String? title,
    String? partner,
    String? description,
    String? emoji,
    List<Color>? gradient,
    bool? claimed,
    String? certificateTrigger,
  }) {
    return RewardData(
      id: id ?? this.id,
      title: title ?? this.title,
      partner: partner ?? this.partner,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      gradient: gradient ?? this.gradient,
      claimed: claimed ?? this.claimed,
      certificateTrigger: certificateTrigger ?? this.certificateTrigger,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'partner': partner,
      'description': description,
      'emoji': emoji,
      'gradient': gradient.map((c) => c.value).toList(),
      'claimed': claimed,
      'certificateTrigger': certificateTrigger,
    };
  }

  factory RewardData.fromJson(Map<String, dynamic> json) {
    return RewardData(
      id: json['id'],
      title: json['title'],
      partner: json['partner'],
      description: json['description'],
      emoji: json['emoji'],
      gradient: (json['gradient'] as List).map((c) => Color(c)).toList(),
      claimed: json['claimed'],
      certificateTrigger: json['certificateTrigger'],
    );
  }
}