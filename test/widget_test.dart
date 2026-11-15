import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/main.dart';

void main() {
  testWidgets('App smoke test - verifies initial home screen loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });
}
