import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/profile_state.dart';
import '../cubits/change_password_cubit.dart';
import '../cubits/change_password_state.dart';
import '../widgets/auth_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  void _showChangePasswordModal(BuildContext context) {
    final changePasswordCubit = context.read<ChangePasswordCubit>();
    changePasswordCubit.reset();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: changePasswordCubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
              if (state.successMessage != null) {
                Navigator.of(bottomSheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<ChangePasswordCubit>();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Şifre Değiştir',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Mevcut Şifre',
                      obscureText: true,
                      errorText: state.currentPasswordError,
                      onChanged: cubit.currentPasswordChanged,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: 'Yeni Şifre',
                      obscureText: true,
                      errorText: state.newPasswordError,
                      onChanged: cubit.newPasswordChanged,
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: 'Yeni Şifre Tekrar',
                      obscureText: true,
                      errorText: state.confirmPasswordError,
                      onChanged: cubit.confirmPasswordChanged,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              cubit.submit();
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Şifreyi Güncelle',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

  void _showDeleteAccountDialog(BuildContext context, ProfileCubit profileCubit) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocConsumer<ProfileCubit, ProfileState>(
          bloc: profileCubit,
          listener: (context, state) {
            if (state.deletionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.deletionError!),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  const Text('Hesabı Kalıcı Olarak Sil'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hesabınızı silmek üzeresiniz. Bu işlem kalıcıdır ve geri alınamaz! Tüm listeleriniz ve görevleriniz tamamen silinecektir.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'İşlemi onaylamak için lütfen hesap şifrenizi girin:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Şifreniz',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: state.isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: state.isDeleting
                      ? null
                      : () async {
                          final success = await profileCubit
                              .deleteAccount(passwordController.text);
                          if (success && context.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: state.isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kalıcı Olarak Sil'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap & Profil'),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          if (state.deletionSuccess) {
            context.read<AuthBloc>().add(LoggedOut());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hesabınız ve ilişkili tüm veriler başarıyla silindi.'),
                backgroundColor: Colors.black87,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profil bilgileri alınamadı.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().loadProfile();
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final initialLetter = profile.email.isNotEmpty
              ? profile.email[0].toUpperCase()
              : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kimlik Kartı
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            initialLetter,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.email,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(
                            profile.role == 'Admin'
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            size: 18,
                            color: profile.role == 'Admin'
                                ? Colors.purple.shade700
                                : Colors.blue.shade700,
                          ),
                          label: Text(
                            profile.role == 'Admin' ? 'Yönetici' : 'Kullanıcı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: profile.role == 'Admin'
                                  ? Colors.purple.shade900
                                  : Colors.blue.shade900,
                            ),
                          ),
                          backgroundColor: profile.role == 'Admin'
                              ? Colors.purple.shade50
                              : Colors.blue.shade50,
                          side: BorderSide(
                            color: profile.role == 'Admin'
                                ? Colors.purple.shade200
                                : Colors.blue.shade200,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kullanıcı ID:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  profile.userId.length > 12
                                      ? '${profile.userId.substring(0, 8)}...${profile.userId.substring(profile.userId.length - 4)}'
                                      : profile.userId,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  tooltip: 'ID Kopyala',
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: profile.userId),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kullanıcı ID panoya kopyalandı.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Güvenlik Bölümü
                Text(
                  'Güvenlik & Giriş',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: const Text('İki Faktörlü Doğrulama (2FA)'),
                        subtitle: Text(
                          profile.isTwoFactorEnabled
                              ? 'Hesabınız ek güvenlik ile korunuyor'
                              : 'Ek güvenlik katmanı kapalı',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                profile.isTwoFactorEnabled ? 'Etkin' : 'Devre Dışı',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: profile.isTwoFactorEnabled
                                      ? Colors.green.shade900
                                      : Colors.grey.shade800,
                                ),
                              ),
                              backgroundColor: profile.isTwoFactorEnabled
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              padding: EdgeInsets.zero,
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          await context.push(RouteNames.twoFactorSettings);
                          if (context.mounted) {
                            context.read<ProfileCubit>().loadProfile();
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_reset),
                        title: const Text('Şifre Değiştir'),
                        subtitle: const Text(
                          'Mevcut şifrenizi yenisiyle güncelleyin',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showChangePasswordModal(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tehlikeli Bölge
                Text(
                  'Tehlikeli Bölge',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  color: Colors.red.shade50.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                    title: Text(
                      'Hesabımı Kalıcı Olarak Sil',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Tüm verileriniz silinir. Bu işlem geri alınamaz.',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      _showDeleteAccountDialog(
                        context,
                        context.read<ProfileCubit>(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
