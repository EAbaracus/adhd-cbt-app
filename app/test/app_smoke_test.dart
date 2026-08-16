import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/main.dart';

void main() {
  testWidgets('app boots to onboarding with disclaimer', (tester) async {
    // Pump the widget directly: the async asset bootstrap can't complete in
    // the widget-test FakeAsync zone (platform channels). bootstrap_test.dart
    // covers the real bootstrap path.
    await tester.pumpWidget(AdhdCbtApp());
    await tester.pumpAndSettle();
    expect(find.text('12-week guided CBT support program'), findsOneWidget);
    expect(find.text('Not medical advice or diagnosis'), findsOneWidget);
  });
}
