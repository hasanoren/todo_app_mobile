import 'package:flutter/material.dart';

import '../../data/models/todo_item_filter_dto.dart';
import '../../domain/entities/todo_item_enums.dart';

class TaskFilterBottomSheet extends StatefulWidget {
  final TodoItemFilterDto currentFilter;

  const TaskFilterBottomSheet({super.key, required this.currentFilter});

  static Future<TodoItemFilterDto?> show(
    BuildContext context, {
    required TodoItemFilterDto currentFilter,
  }) {
    return showModalBottomSheet<TodoItemFilterDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFilterBottomSheet(currentFilter: currentFilter),
    );
  }

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  late int _filterType;
  late int? _status;
  late int? _priority;
  late String _sortBy;
  late String _sortOrder;

  @override
  void initState() {
    super.initState();
    _filterType = widget.currentFilter.filterType;
    _status = widget.currentFilter.status;
    _priority = widget.currentFilter.priority;
    _sortBy = widget.currentFilter.sortBy;
    _sortOrder = widget.currentFilter.sortOrder;
  }

  void _reset() {
    setState(() {
      _filterType = 0;
      _status = null;
      _priority = null;
      _sortBy = 'createdAt';
      _sortOrder = 'desc';
    });
  }

  void _apply() {
    final updated = widget.currentFilter.copyWith(
      filterType: _filterType,
      status: _status,
      clearStatus: _status == null,
      priority: _priority,
      clearPriority: _priority == null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      page: 1,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header with reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrele & Sırala',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: _reset, child: const Text('Sıfırla')),
              ],
            ),
            const Divider(),

            // Filter Type Section
            Text(
              'Görünüm',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskFilterType.values.map((type) {
                final isSelected = _filterType == type.value;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _filterType = type.value);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Status Section
            Text(
              'Durum',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tümü'),
                  selected: _status == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _status = null);
                  },
                ),
                ChoiceChip(
                  label: const Text('Açık'),
                  selected: _status == 0,
                  onSelected: (selected) {
                    if (selected) setState(() => _status = 0);
                  },
                ),
                ChoiceChip(
                  label: const Text('Tamamlandı'),
                  selected: _status == 1,
                  onSelected: (selected) {
                    if (selected) setState(() => _status = 1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Priority Section
            Text(
              'Öncelik',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tümü'),
                  selected: _priority == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _priority = null);
                  },
                ),
                ...TaskPriority.values.map((p) {
                  final isSelected = _priority == p.value;
                  return ChoiceChip(
                    label: Text(p.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _priority = p.value);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Sort Section
            Text(
              'Sıralama Ölçütü',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskSortBy.values.map((sort) {
                final isSelected = _sortBy == sort.apiValue;
                return ChoiceChip(
                  label: Text(sort.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _sortBy = sort.apiValue);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Sort Order
            Text(
              'Sıralama Yönü',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'desc',
                  label: Text('Azalan (Yeni > Eski)'),
                ),
                ButtonSegment(value: 'asc', label: Text('Artan (Eski > Yeni)')),
              ],
              selected: {_sortOrder},
              onSelectionChanged: (set) {
                setState(() => _sortOrder = set.first);
              },
            ),
            const SizedBox(height: 24),

            // Apply Button
            ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Filtreleri Uygula',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
