import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:e_ticketing_helpdesk/features/ticket/domain/models/ticket_model.dart';

void main() {
  late ProviderContainer container;
  late TicketNotifier ticketNotifier;

  setUp(() {
    container = ProviderContainer();
    ticketNotifier = container.read(ticketProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('TicketNotifier', () {
    test('loadTickets populates tickets list', () {
      final state = container.read(ticketProvider);
      expect(state.tickets.length, greaterThan(0));
      expect(state.tickets.length, 15);
    });

    test('filterByStatus filters correctly', () {
      ticketNotifier.filterByStatus('Open');
      final state = container.read(ticketProvider);
      for (final ticket in state.filteredTickets) {
        expect(ticket.status.label, 'Open');
      }
    });

    test('filterByStatus All returns all tickets', () {
      ticketNotifier.filterByStatus('Semua');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, state.tickets.length);
    });

    test('search filters by title', () {
      ticketNotifier.search('VPN');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, 1);
      expect(state.filteredTickets.first.title, contains('VPN'));
    });

    test('search filters by ticket number', () {
      ticketNotifier.search('TKT-005');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, 1);
      expect(state.filteredTickets.first.ticketNumber, 'TKT-005');
    });

    test('search is case insensitive', () {
      ticketNotifier.search('vpn');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, 1);
    });

    test('search with no matches returns empty list', () {
      ticketNotifier.search('zzzzzzz');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.isEmpty, true);
    });

    test('empty search returns all tickets', () {
      ticketNotifier.search('');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, state.tickets.length);
    });

    test('combined filter and search works', () {
      ticketNotifier.filterByStatus('Open');
      ticketNotifier.search('login');
      final state = container.read(ticketProvider);
      for (final ticket in state.filteredTickets) {
        expect(ticket.status.label, 'Open');
      }
    });

    test('filterByAssignee filters by helpdesk name', () {
      ticketNotifier.filterByAssignee('Budi Santoso');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.isNotEmpty, true);
      for (final ticket in state.filteredTickets) {
        expect(ticket.assignedTo, 'Budi Santoso');
      }
    });

    test('filterByAssignee empty returns all', () {
      ticketNotifier.filterByAssignee('');
      final state = container.read(ticketProvider);
      expect(state.filteredTickets.length, state.tickets.length);
    });

    test('mock tickets have all required fields', () {
      final state = container.read(ticketProvider);
      for (final ticket in state.tickets) {
        expect(ticket.id, isNotEmpty);
        expect(ticket.ticketNumber, isNotEmpty);
        expect(ticket.title, isNotEmpty);
        expect(ticket.description, isNotEmpty);
        expect(ticket.category, isA<TicketCategory>());
        expect(ticket.priority, isA<TicketPriority>());
        expect(ticket.status, isA<TicketStatus>());
        expect(ticket.assignedTo, isNotEmpty);
      }
    });
  });
}
