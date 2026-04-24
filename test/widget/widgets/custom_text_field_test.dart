// test/widget/widgets/custom_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('renders label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('can enter text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Password',
              hint: 'Enter password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          ),
        ),
      );

      // Initially obscureText is true, visibility_off icon shown
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Now visibility icon should be shown
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
