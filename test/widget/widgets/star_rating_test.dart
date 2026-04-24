// test/widget/widgets/star_rating_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/widgets/star_rating.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('StarRating', () {
    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    testWidgets('renders 5 star icons', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 4.0)));
      // 4 filled + 0 half + 1 border = 5 icons total
      final starIcons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(starIcons.length, equals(5));
    });

    testWidgets('renders correct filled stars for rating 3', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 3.0)));
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final filledCount = icons.where((i) => i.icon == Icons.star).length;
      expect(filledCount, equals(3));
    });

    testWidgets('renders half star for fractional rating', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 3.5)));
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final halfCount = icons.where((i) => i.icon == Icons.star_half).length;
      expect(halfCount, equals(1));
    });

    testWidgets('renders all empty stars for rating 0', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 0.0)));
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final emptyCount = icons.where((i) => i.icon == Icons.star_border).length;
      expect(emptyCount, equals(5));
    });

    testWidgets('renders all filled stars for rating 5', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 5.0)));
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final filledCount = icons.where((i) => i.icon == Icons.star).length;
      expect(filledCount, equals(5));
    });

    // ------------------------------------------------------------------
    // Size
    // ------------------------------------------------------------------
    testWidgets('star icons have the specified size', (tester) async {
      await tester.pumpWidget(_wrap(const StarRating(rating: 4.0, size: 24)));
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons.first.size, equals(24));
    });

    // ------------------------------------------------------------------
    // Interactive mode
    // ------------------------------------------------------------------
    testWidgets('calls onRatingChanged when tapped in interactive mode',
        (tester) async {
      double? changed;
      await tester.pumpWidget(
        _wrap(StarRating(
          rating: 2.0,
          interactive: true,
          onRatingChanged: (r) => changed = r,
        )),
      );
      // Tap the first star (index 0 → rating 1.0)
      await tester.tap(find.byType(Icon).first);
      await tester.pump();
      expect(changed, isNotNull);
      expect(changed, equals(1.0));
    });

    testWidgets('does not call onRatingChanged when not interactive', (tester) async {
      double? changed;
      await tester.pumpWidget(
        _wrap(StarRating(
          rating: 3.0,
          interactive: false,
          onRatingChanged: (r) => changed = r,
        )),
      );
      await tester.tap(find.byType(Icon).first);
      await tester.pump();
      expect(changed, isNull);
    });
  });
}
