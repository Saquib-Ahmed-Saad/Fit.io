import 'dart:async';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'home_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_goToHome());
  }

  Future<void> _goToHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeShellScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.track_changes, size: 76),
              SizedBox(height: 16),
              Text(
                'Fit.io',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('Build your habits, one day at a time.'),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
