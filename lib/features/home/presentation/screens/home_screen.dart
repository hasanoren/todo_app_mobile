import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../ownership_transfer/presentation/cubits/pending_transfers_cubit.dart';
import '../../../ownership_transfer/presentation/cubits/pending_transfers_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendingTransfersCubit>().loadPendingTransfers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
        actions: [
          BlocBuilder<PendingTransfersCubit, PendingTransfersState>(
            builder: (context, transferState) {
              final count = transferState.pendingCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.assignment_ind_outlined),
                ),
                tooltip: 'Devir İstekleri (Onay / Ret)',
                onPressed: () {
                  context.push(RouteNames.transferRequests);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Çöp Kutusu',
            onPressed: () {
              context.push(RouteNames.trash);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profil & Hesap',
            onPressed: () {
              context.push(RouteNames.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'İki Faktörlü Doğrulama (2FA)',
            onPressed: () {
              context.push(RouteNames.twoFactorSettings);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              context.read<AuthBloc>().add(LoggedOut());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<PendingTransfersCubit>().loadPendingTransfers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pending Transfer Requests Alert Banner
              BlocBuilder<PendingTransfersCubit, PendingTransfersState>(
                builder: (context, transferState) {
                  final count = transferState.pendingCount;
                  if (count == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                      elevation: 2,
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.amber.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.push(RouteNames.transferRequests),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.assignment_ind_rounded,
                                  color: Colors.amber.shade900,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '$count Bekleyen Devir İsteği',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Onay Bekliyor',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Size devredilmek istenen görevleri incelemek, kabul etmek veya reddetmek için dokunun.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.amber.shade900,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Card 1: Tüm Görevler
              _buildMenuCard(
                context,
                title: 'Tüm Görevler',
                subtitle: 'Görevlerinizi görüntüleyin, filtreleyin ve yönetin.',
                icon: Icons.task_alt,
                color: theme.colorScheme.primary,
                onTap: () => context.push(RouteNames.tasks),
              ),
              const SizedBox(height: 16),

              // Card 2: Görev Listeleri
              _buildMenuCard(
                context,
                title: 'Görev Listeleri',
                subtitle: 'Listelerinizi oluşturun ve düzenleyin.',
                icon: Icons.format_list_bulleted,
                color: Colors.teal.shade700,
                onTap: () => context.push(RouteNames.todoLists),
              ),
              const SizedBox(height: 16),

              // Card 3: Devir İstekleri (Onay / Ret)
              BlocBuilder<PendingTransfersCubit, PendingTransfersState>(
                builder: (context, transferState) {
                  final count = transferState.pendingCount;
                  return _buildMenuCard(
                    context,
                    title: 'Devir İstekleri',
                    subtitle:
                        'Size devredilen görevleri kabul edin veya reddedin.',
                    icon: Icons.assignment_ind_outlined,
                    color: Colors.orange.shade800,
                    badgeText: count > 0 ? '$count Bekliyor' : null,
                    badgeColor: Colors.red.shade700,
                    onTap: () => context.push(RouteNames.transferRequests),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Card 4: Çöp Kutusu
              _buildMenuCard(
                context,
                title: 'Çöp Kutusu',
                subtitle:
                    'Silinen görevleri kurtarın veya kalıcı olarak temizleyin.',
                icon: Icons.delete_outline,
                color: Colors.blueGrey.shade700,
                onTap: () => context.push(RouteNames.trash),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor ?? Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
