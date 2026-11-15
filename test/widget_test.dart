import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pendakian/main.dart';

void main() {

  testWidgets('App smoke test - verifies initial preparation screen loads', (

  testWidgets('App smoke test - verifies initial login screen loads', (

    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();


    // Verifikasi bahwa aplikasi berhasil memuat halaman awal persiapan
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Persiapan yang pas\nuntuk perjalananmu.'), findsOneWidget);
    expect(find.text('Persiapan'), findsOneWidget);

    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Selamat datang\nPendaki.'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);

  });
}
