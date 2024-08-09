import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onStartPressed;

  const OnboardingScreen({required this.onStartPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // L10n.of(context) は build メソッド内で呼び出すように修正
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to AnyRadio'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover, Create, and Share Your Radio Stories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AnyRadio is powered by the advanced Gemini AI technology. '
                    'Transform your favorite moments, images, and stories into engaging audio content '
                    'that you can enjoy anywhere, anytime.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How It Works:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. Upload your screenshots, images, or video clips.\n'
                    '2. Gemini AI will generate a script for you.\n'
                    '3. Listen to your personalized radio program, or share it with friends and family.\n'
                    '4. Explore popular and trending radio programs created by other users.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Safety and Enjoyment Combined',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'AnyRadio is designed to make your listening experience both safe and enjoyable. '
                    'Whether you’re on the go or relaxing at home, you can stay informed and entertained '
                    'without needing to look at your screen.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .copyWith(bottom: 24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onStartPressed,
              child: Text(l10n.getStarted),
            ),
          ),
        ],
      ),
    );
  }
}
