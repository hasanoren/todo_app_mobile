import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/two_factor_cubit.dart';
import '../cubits/two_factor_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';

class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İki Adımlı Doğrulama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<TwoFactorCubit, TwoFactorState>(
          listener: (context, state) {
            if (state is TwoFactorSuccess) {
              context.read<AuthBloc>().add(const LoggedIn(userId: ''));
            }
            if (state is TwoFactorFailure && state.generalError != null) {
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
                      context.read<TwoFactorCubit>().codeChanged(val),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Doğrula',
                  isLoading: state is TwoFactorLoading,
                  onPressed: () {
                    context.read<TwoFactorCubit>().submit();
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
