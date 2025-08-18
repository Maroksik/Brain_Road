// lib/models/brain_road_certificate.dart

/// Модель сертифіката для дітей в Brain Road додатку
/// Використовується для зберігання інформації про отримані сертифікати після проходження квізів
class BrainRoadCertificate {
  /// Унікальний ідентифікатор сертифіката
  final String id;
  
  /// ID квіза, за який отримано сертифікат
  final String quizId;
  
  /// Категорія/назва курсу (наприклад: "Logic & Patterns", "Math Basics")
  final String category;
  
  /// Кількість правильних відповідей
  final int score;
  
  /// Загальна кількість питань у квізі
  final int totalQuestions;
  
  /// Відсоток правильних відповідей (0-100)
  final int percentage;
  
  /// Кількість зірок (0-3) залежно від результату
  final int stars;
  
  /// Дата та час отримання сертифіката
  final DateTime earnedDate;
  
  /// Ім'я дитини
  final String childName;
  
  /// Аватар дитини (emoji)
  final String childAvatar;
  
  /// Вік дитини
  final String childAge;

  /// Конструктор для створення нового сертифіката
  BrainRoadCertificate({
    required this.id,
    required this.quizId,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.stars,
    required this.earnedDate,
    required this.childName,
    required this.childAvatar,
    required this.childAge,
  });

  /// Конвертація сертифіката в JSON для збереження
  Map<String, dynamic> toJson() => {
    'id': id,
    'quizId': quizId,
    'category': category,
    'score': score,
    'totalQuestions': totalQuestions,
    'percentage': percentage,
    'stars': stars,
    'earnedDate': earnedDate.toIso8601String(),
    'childName': childName,
    'childAvatar': childAvatar,
    'childAge': childAge,
  };

  /// Створення сертифіката з JSON даних
  factory BrainRoadCertificate.fromJson(Map<String, dynamic> json) => BrainRoadCertificate(
    id: json['id'] as String,
    quizId: json['quizId'] as String,
    category: json['category'] as String,
    score: json['score'] as int,
    totalQuestions: json['totalQuestions'] as int,
    percentage: json['percentage'] as int,
    stars: json['stars'] as int,
    earnedDate: DateTime.parse(json['earnedDate'] as String),
    childName: json['childName'] as String,
    childAvatar: json['childAvatar'] as String,
    childAge: json['childAge'] as String,
  );

  /// Створення копії сертифіката з можливістю зміни окремих полів
  BrainRoadCertificate copyWith({
    String? id,
    String? quizId,
    String? category,
    int? score,
    int? totalQuestions,
    int? percentage,
    int? stars,
    DateTime? earnedDate,
    String? childName,
    String? childAvatar,
    String? childAge,
  }) {
    return BrainRoadCertificate(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      category: category ?? this.category,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      percentage: percentage ?? this.percentage,
      stars: stars ?? this.stars,
      earnedDate: earnedDate ?? this.earnedDate,
      childName: childName ?? this.childName,
      childAvatar: childAvatar ?? this.childAvatar,
      childAge: childAge ?? this.childAge,
    );
  }

  /// Перевірка, чи пройдено квіз успішно (>=80%)
  bool get isPassed => percentage >= 80;

  /// Перевірка, чи результат відмінний (>=90%)
  bool get isExcellent => percentage >= 90;

  /// Отримання текстової оцінки результату
  String get gradeText {
    if (percentage >= 90) return 'Excellent!';
    if (percentage >= 80) return 'Great!';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Fair';
    return 'Keep practicing!';
  }

  /// Отримання кольору зірок залежно від результату
  String get starColor {
    if (stars >= 3) return 'gold';
    if (stars >= 2) return 'silver';
    if (stars >= 1) return 'bronze';
    return 'gray';
  }

  /// Форматована дата для відображення
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(earnedDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${earnedDate.day}/${earnedDate.month}/${earnedDate.year}';
    }
  }

  /// Перевірка рівності двох сертифікатів
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrainRoadCertificate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// Хеш код для сертифіката
  @override
  int get hashCode => id.hashCode;

  /// Строкове представлення сертифіката для відладки
  @override
  String toString() {
    return 'BrainRoadCertificate{id: $id, category: $category, score: $score/$totalQuestions ($percentage%), stars: $stars, child: $childName}';
  }
}