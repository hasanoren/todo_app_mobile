import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_format.dart';
import '../../data/models/todo_item_activity_response_dto.dart';

class TaskActivityItemTile extends StatelessWidget {
  final TodoItemActivityResponseDto activity;
  final bool isLast;

  const TaskActivityItemTile({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = _getActivityVisual(activity.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator (Icon node + connector line)
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: visual.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: visual.color.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  visual.icon,
                  size: 17,
                  color: visual.color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Activity details content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          visual.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppDateFormat.formatDateTime(activity.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Actor (User)
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 13,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.userEmail.isNotEmpty
                              ? activity.userEmail
                              : 'Kullanıcı',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Optional details box
                  if (activity.details != null &&
                      activity.details!.trim().isNotEmpty &&
                      activity.details!.trim() != activity.action.trim()) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        activity.details!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ActivityVisualInfo _getActivityVisual(String action) {
    final normalized = action.toLowerCase().trim();

    // 1. Sahiplik Devri (Transfer)
    if (normalized.contains('transfer') || normalized.contains('devir')) {
      if (normalized.contains('kabul') || normalized.contains('accept')) {
        return _ActivityVisualInfo(
          icon: Icons.done_all,
          color: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
          title: action.isNotEmpty ? action : 'Devir Kabul Edildi',
        );
      } else if (normalized.contains('red') || normalized.contains('reject')) {
        return _ActivityVisualInfo(
          icon: Icons.close,
          color: Colors.red.shade700,
          backgroundColor: Colors.red.shade50,
          title: action.isNotEmpty ? action : 'Devir Reddedildi',
        );
      } else if (normalized.contains('iptal') ||
          normalized.contains('cancel') ||
          normalized.contains('geri çek')) {
        return _ActivityVisualInfo(
          icon: Icons.cancel_outlined,
          color: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
          title: action.isNotEmpty ? action : 'Devir İptal Edildi',
        );
      }
      return _ActivityVisualInfo(
        icon: Icons.swap_horiz_rounded,
        color: Colors.deepPurple.shade700,
        backgroundColor: Colors.deepPurple.shade50,
        title: action.isNotEmpty ? action : 'Sahiplik Devri',
      );
    }

    // 2. Paylaşım (Sharing)
    if (normalized.contains('share') || normalized.contains('paylaş')) {
      if (normalized.contains('unshare') ||
          normalized.contains('remov') ||
          normalized.contains('kaldır') ||
          normalized.contains('sil')) {
        return _ActivityVisualInfo(
          icon: Icons.person_remove_outlined,
          color: Colors.deepOrange.shade700,
          backgroundColor: Colors.deepOrange.shade50,
          title: action.isNotEmpty ? action : 'Paylaşım Kaldırıldı',
        );
      }
      return _ActivityVisualInfo(
        icon: Icons.person_add_alt_1_outlined,
        color: Colors.indigo.shade700,
        backgroundColor: Colors.indigo.shade50,
        title: action.isNotEmpty ? action : 'Görev Paylaşıldı',
      );
    }

    // 3. Alt Görev (Subtask)
    if (normalized.contains('subtask') || normalized.contains('alt görev')) {
      return _ActivityVisualInfo(
        icon: Icons.checklist,
        color: Colors.cyan.shade800,
        backgroundColor: Colors.cyan.shade50,
        title: action.isNotEmpty ? action : 'Alt Görev İşlemi',
      );
    }

    // 4. Etiket (Tag)
    if (normalized.contains('tag') || normalized.contains('etiket')) {
      return _ActivityVisualInfo(
        icon: Icons.label_outline,
        color: Colors.amber.shade900,
        backgroundColor: Colors.amber.shade50,
        title: action.isNotEmpty ? action : 'Etiket İşlemi',
      );
    }

    // 5. Tamamlama (Completion)
    if (normalized.contains('complet') || normalized.contains('tamamlan')) {
      if (normalized.contains('un') ||
          normalized.contains('geri') ||
          normalized.contains('incomplet')) {
        return _ActivityVisualInfo(
          icon: Icons.replay,
          color: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
          title: 'Tamamlanma Geri Alındı',
        );
      }
      return _ActivityVisualInfo(
        icon: Icons.check_circle_outline,
        color: Colors.teal.shade700,
        backgroundColor: Colors.teal.shade50,
        title: 'Görev Tamamlandı',
      );
    }

    // 6. Silme (Deletion)
    if (normalized.contains('delet') || normalized.contains('sil')) {
      return _ActivityVisualInfo(
        icon: Icons.delete_outline,
        color: Colors.red.shade700,
        backgroundColor: Colors.red.shade50,
        title: 'Görev Silindi',
      );
    }

    // 7. Geri Yükleme (Restore)
    if (normalized.contains('restor') ||
        normalized.contains('kurtar') ||
        normalized.contains('geri yükle')) {
      return _ActivityVisualInfo(
        icon: Icons.restore,
        color: Colors.teal.shade700,
        backgroundColor: Colors.teal.shade50,
        title: 'Görev Geri Yüklendi',
      );
    }

    // 8. Güncelleme (Update)
    if (normalized.contains('updat') ||
        normalized.contains('edit') ||
        normalized.contains('güncel')) {
      return _ActivityVisualInfo(
        icon: Icons.edit_note,
        color: Colors.blue.shade700,
        backgroundColor: Colors.blue.shade50,
        title: 'Görev Güncellendi',
      );
    }

    // 9. Görev Oluşturulması (Creation - Yalnızca genel görev oluşturma)
    if (normalized.contains('creat') ||
        normalized == 'oluşturuldu' ||
        normalized == 'görev oluşturuldu') {
      return _ActivityVisualInfo(
        icon: Icons.add_circle_outline,
        color: Colors.green.shade700,
        backgroundColor: Colors.green.shade50,
        title: 'Görev Oluşturuldu',
      );
    }

    return _ActivityVisualInfo(
      icon: Icons.history,
      color: Colors.blueGrey.shade700,
      backgroundColor: Colors.blueGrey.shade50,
      title: action.isNotEmpty ? action : 'Aktivite',
    );
  }
}

class _ActivityVisualInfo {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;

  const _ActivityVisualInfo({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
  });
}
