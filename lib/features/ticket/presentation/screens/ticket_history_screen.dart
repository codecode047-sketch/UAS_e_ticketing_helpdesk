import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/ticket_card.dart';
import '../providers/ticket_provider.dart';

class TicketHistoryScreen extends ConsumerStatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  ConsumerState<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends ConsumerState<TicketHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Semua', 'Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketProvider);

    var tickets = state.tickets;
    if (_tabController.index > 0) {
      final filterLabel = _tabs[_tabController.index];
      tickets = tickets.where((t) => t.status.label == filterLabel).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tiket'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: state.isLoading
          ? const TicketCardShimmer()
          : tickets.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'Tidak ada riwayat tiket',
                  subtitle: 'Belum ada tiket yang sesuai dengan filter ini',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.read(ticketProvider.notifier).loadTickets();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: TicketCard(
                          ticketId: ticket.ticketNumber,
                          title: ticket.title,
                          status: ticket.status.label,
                          priority: ticket.priority.label,
                          createdAt: ticket.createdAt,
                          assignedTo: ticket.assignedTo,
                          onTap: () {
                            context.push(
                              '${AppRouter.tickets}/${ticket.id}',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
