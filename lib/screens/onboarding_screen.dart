import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onStartPressed;

  const OnboardingScreen({required this.onStartPressed, super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Discover, Create, and Share Your Radio Stories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'AnyRadio is powered by the advanced Gemini AI technology. '
                    'Transform your favorite moments, images, and stories into engaging audio content '
                    'that you can enjoy anywhere, anytime.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How It Works:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. Upload your screenshots, images, or video clips.\n'
                    '2. Gemini AI will generate a script for you.\n'
                    '3. Listen to your personalized radio program, or share it with friends and family.\n'
                    '4. Explore popular and trending radio programs created by other users.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Safety and Enjoyment Combined',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AnyRadio is designed to make your listening experience both safe and enjoyable. '
                    'Whether you’re on the go or relaxing at home, you can stay informed and entertained '
                    'without needing to look at your screen.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
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
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onStartPressed,
              child: Text(L10n.of(context)!.getStarted),
            ),
          ),
        ],
      ),
    );
  }
}
