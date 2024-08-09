// onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onStartPressed;

  const OnboardingScreen({required this.onStartPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Onboarding Screen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onStartPressed,
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
