import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopease_ecommerce_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke: launches and reaches the landing screen', (
    tester,
  ) async {
    await app.main();
    await tester.pump();

    expect(find.text('ShopEase'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Login to Your Account'), findsOneWidget);
  });
}
