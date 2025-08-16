import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
import '../services/brain_road_quiz_service.dart';
import '../services/user_preferences.dart';
import 'brain_road_quiz_screen.dart';

class BrainRoadQuizzesScreen extends StatefulWidget {
  const BrainRoadQuizzesScreen({super.key});

  @override
  State<BrainRoadQuizzesScreen> createState() => _BrainRoadQuizzesScreenState();
}

class _BrainRoadQuizzesScreenState extends State<BrainRoadQuizzesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  
  String _userAge = '';
  Map<String, dynamic> _statistics = {};
  String? _recommendedQuizId;

  @override
  void initState() {
    super.initState();
    _userAge = UserPreferences.userAge;
    _loadData();
    
    _headerController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));
    
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOut,
    ));
    
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final stats = await BrainRoadQuizService.getOverallStatistics();
    final recommended = await BrainRoadQuizService.getRecommendedQuiz();
    
    if (mounted) {
      setState(() {
        _statistics = stats;
        _recommendedQuizId = recommended;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildHeader(),
            ),
            
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildStatistics(),
            ),
            
            Expanded(
              child: FadeTransition(
                opacity: _listAnimation,
                child: _buildQuizList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
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
              
              // Header content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brain Challenges',
                      style: AppTextStyles.mainTitle.copyWith(
                        color: AppColors.white,
                        fontSize: screenWidth * 0.06,
                      ),
                    ),
                    Text(
                      'Test your knowledge and earn stars!',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Brain emoji
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Text(
                  '🧠',
                  style: TextStyle(fontSize: screenWidth * 0.08),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics.isEmpty) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          // Level and progress
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Text(
                  '👑 ${_statistics['level'] ?? 'Beginner'}',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Stars
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  SizedBox(width: AppSizes.paddingXSmall),
                  Text(
                    '${_statistics['totalStars'] ?? 0}/${_statistics['maxStars'] ?? 0}',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          // Stats row
          Row(
            children: [
              _buildStatCard(
                '${_statistics['completedQuizzes'] ?? 0}',
                'Completed',
                Icons.quiz,
                AppColors.green,
              ),
              
              SizedBox(width: AppSizes.paddingMedium),
              
              _buildStatCard(
                '${_statistics['averageScore'] ?? 0}%',
                'Average',
                Icons.analytics,
                AppColors.yellow,
              ),
              
              SizedBox(width: AppSizes.paddingMedium),
              
              _buildStatCard(
                '${_statistics['earnedCertificates'] ?? 0}',
                'Certificates',
                Icons.workspace_premium,
                AppColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingSmall),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            SizedBox(height: AppSizes.paddingXSmall),
            Text(
              value,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList() {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.paddingMedium),
      child: Column(
        children: [
          // Recommended quiz (if any)
          if (_recommendedQuizId != null) _buildRecommendedSection(),
          
          // All quizzes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
              itemCount: brainRoadQuizData.length,
              itemBuilder: (context, index) {
                final quiz = brainRoadQuizData[index];
                // Filter by age group
                if (!_isQuizForUserAge(quiz)) return const SizedBox.shrink();
                
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  child: _buildQuizCard(quiz, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommendedQuiz = brainRoadQuizData.firstWhere(
      (quiz) => quiz.id == _recommendedQuizId,
      orElse: () => brainRoadQuizData.first,
    );
    
    return Container(
      margin: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ Recommended for you',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.white,
            ),
          ),
          
          SizedBox(height: AppSizes.paddingMedium),
          
          _buildQuizCard(recommendedQuiz, -1, isRecommended: true),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BrainRoadQuiz quiz, int index, {bool isRecommended = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return FutureBuilder<bool>(
      future: BrainRoadQuizService.isQuizCompleted(quiz.id),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        
        return FutureBuilder<Map<String, dynamic>?>(
          future: getQuizScore(quiz.id),
          builder: (context, scoreSnapshot) {
            final scoreData = scoreSnapshot.data;
            
            return Container(
              margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
              child: GestureDetector(
                onTap: () => _startQuiz(quiz),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: isRecommended
                        ? Border.all(color: AppColors.yellow, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Quiz emoji and info
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingSmall),
                            decoration: BoxDecoration(
                              color: _getQuizColor(quiz.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Text(
                              quiz.emoji,
                              style: TextStyle(fontSize: screenWidth * 0.08),
                            ),
                          ),
                          
                          SizedBox(width: AppSizes.paddingMedium),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                                
                                SizedBox(height: AppSizes.paddingXSmall),
                                
                                Text(
                                  quiz.description,
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Completion status
                          if (isCompleted) ...[
                            Container(
                              padding: EdgeInsets.all(AppSizes.paddingXSmall),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(AppSizes.paddingXSmall),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: AppColors.grey,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: AppSizes.paddingMedium),
                      
                      // Quiz info row
                      Row(
                        children: [
                          _buildInfoChip(
                            '${quiz.questions.length} Questions',
                            Icons.quiz,
                            _getQuizColor(quiz.category),
                          ),
                          
                          SizedBox(width: AppSizes.paddingSmall),
                          
                          _buildInfoChip(
                            '${quiz.timeLimit} min',
                            Icons.timer,
                            _getQuizColor(quiz.category),
                          ),
                          
                          SizedBox(width: AppSizes.paddingSmall),
                          
                          _buildInfoChip(
                            _getDifficultyText(quiz.difficulty),
                            _getDifficultyIcon(quiz.difficulty),
                            _getDifficultyColor(quiz.difficulty),
                          ),
                          
                          const Spacer(),
                          
                          // Age group
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Text(
                              quiz.ageGroup,
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 10,
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Score display (if completed)
                      if (isCompleted && scoreData != null) ...[
                        SizedBox(height: AppSizes.paddingMedium),
                        _buildScoreDisplay(scoreData),
                      ],
                      
                      SizedBox(height: AppSizes.paddingMedium),
                      
                      // Start/Retry button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _startQuiz(quiz),
                          style: isCompleted 
                              ? AppButtonStyles.successButton.copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                    _getQuizColor(quiz.category).withOpacity(0.2),
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                    _getQuizColor(quiz.category),
                                  ),
                                )
                              : AppButtonStyles.primaryButton.copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                    _getQuizColor(quiz.category),
                                  ),
                                ),
                          child: Text(
                            isCompleted ? 'Try Again' : 'Start Quiz',
                            style: AppTextStyles.buttonMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(Map<String, dynamic> scoreData) {
    final stars = scoreData['stars'] as int;
    final percentage = scoreData['percentage'] as int;
    
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 16,
          ),
          
          SizedBox(width: AppSizes.paddingSmall),
          
          Text(
            'Completed: $percentage%',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          
          const Spacer(),
          
          // Stars
          Row(
            children: List.generate(3, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < stars 
                    ? AppColors.yellow 
                    : AppColors.grey.withOpacity(0.3),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> getQuizScore(String quizId) async {
    final scores = await BrainRoadQuizService.getQuizScores();
    return scores[quizId];
  }

  bool _isQuizForUserAge(BrainRoadQuiz quiz) {
    // Show all quizzes for now, but could filter based on user age
    return true;
  }

  Color _getQuizColor(String category) {
    switch (category) {
      case 'Logic & Patterns': return AppColors.yellow;
      case 'Math Basics': return AppColors.green;
      case 'Problem Solving': return const Color(0xFF9C27B0);
      case 'Memory Games': return const Color(0xFF2196F3);
      case 'Spatial Thinking': return const Color(0xFFFF5722);
      case 'Word Puzzles': return const Color(0xFF795548);
      default: return AppColors.darkBlue;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy: return 'Easy';
      case DifficultyLevel.medium: return 'Medium';
      case DifficultyLevel.hard: return 'Hard';
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy: return Icons.sentiment_satisfied;
      case DifficultyLevel.medium: return Icons.sentiment_neutral;
      case DifficultyLevel.hard: return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy: return AppColors.success;
      case DifficultyLevel.medium: return AppColors.warning;
      case DifficultyLevel.hard: return AppColors.error;
    }
  }

  void _startQuiz(BrainRoadQuiz quiz) {
    HapticFeedback.selectionClick();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BrainRoadQuizScreen(quiz: quiz),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    ).then((_) {
      // Refresh data when returning from quiz
      _loadData();
    });
  }
}