import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/main.dart';

void main() {
  testWidgets('App smoke test - verifies initial preparation screen loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verifikasi bahwa aplikasi berhasil memuat halaman awal persiapan
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Persiapan yang pas\nuntuk perjalananmu.'), findsOneWidget);
    expect(find.text('Persiapan'), findsOneWidget);
  });
}
