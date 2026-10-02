import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/register_cubit.dart';
import '../cubits/register_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              context.read<AuthBloc>().add(const LoggedIn(userId: ''));
            }
            if (state is RegisterFailure && state.generalError != null) {
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
                      context.read<RegisterCubit>().emailChanged(val),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Şifre',
                  errorText: state.passwordError,
                  obscureText: true,
                  onChanged: (val) =>
                      context.read<RegisterCubit>().passwordChanged(val),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Kayıt Ol',
                  isLoading: state is RegisterLoading,
                  onPressed: () {
                    context.read<RegisterCubit>().submit();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
