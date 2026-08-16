import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/main.dart' as app;

void main() {
  testWidgets('app boots to onboarding with disclaimer', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('12-week guided CBT support program'), findsOneWidget);
    expect(find.text('Not medical advice or diagnosis'), findsOneWidget);
  });
}
