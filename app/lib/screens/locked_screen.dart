import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Calm locked state (I1): no urgency colors, plain reactivation hint.
class LockedScreen extends StatelessWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: AppTheme.spacing16),
            Text(AppStrings.tr(AppLocale.of(context)?.code ?? AppLocaleCode.en, 'subscription_ended'), style: AppText.h2,
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Renew to keep working through the program.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
