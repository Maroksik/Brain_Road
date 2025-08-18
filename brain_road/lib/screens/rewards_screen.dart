import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brain_road/models/reward_data.dart';
import 'package:brain_road/services/user_preferences.dart';
import 'package:brain_road/constants/rewards_constants.dart';
import 'package:brain_road/styles/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  Future<void> _saveRewards(List<RewardData> rewards) async {
    try {
      await UserPreferences.init();
      
      final rewardsJson = rewards.map((reward) => reward.toJson()).toList();
      final rewardsString = jsonEncode(rewardsJson);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rewards', rewardsString);
      print('✅ Rewards saved successfully');
    } catch (e) {
      print('❌ Error saving rewards: $e');
    }
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  late Future<List<RewardData>> _rewardsFuture;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _rewardsFuture = UserPreferences.getRewards();
    _initAnimations();
  }

  void _initAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _bounceController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _refreshRewards() async {
    setState(() {
      _rewardsFuture = UserPreferences.getRewards();
    });
  }

  Future<void> _activateReward(RewardData reward) async {
    HapticFeedback.mediumImpact();
    
    // Анімація активації
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildActivationDialog(reward),
    );

    // Оновлюємо статус винагороди
    final updatedReward = RewardData(
      id: reward.id,
      title: reward.title,
      partner: reward.partner,
      description: reward.description,
      emoji: reward.emoji,
      gradient: reward.gradient,
      claimed: true,
      certificateTrigger: reward.certificateTrigger,
    );

    // Оновлюємо статус винагороди в локальному сховищі
    await UserPreferences.updateReward(reward.id, true);

    // Оновлюємо UI
    _refreshRewards();
  }

  Widget _buildActivationDialog(RewardData reward) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: reward.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: reward.gradient[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Анімований емодзі
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Text(
                      reward.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Заголовок
            Text(
              'Congratulations!',
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Назва подарка
            Text(
              reward.title,
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Партнер
            Text(
              'from ${reward.partner}',
              style: AppTextStyles.bodyText.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Опис
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reward.description,
                style: AppTextStyles.bodyText.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Кнопка закриття
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: reward.gradient[0],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftCard(RewardData reward, double screenWidth) {
    final isActivated = reward.claimed;
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_bounceAnimation.value * 0.2),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            child: Stack(
              children: [
                // Основна карточка
                Container(
                  height: screenWidth * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActivated 
                        ? [Colors.grey[300]!, Colors.grey[400]!]
                        : reward.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isActivated 
                          ? Colors.grey.withOpacity(0.2)
                          : reward.gradient[0].withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: isActivated ? null : () => _activateReward(reward),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Верхній рядок з емодзі та статусом
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Анімований емодзі
                                AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 3 * _floatAnimation.value),
                                      child: Text(
                                        reward.emoji,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.12,
                                          color: isActivated 
                                            ? Colors.grey[600]
                                            : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Статус
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActivated 
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isActivated 
                                          ? Icons.check_circle
                                          : Icons.card_giftcard,
                                        size: 16,
                                        color: isActivated 
                                          ? Colors.green[700]
                                          : Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActivated ? 'Used' : 'Ready',
                                        style: TextStyle(
                                          color: isActivated 
                                            ? Colors.green[700]
                                            : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Назва винагороди
                            Text(
                              reward.title,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: isActivated 
                                  ? Colors.grey[700]
                                  : Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Партнер
                            Text(
                              reward.partner,
                              style: AppTextStyles.bodyText.copyWith(
                                color: isActivated 
                                  ? Colors.grey[600]
                                  : Colors.white.withOpacity(0.9),
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Опис
                            Text(
                              reward.description,
                              style: AppTextStyles.bodyText.copyWith(
                                color: isActivated 
                                  ? Colors.grey[600]
                                  : Colors.white.withOpacity(0.8),
                                fontSize: screenWidth * 0.032,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Кнопка активації (тільки для неактивованих)
                if (!isActivated)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _activateReward(reward),
                        icon: Icon(
                          Icons.touch_app,
                          color: reward.gradient[0],
                          size: 24,
                        ),
                        tooltip: 'Tap to activate',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * _floatAnimation.value),
                child: Text(
                  '🎁',
                  style: TextStyle(fontSize: screenWidth * 0.2),
                ),
              );
            },
          ),
          
          SizedBox(height: screenWidth * 0.05),
          
          Text(
            'No Rewards Yet',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: screenWidth * 0.06,
              color: AppColors.grey,
            ),
          ),
          
          SizedBox(height: screenWidth * 0.02),
          
          Text(
            'Complete quizzes and earn certificates\nto unlock amazing rewards!',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: screenWidth * 0.04,
              color: AppColors.grey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenWidth * 0.08),
          
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/quizzes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenWidth * 0.04,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Learning',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding;
    
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Кастомний app bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Кнопка назад
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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
                  
                  // Іконка та заголовок
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🎁',
                            style: TextStyle(fontSize: screenWidth * 0.06),
                          ),
                        ),
                        
                        SizedBox(width: screenWidth * 0.03),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Rewards',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<List<RewardData>>(
                              future: _rewardsFuture,
                              builder: (context, snapshot) {
                                final rewards = snapshot.data ?? [];
                                final unclaimedCount = rewards
                                    .where((r) => !r.claimed)
                                    .length;
                                return Text(
                                  '$unclaimedCount available',
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.grey.withOpacity(0.7),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Кнопка оновлення
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _refreshRewards,
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.grey,
                        size: screenWidth * 0.06,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Контент
            Expanded(
              child: FutureBuilder<List<RewardData>>(
                future: _rewardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.darkBlue,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          Text(
                            'Loading your rewards...',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: screenWidth * 0.15,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          Text(
                            'Error loading rewards',
                            style: AppTextStyles.cardTitle.copyWith(
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          ElevatedButton(
                            onPressed: _refreshRewards,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final rewards = snapshot.data ?? [];
                  
                  if (rewards.isEmpty) {
                    return _buildEmptyState(screenWidth);
                  }
                  
                  // Сортуємо: неактивовані спершу
                  rewards.sort((a, b) {
                    if (a.claimed == b.claimed) return 0;
                    return a.claimed ? 1 : -1;
                  });
                  
                  return RefreshIndicator(
                    onRefresh: _refreshRewards,
                    color: AppColors.darkBlue,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.02,
                      ),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        return _buildGiftCard(rewards[index], screenWidth);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}