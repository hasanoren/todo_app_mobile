import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/reset_password_cubit.dart';
import '../cubits/reset_password_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../../../../core/router/route_names.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Şifre Belirle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccess) {
                context.go(
                  RouteNames.login,
                  extra: {'email': email ?? '', 'message': state.message},
                );
              }
              if (state is ResetPasswordFailure &&
                  state.generalError != null &&
                  !state.isTokenInvalid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.generalError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.isTokenInvalid) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Geçersiz veya Süresi Dolmuş Bağlantı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.generalError ?? 'Sıfırlama bağlantısının süresi dolmuş veya geçersiz.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        text: 'Yeni Bağlantı İste',
                        onPressed: () => context.go(RouteNames.forgotPassword),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Yeni Şifrenizi Oluşturun',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lütfen en az 8 karakterden oluşan, büyük harf, rakam ve özel karakter içeren yeni bir şifre belirleyin.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'Yeni Şifre',
                      obscureText: true,
                      errorText: state.passwordError,
                      onChanged: (val) => context
                          .read<ResetPasswordCubit>()
                          .newPasswordChanged(val),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Yeni Şifre Tekrarı',
                      obscureText: true,
                      errorText: state.confirmPasswordError,
                      onChanged: (val) => context
                          .read<ResetPasswordCubit>()
                          .confirmPasswordChanged(val),
                    ),
                    const SizedBox(height: 24),
                    AuthPrimaryButton(
                      text: 'Şifreyi Güncelle',
                      isLoading: state is ResetPasswordSubmitting,
                      onPressed: () =>
                          context.read<ResetPasswordCubit>().submit(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
