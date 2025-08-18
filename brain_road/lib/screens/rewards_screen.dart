import 'package:flutter/material.dart';
import 'package:brain_road/models/reward_data.dart';
import 'package:brain_road/services/user_preferences.dart';
import 'package:brain_road/constants/rewards_constants.dart';
import 'package:brain_road/styles/app_styles.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late Future<List<RewardData>> _rewardsFuture;

  @override
  void initState() {
    super.initState();
    _rewardsFuture = UserPreferences.getRewards();
  }

  Future<void> _refreshRewards() async {
    setState(() {
      _rewardsFuture = UserPreferences.getRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: AppColors.darkBlue,
      ),
      body: FutureBuilder<List<RewardData>>(
        future: _rewardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading rewards'));
          }
          final rewards = snapshot.data ?? [];
          if (rewards.isEmpty) {
            return Center(child: Text('No rewards received yet'));
          }
          return RefreshIndicator(
            onRefresh: _refreshRewards,
            child: ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                    vertical: AppSizes.paddingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: reward.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                    child: ListTile(
                      leading: Text(
                        reward.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        reward.title,
                        style: AppTextStyles.cardTitle,
                      ),
                      subtitle: Text(
                        '${reward.partner}\n${reward.description}',
                        style: AppTextStyles.bodyText,
                      ),
                      trailing: reward.claimed
                          ? Icon(Icons.check_circle, color: AppColors.green)
                          : Icon(Icons.card_giftcard, color: AppColors.yellow),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}