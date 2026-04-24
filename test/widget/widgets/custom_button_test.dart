// test/widget/widgets/custom_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/widgets/custom_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('CustomButton', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders button text', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Click Me', onPressed: () {})),
      );
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('renders as ElevatedButton by default', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Submit', onPressed: () {})),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders as OutlinedButton when isOutlined is true', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Outlined', onPressed: () {}, isOutlined: true)),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders icon when icon is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(
          text: 'Go',
          onPressed: () {},
          icon: Icons.arrow_forward,
        )),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(
          text: 'Loading',
          onPressed: () {},
          isLoading: true,
        )),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not render text when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(
          text: 'Hidden',
          onPressed: () {},
          isLoading: true,
        )),
      );
      expect(find.text('Hidden'), findsNothing);
    });

    // ------------------------------------------------------------------
    // Interaction
    // ------------------------------------------------------------------
    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Tap', onPressed: () => tapped = true)),
      );
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when isLoading is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(CustomButton(
          text: 'Busy',
          onPressed: () => tapped = true,
          isLoading: true,
        )),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    // ------------------------------------------------------------------
    // Width
    // ------------------------------------------------------------------
    testWidgets('renders with constrained width when width is specified', (tester) async {
      await tester.pumpWidget(
        _wrap(CustomButton(text: 'Narrow', onPressed: () {}, width: 200)),
      );
      final box = tester.renderObject<RenderBox>(find.byType(SizedBox).first);
      expect(box.size.width, lessThanOrEqualTo(200));
    });
  });
}
