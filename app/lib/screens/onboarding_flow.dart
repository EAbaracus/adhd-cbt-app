import 'package:flutter/material.dart';

import '../api/api_client.dart';
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
      await (_loginMode
          ? widget.api.login(
              email: _email.text.trim(), password: _password.text)
          : widget.api.register(
              email: _email.text.trim(),
              password: _password.text,
              ageCountry: 'US',
              ageMin: 18));
      if (!mounted) return;
      // M2: in-memory session; Drift UserSettings persistence lands in M3.
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
        _error = 'Could not reach the server. Check your connection and try again.';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ageGateStep(),
            _accountStep(),
          ],
        ),
      ),
    );
  }

  Widget _ageGateStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A few things first', style: AppText.h2),
          const SizedBox(height: AppTheme.spacing24),
          CheckboxListTile(
            value: _ageOk,
            onChanged: (v) => setState(() => _ageOk = v ?? false),
            title: const Text('I am 18 or older'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _consentOk,
            onChanged: (v) => setState(() => _consentOk = v ?? false),
            title: const Text('I agree to the privacy policy'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _continueEnabled
                ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut)
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _accountStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_loginMode ? 'Welcome back' : 'Create your account',
              style: AppText.h2),
          const SizedBox(height: AppTheme.spacing24),
          TextField(
            key: const Key('email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: AppTheme.spacing16),
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Text(_error!,
                style: AppText.small.copyWith(color: AppColors.textSecondary)),
          ],
          const Spacer(),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_loginMode ? 'Log in' : 'Create account'),
          ),
          TextButton(
            onPressed: () => setState(() => _loginMode = !_loginMode),
            child: Text(_loginMode
                ? 'Create an account instead'
                : 'I already have an account'),
          ),
        ],
      ),
    );
  }
}
