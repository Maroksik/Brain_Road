import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
import '../services/brain_road_quiz_service.dart';
import 'brain_road_quiz_screen.dart';

class BrainRoadQuizzesListScreen extends StatefulWidget {
  const BrainRoadQuizzesListScreen({super.key});

  @override
  State<BrainRoadQuizzesListScreen> createState() => _BrainRoadQuizzesListScreenState();
}

class _BrainRoadQuizzesListScreenState extends State<BrainRoadQuizzesListScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  
  Map<String, dynamic> _statistics = {};
  String? _recommendedQuizId;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: AppAnimations.medium,
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
      if (mounted) {
        _listController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _scrollController.dispose();
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
            // Fixed header
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildHeader(),
            ),
            
            // Fixed statistics
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildStatistics(),
            ),
            
            // Scrollable content
            Expanded(
              child: FadeTransition(
                opacity: _listAnimation,
                child: _buildScrollableContent(),
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
      child: Row(
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
      child: Row(
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
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.paddingMedium),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Recommended quiz section
          if (_recommendedQuizId != null)
            SliverToBoxAdapter(
              child: _buildRecommendedSection(),
            ),
          
          // All quizzes header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.paddingLarge,
                AppSizes.paddingLarge,
                AppSizes.paddingLarge,
                AppSizes.paddingMedium,
              ),
              child: Text(
                'All Quizzes',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          
          // Quiz list with proper spacing
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= brainRoadQuizData.length) return null;
                
                final quiz = brainRoadQuizData[index];
                
                // Filter by age group
                if (!_isQuizForUserAge(quiz)) return const SizedBox.shrink();
                
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.paddingLarge,
                    right: AppSizes.paddingLarge,
                    bottom: AppSizes.paddingMedium,
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: _buildQuizCard(quiz, index),
                  ),
                );
              },
              childCount: brainRoadQuizData.length,
            ),
          ),
          
          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingXXLarge),
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
    return FutureBuilder<bool>(
      future: BrainRoadQuizService.isQuizCompleted(quiz.id),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        
        return FutureBuilder<Map<String, dynamic>>(
          future: isCompleted 
              ? BrainRoadQuizService.getQuizScores().then((scores) => scores[quiz.id] ?? <String, dynamic>{})
              : Future.value(<String, dynamic>{}),
          builder: (context, scoreSnapshot) {
            final scoreData = scoreSnapshot.data;
            
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: isRecommended 
                    ? Border.all(color: AppColors.yellow, width: 3)
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  onTap: () => _startQuiz(quiz),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingLarge),
                    child: Row(
                      children: [
                        // Quiz emoji and category color indicator
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getQuizColor(quiz.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                              color: _getQuizColor(quiz.category),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              quiz.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: AppSizes.paddingMedium),
                        
                        // Quiz info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and completion status
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      quiz.title,
                                      style: AppTextStyles.cardTitle.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isCompleted) 
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                              
                              SizedBox(height: AppSizes.paddingXSmall),
                              
                              // Description
                              Text(
                                quiz.description,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 14,
                                  color: AppColors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              SizedBox(height: AppSizes.paddingSmall),
                              
                              // Quiz metadata
                              Row(
                                children: [
                                  _buildInfoChip(
                                    '${quiz.questions.length}Q',
                                    Icons.quiz,
                                    _getQuizColor(quiz.category),
                                  ),
                                  SizedBox(width: AppSizes.paddingXSmall),
                                  _buildInfoChip(
                                    '${quiz.timeLimit}min',
                                    Icons.timer,
                                    AppColors.grey,
                                  ),
                                  SizedBox(width: AppSizes.paddingXSmall),
                                  _buildInfoChip(
                                    quiz.ageGroup,
                                    Icons.child_care,
                                    AppColors.darkBlue,
                                  ),
                                ],
                              ),
                              
                              // Score display if completed
                              if (isCompleted && scoreData != null) ...[
                                SizedBox(height: AppSizes.paddingSmall),
                                _buildScoreDisplay(scoreData),
                              ],
                            ],
                          ),
                        ),
                        
                        SizedBox(width: AppSizes.paddingMedium),
                        
                        // Start button
                        Container(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: () => _startQuiz(quiz),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted 
                                  ? AppColors.green.withOpacity(0.1)
                                  : _getQuizColor(quiz.category),
                              foregroundColor: isCompleted 
                                  ? AppColors.green
                                  : AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.paddingSmall,
                              ),
                            ),
                            child: Text(
                              isCompleted ? 'Retry' : 'Start',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
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
            style: TextStyle(
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          SizedBox(width: 8),
          Row(
            children: List.generate(3, (index) {
              return Icon(
                Icons.star,
                size: 12,
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

  // Helper methods
  bool _isQuizForUserAge(BrainRoadQuiz quiz) {
    return true; // For now, show all quizzes
  }

  Color _getQuizColor(String category) {
    switch (category.toLowerCase()) {
      case 'logic & patterns':
        return AppColors.yellow;
      case 'math basics':
        return AppColors.green;
      case 'problem solving':
        return AppColors.lightBlue;
      case 'memory games':
        return AppColors.darkBlue;
      case 'spatial thinking':
        return AppColors.lightGreen;
      case 'word puzzles':
        return AppColors.grey;
      default:
        return AppColors.darkBlue;
    }
  }

  void _startQuiz(BrainRoadQuiz quiz) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BrainRoadQuizScreen(quiz: quiz),
      ),
    ).then((_) {
      _loadData();
    });
  }
}