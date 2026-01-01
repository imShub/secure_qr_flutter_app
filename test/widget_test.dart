import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(SecureQrApp());
    expect(find.text('Scan'), findsWidgets); // Bottom nav item
    expect(find.text('Generate'), findsWidgets);
  });
}
