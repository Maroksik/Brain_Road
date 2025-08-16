import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_styles.dart';
import '../services/brain_road_quiz_service.dart';
import '../services/user_preferences.dart';

class BrainRoadCertificatesScreen extends StatefulWidget {
  const BrainRoadCertificatesScreen({super.key});

  @override
  State<BrainRoadCertificatesScreen> createState() => _BrainRoadCertificatesScreenState();
}

class _BrainRoadCertificatesScreenState extends State<BrainRoadCertificatesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<BrainRoadCertificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
    
    _animationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    final certificates = await BrainRoadQuizService.getCertificates();
    
    if (mounted) {
      setState(() {
        _certificates = certificates;
        _isLoading = false;
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
              opacity: _fadeAnimation,
              child: _buildHeader(),
            ),
            
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isLoading 
                    ? _buildLoadingState()
                    : _certificates.isEmpty
                        ? _buildEmptyState()
                        : _buildCertificatesList(),
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
                  'My Certificates',
                  style: AppTextStyles.mainTitle.copyWith(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
                Text(
                  'Your amazing achievements!',
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          
          // Trophy emoji
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Text(
              '🏆',
              style: TextStyle(fontSize: screenWidth * 0.08),
            ),
          ),
        ],
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

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingXLarge),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '📜',
                style: TextStyle(fontSize: screenWidth * 0.2),
              ),
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            Text(
              'No Certificates Yet',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
            
            SizedBox(height: AppSizes.paddingSmall),
            
            Text(
              'Complete quizzes with 80% or higher to earn certificates!',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white.withOpacity(0.8),
                fontSize: screenWidth * 0.04,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppButtonStyles.primaryButton,
              child: const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        final certificate = _certificates[index];
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: _buildCertificateCard(certificate, index),
        );
      },
    );
  }

  Widget _buildCertificateCard(BrainRoadCertificate certificate, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = _getCertificateColor(certificate.category);
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: GestureDetector(
        onTap: () => _showCertificateDetail(certificate),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
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
                  // Certificate icon
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingSmall),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: color,
                      size: screenWidth * 0.08,
                    ),
                  ),
                  
                  SizedBox(width: AppSizes.paddingMedium),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certificate.category,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: screenWidth * 0.045,
                            color: color,
                          ),
                        ),
                        
                        SizedBox(height: AppSizes.paddingXSmall),
                        
                        Text(
                          'Earned on ${_formatDate(certificate.earnedDate)}',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.grey,
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
                        size: 20,
                        color: starIndex < certificate.stars 
                            ? AppColors.yellow 
                            : AppColors.grey.withOpacity(0.3),
                      );
                    }),
                  ),
                ],
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Score info
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSmall),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 16,
                    ),
                    
                    SizedBox(width: AppSizes.paddingSmall),
                    
                    Text(
                      'Score: ${certificate.score}/${certificate.totalQuestions} (${certificate.percentage}%)',
                      style: AppTextStyles.bodyText.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      'Tap to view',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.grey,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCertificateDetail(BrainRoadCertificate certificate) {
    HapticFeedback.selectionClick();
    
    showDialog(
      context: context,
      builder: (context) => _buildCertificateDialog(certificate),
    );
  }

  Widget _buildCertificateDialog(BrainRoadCertificate certificate) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = _getCertificateColor(certificate.category);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.9,
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: color, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Certificate header
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    '🏆',
                    style: TextStyle(fontSize: screenWidth * 0.15),
                  ),
                  
                  SizedBox(height: AppSizes.paddingSmall),
                  
                  Text(
                    'BRAIN ROAD CERTIFICATE',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: screenWidth * 0.04,
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            // This is to certify text
            Text(
              'This is to certify that',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: screenWidth * 0.04,
                color: AppColors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            SizedBox(height: AppSizes.paddingSmall),
            
            // Child name with avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  certificate.childAvatar,
                  style: TextStyle(fontSize: screenWidth * 0.08),
                ),
                
                SizedBox(width: AppSizes.paddingSmall),
                
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.paddingSmall,
                    horizontal: AppSizes.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: color,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    certificate.childName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: screenWidth * 0.055,
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            // Achievement text
            Text(
              'has successfully completed',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: screenWidth * 0.04,
                color: AppColors.grey,
              ),
            ),
            
            SizedBox(height: AppSizes.paddingSmall),
            
            // Category name
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                certificate.category,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: screenWidth * 0.05,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            // Score and stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Score: ${certificate.percentage}%',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                
                SizedBox(width: AppSizes.paddingMedium),
                
                Row(
                  children: List.generate(3, (index) {
                    return Icon(
                      Icons.star,
                      size: 24,
                      color: index < certificate.stars 
                          ? AppColors.yellow 
                          : AppColors.grey.withOpacity(0.3),
                    );
                  }),
                ),
              ],
            ),
            
            SizedBox(height: AppSizes.paddingMedium),
            
            // Date
            Text(
              'Earned on ${_formatDate(certificate.earnedDate)}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: screenWidth * 0.035,
                color: AppColors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            // Motivational message
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Row(
                children: [
                  Text(
                    '🌟',
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                  
                  SizedBox(width: AppSizes.paddingSmall),
                  
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(certificate.stars),
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSizes.paddingLarge),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppButtonStyles.primaryButton.copyWith(
                  backgroundColor: MaterialStateProperty.all(color),
                ),
                child: const Text('Amazing!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCertificateColor(String category) {
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

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getMotivationalMessage(int stars) {
    switch (stars) {
      case 3:
        return 'Outstanding! You\'re a true genius! 🎉';
      case 2:
        return 'Great job! You\'re getting smarter! 👏';
      default:
        return 'Good work! Keep practicing! 💪';
    }
  }
}