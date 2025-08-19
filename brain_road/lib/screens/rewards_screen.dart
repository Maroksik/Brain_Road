// lib/screens/rewards_screen.dart

import 'package:brain_road/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:brain_road/models/reward_data.dart';
import 'package:brain_road/services/user_preferences.dart';
import 'package:brain_road/widgets/gift_barcode_dialog.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  List<RewardData> _rewards = [];
  bool _isLoading = true;

  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRewards();
  }

  void _initAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
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

  Future<void> _loadRewards() async {
    try {
      final rewards = await UserPreferences.getRewards();
      setState(() {
        _rewards = rewards;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rewards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRewards() async {
    await _loadRewards();
  }

  void _activateReward(RewardData reward) async {
    // Показуємо діалог зі штрихкодом замість простого діалогу
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GiftBarcodeDialog(reward: reward),
    );

    // Позначаємо винагороду як використану
    await UserPreferences.updateReward(reward.id, true);

    // Оновлюємо UI
    _refreshRewards();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        title: Text(
          'My Rewards',
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.yellow,
            fontSize: screenWidth * 0.06,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.yellow,
            size: screenWidth * 0.06,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _rewards.isEmpty
              ? _buildEmptyState(screenWidth)
              : RefreshIndicator(
                  onRefresh: _refreshRewards,
                  color: AppColors.yellow,
                  backgroundColor: AppColors.white,
                  child: Column(
                    children: [
                      // Статистика
                      _buildStatsHeader(screenWidth),
                      
                      // Список винагород
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.02,
                          ),
                          itemCount: _rewards.length,
                          itemBuilder: (context, index) {
                            return _buildGiftCard(_rewards[index], screenWidth);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsHeader(double screenWidth) {
    final totalRewards = _rewards.length;
    final claimedRewards = _rewards.where((r) => r.claimed).length;
    final availableRewards = totalRewards - claimedRewards;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.yellow.withOpacity(0.1), AppColors.green.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.yellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('All', totalRewards.toString(), Icons.card_giftcard, AppColors.yellow),
          _buildStatItem('Available', availableRewards.toString(), Icons.notifications_active, AppColors.green),
          _buildStatItem('Claimed', claimedRewards.toString(), Icons.check_circle, AppColors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.darkBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.darkBlue,
          ),
        ),
      ],
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
                        ? [AppColors.lightGrey, AppColors.grey]
                        : reward.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isActivated 
                          ? AppColors.grey.withOpacity(0.2)
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
                                            ? AppColors.grey
                                            : AppColors.yellow,
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
                                      ? AppColors.green.withOpacity(0.2)
                                      : AppColors.yellow.withOpacity(0.2),
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
                                          ? AppColors.green
                                          : AppColors.yellow,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActivated ? 'Claimed' : 'Ready',
                                        style: TextStyle(
                                          color: isActivated 
                                            ? AppColors.green
                                            : AppColors.yellow,
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
                                  ? AppColors.grey
                                  : AppColors.white,
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
                                  ? AppColors.grey
                                  : AppColors.white.withOpacity(0.8),
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
                                  ? AppColors.grey
                                  : AppColors.white.withOpacity(0.8),
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
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.yellow.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _activateReward(reward),
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.darkBlue,
                          size: 24,
                        ),
                        tooltip: 'Get Barcode',
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
            'No rewards yet',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: screenWidth * 0.06,
              color: AppColors.yellow,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'Take quizzes and earn certificates \nto unlock great rewards!',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: screenWidth * 0.04,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}