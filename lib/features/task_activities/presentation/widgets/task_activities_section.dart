import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/task_activities_repository.dart';
import '../cubits/task_activities_cubit.dart';
import '../cubits/task_activities_state.dart';
import 'task_activity_item_tile.dart';

class TaskActivitiesSection extends StatelessWidget {
  final String taskId;

  const TaskActivitiesSection({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<TaskActivitiesRepository>();

    return BlocProvider(
      create: (_) => TaskActivitiesCubit(repository: repo)..loadActivities(taskId),
      child: _TaskActivitiesSectionContent(taskId: taskId),
    );
  }
}

class _TaskActivitiesSectionContent extends StatelessWidget {
  final String taskId;

  const _TaskActivitiesSectionContent({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskActivitiesCubit, TaskActivitiesState>(
      builder: (context, state) {
        final count = state.activities.length;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Aktivite Geçmişi${state.status == TaskActivitiesStatus.success ? ' ($count)' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (state.status == TaskActivitiesStatus.loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Aktiviteleri Yenile',
                        onPressed: () {
                          context
                              .read<TaskActivitiesCubit>()
                              .refreshActivities(taskId);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Body content based on state
                if (state.status == TaskActivitiesStatus.loading &&
                    state.activities.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else if (state.status == TaskActivitiesStatus.error &&
                    state.activities.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ??
                                'Aktiviteler yüklenirken bir sorun oluştu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<TaskActivitiesCubit>()
                                  .loadActivities(taskId);
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (state.activities.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_toggle_off_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bu görev için henüz bir aktivite kaydı bulunmuyor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Timeline items list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.activities.length,
                    itemBuilder: (context, index) {
                      final activity = state.activities[index];
                      return TaskActivityItemTile(
                        activity: activity,
                        isLast: index == state.activities.length - 1,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
