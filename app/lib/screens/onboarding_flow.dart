import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../app_scope.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Two-step onboarding: (1) age gate + privacy consent, (2) register/login.
/// I1: no pressure — primary action only enabled when consent is given.
class OnboardingFlow extends StatefulWidget {
  final ApiClient api;
  const OnboardingFlow({super.key, required this.api});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  bool _ageOk = false;
  bool _consentOk = false;
  bool _loginMode = false;
  bool _busy = false;
  String? _error;
  final _email = TextEditingController();
  final _password = TextEditingController();

  Function(String) _tr = (key) => key;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _continueEnabled => _ageOk && _consentOk;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await (_loginMode
          ? widget.api.login(
              email: _email.text.trim(), password: _password.text)
          : widget.api.register(
              email: _email.text.trim(),
              password: _password.text,
              ageCountry: 'US',
              ageMin: 18));
      if (!mounted) return;
      final sm = AppScope.of(context)?.sessionManager;
      if (sm != null) {
        await sm.persistAuth(result.token, _email.text.trim());
      } else {
        widget.api.token = result.token;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _tr('onboarding_network_error');
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    _tr = (key) => AppStrings.tr(locale, key);
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ageGateStep(_tr),
            _accountStep(_tr),
          ],
        ),
      ),
    );
  }

  Widget _ageGateStep(Function(String) tr) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('onboarding_title'), style: AppText.h2),
          const SizedBox(height: AppTheme.spacing24),
          CheckboxListTile(
            value: _ageOk,
            onChanged: (v) => setState(() => _ageOk = v ?? false),
            title: Text(tr('onboarding_age')),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _consentOk,
            onChanged: (v) => setState(() => _consentOk = v ?? false),
            title: Text(tr('onboarding_consent')),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _continueEnabled
                ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut)
                : null,
            child: Text(tr('onboarding_continue')),
          ),
        ],
      ),
    );
  }

  Widget _accountStep(Function(String) tr) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_loginMode ? tr('onboarding_welcome_back') : tr('onboarding_create_account'),
              style: AppText.h2),
          const SizedBox(height: AppTheme.spacing24),
          TextField(
            key: const Key('email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: tr('onboarding_email')),
          ),
          const SizedBox(height: AppTheme.spacing16),
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: tr('onboarding_password')),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Text(_error!,
                style: AppText.small.copyWith(color: AppColors.textSecondary)),
          ],
          const Spacer(),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_loginMode ? tr('onboarding_login') : tr('onboarding_create')),
          ),
          TextButton(
            onPressed: () => setState(() => _loginMode = !_loginMode),
            child: Text(_loginMode
                ? tr('onboarding_has_account')
                : tr('onboarding_create_instead')),
          ),
        ],
      ),
    );
  }
}
