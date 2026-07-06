import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/comment_model.dart';
import '../../domain/models/ticket_model.dart';

class TicketState {
  final List<Ticket> tickets;
  final List<Ticket> filteredTickets;
  final String selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final String? assigneeFilter;

  const TicketState({
    this.tickets = const [],
    this.filteredTickets = const [],
    this.selectedFilter = 'Semua',
    this.searchQuery = '',
    this.isLoading = false,
    this.assigneeFilter,
  });

  TicketState copyWith({
    List<Ticket>? tickets,
    List<Ticket>? filteredTickets,
    String? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    String? assigneeFilter,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      assigneeFilter: assigneeFilter ?? this.assigneeFilter,
    );
  }
}

class TicketNotifier extends StateNotifier<TicketState> {
  TicketNotifier() : super(const TicketState()) {
    loadTickets();
  }

  void loadTickets() {
    state = state.copyWith(isLoading: true);
    final tickets = _generateMockTickets();
    state = state.copyWith(
      tickets: tickets,
      filteredTickets: tickets,
      isLoading: false,
    );
  }

  void filterByStatus(String status) {
    state = state.copyWith(selectedFilter: status);
    _applyFilters();
  }

  void filterByAssignee(String assignee) {
    state = state.copyWith(
      assigneeFilter: assignee.isEmpty ? null : assignee,
    );
    _applyFilters();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<Ticket>.from(state.tickets);

    if (state.selectedFilter != 'Semua') {
      result = result.where(
        (t) => t.status.label == state.selectedFilter,
      ).toList();
    }

    if (state.assigneeFilter != null && state.assigneeFilter!.isNotEmpty) {
      result = result.where(
        (t) => t.assignedTo == state.assigneeFilter,
      ).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.ticketNumber.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q),
      ).toList();
    }

    state = state.copyWith(filteredTickets: result);
  }

  void createTicket(Ticket ticket) {
    state = state.copyWith(
      tickets: [...state.tickets, ticket],
    );
    _applyFilters();
  }

  void updateTicket(Ticket updatedTicket) {
    state = state.copyWith(
      tickets: state.tickets.map((t) =>
        t.id == updatedTicket.id ? updatedTicket : t
      ).toList(),
    );
    _applyFilters();
  }

  void deleteTicket(String id) {
    state = state.copyWith(
      tickets: state.tickets.where((t) => t.id != id).toList(),
    );
    _applyFilters();
  }

  void updateStatus(String id, TicketStatus status) {
    final ticket = _findById(id);
    if (ticket == null) return;
    final now = _now();
    final history = TicketHistory(
      status: status.label,
      updatedBy: 'Surya Prakoso',
      updatedAt: now,
      note: 'Status berubah dari ${ticket.status.label} ke ${status.label}',
    );
    updateTicket(
      ticket.copyWith(
        status: status,
        updatedAt: now,
        history: [...ticket.history, history],
      ),
    );
  }

  void assignTicket(String id, String assignee) {
    updateTicket(
      _findById(id)!.copyWith(assignedTo: assignee, updatedAt: _now()),
    );
  }

  Ticket? _findById(String id) {
    try {
      return state.tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  String _now() {
    final now = DateTime.now();
    final y = now.year;
    final M = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$y-$M-$d $h:$m';
  }

  List<TicketHistory> _initialHistory(String status, String createdAt, String updatedAt) {
    return [
      TicketHistory(
        status: 'Open',
        updatedBy: 'Siti Rahma',
        updatedAt: createdAt,
        note: 'Tiket dibuat oleh pengguna',
      ),
      if (status == 'In Progress' || status == 'Resolved' || status == 'Closed' || status == 'Cancelled')
        TicketHistory(
          status: 'In Progress',
          updatedBy: 'Budi Santoso',
          updatedAt: updatedAt,
          note: 'Tiket sedang diproses oleh tim IT',
        ),
      if (status == 'Resolved' || status == 'Closed')
        TicketHistory(
          status: 'Resolved',
          updatedBy: 'Budi Santoso',
          updatedAt: updatedAt,
          note: 'Tiket telah diselesaikan',
        ),
      if (status == 'Closed')
        TicketHistory(
          status: 'Closed',
          updatedBy: 'Surya Prakoso',
          updatedAt: updatedAt,
          note: 'Tiket ditutup',
        ),
      if (status == 'Cancelled')
        TicketHistory(
          status: 'Cancelled',
          updatedBy: 'System',
          updatedAt: updatedAt,
          note: 'Tiket dibatalkan',
        ),
    ];
  }

  List<Ticket> _generateMockTickets() {
    return [
      Ticket(
        id: '1',
        ticketNumber: 'TKT-001',
        title: 'Cannot login to email system',
        description: 'User cannot login to the email system since yesterday. Password reset does not work.',
        category: TicketCategory.software,
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdAt: '2026-06-07 09:30',
        updatedAt: '2026-06-07 09:30',
        userId: 'USR-001',
        assignedTo: 'Budi Santoso',
        history: _initialHistory('Open', '2026-06-07 09:30', '2026-06-07 09:30'),
      ),
      Ticket(
        id: '2',
        ticketNumber: 'TKT-002',
        title: 'Printer not responding after update',
        description: 'Office printer stopped working after the latest firmware update. Error code 0xE0.',
        category: TicketCategory.hardware,
        priority: TicketPriority.medium,
        status: TicketStatus.inProgress,
        createdAt: '2026-06-06 14:15',
        updatedAt: '2026-06-07 08:00',
        userId: 'USR-002',
        assignedTo: 'Dewi Lestari',
        history: _initialHistory('In Progress', '2026-06-06 14:15', '2026-06-07 08:00'),
      ),
      Ticket(
        id: '3',
        ticketNumber: 'TKT-003',
        title: 'Request new software license',
        description: 'Need a new license for Adobe Creative Cloud for the design team.',
        category: TicketCategory.software,
        priority: TicketPriority.low,
        status: TicketStatus.closed,
        createdAt: '2026-06-05 10:00',
        updatedAt: '2026-06-06 16:30',
        userId: 'USR-003',
        assignedTo: 'Ahmad Fauzi',
        history: _initialHistory('Closed', '2026-06-05 10:00', '2026-06-06 16:30'),
      ),
      Ticket(
        id: '4',
        ticketNumber: 'TKT-004',
        title: 'VPN connection dropping frequently',
        description: 'VPN connection drops every 15 minutes. Need urgent fix for remote work.',
        category: TicketCategory.jaringan,
        priority: TicketPriority.critical,
        status: TicketStatus.inProgress,
        createdAt: '2026-06-07 07:00',
        updatedAt: '2026-06-07 11:00',
        userId: 'USR-004',
        assignedTo: 'Budi Santoso',
        history: _initialHistory('In Progress', '2026-06-07 07:00', '2026-06-07 11:00'),
      ),
      Ticket(
        id: '5',
        ticketNumber: 'TKT-005',
        title: 'New hire account setup',
        description: 'Please create accounts for 3 new employees starting next Monday.',
        category: TicketCategory.akunAkses,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: '2026-06-07 08:45',
        updatedAt: '2026-06-07 08:45',
        userId: 'USR-005',
        assignedTo: 'Dewi Lestari',
        history: _initialHistory('Open', '2026-06-07 08:45', '2026-06-07 08:45'),
      ),
      Ticket(
        id: '6',
        ticketNumber: 'TKT-006',
        title: 'Database connection timeout',
        description: 'Application server reports database connection timeout after migration.',
        category: TicketCategory.software,
        priority: TicketPriority.critical,
        status: TicketStatus.open,
        createdAt: '2026-06-07 10:00',
        updatedAt: '2026-06-07 10:00',
        userId: 'USR-006',
        assignedTo: 'Ahmad Fauzi',
        history: _initialHistory('Open', '2026-06-07 10:00', '2026-06-07 10:00'),
      ),
      Ticket(
        id: '7',
        ticketNumber: 'TKT-007',
        title: 'Monitor flickering issue',
        description: 'Dell monitor flickers intermittently. Already tried different cables.',
        category: TicketCategory.hardware,
        priority: TicketPriority.low,
        status: TicketStatus.open,
        createdAt: '2026-06-06 11:30',
        updatedAt: '2026-06-06 11:30',
        userId: 'USR-007',
        assignedTo: 'Budi Santoso',
        history: _initialHistory('Open', '2026-06-06 11:30', '2026-06-06 11:30'),
      ),
      Ticket(
        id: '8',
        ticketNumber: 'TKT-008',
        title: 'WiFi access point not working',
        description: 'Access point on 3rd floor has been down for 2 days.',
        category: TicketCategory.jaringan,
        priority: TicketPriority.high,
        status: TicketStatus.resolved,
        createdAt: '2026-06-04 09:00',
        updatedAt: '2026-06-06 13:00',
        userId: 'USR-008',
        assignedTo: 'Dewi Lestari',
        history: _initialHistory('Resolved', '2026-06-04 09:00', '2026-06-06 13:00'),
      ),
      Ticket(
        id: '9',
        ticketNumber: 'TKT-009',
        title: 'Email signature update request',
        description: 'Please update company email signatures with new logo.',
        category: TicketCategory.akunAkses,
        priority: TicketPriority.low,
        status: TicketStatus.closed,
        createdAt: '2026-06-03 15:00',
        updatedAt: '2026-06-04 10:00',
        userId: 'USR-009',
        assignedTo: 'Ahmad Fauzi',
        history: _initialHistory('Closed', '2026-06-03 15:00', '2026-06-04 10:00'),
      ),
      Ticket(
        id: '10',
        ticketNumber: 'TKT-010',
        title: 'Server rack cooling issue',
        description: 'Temperature in server room reaching critical levels. AC unit needs repair.',
        category: TicketCategory.hardware,
        priority: TicketPriority.critical,
        status: TicketStatus.inProgress,
        createdAt: '2026-06-07 06:00',
        updatedAt: '2026-06-07 09:00',
        userId: 'USR-010',
        assignedTo: 'Budi Santoso',
        history: _initialHistory('In Progress', '2026-06-07 06:00', '2026-06-07 09:00'),
      ),
      Ticket(
        id: '11',
        ticketNumber: 'TKT-011',
        title: 'Software update failed',
        description: 'Latest Windows update fails with error 0x80070643.',
        category: TicketCategory.software,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: '2026-06-07 12:00',
        updatedAt: '2026-06-07 12:00',
        userId: 'USR-011',
        assignedTo: 'Dewi Lestari',
        history: _initialHistory('Open', '2026-06-07 12:00', '2026-06-07 12:00'),
      ),
      Ticket(
        id: '12',
        ticketNumber: 'TKT-012',
        title: 'Network drive access denied',
        description: 'User cannot access shared network drive after password change.',
        category: TicketCategory.jaringan,
        priority: TicketPriority.high,
        status: TicketStatus.cancelled,
        createdAt: '2026-06-05 08:00',
        updatedAt: '2026-06-06 11:00',
        userId: 'USR-012',
        assignedTo: 'Ahmad Fauzi',
        history: _initialHistory('Cancelled', '2026-06-05 08:00', '2026-06-06 11:00'),
      ),
      Ticket(
        id: '13',
        ticketNumber: 'TKT-013',
        title: 'Request USB blocking policy',
        description: 'Management requests USB storage devices to be blocked for security.',
        category: TicketCategory.akunAkses,
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: '2026-06-07 13:30',
        updatedAt: '2026-06-07 13:30',
        userId: 'USR-013',
        assignedTo: 'Budi Santoso',
        history: _initialHistory('Open', '2026-06-07 13:30', '2026-06-07 13:30'),
      ),
      Ticket(
        id: '14',
        ticketNumber: 'TKT-014',
        title: 'VoIP phone not registering',
        description: 'IP phone cannot register with PBX server. Network connectivity is fine.',
        category: TicketCategory.hardware,
        priority: TicketPriority.high,
        status: TicketStatus.inProgress,
        createdAt: '2026-06-06 16:00',
        updatedAt: '2026-06-07 07:30',
        userId: 'USR-014',
        assignedTo: 'Dewi Lestari',
        history: _initialHistory('In Progress', '2026-06-06 16:00', '2026-06-07 07:30'),
      ),
      Ticket(
        id: '15',
        ticketNumber: 'TKT-015',
        title: 'Antivirus alert false positive',
        description: 'Company internal app flagged as threat by antivirus. Needs whitelisting.',
        category: TicketCategory.software,
        priority: TicketPriority.medium,
        status: TicketStatus.resolved,
        createdAt: '2026-06-04 14:00',
        updatedAt: '2026-06-05 09:00',
        userId: 'USR-015',
        assignedTo: 'Ahmad Fauzi',
        history: _initialHistory('Resolved', '2026-06-04 14:00', '2026-06-05 09:00'),
      ),
    ];
  }
}

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  return TicketNotifier();
});
