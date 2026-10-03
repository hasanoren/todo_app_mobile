import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/login_2fa_cubit.dart';
import '../cubits/login_2fa_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';

class Login2faScreen extends StatelessWidget {
  const Login2faScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İki Adımlı Doğrulama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<Login2faCubit, Login2faState>(
          listener: (context, state) {
            if (state is Login2faSuccess) {
              context.read<AuthBloc>().add(const LoggedIn(userId: ''));
            }
            if (state is Login2faFailure && state.generalError != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.generalError!)));
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Lütfen 6 haneli doğrulama kodunuzu girin.'),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Doğrulama Kodu',
                  errorText: state.codeError,
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      context.read<Login2faCubit>().codeChanged(val),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Doğrula',
                  isLoading: state is Login2faLoading,
                  onPressed: () {
                    context.read<Login2faCubit>().submit();
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
