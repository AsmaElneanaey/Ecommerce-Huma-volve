import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/main.dart';

void main() {
  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Huma-volve'), findsOneWidget);
    expect(find.text('Your Ultimate E-Commerce App'), findsOneWidget);

    // Advance timer past splash delay to ensure clean teardown
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
