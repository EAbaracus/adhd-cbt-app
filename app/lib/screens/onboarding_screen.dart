import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('ADHD CBT', style: AppText.h1),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '12-week guided CBT support program',
                style: AppText.lead.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Not medical advice or diagnosis',
                style: AppText.small.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'This app is a supportive guide, not a human coach or a diagnostic tool. '
                'If you are in crisis, reach out to local emergency services (988 in the US).',
                style: AppText.small.copyWith(color: AppColors.textTertiary),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, RouteGenerator.home),
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
