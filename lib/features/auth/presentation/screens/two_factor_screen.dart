import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../cubits/two_factor_cubit.dart';
import '../cubits/two_factor_state.dart';

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final TextEditingController _verifyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TwoFactorCubit>().loadStatus();
    });
  }

  @override
  void dispose() {
    _verifyCodeController.dispose();
    super.dispose();
  }

  void _showDisableDialog(BuildContext context, TwoFactorCubit cubit) {
    final TextEditingController disableCodeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocConsumer<TwoFactorCubit, TwoFactorState>(
          bloc: cubit,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
            if (state.successMessage != null && !state.isEnabled) {
              Navigator.of(dialogContext).pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text('2FA\'yı Devre Dışı Bırak'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İki faktörlü doğrulamayı kapatmak istediğinize emin misiniz? Güvenliğiniz için lütfen Authenticator uygulamanızdaki 6 haneli kodu girin:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: disableCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                    decoration: const InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          cubit.disable2fa(disableCodeController.text);
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Devre Dışı Bırak'),
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
        title: const Text('İki Faktörlü Doğrulama'),
      ),
      body: BlocConsumer<TwoFactorCubit, TwoFactorState>(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
            _verifyCodeController.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Durum Kartı
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          state.isEnabled
                              ? Icons.verified_user
                              : Icons.gpp_maybe,
                          size: 56,
                          color: state.isEnabled
                              ? Colors.green.shade600
                              : Colors.amber.shade700,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.isEnabled
                              ? '2FA Şu Anda Etkin'
                              : '2FA Şu Anda Devre Dışı',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state.isEnabled
                                ? Colors.green.shade800
                                : Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.isEnabled
                              ? 'Hesabınız ek bir güvenlik katmanı ile korunuyor. Giriş yaparken Authenticator kodunuz istenecektir.'
                              : 'Hesabınızı yetkisiz erişimlere karşı korumak için iki faktörlü doğrulamayı etkinleştirmeniz önerilir.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2FA Zaten Etkinse -> Devre Dışı Bırakma Butonu
                if (state.isEnabled) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.lock_open),
                    label: const Text(
                      'İki Faktörlü Doğrulamayı Devre Dışı Bırak',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _showDisableDialog(
                        context,
                        context.read<TwoFactorCubit>(),
                      );
                    },
                  ),
                ],

                // 2FA Devre Dışı İse ve Kurulum Başlatılmamışsa -> Etkinleştir Butonu
                if (!state.isEnabled && !state.isSetupVisible) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shield_outlined),
                    label: Text(
                      state.isSubmitting
                          ? 'Hazırlanıyor...'
                          : 'İki Faktörlü Doğrulamayı Etkinleştir',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            context.read<TwoFactorCubit>().initiateSetup();
                          },
                  ),
                ],

                // 2FA Kurulum Sihirbazı (QR Kod + Gizli Anahtar + Doğrulama Kodu)
                if (!state.isEnabled && state.isSetupVisible) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '1. QR Kodu Tarayın',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Google Authenticator veya Microsoft Authenticator uygulamanız ile aşağıdaki QR kodu okutun:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          if (state.qrCodeUri != null &&
                              state.qrCodeUri!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: QrImageView(
                                data: state.qrCodeUri!,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                          const SizedBox(height: 20),

                          const Divider(),
                          const SizedBox(height: 12),

                          // Manuel Giriş Anahtarı
                          Text(
                            'Veya Gizli Anahtarı Elle Girin',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    state.secret ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  tooltip: 'Panoya Kopyala',
                                  onPressed: () {
                                    if (state.secret != null) {
                                      Clipboard.setData(
                                        ClipboardData(text: state.secret!),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Gizli anahtar panoya kopyalandı.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Divider(),
                          const SizedBox(height: 16),

                          // Doğrulama Kodu Girişi
                          Text(
                            '2. Doğrulama Kodunu Girin',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Authenticator uygulamanızda üretilen 6 haneli kodu yazarak kurulumu tamamlayın:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _verifyCodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: const InputDecoration(
                              hintText: '000000',
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Doğrulama Butonları
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () {
                                          context
                                              .read<TwoFactorCubit>()
                                              .cancelSetup();
                                        },
                                  child: const Text('Vazgeç'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () {
                                          context
                                              .read<TwoFactorCubit>()
                                              .verifyCode(
                                                _verifyCodeController.text,
                                              );
                                        },
                                  child: state.isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Doğrula ve Etkinleştir',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
