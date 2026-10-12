import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/main.dart';

void main() {
  testWidgets('App smoke test - verifies splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Huma-volve'), findsOneWidget);
  });
}
