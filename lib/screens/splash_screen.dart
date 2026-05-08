import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/glassmorphic_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _startAnimations();
    _navigateToOnboarding();
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
  }
  
  void _navigateToOnboarding() async {
    await Future.delayed(AppConstants.splashAnimationDuration);
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
      if (!mounted) return;
      context.go(isFirstLaunch ? AppConstants.onboardingRoute : AppConstants.homeRoute);
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
        child: Stack(
          children: [
            // Background animated circles
            ...List.generate(6, (index) {
              return Positioned(
                top: (index % 2) == 0 ? 
                    MediaQuery.of(context).size.height * (0.1 + index * 0.15) :
                    MediaQuery.of(context).size.height * (0.2 + index * 0.12),
                left: (index % 3) == 0 ? 
                    MediaQuery.of(context).size.width * 0.1 :
                    MediaQuery.of(context).size.width * 0.7,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100 + (index * 20),
                      height: 100 + (index * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGreen.withOpacity(
                          0.1 + (_pulseController.value * 0.1),
                        ),
                      ),
                    ).animate()
                      .scale(
                        duration: Duration(milliseconds: 2000 + index * 200),
                        curve: Curves.easeInOut,
                      )
                      .fadeIn(
                        duration: AppConstants.longAnimation,
                        delay: Duration(milliseconds: index * 200),
                      );
                  },
                ),
              );
            }),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoController.value,
                        child: GlassmorphicContainer(
                          width: 178,
                          height: 178,
                          borderRadius: 42,
                          color: Colors.white.withOpacity(0.46),
                          borderColor: AppTheme.primaryGreen,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/app_logo_icon.png',
                              fit: BoxFit.contain,
                            ).animate()
                              .scale(
                                duration: AppConstants.mediumAnimation,
                                curve: Curves.easeOutBack,
                              ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _textController,
                            curve: Curves.easeOut,
                          )),
                          child: Column(
                            children: [
                              Text(
                                AppConstants.appName,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                  fontSize: 42,
                                ),
                              ).animate()
                                .fadeIn(
                                  duration: AppConstants.mediumAnimation,
                                  delay: const Duration(milliseconds: 300),
                                )
                                .slideY(
                                  duration: AppConstants.mediumAnimation,
                                  begin: -0.3,
                                  end: 0,
                                ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                AppConstants.tagline,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.8)
                                      : AppTheme.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ).animate()
                                .fadeIn(
                                  duration: AppConstants.mediumAnimation,
                                  delay: const Duration(milliseconds: 600),
                                )
                                .slideY(
                                  duration: AppConstants.mediumAnimation,
                                  begin: 0.3,
                                  end: 0,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.2),
                        child: GlassmorphicContainer(
                          width: 60,
                          height: 60,
                          borderRadius: 30,
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          borderColor: AppTheme.primaryGreen,
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).animate()
                    .fadeIn(
                      duration: AppConstants.mediumAnimation,
                      delay: const Duration(milliseconds: 1000),
                    ),
                ],
              ),
            ),
            
            // Version info
            Positioned(
              bottom: 40,
              right: 20,
              child: Text(
                'v${AppConstants.version}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? Colors.white.withOpacity(0.6)
                      : AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ).animate()
                .fadeIn(
                  duration: AppConstants.mediumAnimation,
                  delay: const Duration(milliseconds: 1500),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
