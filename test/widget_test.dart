import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/main.dart';

void main() {
  testWidgets('App smoke test - verifies initial home screen loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainNavigationScreen());
    await tester.pumpAndSettle();

    expect(find.text('Aplikasi Pendakian'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });
}
