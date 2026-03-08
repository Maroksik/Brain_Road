// Створіть файл lib/constants/rewards_constants.dart

import 'package:flutter/material.dart';
import 'package:think_and_solve/models/reward_data.dart';

class RewardsConstants {
  
  // Мапа винагород для різних категорій сертифікатів
  static final Map<String, List<RewardTemplate>> categoryRewards = {
    'Logic & Patterns': [
      RewardTemplate(
        title: 'Free Ice Cream Cone',
        partner: 'Cinema Plus',
        description: 'Enjoy a delicious scoop of premium gelato',
        emoji: '🍦',
        gradient: [const Color(0xFFFFD54F), const Color(0xFFFFE082)],
      ),
      RewardTemplate(
        title: 'Brain Game Session',
        partner: 'TechnoLab',
        description: 'Free 30-minute brain training session',
        emoji: '🧩',
        gradient: [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
      ),
    ],
    
    'Math Basics': [
      RewardTemplate(
        title: '1 Hour Gaming Zone',
        partner: 'GameMaster Arena',
        description: 'Free hour in our premium gaming zone',
        emoji: '🎮',
        gradient: [const Color(0xFF66BB6A), const Color(0xFF81C784)],
      ),
      RewardTemplate(
        title: 'Math Kit Discount',
        partner: 'KidsLearn Academy',
        description: '25% off on educational math kits',
        emoji: '🔢',
        gradient: [const Color(0xFF9C27B0), const Color(0xFFCE93D8)],
      ),
    ],
    
    'Memory Games': [
      RewardTemplate(
        title: 'Free Pastry',
        partner: 'AquaWorld',
        description: 'Complimentary coffee and fresh pastry',
        emoji: '☕',
        gradient: [const Color(0xFFFF8A65), const Color(0xFFFFAB91)],
      ),
      RewardTemplate(
        title: 'Memory Cards Set',
        partner: 'FunZone Arcade',
        description: 'Premium memory training card set',
        emoji: '🃏',
        gradient: [const Color(0xFFFFB74D), const Color(0xFFFFCC02)],
      ),
    ],
    
    'Word Puzzles': [
      RewardTemplate(
        title: '20% Off Shopping',
        partner: 'TechStore',
        description: '20% discount on any tech accessories',
        emoji: '🛍️',
        gradient: [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
      ),
      RewardTemplate(
        title: 'Art Supplies Kit',
        partner: 'Creative Corner',
        description: 'Complete drawing and painting set',
        emoji: '🎨',
        gradient: [const Color(0xFF8E24AA), const Color(0xFFBA68C8)],
      ),
    ],
    
    'Problem Solving': [
      RewardTemplate(
        title: 'Free Book Voucher',
        partner: 'BookWorm Library',
        description: 'Choose any programming book for free',
        emoji: '📚',
        gradient: [const Color(0xFF5C6BC0), const Color(0xFF7986CB)],
      ),
      RewardTemplate(
        title: 'Puzzle Challenge Box',
        partner: 'Mind Games Co.',
        description: 'Collection of challenging puzzles',
        emoji: '🧩',
        gradient: [const Color(0xFF26A69A), const Color(0xFF4DB6AC)],
      ),
    ],
    
    'Spatial Thinking': [
      RewardTemplate(
        title: 'Pizza Party Voucher',
        partner: 'Code & Pizza',
        description: 'Free personal pizza and drink',
        emoji: '🍕',
        gradient: [const Color(0xFFFF7043), const Color(0xFFFF8A65)],
      ),
      RewardTemplate(
        title: 'Building Blocks Set',
        partner: 'Constructor Zone',
        description: 'Advanced 3D building blocks kit',
        emoji: '🧱',
        gradient: [const Color(0xFF78909C), const Color(0xFF90A4AE)],
      ),
    ],
    
    'Brain Training': [
      RewardTemplate(
        title: 'Mystery Surprise Box',
        partner: 'Think & Solve Academy',
        description: 'Special surprise gift for top performers',
        emoji: '🎁',
        gradient: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      ),
    ],
  };

  // Отримання випадкової винагороди для категорії
  static RewardData? getRandomRewardForCategory(String category) {
    final templates = categoryRewards[category];
    if (templates == null || templates.isEmpty) return null;
    
    final random = DateTime.now().millisecond % templates.length;
    final template = templates[random];
    
    return RewardData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: template.title,
      partner: template.partner,
      description: template.description,
      emoji: template.emoji,
      gradient: template.gradient,
      claimed: false,
      certificateTrigger: category,
    );
  }

  // Отримання всіх можливих винагород для категорії
  static List<RewardData> getAllRewardsForCategory(String category) {
    final templates = categoryRewards[category];
    if (templates == null) return [];
    
    return templates.map((template) => RewardData(
      id: '${category}_${template.title}_${DateTime.now().millisecondsSinceEpoch}',
      title: template.title,
      partner: template.partner,
      description: template.description,
      emoji: template.emoji,
      gradient: template.gradient,
      claimed: false,
      certificateTrigger: category,
    )).toList();
  }

  // Отримання списку всіх партнерів
  static List<String> getAllPartners() {
    final partners = <String>{};
    for (final templates in categoryRewards.values) {
      for (final template in templates) {
        partners.add(template.partner);
      }
    }
    return partners.toList();
  }

  // Отримання статистики винагород по категоріях
  static Map<String, int> getRewardsCountByCategory() {
    return categoryRewards.map((key, value) => MapEntry(key, value.length));
  }

  // Перевірка чи існує категорія
  static bool categoryExists(String category) {
    return categoryRewards.containsKey(category);
  }

  // Отримання кольорів для категорії
  static List<Color> getColorsForCategory(String category) {
    final templates = categoryRewards[category];
    if (templates == null || templates.isEmpty) {
      return [const Color(0xFF2196F3), const Color(0xFF64B5F6)]; // Default blue
    }
    return templates.first.gradient;
  }
}

// Шаблон винагороди
class RewardTemplate {
  final String title;
  final String partner;
  final String description;
  final String emoji;
  final List<Color> gradient;

  const RewardTemplate({
    required this.title,
    required this.partner,
    required this.description,
    required this.emoji,
    required this.gradient,
  });
}