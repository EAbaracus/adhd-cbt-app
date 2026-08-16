import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/screens/onboarding_flow.dart';

class FakeApi extends ApiClient {
  FakeApi() : super(baseUrl: 'http://fake');
  int registerCalls = 0;
  int loginCalls = 0;
  @override
  Future<AuthResult> register(
      {required String email,
      required String password,
      required String ageCountry,
      required int ageMin}) async {
    registerCalls++;
    return AuthResult(token: 't', user: {'email': email});
  }

  @override
  Future<AuthResult> login(
      {required String email, required String password}) async {
    loginCalls++;
    return AuthResult(token: 't', user: {'email': email});
  }
}

void main() {
  testWidgets('continue disabled until age + consent checked', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: OnboardingFlow(api: api)));
    final btn = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(btn).onPressed, isNull);
    await tester.tap(find.text('I am 18 or older'));
    await tester.pump();
    await tester.tap(find.text('I agree to the privacy policy'));
    await tester.pump();
    expect(tester.widget<FilledButton>(btn).onPressed, isNotNull);
  });

  testWidgets('register with consent calls api once', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: OnboardingFlow(api: api)));
    await tester.tap(find.text('I am 18 or older'));
    await tester.pump();
    await tester.tap(find.text('I agree to the privacy policy'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('password')), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(api.registerCalls, 1);
    expect(api.loginCalls, 0);
  });

  testWidgets('login mode calls login api', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: OnboardingFlow(api: api)));
    await tester.tap(find.text('I am 18 or older'));
    await tester.pump();
    await tester.tap(find.text('I agree to the privacy policy'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('password')), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(api.loginCalls, 1);
  });
}
