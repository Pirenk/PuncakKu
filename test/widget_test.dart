import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/main.dart';

void main() {
  testWidgets('App smoke test - verifies initial login screen loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Selamat datang\nPendaki.'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
  });
}
