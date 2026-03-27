import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './theme/app_theme.dart';
import './screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent to blend with gradient background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const KickLoadApp());
}

class KickLoadApp extends StatelessWidget {
  const KickLoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KickLoad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      // Entry point
      home: const SplashScreen(),
    );
  }
}
