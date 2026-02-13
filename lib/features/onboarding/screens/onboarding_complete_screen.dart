import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Center(
        child: Text(
          'Onboarding Complete',
          style: TextStyle(fontSize: AppConstants.fontSizeXl),
        ),
      ),
    );
  }
}
