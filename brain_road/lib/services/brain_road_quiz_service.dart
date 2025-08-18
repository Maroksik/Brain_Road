import 'package:brain_road/services/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:brain_road/models/brain_road_certificate.dart';

class BrainRoadQuizService {
  static const String _completedQuizzesKey = 'br_completed_quizzes';
  static const String _certificatesKey = 'br_earned_certificates';
  static const String _quizScoresKey = 'br_quiz_scores';
  static const String _quizAttemptsKey = 'br_quiz_attempts';

  // Отримати пройдені квізи
  static Future<Set<String>> getCompletedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_completedQuizzesKey) ?? [];
    return completedList.toSet();
  }

  // Позначити квіз як пройдений
  static Future<void> markQuizCompleted(String quizId, int score, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Додаємо квіз до пройдених
    final completed = await getCompletedQuizzes();
    completed.add(quizId);
    await prefs.setStringList(_completedQuizzesKey, completed.toList());
    
    // Зберігаємо результат
    final scores = await getQuizScores();
    scores[quizId] = {
      'score': score, 
      'total': totalQuestions, 
      'percentage': (score / totalQuestions * 100).round(),
      'stars': calculateStars(score, totalQuestions),
      'completedAt': DateTime.now().toIso8601String(),
    };
    await _saveQuizScores(scores);
    
    // Оновлюємо кількість спроб
    await _incrementQuizAttempts(quizId);
    
    // Генеруємо нагороду якщо результат достатньо високий (80%+)
    if ((score / totalQuestions * 100) >= 80) {
      await _generateCertificate(quizId, score, totalQuestions);
    }
  }

  // Розрахувати кількість зірок (1-3)
  static int calculateStars(int score, int totalQuestions) {
    final percentage = (score / totalQuestions * 100);
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    return 1;
  }

  // Отримати результати квізів
  static Future<Map<String, Map<String, dynamic>>> getQuizScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresString = prefs.getString(_quizScoresKey) ?? '{}';
    final scoresJson = json.decode(scoresString) as Map<String, dynamic>;
    
    return scoresJson.map((key, value) => MapEntry(
      key, 
      Map<String, dynamic>.from(value as Map)
    ));
  }

  static Future<void> generateCertificateWithReward(
    String quizId, 
    int score, 
    int totalQuestions
  ) async {
    try {
      print('🎓 Generating certificate with reward for quiz: $quizId');
      
      // Створюємо сертифікат
      await _generateCertificate(quizId, score, totalQuestions);
      
      // Отримуємо категорію
      final category = _getCategoryByQuizId(quizId);
      
      // Додаємо винагороду
      await UserPreferences.addRewardForCertificate(category);
      
      print('✅ Certificate and reward generated successfully');
      
    } catch (e) {
      print('❌ Error generating certificate with reward: $e');
      // Принаймні створюємо сертифікат
      try {
        await _generateCertificate(quizId, score, totalQuestions);
        print('✅ Certificate created without reward');
      } catch (certError) {
        print('❌ Certificate creation failed: $certError');
      }
    }
  }

  static Future<void> _saveQuizScores(Map<String, Map<String, dynamic>> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quizScoresKey, json.encode(scores));
  }

  // Оновити кількість спроб
  static Future<void> _incrementQuizAttempts(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = await getQuizAttempts();
    attempts[quizId] = (attempts[quizId] ?? 0) + 1;
    await prefs.setString(_quizAttemptsKey, json.encode(attempts));
  }

  // Отримати кількість спроб
  static Future<Map<String, int>> getQuizAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attemptsString = prefs.getString(_quizAttemptsKey) ?? '{}';
    final attemptsJson = json.decode(attemptsString) as Map<String, dynamic>;
    
    return attemptsJson.map((key, value) => MapEntry(key, value as int));
  }

  // Генерувати нагороду/сертифікат
  static Future<void> _generateCertificate(String quizId, int score, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();
    final certificates = await getCertificates();

    final category = _getCategoryByQuizId(quizId);

    final certificate = BrainRoadCertificate(
      id: 'cert_${quizId}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: quizId,
      category: category,
      score: score,
      totalQuestions: totalQuestions,
      percentage: (score / totalQuestions * 100).round(),
      stars: calculateStars(score, totalQuestions),
      earnedDate: DateTime.now(),
      childName: prefs.getString('user_name') ?? '',
      childAvatar: prefs.getString('user_avatar') ?? '🧠',
      childAge: prefs.getString('user_age') ?? '',
    );

    certificates.add(certificate);
    await _saveCertificates(certificates);

    // Додаємо подарунковий сертифікат від партнерів автоматично
    await UserPreferences.addRewardForCertificate(category);
  }

  // Отримати сертифікати
  static Future<List<BrainRoadCertificate>> getCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final certificatesString = prefs.getString(_certificatesKey) ?? '[]';
    final certificatesJson = json.decode(certificatesString) as List;
    
    return certificatesJson.map((cert) => BrainRoadCertificate.fromJson(cert)).toList();
  }

  static Future<void> _saveCertificates(List<BrainRoadCertificate> certificates) async {
    final prefs = await SharedPreferences.getInstance();
    final certificatesJson = certificates.map((cert) => cert.toJson()).toList();
    await prefs.setString(_certificatesKey, json.encode(certificatesJson));
  }

  // Перевірити чи квіз пройдений
  static Future<bool> isQuizCompleted(String quizId) async {
    final completed = await getCompletedQuizzes();
    return completed.contains(quizId);
  }

  // Отримати кількість пройдених квізів
  static Future<int> getCompletedQuizzesCount() async {
    final completed = await getCompletedQuizzes();
    return completed.length;
  }

  // Отримати категорію по ID квіза
  static String _getCategoryByQuizId(String quizId) {
    switch (quizId) {
      case 'logic_patterns_quiz': return 'Logic & Patterns';
      case 'math_basics_quiz': return 'Math Basics';
      case 'problem_solving_quiz': return 'Problem Solving';
      case 'memory_games_quiz': return 'Memory Games';
      case 'spatial_thinking_quiz': return 'Spatial Thinking';
      case 'word_puzzles_quiz': return 'Word Puzzles';
      default: return 'Logic Games';
    }
  }

  // Скинути всі дані (для тестування)
  static Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedQuizzesKey);
    await prefs.remove(_certificatesKey);
    await prefs.remove(_quizScoresKey);
    await prefs.remove(_quizAttemptsKey);
  }

  // Статистика для дитини
  static Future<Map<String, dynamic>> getOverallStatistics() async {
    final completed = await getCompletedQuizzes();
    final certificates = await getCertificates();
    final scores = await getQuizScores();
    
    double averageScore = 0;
    int totalStars = 0;
    
    if (scores.isNotEmpty) {
      final totalPercentage = scores.values.fold(0, (sum, score) => sum + (score['percentage'] as int));
      averageScore = totalPercentage / scores.length;
      
      totalStars = scores.values.fold(0, (sum, score) => sum + (score['stars'] as int));
    }
    
    return {
      'completedQuizzes': completed.length,
      'earnedCertificates': certificates.length,
      'averageScore': averageScore.round(),
      'totalQuizzes': brainRoadQuizData.length,
      'totalStars': totalStars,
      'maxStars': brainRoadQuizData.length * 3,
      'level': _calculateChildLevel(completed.length, totalStars),
    };
  }

  // Розрахувати рівень дитини
  static String _calculateChildLevel(int completedQuizzes, int totalStars) {
    if (completedQuizzes == 0) return 'Beginner';
    if (totalStars >= 15) return 'Logic Master';
    if (totalStars >= 10) return 'Smart Thinker';
    if (completedQuizzes >= 3) return 'Quick Learner';
    return 'Young Explorer';
  }

  // Отримати рекомендації для наступного квіза
  static Future<String?> getRecommendedQuiz() async {
    final completed = await getCompletedQuizzes();
    final scores = await getQuizScores();
    
    // Знайти квіз з найменшою кількістю зірок для повторного проходження
    String? retryQuiz;
    int minStars = 4;
    
    for (final entry in scores.entries) {
      final stars = entry.value['stars'] as int;
      if (stars < minStars) {
        minStars = stars;
        retryQuiz = entry.key;
      }
    }
    
    // Якщо є квіз з 1-2 зірками, рекомендуємо його
    if (retryQuiz != null && minStars < 3) {
      return retryQuiz;
    }
    
    // Інакше рекомендуємо новий квіз
    for (final quiz in brainRoadQuizData) {
      if (!completed.contains(quiz.id)) {
        return quiz.id;
      }
    }
    
    return null; // Всі квізи пройдені
  }
}

// Модель питання квіза для дітей
class BrainRoadQuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? imageHint; // Для візуальних підказок
  final QuestionType type;

  BrainRoadQuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.imageHint,
    this.type = QuestionType.multipleChoice,
  });
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  visual,
  sequence,
}

// Модель квіза для дітей
class BrainRoadQuiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<BrainRoadQuizQuestion> questions;
  final int timeLimit; // в хвилинах
  final int passingScore; // мінімальний відсоток для проходження
  final String ageGroup; // '5-7', '8-10', '11-13'
  final String emoji;
  final DifficultyLevel difficulty;

  BrainRoadQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    required this.timeLimit,
    required this.passingScore,
    required this.ageGroup,
    required this.emoji,
    required this.difficulty,
  });
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

// Дані квізів для Brain Road
final List<BrainRoadQuiz> brainRoadQuizData = [
  BrainRoadQuiz(
    id: 'logic_patterns_quiz',
    title: 'Logic & Patterns',
    description: 'Find patterns and complete sequences',
    category: 'Logic & Patterns',
    emoji: '🧩',
    ageGroup: '5-7',
    difficulty: DifficultyLevel.easy,
    timeLimit: 10,
    passingScore: 60,
    questions: [
      BrainRoadQuizQuestion(
        question: 'What comes next in this pattern: 🟦 🟩 🟦 🟩 ?',
        options: ['🟦', '🟩', '🟨', '🟪'],
        correctAnswerIndex: 0,
        explanation: 'The pattern alternates: blue, green, blue, green, so next is blue!',
        type: QuestionType.visual,
      ),
      BrainRoadQuizQuestion(
        question: 'Complete the sequence: 2, 4, 6, 8, ?',
        options: ['9', '10', '11', '12'],
        correctAnswerIndex: 1,
        explanation: 'Each number increases by 2: 2+2=4, 4+2=6, 6+2=8, 8+2=10',
      ),
      BrainRoadQuizQuestion(
        question: 'Which shape is different?',
        options: ['🔴 Circle', '🔵 Circle', '⬜ Square', '🟢 Circle'],
        correctAnswerIndex: 2,
        explanation: 'All others are circles, but the square is different!',
        type: QuestionType.visual,
      ),
      BrainRoadQuizQuestion(
        question: 'What comes next: A, B, C, D, ?',
        options: ['E', 'F', 'G', 'H'],
        correctAnswerIndex: 0,
        explanation: 'The alphabet continues: A, B, C, D, E',
      ),
      BrainRoadQuizQuestion(
        question: 'How many sides does a triangle have?',
        options: ['2', '3', '4', '5'],
        correctAnswerIndex: 1,
        explanation: 'A triangle always has exactly 3 sides!',
      ),
    ],
  ),
  
  BrainRoadQuiz(
    id: 'math_basics_quiz',
    title: 'Math Adventures',
    description: 'Fun with numbers and counting',
    category: 'Math Basics',
    emoji: '🔢',
    ageGroup: '5-7',
    difficulty: DifficultyLevel.easy,
    timeLimit: 8,
    passingScore: 70,
    questions: [
      BrainRoadQuizQuestion(
        question: 'What is 3 + 2?',
        options: ['4', '5', '6', '7'],
        correctAnswerIndex: 1,
        explanation: '3 apples + 2 apples = 5 apples!',
      ),
      BrainRoadQuizQuestion(
        question: 'Which number is bigger: 7 or 4?',
        options: ['7', '4', 'They are equal', 'Cannot tell'],
        correctAnswerIndex: 0,
        explanation: '7 is bigger than 4. You can count: 1,2,3,4,5,6,7!',
      ),
      BrainRoadQuizQuestion(
        question: 'Count the stars: ⭐⭐⭐⭐⭐',
        options: ['4', '5', '6', '3'],
        correctAnswerIndex: 1,
        explanation: 'Count carefully: 1⭐, 2⭐, 3⭐, 4⭐, 5⭐ = 5 stars!',
        type: QuestionType.visual,
      ),
      BrainRoadQuizQuestion(
        question: 'What is 10 - 3?',
        options: ['6', '7', '8', '9'],
        correctAnswerIndex: 1,
        explanation: 'Start with 10, take away 3: 10-3=7',
      ),
      BrainRoadQuizQuestion(
        question: 'Which shape has 4 equal sides?',
        options: ['Triangle', 'Circle', 'Square', 'Line'],
        correctAnswerIndex: 2,
        explanation: 'A square has 4 sides that are all the same length!',
        type: QuestionType.visual,
      ),
    ],
  ),
  
  BrainRoadQuiz(
    id: 'problem_solving_quiz',
    title: 'Problem Solvers',
    description: 'Think smart and find solutions',
    category: 'Problem Solving',
    emoji: '🤔',
    ageGroup: '8-10',
    difficulty: DifficultyLevel.medium,
    timeLimit: 12,
    passingScore: 70,
    questions: [
      BrainRoadQuizQuestion(
        question: 'If you have 10 candies and give 3 to your friend, how many do you have left?',
        options: ['6', '7', '8', '9'],
        correctAnswerIndex: 1,
        explanation: 'You start with 10 candies, give away 3, so 10-3=7 candies left',
      ),
      BrainRoadQuizQuestion(
        question: 'A cat is stuck in a tree. What should you do first?',
        options: ['Climb the tree yourself', 'Ask an adult for help', 'Throw rocks at the cat', 'Ignore it'],
        correctAnswerIndex: 1,
        explanation: 'Always ask a grown-up for help in difficult situations. Safety first!',
      ),
      BrainRoadQuizQuestion(
        question: 'You need to be at school at 8:00. It takes 20 minutes to get ready and 10 minutes to walk. What time should you wake up?',
        options: ['7:30', '7:45', '8:00', '7:00'],
        correctAnswerIndex: 0,
        explanation: 'Work backwards: 8:00 - 10 min walk - 20 min ready = 7:30',
      ),
      BrainRoadQuizQuestion(
        question: 'If today is Monday, what day will it be in 3 days?',
        options: ['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        correctAnswerIndex: 2,
        explanation: 'Count forward: Monday+1=Tuesday, +2=Wednesday, +3=Thursday',
      ),
      BrainRoadQuizQuestion(
        question: 'You have 4 red balls and 6 blue balls. How many balls do you have in total?',
        options: ['8', '9', '10', '11'],
        correctAnswerIndex: 2,
        explanation: 'Add them together: 4 red balls + 6 blue balls = 10 balls total',
      ),
    ],
  ),
  
  BrainRoadQuiz(
    id: 'memory_games_quiz',
    title: 'Memory Masters',
    description: 'Test and improve your memory',
    category: 'Memory Games',
    emoji: '🧠',
    ageGroup: '8-10',
    difficulty: DifficultyLevel.medium,
    timeLimit: 15,
    passingScore: 60,
    questions: [
      BrainRoadQuizQuestion(
        question: 'Remember these items: 🍎🐕📚. Which one was first?',
        options: ['🐕 Dog', '📚 Book', '🍎 Apple', '🏀 Ball'],
        correctAnswerIndex: 2,
        explanation: 'The apple 🍎 was first in the sequence!',
        type: QuestionType.visual,
      ),
      BrainRoadQuizQuestion(
        question: 'Study this: CAT, DOG, BIRD. Which animal was in the middle?',
        options: ['CAT', 'DOG', 'BIRD', 'FISH'],
        correctAnswerIndex: 1,
        explanation: 'DOG was the middle word in the sequence: CAT, DOG, BIRD',
      ),
      BrainRoadQuizQuestion(
        question: 'Look at these numbers: 5, 2, 8, 1. What was the largest number?',
        options: ['5', '2', '8', '1'],
        correctAnswerIndex: 2,
        explanation: '8 was the largest number in the sequence: 5, 2, 8, 1',
      ),
      BrainRoadQuizQuestion(
        question: 'Remember: RED, BLUE, GREEN, YELLOW. Which color was third?',
        options: ['RED', 'BLUE', 'GREEN', 'YELLOW'],
        correctAnswerIndex: 2,
        explanation: 'GREEN was the third color: RED(1st), BLUE(2nd), GREEN(3rd), YELLOW(4th)',
      ),
      BrainRoadQuizQuestion(
        question: 'These letters appeared: X, M, P, K. Which letter comes first in the alphabet?',
        options: ['X', 'M', 'P', 'K'],
        correctAnswerIndex: 3,
        explanation: 'In alphabetical order: K comes before M, which comes before P, which comes before X',
      ),
    ],
  ),
  
  BrainRoadQuiz(
    id: 'spatial_thinking_quiz',
    title: 'Space & Shapes',
    description: 'Think about shapes and space',
    category: 'Spatial Thinking',
    emoji: '📐',
    ageGroup: '11-13',
    difficulty: DifficultyLevel.hard,
    timeLimit: 15,
    passingScore: 75,
    questions: [
      BrainRoadQuizQuestion(
        question: 'If you fold a square paper in half, what shape do you get?',
        options: ['Triangle', 'Rectangle', 'Circle', 'Pentagon'],
        correctAnswerIndex: 1,
        explanation: 'When you fold a square in half, you get a rectangle!',
        type: QuestionType.visual,
      ),
      BrainRoadQuizQuestion(
        question: 'Which direction is opposite to North?',
        options: ['East', 'West', 'South', 'Northeast'],
        correctAnswerIndex: 2,
        explanation: 'South is directly opposite to North on a compass',
      ),
      BrainRoadQuizQuestion(
        question: 'How many corners does a cube have?',
        options: ['6', '8', '12', '4'],
        correctAnswerIndex: 1,
        explanation: 'A cube has 8 corners (vertices). Think of a dice!',
      ),
      BrainRoadQuizQuestion(
        question: 'If you turn 90 degrees to the right twice, which direction are you facing?',
        options: ['Same direction', 'Opposite direction', '90 degrees right', '45 degrees right'],
        correctAnswerIndex: 1,
        explanation: '90° + 90° = 180°, which means you\'re facing the opposite direction',
      ),
      BrainRoadQuizQuestion(
        question: 'Which shape can roll?',
        options: ['Square', 'Triangle', 'Circle', 'Rectangle'],
        correctAnswerIndex: 2,
        explanation: 'A circle is round and can roll smoothly. Other shapes have corners that would make them bump!',
        type: QuestionType.visual,
      ),
    ],
  ),
  
  BrainRoadQuiz(
    id: 'word_puzzles_quiz',
    title: 'Word Wizards',
    description: 'Play with words and letters',
    category: 'Word Puzzles',
    emoji: '📝',
    ageGroup: '11-13',
    difficulty: DifficultyLevel.hard,
    timeLimit: 12,
    passingScore: 70,
    questions: [
      BrainRoadQuizQuestion(
        question: 'Which word is spelled correctly?',
        options: ['Freinds', 'Friends', 'Freands', 'Frends'],
        correctAnswerIndex: 1,
        explanation: 'The correct spelling is "Friends" - remember "i before e"!',
      ),
      BrainRoadQuizQuestion(
        question: 'What do you call a word that means the opposite?',
        options: ['Synonym', 'Antonym', 'Homonym', 'Acronym'],
        correctAnswerIndex: 1,
        explanation: 'Antonym means opposite. Synonym means similar!',
      ),
      BrainRoadQuizQuestion(
        question: 'Unscramble this word: TAC',
        options: ['ACT', 'CAT', 'TAC', 'CTA'],
        correctAnswerIndex: 1,
        explanation: 'T-A-C can be rearranged to spell C-A-T!',
      ),
      BrainRoadQuizQuestion(
        question: 'Which word rhymes with "NIGHT"?',
        options: ['LIGHT', 'NEAR', 'NOON', 'NOTE'],
        correctAnswerIndex: 0,
        explanation: 'LIGHT rhymes with NIGHT - they both end with the same sound!',
      ),
      BrainRoadQuizQuestion(
        question: 'How many vowels are in the word "EDUCATION"?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 2,
        explanation: 'E-D-U-C-A-T-I-O-N has 5 vowels: E, U, A, I, O',
      ),
    ],
  ),
];