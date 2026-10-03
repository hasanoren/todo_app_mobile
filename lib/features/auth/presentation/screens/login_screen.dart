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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _extraHandled = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExtraPayload();
    });
  }

  void _checkExtraPayload() {
    if (!mounted || _extraHandled) return;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      _extraHandled = true;
      if (extra['email'] != null && extra['email'].toString().isNotEmpty) {
        final email = extra['email'].toString();
        _emailController.text = email;
        context.read<LoginCubit>().emailChanged(email);
      }
      if (extra['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(extra['message'].toString()),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                context.read<AuthBloc>().add(const LoggedIn(userId: ''));
              }
            }
            if (state is LoginFailure && state.generalError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.generalError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthTextField(
                  label: 'E-posta',
                  controller: _emailController,
                  errorText: state.emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) =>
                      context.read<LoginCubit>().emailChanged(val),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Şifre',
                  controller: _passwordController,
                  errorText: state.passwordError,
                  obscureText: true,
                  onChanged: (val) =>
                      context.read<LoginCubit>().passwordChanged(val),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(RouteNames.forgotPassword);
                    },
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),
                const SizedBox(height: 16),
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
