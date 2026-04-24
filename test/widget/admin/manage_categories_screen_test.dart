// test/widget/admin/manage_categories_screen_test.dart
//
// ManageCategoriesScreen widget tests.
// CategoryProvider is backed by empty FakeFirestore (synchronous).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/admin/manage_categories_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ManageCategoriesScreen', () {
    // ------------------------------------------------------------------
    // Structural rendering
    // ------------------------------------------------------------------
    testWidgets('renders Manage Categories app bar title', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      expect(find.text('Manage Categories'), findsOneWidget);
    });

    testWidgets('renders add icon button in app bar', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Empty state (FakeFirestore has no categories)
    // ------------------------------------------------------------------
    testWidgets('renders No categories found when provider is empty', (tester) async {
      await tester.pumpApp(
        const ManageCategoriesScreen(),
        categories: makeCategoryProvider(),
      );
      await tester.pump();
      expect(find.text('No categories found.'), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Add Category dialog
    // ------------------------------------------------------------------
    testWidgets('tapping add icon opens Add Category dialog', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Add Category'), findsOneWidget);
    });

    testWidgets('Add Category dialog has Category Name field', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Category Name'), findsOneWidget);
    });

    testWidgets('Add Category dialog has Image URL field', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Image URL'), findsOneWidget);
    });

    testWidgets('Add Category dialog has Save button', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Add Category dialog has Cancel button', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping Cancel in dialog dismisses it', (tester) async {
      await tester.pumpApp(const ManageCategoriesScreen());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Add Category'), findsNothing);
    });
  });
}
