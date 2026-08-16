import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr(_locale(ctx), 'logout_confirm')),
        content:
            Text(AppStrings.tr(_locale(ctx), 'logout_confirm_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppStrings.tr(_locale(ctx), 'cancel'))),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppStrings.tr(_locale(ctx), 'settings_logout'))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppScope.of(context)?.sessionManager?.clearAuth();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (r) => false);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(scope: AppScope.of(ctx)),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    final scope = AppScope.of(context);
    final ok = await scope?.api?.deleteAccount() ?? false;
    if (ok) {
      await scope?.sessionManager?.clearAuth();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (r) => false);
      return;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = AppStrings.tr(_locale(context), 'settings_delete_error');
    });
  }

  AppLocaleCode _locale(BuildContext context) =>
      AppLocale.of(context)?.code ?? AppLocaleCode.en;

  @override
  Widget build(BuildContext context) {
    final code = _locale(context);
    String s(String k) => AppStrings.tr(code, k);
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s('settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          Text(s('settings_language'), style: AppText.subtitle),
          const SizedBox(height: AppTheme.spacing8),
          SegmentedButton<AppLocaleCode>(
            segments: const [
              ButtonSegment(value: AppLocaleCode.en, label: Text('English')),
              ButtonSegment(value: AppLocaleCode.tr, label: Text('Türkçe')),
            ],
            selected: {code},
            onSelectionChanged: (sel) =>
                AppLocale.of(context)?.set(sel.first),
          ),
          const SizedBox(height: AppTheme.spacing32),
          // Crisis banner (A2): supportive, always visible
          Card(
            color: AppColors.panel,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s('crisis_title'), style: AppText.subtitle),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(s('crisis_body'),
                      style: AppText.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
          Text(s('settings_account'), style: AppText.subtitle),
          const SizedBox(height: AppTheme.spacing8),
          FutureBuilder<String?>(
            future: scope?.sessionManager?.email(),
            builder: (ctx, snap) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s('settings_email')),
              subtitle: Text(snap.data ?? '—', style: AppText.small),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s('settings_logout')),
            trailing: const Icon(Icons.logout),
            onTap: _busy ? null : _logout,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s('settings_delete'),
                style: AppText.body.copyWith(color: AppColors.textSecondary)),
            trailing: const Icon(Icons.delete_outline),
            enabled: !_busy,
            onTap: _deleteAccount,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Text(_error!,
                style: AppText.small.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// G2: destructive action requires typing 'delete' — never one-tap.
class _DeleteConfirmDialog extends StatefulWidget {
  final AppScope? scope;
  const _DeleteConfirmDialog({this.scope});

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _input = TextEditingController();
  bool get _ok => _input.text.trim() == 'delete';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    return AlertDialog(
      title: Text(AppStrings.tr(code, 'settings_delete')),
      content: TextField(
        controller: _input,
        autofocus: true,
        decoration: InputDecoration(
            hintText: AppStrings.tr(code, 'settings_delete_hint')),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.tr(code, 'cancel')),
        ),
        FilledButton(
          onPressed: _ok ? () => Navigator.of(context).pop(true) : null,
          child: Text(AppStrings.tr(code, 'settings_delete')),
        ),
      ],
    );
  }
}
