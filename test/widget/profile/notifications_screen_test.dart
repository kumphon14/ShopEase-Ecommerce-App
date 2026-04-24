// test/widget/profile/notifications_screen_test.dart
//
// NotificationsScreen widget tests.
// NotificationsScreen reads from OrderProvider.notifications which is
// populated by Firestore stream after sign-in. Without a signed-in user
// the list is empty — we test the empty state and structural elements.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/screens/profile/notifications_screen.dart';

import '../helpers/fake_providers.dart';
import '../helpers/pump_app.dart';

void main() {
  group('NotificationsScreen', () {
    // ------------------------------------------------------------------
    // Empty state (no signed-in user → no notifications)
    // ------------------------------------------------------------------
    testWidgets('renders Notifications app bar title', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('renders No notifications yet when empty', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('renders notifications_none icon when empty', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    // ------------------------------------------------------------------
    // Structure
    // ------------------------------------------------------------------
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('does not render ListView when empty', (tester) async {
      await tester.pumpApp(const NotificationsScreen(), orders: makeOrderProvider());
      await tester.pump();
      expect(find.byType(ListView), findsNothing);
    });
  });
}
