import 'package:flutter/material.dart';

import '../../data/models/subtask_response_dto.dart';

class SubtaskItemTile extends StatelessWidget {
  final SubtaskResponseDto subtask;
  final bool isOwner;
  final bool isToggling;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const SubtaskItemTile({
    super.key,
    required this.subtask,
    required this.isOwner,
    this.isToggling = false,
    required this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = subtask.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Checkbox or toggle spinner
          InkWell(
            onTap: isToggling ? null : onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: isToggling
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Colors.green.shade600
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green.shade600
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Text(
              subtask.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey.shade500 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),

          // Delete button (owner only)
          if (isOwner && onDelete != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade500,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Alt görevi sil',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
