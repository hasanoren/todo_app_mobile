import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/two_factor_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';

// Cubits
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/reset_password_cubit.dart';

class AppRouter {
  final AuthBloc authBloc;
  final AuthRepository authRepository;

  AppRouter(this.authBloc, this.authRepository);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;

      final bool isGoingToLogin = state.matchedLocation == RouteNames.login;
      final bool isGoingToRegister =
          state.matchedLocation == RouteNames.register;
      final bool isGoingTo2FA = state.matchedLocation == RouteNames.login2fa;
      final bool isGoingToForgotPassword =
          state.matchedLocation == RouteNames.forgotPassword;
      final bool isGoingToResetPassword =
          state.matchedLocation == RouteNames.resetPassword;

      if (authState is AuthInitial) {
        return null; // Wait for initialization (maybe show splash)
      }

      // Check empty token for reset password
      if (isGoingToResetPassword) {
        final token = state.uri.queryParameters['token'];
        if (token == null || token.trim().isEmpty) {
          return RouteNames.login;
        }
      }

      if (authState is Unauthenticated) {
        if (!isGoingToLogin &&
            !isGoingToRegister &&
            !isGoingToForgotPassword &&
            !isGoingToResetPassword) {
          return RouteNames.login;
        }
      }

      if (authState is AuthTwoFactorRequiredState) {
        if (!isGoingTo2FA) {
          return RouteNames.login2fa;
        }
      }

      if (authState is Authenticated) {
        if (isGoingToLogin ||
            isGoingToRegister ||
            isGoingTo2FA ||
            isGoingToForgotPassword ||
            isGoingToResetPassword) {
          return RouteNames.home;
        }
      }

      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Ana Ekran'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(LoggedOut());
                },
              ),
            ],
          ),
          body: const Center(child: Text('Todo Uygulaması Ana Ekranı (Dummy)')),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.login2fa,
        builder: (context, state) => const TwoFactorScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => ForgotPasswordCubit(authRepository),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) {
          final rawToken = state.uri.queryParameters['token'] ?? '';
          final decodedToken = rawToken.isNotEmpty
              ? Uri.decodeComponent(rawToken)
              : '';
          final email = state.uri.queryParameters['email'];

          return BlocProvider(
            create: (_) =>
                ResetPasswordCubit(authRepository, token: decodedToken),
            child: ResetPasswordScreen(email: email),
          );
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
