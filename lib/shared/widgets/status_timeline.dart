import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../features/ticket/domain/models/comment_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<TicketHistory> history;

  const StatusTimeline({super.key, required this.history});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.warning;
      case 'in progress':
        return AppColors.info;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.radio_button_unchecked;
      case 'in progress':
        return Icons.autorenew;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'closed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(history.length, (index) {
          final item = history[index];
          final isLast = index == history.length - 1;
          final color = _statusColor(item.status);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _statusIcon(item.status),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isDark
                                ? color.withOpacity(0.3)
                                : color.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.status,
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.updatedAt,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.note,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'oleh ${item.updatedBy}',
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
