import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/forgot_password_cubit.dart';
import '../cubits/forgot_password_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../../../../core/router/route_names.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess &&
                  state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is ForgotPasswordFailure &&
                  state.generalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.generalError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isCooldown = state.isCooldownActive;
              final buttonText = isCooldown
                  ? 'Tekrar göndermek için ${state.cooldownSeconds} sn bekleyin'
                  : (state.successMessage != null
                        ? 'Tekrar Gönder'
                        : 'Sıfırlama Bağlantısı Gönder');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Şifrenizi mi unuttunuz?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kayıtlı e-posta adresinizi girin. Size şifrenizi sıfırlamanız için güvenli bir bağlantı göndereceğiz.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    label: 'E-posta Adresi',
                    hintText: 'ornek@email.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: state.emailError,
                    onChanged: (val) =>
                        context.read<ForgotPasswordCubit>().emailChanged(val),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    text: buttonText,
                    isLoading: state is ForgotPasswordSubmitting,
                    onPressed: isCooldown
                        ? null
                        : () => context.read<ForgotPasswordCubit>().submit(),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Şifrenizi hatırladınız mı?'),
                      TextButton(
                        onPressed: () => context.go(RouteNames.login),
                        child: const Text('Giriş Yap'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
