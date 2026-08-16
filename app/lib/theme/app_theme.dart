import 'package:flutter/material.dart';

/// Refactoring-UI-grounded tokens. Structure is the deliverable; hues are
/// starting points. Never add ad-hoc values in widgets — change a token here.
class AppColors {
  // Cool blue-tinted greys (grey-50..900)
  static const bg = Color(0xFFF6F8FA);           // grey-50
  static const panel = Color(0xFFF0F3F6);        // grey-100
  static const border = Color(0xFFE2E6EB);       // grey-200
  static const inputBorder = Color(0xFFC6CCD4);  // grey-300
  static const placeholder = Color(0xFFA3ABB5);  // grey-400
  static const textTertiary = Color(0xFF7C8490); // grey-500
  static const textSecondary = Color(0xFF565E6A);// grey-600/700
  static const textPrimary = Color(0xFF1F242C);  // grey-900, never pure black

  // Primary blue 100-900 (base = 500)
  static const primary100 = Color(0xFFE3EBFA);
  static const primary300 = Color(0xFF9DB8EC);
  static const primary500 = Color(0xFF2F5FD0);
  static const primary600 = Color(0xFF2750B4);
  static const primary700 = Color(0xFF1F4296);
  static const primary900 = Color(0xFF14295C);

  // Accents (100 tint / 500 base / 900 text-on-tint)
  static const red500 = Color(0xFFE03E3E);
  static const red900 = Color(0xFF6E1515);
  static const green500 = Color(0xFF2FA36B);
  static const green900 = Color(0xFF11452C);
  static const amber500 = Color(0xFFE5A50E);
  static const amber900 = Color(0xFF66450A);
}

class AppText {
  // Ballast design system (DESIGN.md): Public Sans throughout.
  static const _f = 'PublicSans';
  // Hand-crafted scale, logical px only. 10 sizes max. Every style carries an
  // explicit color (refactoring-ui: 3 text colors max) — a color-less style
  // inherits the ambient DefaultTextStyle, which broke to WHITE-on-white here.
  static const caption =
      TextStyle(fontFamily: _f, fontSize: 12, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static const small =
      TextStyle(fontFamily: _f, fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const body =
      TextStyle(fontFamily: _f, fontSize: 16, height: 1.6, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const lead =
      TextStyle(fontFamily: _f, fontSize: 18, height: 1.6, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const subtitle =
      TextStyle(fontFamily: _f, fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const section =
      TextStyle(fontFamily: _f, fontSize: 24, height: 1.25, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const h2 =
      TextStyle(fontFamily: _f, fontSize: 30, height: 1.2, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const h1 =
      TextStyle(fontFamily: _f, fontSize: 36, height: 1.15, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
}

class AppTheme {
  static const spacing4 = 4.0, spacing8 = 8.0, spacing12 = 12.0, spacing16 = 16.0;
  static const spacing24 = 24.0, spacing32 = 32.0, spacing48 = 48.0, spacing64 = 64.0;
  static const radius8 = 8.0, radius12 = 12.0;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary500),
      scaffoldBackgroundColor: AppColors.bg,
    );
    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary)
          .copyWith(
            bodyMedium: AppText.body,
            bodySmall: AppText.small,
            labelLarge: AppText.subtitle.copyWith(fontSize: 16),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing12, horizontal: AppTheme.spacing24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing12, horizontal: AppTheme.spacing24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius8)),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius12)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppTheme.radius8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.radius8),
        ),
        hintStyle: AppText.small.copyWith(color: AppColors.placeholder),
        labelStyle: AppText.small.copyWith(color: AppColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.panel,
        selectedColor: AppColors.primary100,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppText.small.copyWith(color: AppColors.textSecondary),
        secondaryLabelStyle: AppText.small.copyWith(color: AppColors.primary700),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius12)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary700
                  : AppColors.textSecondary),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary100
                  : Colors.white),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius8))),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppText.small.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius8)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: const WidgetStatePropertyAll(AppColors.primary500),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.primary500),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.primary500),
    );
  }
}
