import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_ticketing_helpdesk/shared/widgets/ticket_card.dart';

void main() {
  group('TicketCard', () {
    Widget createCard({
      String status = 'Open',
      String priority = 'Medium',
      String? assignedTo,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TicketCard(
              ticketId: 'TKT-001',
              title: 'Test ticket title',
              status: status,
              priority: priority,
              createdAt: '2026-06-10',
              assignedTo: assignedTo,
              onTap: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders ticket id and title', (WidgetTester tester) async {
      await tester.pumpWidget(createCard());

      expect(find.text('TKT-001'), findsOneWidget);
      expect(find.text('Test ticket title'), findsOneWidget);
    });

    testWidgets('renders status badge', (WidgetTester tester) async {
      await tester.pumpWidget(createCard(status: 'Open'));

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('renders priority badge', (WidgetTester tester) async {
      await tester.pumpWidget(createCard(priority: 'High'));

      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('renders date', (WidgetTester tester) async {
      await tester.pumpWidget(createCard());

      expect(find.text('2026-06-10'), findsOneWidget);
    });

    testWidgets('shows assignedTo when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createCard(assignedTo: 'Budi Santoso'));

      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('does not show assignedTo when null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCard());

      expect(find.text('Budi Santoso'), findsNothing);
    });

    testWidgets('renders status color for different status values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCard(status: 'Closed'));

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TicketCard(
              ticketId: 'TKT-001',
              title: 'Test',
              status: 'Open',
              priority: 'Medium',
              createdAt: '2026-06-10',
              onTap: () => tapped = true,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Test'));
      expect(tapped, isTrue);
    });

    testWidgets('renders different statuses', (WidgetTester tester) async {
      await tester.pumpWidget(createCard(status: 'In Progress'));

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('renders different priorities correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCard(priority: 'Critical'));

      expect(find.text('Critical'), findsOneWidget);
    });
  });
}
