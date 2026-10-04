import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_format.dart';
import '../../data/models/todo_item_response_dto.dart';
import 'priority_badge.dart';

class TrashTaskCard extends StatelessWidget {
  final TodoItemResponseDto item;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const TrashTaskCard({
    super.key,
    required this.item,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priority = item.taskPriority;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                PriorityBadge(priority: priority),
              ],
            ),
            if (item.description != null &&
                item.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  item.deletedAt != null
                      ? 'Silindi: ${AppDateFormat.formatDateTime(item.deletedAt)}'
                      : 'Silinmiş Görev',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore_from_trash, size: 18),
                  label: const Text('Geri Yükle'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onPermanentDelete,
                  icon: Icon(
                    Icons.delete_forever,
                    size: 18,
                    color: Colors.red.shade700,
                  ),
                  label: Text(
                    'Kalıcı Sil',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

