import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/glassmorphic_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Navigate Beyond Limits',
      description: 'Experience the future of accessibility with AI-powered navigation designed for everyone.',
      icon: Icons.navigation,
      color: AppTheme.primaryGreen,
      animationPath: 'assets/animations/navigation.json',
    ),
    OnboardingData(
      title: 'Voice-Powered Control',
      description: 'Control your entire journey with natural voice commands and smart assistance.',
      icon: Icons.mic,
      color: AppTheme.accentBlue,
      animationPath: 'assets/animations/voice.json',
    ),
    OnboardingData(
      title: 'Smart Device Hub',
      description: 'Connect seamlessly with Bluetooth devices for enhanced accessibility.',
      icon: Icons.bluetooth,
      color: AppTheme.lightGreen,
      animationPath: 'assets/animations/bluetooth.json',
    ),
    OnboardingData(
      title: 'Emergency Ready',
      description: 'Stay safe with instant SOS features and real-time location sharing.',
      icon: Icons.emergency,
      color: Colors.red,
      animationPath: 'assets/animations/emergency.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isFirstLaunchKey, false);
    await Future.delayed(AppConstants.shortAnimation);
    if (mounted) {
      context.pushReplacement(AppConstants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
                ? [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                    const Color(0xFF01579B),
                  ]
                : [
                    const Color(0xFFE8F5E8),
                    const Color(0xFFE3F2FD),
                    const Color(0xFFE1F5FE),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark 
                            ? Colors.white.withOpacity(0.8)
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: AppConstants.shortAnimation,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? _onboardingData[index].color
                            : (isDark 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      data: _onboardingData[index],
                      isLastPage: index == _onboardingData.length - 1,
                      onNext: _nextPage,
                      onPrevious: _previousPage,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const OnboardingPage({
    Key? key,
    required this.data,
    required this.isLastPage,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Animation container
          GlassmorphicContainer(
            width: 200,
            height: 200,
            borderRadius: 100,
            color: data.color.withOpacity(0.2),
            borderColor: data.color,
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          ).animate()
            .scale(
              duration: AppConstants.mediumAnimation,
              curve: Curves.elasticOut,
            )
            .rotate(
              duration: AppConstants.longAnimation,
              curve: Curves.easeInOut,
            ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            data.title,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(
              duration: AppConstants.mediumAnimation,
              delay: const Duration(milliseconds: 200),
            )
            .slideY(
              duration: AppConstants.mediumAnimation,
              begin: -0.3,
              end: 0,
            ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark 
                  ? Colors.white.withOpacity(0.8)
                  : AppTheme.textSecondary,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(
              duration: AppConstants.mediumAnimation,
              delay: const Duration(milliseconds: 400),
            )
            .slideY(
              duration: AppConstants.mediumAnimation,
              begin: 0.3,
              end: 0,
            ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              // Previous button
              if (!isLastPage)
                Expanded(
                  child: GlassmorphicButton(
                    onPressed: onPrevious,
                    backgroundColor: Colors.transparent,
                    borderColor: isDark 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ).animate()
                    .fadeIn(
                      duration: AppConstants.mediumAnimation,
                      delay: const Duration(milliseconds: 600),
                    ),
                ),
              
              if (!isLastPage) const SizedBox(width: 16),
              
              // Next/Get Started button
              Expanded(
                child: GlassmorphicButton(
                  onPressed: onNext,
                  backgroundColor: data.color,
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate()
                  .fadeIn(
                    duration: AppConstants.mediumAnimation,
                    delay: const Duration(milliseconds: 800),
                  )
                  .scale(
                    duration: AppConstants.shortAnimation,
                    delay: const Duration(milliseconds: 800),
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String animationPath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.animationPath,
  });
}
