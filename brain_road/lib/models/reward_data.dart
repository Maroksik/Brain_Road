import 'package:flutter/material.dart';

class RewardData {
  final String id;
  final String title;
  final String partner;
  final String description;
  final String emoji;
  final List<Color> gradient;
  final bool claimed;
  final String? certificateTrigger;

  RewardData({
    required this.id,
    required this.title,
    required this.partner,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.claimed,
    this.certificateTrigger,
  });

  factory RewardData.fromJson(Map<String, dynamic> json) => RewardData(
    id: json['id'] as String,
    title: json['title'] as String,
    partner: json['partner'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String,
    gradient: (json['gradient'] as List).map((c) => Color(c as int)).toList(),
    claimed: json['claimed'] as bool,
    certificateTrigger: json['certificateTrigger'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'partner': partner,
    'description': description,
    'emoji': emoji,
    'gradient': gradient.map((c) => c.value).toList(),
    'claimed': claimed,
    'certificateTrigger': certificateTrigger,
  };

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
}
