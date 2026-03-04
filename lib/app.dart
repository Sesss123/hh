import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/colors.dart';

class TripMeApp extends StatelessWidget {
  const TripMeApp({super.key});

  static const String splashRoute = '/';
  static const String homeRoute = '/home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMe.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.deepCeylonBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepCeylonBlue,
          brightness: Brightness.dark,
        ),
      ),
      routes: {
        splashRoute: (_) => const SplashScreen(),
        homeRoute: (_) => const HomeScreen(),
      },
      initialRoute: splashRoute,
    );
  }
}
