import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/login_cubit.dart';
import '../cubits/login_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../../../../core/router/route_names.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              if (state.requiresTwoFactor) {
                context.read<AuthBloc>().add(
                  TwoFactorRequired(
                    twoFactorToken: state.twoFactorToken!,
                    email: state.email,
                  ),
                );
              } else {
                // In a real app we'd extract userId from session,
                // but AuthBloc just needs to know we're authenticated.
                // The repository handles the token storage.
                context.read<AuthBloc>().add(const LoggedIn(userId: ''));
              }
            }
            if (state is LoginFailure && state.generalError != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.generalError!)));
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthTextField(
                  label: 'E-posta',
                  errorText: state.emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) =>
                      context.read<LoginCubit>().emailChanged(val),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Şifre',
                  errorText: state.passwordError,
                  obscureText: true,
                  onChanged: (val) =>
                      context.read<LoginCubit>().passwordChanged(val),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Giriş Yap',
                  isLoading: state is LoginLoading,
                  onPressed: () {
                    context.read<LoginCubit>().submit();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.push(RouteNames.register);
                  },
                  child: const Text('Hesabınız yok mu? Kayıt Ol'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
