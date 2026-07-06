import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:e_ticketing_helpdesk/shared/widgets/app_button.dart';
import 'package:e_ticketing_helpdesk/core/constants/app_colors.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(text: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(text: 'Loading', isLoading: true, onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppColors', () {
    test('has correct primary color', () {
      expect(AppColors.primary.value, 0xFF1A3C6E);
    });

    test('has correct secondary color', () {
      expect(AppColors.secondary.value, 0xFFFF6B35);
    });
  });
}
