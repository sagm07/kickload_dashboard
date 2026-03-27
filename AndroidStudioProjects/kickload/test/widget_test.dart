import 'package:flutter_test/flutter_test.dart';

import 'package:kickload/main.dart';

void main() {
  testWidgets('shows the sign in screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KickLoadApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('KickLoad'), findsWidgets);
    expect(find.text('Sign in to your account'), findsOneWidget);
  });
}
