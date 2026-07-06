class TicketMock {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String createdAt;
  final String assignedTo;

  const TicketMock({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.assignedTo,
  });
}

class MockData {
  const MockData._();

  static const String userName = 'Surya Prakoso';

  static const Map<String, int> stats = {
    'total': 24,
    'open': 8,
    'inProgress': 10,
    'closed': 6,
  };

  static const List<TicketMock> recentTickets = [
    TicketMock(
      id: 'TKT-001',
      title: 'Cannot login to email system',
      status: 'Open',
      priority: 'High',
      createdAt: '2026-06-07 09:30',
      assignedTo: 'Budi Santoso',
    ),
    TicketMock(
      id: 'TKT-002',
      title: 'Printer not responding after update',
      status: 'In Progress',
      priority: 'Medium',
      createdAt: '2026-06-06 14:15',
      assignedTo: 'Budi Santoso',
    ),
    TicketMock(
      id: 'TKT-003',
      title: 'Request new software license',
      status: 'Closed',
      priority: 'Low',
      createdAt: '2026-06-05 10:00',
      assignedTo: 'Budi Santoso',
    ),
  ];

  static const Map<String, int> chartData = {
    'Sen': 5,
    'Sel': 8,
    'Rab': 3,
    'Kam': 6,
    'Jum': 10,
    'Sab': 4,
    'Min': 2,
  };
}
