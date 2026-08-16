import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    String tr(String key) => AppStrings.tr(locale, key);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacing24),
              Image.asset('assets/icons/brain_leaf_mark.png', height: 56),
              const SizedBox(height: AppTheme.spacing24),
              Text(tr('onboarding_app_title'), style: AppText.h1),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                tr('onboarding_subtitle'),
                style: AppText.lead.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                tr('onboarding_disclaimer'),
                style: AppText.small.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                tr('onboarding_body'),
                style: AppText.small.copyWith(color: AppColors.textTertiary),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, RouteGenerator.home),
                child: Text(tr('onboarding_get_started')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
