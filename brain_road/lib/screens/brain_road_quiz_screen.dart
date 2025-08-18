import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../styles/app_styles.dart';
import '../services/brain_road_quiz_service.dart';

class BrainRoadQuizScreen extends StatefulWidget {
  final BrainRoadQuiz quiz;

  const BrainRoadQuizScreen({super.key, required this.quiz});

  @override
  State<BrainRoadQuizScreen> createState() => _BrainRoadQuizScreenState();
}

class _BrainRoadQuizScreenState extends State<BrainRoadQuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {};
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isQuizCompleted = false;
  
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.quiz.timeLimit * 60; // Convert to seconds
    _startTimer();
    
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;
    _progressController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizCompleted) {
      return _buildResultScreen();
    }
    
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildQuizHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: FadeTransition(
                  opacity: _slideAnimation,
                  child: _buildQuestionCard(),
                ),
              ),
            ),
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showExitDialog(),
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.quiz.emoji} ${widget.quiz.title}',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    Text(
                      widget.quiz.category,
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
          
          SizedBox(height: AppSizes.paddingMedium),
          
          // Progress and timer card
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: _getTimerColor(),
                          size: 16,
                        ),
                        SizedBox(width: AppSizes.paddingXSmall),
                        Text(
                          _formatTime(_timeRemaining),
                          style: AppTextStyles.bodyText.copyWith(
                            color: _getTimerColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: AppSizes.paddingSmall),
                
                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
                      minHeight: 6,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = widget.quiz.questions[_currentQuestionIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: AppDecorations.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with emoji
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Row(
              children: [
                Text(
                  '🤔',
                  style: TextStyle(fontSize: screenWidth * 0.08),
                ),
                SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'Question ${_currentQuestionIndex + 1}',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSizes.paddingLarge),
          
          // Question text
          Text(
            question.question,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: screenWidth * 0.05,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: AppSizes.paddingLarge),
          
          // Answer options
          ...question.options.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            bool isSelected = _userAnswers[_currentQuestionIndex] == index;
            
            return Container(
              margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
              child: GestureDetector(
                onTap: () => _selectAnswer(index),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.yellow.withOpacity(0.2) : AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: isSelected ? AppColors.yellow : AppColors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Option indicator
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.yellow : AppColors.grey.withOpacity(0.4),
                            width: 2,
                          ),
                          color: isSelected ? AppColors.yellow : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: AppColors.darkBlue,
                                size: 16,
                              )
                            : Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.darkBlue : AppColors.grey,
                                  ),
                                ),
                              ),
                      ),
                      
                      SizedBox(width: AppSizes.paddingMedium),
                      
                      // Option text
                      Expanded(
                        child: Text(
                          option,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.04,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.darkBlue : AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
  return Container(
    padding: EdgeInsets.all(AppSizes.paddingLarge),
    child: Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: _previousQuestion,
              style: AppButtonStyles.secondaryButton.copyWith(
                backgroundColor: WidgetStateProperty.all(  // ЗАМІНЕНО з MaterialStateProperty
                  AppColors.white.withOpacity(0.1),
                ),
                foregroundColor: WidgetStateProperty.all(AppColors.white),  // ЗАМІНЕНО з MaterialStateProperty
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: AppSizes.paddingXSmall),
                  const Text('Previous'),
                ],
              ),
            ),
          ),
        
        if (_currentQuestionIndex > 0) SizedBox(width: AppSizes.paddingMedium),
        
        Expanded(
          child: ElevatedButton(
            onPressed: _isCurrentAnswered() ? _nextQuestion : null,
            style: _isCurrentAnswered() 
                ? AppButtonStyles.primaryButton
                : AppButtonStyles.disabledButton,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? 'Next'
                      : 'Finish',
                ),
                SizedBox(width: AppSizes.paddingXSmall),
                Icon(
                  _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? Icons.arrow_forward
                      : Icons.check,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildResultScreen() {
    final correctAnswers = _calculateScore();
    final percentage = (correctAnswers / widget.quiz.questions.length * 100).round();
    final stars = BrainRoadQuizService.calculateStars(correctAnswers, widget.quiz.questions.length);
    final passed = percentage >= widget.quiz.passingScore;
    
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result animation and emoji
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXLarge),
                decoration: BoxDecoration(
                  color: passed ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  passed ? '🎉' : '🤔',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.2),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingLarge),
              
              // Result text
              Text(
                passed ? 'Great Job!' : 'Good Try!',
                style: AppTextStyles.mainTitle.copyWith(
                  color: AppColors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              Text(
                passed 
                    ? 'You did amazing! Keep learning!' 
                    : 'Practice makes perfect! Try again!',
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSizes.paddingXLarge),
              
              // Score card
              Container(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  children: [
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXSmall),
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color: index < stars ? AppColors.yellow : AppColors.grey.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: AppSizes.paddingMedium),
                    
                    Text(
                      '$correctAnswers / ${widget.quiz.questions.length}',
                      style: AppTextStyles.mainTitle.copyWith(
                        color: AppColors.darkBlue,
                        fontSize: 36,
                      ),
                    ),
                    
                    Text(
                      '$percentage% Correct',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    
                    if (passed) ...[
                      SizedBox(height: AppSizes.paddingMedium),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                        child: Text(
                          '🏆 Certificate Earned!',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: AppSizes.paddingXLarge),
              
              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: AppButtonStyles.primaryButton,
                      child: const Text('Back to Quizzes'),
                    ),
                  ),
                  
                  if (!passed) ...[
                    SizedBox(height: AppSizes.paddingMedium),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _retryQuiz,
                        style: AppButtonStyles.successButton,
                        child: const Text('Try Again'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _animationController.reset();
      _animationController.forward();
      _updateProgress();
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _animationController.reset();
      _animationController.forward();
      _updateProgress();
    }
  }

  bool _isCurrentAnswered() {
    return _userAnswers[_currentQuestionIndex] != null;
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_userAnswers[i] == widget.quiz.questions[i].correctAnswerIndex) {
        correct++;
      }
    }
    return correct;
  }

  void _submitQuiz() async {
    _timer?.cancel();
    
    final correctAnswers = _calculateScore();
    await BrainRoadQuizService.markQuizCompleted(
      widget.quiz.id,
      correctAnswers,
      widget.quiz.questions.length,
    );
    
    if (mounted) {
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _retryQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _timeRemaining = widget.quiz.timeLimit * 60;
      _isQuizCompleted = false;
    });
    
    _startTimer();
    _animationController.reset();
    _animationController.forward();
    _progressController.reset();
    _updateProgress();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '😟',
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Exit Quiz?',
              style: AppTextStyles.sectionTitle,
            ),
            SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Your progress will be lost if you exit now.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Stay',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    if (_timeRemaining < 60) return AppColors.error;
    if (_timeRemaining < 180) return AppColors.warning;
    return AppColors.success;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}