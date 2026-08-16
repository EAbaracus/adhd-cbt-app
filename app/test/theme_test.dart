import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/theme/app_theme.dart';

void main() {
  test('input decoration uses canonical border tokens', () {
    final theme = AppTheme.light;
    final input = theme.inputDecorationTheme;
    final border = input.enabledBorder as OutlineInputBorder?;
    expect(border?.borderSide.color, AppColors.inputBorder);
    final focused = input.focusedBorder as OutlineInputBorder?;
    expect(focused?.borderSide.color, AppColors.primary500);
    expect(focused?.borderSide.width, 2);
    expect(input.hintStyle?.color, AppColors.placeholder);
  });

  test('chip theme uses canonical selected state', () {
    final theme = AppTheme.light;
    expect(theme.chipTheme.selectedColor, AppColors.primary100);
    expect(theme.chipTheme.backgroundColor, AppColors.panel);
  });

  test('segmented button selected state canonical', () {
    final theme = AppTheme.light;
    final selected = theme.segmentedButtonTheme.style?.backgroundColor
        ?.resolve({WidgetState.selected});
    expect(selected, AppColors.primary100);
    final fg = theme.segmentedButtonTheme.style?.foregroundColor
        ?.resolve({WidgetState.selected});
    expect(fg, AppColors.primary700);
  });

  test('dialog theme white + radius12 + border', () {
    final theme = AppTheme.light;
    expect(theme.dialogTheme.backgroundColor, Colors.white);
    final shape = theme.dialogTheme.shape as RoundedRectangleBorder?;
    expect(shape?.borderRadius, BorderRadius.circular(AppTheme.radius12));
    expect(shape?.side.color, AppColors.border);
  });

  test('snackbar dark surface + radius8', () {
    final theme = AppTheme.light;
    expect(theme.snackBarTheme.backgroundColor, AppColors.textPrimary);
    expect(
        (theme.snackBarTheme.shape as RoundedRectangleBorder?)?.borderRadius,
        BorderRadius.circular(AppTheme.radius8));
  });

  test('checkbox/switch/progress primary500', () {
    final theme = AppTheme.light;
    expect(
        theme.checkboxTheme.fillColor?.resolve({WidgetState.selected}),
        AppColors.primary500);
    expect(
        theme.switchTheme.thumbColor?.resolve({WidgetState.selected}),
        AppColors.primary500);
    expect(theme.progressIndicatorTheme.color, AppColors.primary500);
  });

  test('list tile canonical text colors', () {
    final theme = AppTheme.light;
    expect(theme.listTileTheme.textColor, AppColors.textPrimary);
    expect(theme.listTileTheme.iconColor, AppColors.textSecondary);
  });
}
