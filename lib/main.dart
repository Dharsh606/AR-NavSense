import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'theme/app_theme.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const ARNavSenseApp());
}

class ARNavSenseApp extends StatelessWidget {
  const ARNavSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
