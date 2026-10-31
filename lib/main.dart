import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BugTatsuApp());
}

class BugTatsuApp extends StatelessWidget {
  const BugTatsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildApp();
  }

  Widget _buildApp() {
    return MaterialApp(
      title: 'BugTatsu Sec',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
