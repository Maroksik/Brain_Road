import 'dart:convert';
import 'package:brain_road/services/brain_road_quiz_service.dart';

// import '../models/brain_road_certificate.dart';
import 'package:brain_road/services/brain_road_quiz_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/brain_road_certificate.dart';
import '../styles/app_styles.dart';
import '../services/user_preferences.dart';
import 'package:intl/intl.dart';
// Remove duplicate import if present


class BrainRoadCertificatesScreen extends StatefulWidget {
  const BrainRoadCertificatesScreen({super.key});

  @override
  State<BrainRoadCertificatesScreen> createState() => _BrainRoadCertificatesScreenState();
}

class _BrainRoadCertificatesScreenState extends State<BrainRoadCertificatesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  List<BrainRoadCertificate> _certificates = [];
  bool _isLoading = true;
  bool _showRewardNotification = false;
  String _newRewardTitle = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCertificates();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    try {
      final certificates = await BrainRoadQuizService.getCertificates();
      
      if (mounted) {
        setState(() {
          _certificates = certificates.reversed.cast<BrainRoadCertificate>().toList(); // Показуємо найновіші першими
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading certificates: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  


// ВИПРАВЛЕНИЙ метод з правильним типом параметра
Future<void> _saveCertificate(BrainRoadCertificate certificate) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final certificates = await BrainRoadQuizService.getCertificates();
    certificates.add(certificate);
    
    // Зберігаємо через SharedPreferences з правильною структурою
    final certificatesJson = certificates.map((cert) => cert.toJson()).toList();
    await prefs.setString('br_earned_certificates', json.encode(certificatesJson));
    
    print('✅ Certificate saved successfully');
    
  } catch (e, stackTrace) {
    print('❌ Error saving certificate: $e');
    print('📍 Stack trace: $stackTrace');
    rethrow;
  }
}


// Виправлений метод додавання сертифіката з винагородою
Future<void> _addCertificateWithReward(String quizId, String courseName, int score, int totalQuestions) async {
  try {
    print('🎯 Starting certificate creation process...');
    
    // 1. Створюємо сертифікат з правильною структурою
    final certificate = BrainRoadCertificate(
      id: 'cert_${quizId}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: quizId,
      category: courseName,
      score: score,
      totalQuestions: totalQuestions,
      percentage: (score / totalQuestions * 100).round(),
      stars: _calculateStars(score, totalQuestions),
      earnedDate: DateTime.now(),
      childName: UserPreferences.userName,
      childAvatar: UserPreferences.userAvatar,
      childAge: UserPreferences.userAge,
    );
    
    // 2. Зберігаємо сертифікат через виправлений метод
    await _saveCertificate(certificate);
    print('✅ Certificate saved');
    
    // 3. Додаємо винагороду тільки якщо бал >= 80%
    final percentage = (score / totalQuestions * 100);
    if (percentage >= 80) {
      await UserPreferences.addRewardForCertificate(courseName);
      print('✅ Reward added');
    } else {
      print('⚠️ Score too low for reward ($percentage% < 80%), but certificate created');
    }
    
    // 4. Оновлюємо список сертифікатів
    await _loadCertificates();
    
    // 5. Показуємо повідомлення
    if (mounted) {
      setState(() {
        _showRewardNotification = true;
        _newRewardTitle = percentage >= 80 ? _getRewardTitleForCourse(courseName) : 'Certificate Earned!';
      });
      
      // Вібрація
      HapticFeedback.heavyImpact();
      
      // Показуємо діалог
      _showCertificateDialog(courseName, percentage >= 80);
    }
    
    print('🎉 Certificate process completed successfully');
    
  } catch (e, stackTrace) {
    print('❌ Error in _addCertificateWithReward: $e');
    print('📍 Stack trace: $stackTrace');
    
    // Показуємо повідомлення про помилку користувачу
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка при створенні сертифікату: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Новий метод для показу діалогу (замість _showRewardDialog)
void _showCertificateDialog(String courseName, bool hasReward) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              hasReward ? Icons.emoji_events : Icons.assignment_turned_in,
              size: 64,
              color: hasReward ? Colors.amber : Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              hasReward ? '🎉 Congratulations!' : '📜 Certificate Earned!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasReward 
                ? 'You\'ve earned a certificate and reward for completing $courseName!'
                : 'You\'ve earned a certificate for completing $courseName!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (!hasReward) ...[
              SizedBox(height: 16),
              Text(
                'Tip: Score 80% or higher to earn rewards!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (hasReward) {
                // Переходимо на сторінку винагород
                Navigator.pushNamed(context, '/rewards');
              }
            },
            child: Text(hasReward ? 'View Rewards' : 'OK'),
          ),
        ],
      );
    },
  );
}

  // Демо метод для тестування (видаліть у продакшні)
  void _addDemoCertificate() async {
    final demoQuizzes = [
      {'id': 'logic_patterns_quiz', 'name': 'Logic & Patterns', 'score': 8, 'total': 10},
      {'id': 'math_basics_quiz', 'name': 'Math Basics', 'score': 9, 'total': 10},
      {'id': 'memory_training_quiz', 'name': 'Memory Training', 'score': 7, 'total': 10},
      {'id': 'creative_thinking_quiz', 'name': 'Creative Thinking', 'score': 10, 'total': 10},
    ];
    
    final randomQuiz = demoQuizzes[DateTime.now().millisecond % demoQuizzes.length];
    await _addCertificateWithReward(
      randomQuiz['id'] as String,
      randomQuiz['name'] as String,
      randomQuiz['score'] as int,
      randomQuiz['total'] as int,
    );
  }

  String _getCategoryByQuizId(String quizId) {
    switch (quizId) {
      case 'logic_patterns_quiz': return 'Logic & Patterns';
      case 'math_basics_quiz': return 'Math Basics';
      case 'memory_training_quiz': return 'Memory Training';
      case 'creative_thinking_quiz': return 'Creative Thinking';
      case 'problem_solving_quiz': return 'Problem Solving';
      case 'spatial_reasoning_quiz': return 'Spatial Reasoning';
      default: return 'Brain Training';
    }
  }

  int _calculateStars(int score, int total) {
    final percentage = (score / total * 100);
    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    if (percentage >= 50) return 1;
    return 0;
  }

  String _getRewardTitleForCourse(String courseName) {
    final rewards = {
      'Logic & Patterns': 'Free Ice Cream Cone',
      'Math Basics': '1 Hour Gaming Zone',
      'Memory Training': 'Free Coffee & Pastry',
      'Creative Thinking': '20% Off Shopping',
      'Problem Solving': 'Free Book Voucher',
      'Spatial Reasoning': 'Pizza Party Voucher',
    };
    return rewards[courseName] ?? 'Special Reward';
  }

  Future<String> _getChildName() async {
    return await UserPreferences.userData['name'] ?? 'Young Learner';
  }

  Future<String> _getChildAvatar() async {
    return await UserPreferences.userData['avatar'] ?? '🧠';
  }

  Future<String> _getChildAge() async {
    return await UserPreferences.userData['age'] ?? '8-10';
  }



  Color _getCertificateColor(String category) {
    switch (category.toLowerCase()) {
      case 'logic & patterns': return const Color(0xFF2196F3);
      case 'math basics': return const Color(0xFF4CAF50);
      case 'memory training': return const Color(0xFFFF9800);
      case 'creative thinking': return const Color(0xFFE91E63);
      case 'problem solving': return const Color(0xFF9C27B0);
      case 'spatial reasoning': return const Color(0xFFFF5722);
      default: return AppColors.darkBlue;
    }
  }

  void _showRewardDialog(String courseName) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rewardTitle = _getRewardTitleForCourse(courseName);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated reward icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.yellow, AppColors.lightYellow],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: screenWidth * 0.08),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              Text(
                'Congratulations! 🏆',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: screenWidth * 0.06,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              Text(
                'You earned a certificate in $courseName!',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.grey,
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Reward notification
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Text(
                      '🎁',
                      style: TextStyle(fontSize: screenWidth * 0.06),
                    ),
                    SizedBox(width: AppSizes.paddingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonus Reward Unlocked!',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          Text(
                            rewardTitle,
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: AppButtonStyles.secondaryButton,
                      child: Text(
                        'Continue',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/rewards');
                      },
                      style: AppButtonStyles.primaryButton,
                      child: Text(
                        'View Rewards',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildHeader(screenWidth),
              ),
              
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _isLoading 
                      ? _buildLoadingState()
                      : _certificates.isEmpty
                          ? _buildEmptyState(screenWidth)
                          : _buildCertificatesList(screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Navigation and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              
              SizedBox(width: AppSizes.paddingMedium),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Certificates',
                      style: AppTextStyles.mainTitle.copyWith(
                        color: AppColors.white,
                        fontSize: screenWidth * 0.06,
                      ),
                    ),
                    Text(
                      'Your amazing achievements!',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSizes.paddingLarge),
          
          // Statistics
          Row(
            children: [
              _buildStatCard('Total', _certificates.length.toString(), Icons.workspace_premium, screenWidth),
              SizedBox(width: AppSizes.paddingSmall),
              _buildStatCard('This Month', _getThisMonthCount().toString(), Icons.calendar_today, screenWidth),
              SizedBox(width: AppSizes.paddingSmall),
              _buildStatCard('Best Score', _getBestScore().toString() + '%', Icons.star, screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, double screenWidth) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: screenWidth * 0.05,
            ),
            SizedBox(height: AppSizes.paddingXSmall),
            Text(
              value,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🏆',
                      style: TextStyle(fontSize: screenWidth * 0.15),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingLarge),
                
                Text(
                  'No Certificates Yet',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.06,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingMedium),
                
                Text(
                  'Complete quizzes and challenges to earn your first certificate and unlock amazing rewards!',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: screenWidth * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSizes.paddingXLarge),
                
                // Demo button for testing
                ElevatedButton(
                  onPressed: _addDemoCertificate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXLarge,
                      vertical: AppSizes.paddingMedium,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎯 ',
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                      Text(
                        'Earn Certificate (Demo)',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSizes.paddingMedium),
                
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/quizzes'),
                  style: AppButtonStyles.secondaryButton.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.white.withOpacity(0.1)),
                    foregroundColor: WidgetStateProperty.all(AppColors.white),
                  ),
                  child: Text(
                    'Start Learning',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: screenWidth * 0.04,
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

  Widget _buildCertificatesList(double screenWidth) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            itemCount: _certificates.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutBack,
                child: _buildCertificateCard(_certificates[index], index, screenWidth),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCertificateCard(BrainRoadCertificate certificate, int index, double screenWidth) {
    final color = _getCertificateColor(certificate.category);
    final isRecent = DateTime.now().difference(certificate.earnedDate).inDays < 7;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: GestureDetector(
        onTap: () => _showCertificateDetail(certificate, screenWidth),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isRecent ? AppColors.yellow : color.withOpacity(0.3), 
              width: isRecent ? 3 : 2
            ),
            boxShadow: [
              BoxShadow(
                color: (isRecent ? AppColors.yellow : color).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Certificate icon with animation for recent certificates
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingSmall),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: isRecent 
                      ? ScaleTransition(
                          scale: _pulseAnimation,
                          child: Icon(
                            Icons.workspace_premium,
                            color: color,
                            size: screenWidth * 0.08,
                          ),
                        )
                      : Icon(
                          Icons.workspace_premium,
                          color: color,
                          size: screenWidth * 0.08,
                        ),
                  ),
                  
                  SizedBox(width: AppSizes.paddingMedium),
                  
                  // Certificate info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                certificate.category,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: screenWidth * 0.045,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                            ),
                            if (isRecent)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingSmall,
                                  vertical: AppSizes.paddingXSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                ),
                                child: Text(
                                  'NEW',
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: AppColors.darkBlue,
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        SizedBox(height: AppSizes.paddingXSmall),
                        
                        Text(
                          'Score: ${certificate.percentage}% • ${DateFormat('MMM dd, yyyy').format(certificate.earnedDate)}',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.grey.withOpacity(0.8),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stars
                  Row(
                    children: List.generate(3, (starIndex) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: starIndex < certificate.stars 
                            ? AppColors.yellow 
                            : AppColors.grey.withOpacity(0.3),
                      );
                    }),
                  ),
                ],
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Progress bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: certificate.percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Achievement details
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.grey.withOpacity(0.6),
                  ),
                  SizedBox(width: AppSizes.paddingXSmall),
                  Text(
                    certificate.childName,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.grey.withOpacity(0.8),
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                  SizedBox(width: AppSizes.paddingMedium),
                  Icon(
                    Icons.cake,
                    size: 16,
                    color: AppColors.grey.withOpacity(0.6),
                  ),
                  SizedBox(width: AppSizes.paddingXSmall),
                  Text(
                    '${certificate.childAge} years',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.grey.withOpacity(0.8),
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: color.withOpacity(0.6),
                  ),
                  SizedBox(width: AppSizes.paddingXSmall),
                  Text(
                    'Tap to view',
                    style: AppTextStyles.bodyText.copyWith(
                      color: color.withOpacity(0.8),
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCertificateDetail(BrainRoadCertificate certificate, double screenWidth) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => _buildCertificateDialog(certificate, screenWidth),
    );
  }


  Widget _buildCertificateDialog(BrainRoadCertificate certificate, double screenWidth) {
    final color = _getCertificateColor(certificate.category);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isTablet = screenWidth > 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.15 : 16.0,
        vertical: isSmallScreen ? 20.0 : 40.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : screenWidth * 0.92,
          maxHeight: screenHeight * 0.85, // Обмежуємо висоту
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 20.0),
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: SingleChildScrollView( // Додаємо прокручування
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Хедер сертифіката з декоративними елементами
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Іконка сертифіката
                      Container(
                        width: isSmallScreen ? 60.0 : 80.0,
                        height: isSmallScreen ? 60.0 : 80.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: isSmallScreen ? 30.0 : 40.0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      
                      // Заголовок сертифіката
                      Text(
                        'Certificate of Achievement',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: isSmallScreen ? 18.0 : 22.0,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                      
                      // Декоративна лінія
                      Container(
                        width: isSmallScreen ? 80.0 : 100.0,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              color,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                
                // Основна інформація про сертифікат
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Ім'я дитини
                      Text(
                        'This certifies that',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            certificate.childAvatar,
                            style: TextStyle(fontSize: isSmallScreen ? 24.0 : 32.0),
                          ),
                          SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                          Flexible(
                            child: Text(
                              certificate.childName.isNotEmpty ? certificate.childName : 'Student',
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: isSmallScreen ? 20.0 : 24.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlue,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      
                      Text(
                        'has successfully completed',
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                      
                      // Категорія курсу
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16.0 : 20.0,
                          vertical: isSmallScreen ? 8.0 : 12.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 8.0 : 12.0),
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          certificate.category,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                
                // Результати
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.green.withOpacity(0.1),
                        AppColors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
                    border: Border.all(
                      color: AppColors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Зірки
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              index < certificate.stars ? Icons.star : Icons.star_border,
                              color: index < certificate.stars 
                                  ? AppColors.yellow 
                                  : AppColors.grey.withOpacity(0.3),
                              size: isSmallScreen ? 24.0 : 30.0,
                            ),
                          );
                        }),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      
                      // Статистика в адаптивній сітці
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isSmallScreen ? 16.0 : 24.0,
                        runSpacing: isSmallScreen ? 12.0 : 16.0,
                        children: [
                          _buildStatItem(
                            icon: Icons.quiz,
                            label: 'Score',
                            value: '${certificate.score}/${certificate.totalQuestions}',
                            color: AppColors.darkBlue,
                            isSmallScreen: isSmallScreen,
                          ),
                          _buildStatItem(
                            icon: Icons.percent,
                            label: 'Percentage',
                            value: '${certificate.percentage}%',
                            color: AppColors.green,
                            isSmallScreen: isSmallScreen,
                          ),
                          _buildStatItem(
                            icon: Icons.calendar_today,
                            label: 'Earned',
                            value: DateFormat('MMM dd, yyyy').format(certificate.earnedDate),
                            color: AppColors.yellow,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      
                      // Оцінка результату
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12.0 : 16.0,
                          vertical: isSmallScreen ? 6.0 : 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getGradeColor(certificate.percentage).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 6.0 : 8.0),
                          border: Border.all(
                            color: _getGradeColor(certificate.percentage).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          certificate.percentage >= 90
                              ? 'Excellent'
                              : certificate.percentage >= 80
                                  ? 'Very Good'
                                  : certificate.percentage >= 70
                                      ? 'Good'
                                      : certificate.percentage >= 50
                                          ? 'Satisfactory'
                                          : 'Needs Improvement',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(certificate.percentage),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20.0 : 24.0),
                
                // Кнопки дій
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.grey,
                          side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 8.0 : 12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12.0 : 16.0,
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12.0 : 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _shareCertificate(certificate);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 8.0 : 12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12.0 : 16.0,
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share,
                              size: isSmallScreen ? 16.0 : 18.0,
                            ),
                            SizedBox(width: isSmallScreen ? 6.0 : 8.0),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14.0 : 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 6.0 : 8.0),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmallScreen ? 18.0 : 20.0,
          ),
          SizedBox(height: isSmallScreen ? 4.0 : 6.0),
          Text(
            value,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: isSmallScreen ? 12.0 : 14.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: isSmallScreen ? 10.0 : 12.0,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, double screenWidth) {
    return Column(
      children: [
        Icon(
          icon,
          size: screenWidth * 0.05,
          color: AppColors.darkBlue,
        ),
        SizedBox(height: AppSizes.paddingXSmall),
        Text(
          value,
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: screenWidth * 0.04,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: screenWidth * 0.03,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.grey.withOpacity(0.3),
    );
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _certificates.where((cert) {
      return cert.earnedDate.year == now.year && cert.earnedDate.month == now.month;
    }).length;
  }

  int _getBestScore() {
    if (_certificates.isEmpty) return 0;
    return _certificates.map((cert) => cert.percentage).reduce((a, b) => a > b ? a : b);
  }

  // Add this method to fix the error
  void _shareCertificate(BrainRoadCertificate certificate) {
    // TODO: Implement sharing functionality, e.g. using 'share_plus' package
    // For now, just show a snackbar as a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share certificate: ${certificate.category} (${certificate.percentage}%)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Added method to return color based on percentage
  Color _getGradeColor(int percentage) {
    if (percentage >= 90) return AppColors.green;
    if (percentage >= 80) return AppColors.darkBlue;
    if (percentage >= 70) return AppColors.lightBlue;
    if (percentage >= 50) return AppColors.yellow;
    return AppColors.grey;
  }
}
// Remove local BrainRoadCertificate model, use the one from brain_road_quiz_service.dart }
