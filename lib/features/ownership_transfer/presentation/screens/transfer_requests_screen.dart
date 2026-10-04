import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/pending_transfers_cubit.dart';
import '../cubits/pending_transfers_state.dart';
import '../widgets/transfer_request_card.dart';

class TransferRequestsScreen extends StatefulWidget {
  const TransferRequestsScreen({super.key});

  @override
  State<TransferRequestsScreen> createState() => _TransferRequestsScreenState();
}

class _TransferRequestsScreenState extends State<TransferRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendingTransfersCubit>().loadPendingTransfers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devir İstekleri'),
      ),
      body: BlocConsumer<PendingTransfersCubit, PendingTransfersState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PendingTransfersStatus.loading &&
              state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PendingTransfersStatus.error &&
              state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 54,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'İstekler yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<PendingTransfersCubit>()
                          .loadPendingTransfers(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context
                  .read<PendingTransfersCubit>()
                  .loadPendingTransfers(),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bekleyen Devir İsteği Yok',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Size devredilen görevler burada listelenir.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<PendingTransfersCubit>().loadPendingTransfers(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final req = state.items[index];
                return TransferRequestCard(
                  request: req,
                  onAccept: () async {
                    await context
                        .read<PendingTransfersCubit>()
                        .acceptTransfer(req.id);
                  },
                  onReject: () async {
                    await context
                        .read<PendingTransfersCubit>()
                        .rejectTransfer(req.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

