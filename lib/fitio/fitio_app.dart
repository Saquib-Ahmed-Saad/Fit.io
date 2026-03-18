import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'screens/splash_screen.dart';

class FitioApp extends StatelessWidget {
  const FitioApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'Fit.io',
          debugShowCheckedModeBanner: false,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              brightness: Brightness.dark,
            ),
          ),
          home: SplashScreen(controller: controller),
        );
      },
    );
  }
}
