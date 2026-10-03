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
import '../../features/auth/presentation/screens/login_2fa_screen.dart';
import '../../features/auth/presentation/screens/two_factor_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';

// Cubits
import '../../features/auth/presentation/cubits/login_2fa_cubit.dart';
import '../../features/auth/presentation/cubits/two_factor_cubit.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/reset_password_cubit.dart';
import '../../features/auth/presentation/cubits/profile_cubit.dart';
import '../../features/auth/presentation/cubits/change_password_cubit.dart';

// TodoLists
import '../../features/todo_lists/domain/repositories/todo_lists_repository.dart';
import '../../features/todo_lists/presentation/cubits/todo_lists_cubit.dart';
import '../../features/todo_lists/presentation/screens/todo_lists_screen.dart';

class AppRouter {
  final AuthBloc authBloc;
  final AuthRepository authRepository;
  final TodoListsRepository todoListsRepository;

  AppRouter(this.authBloc, this.authRepository, this.todoListsRepository);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      debugPrint('GoRouter redirect -> URI: ${state.uri}, host: "${state.uri.host}", path: "${state.uri.path}", matchedLocation: "${state.matchedLocation}"');

      // Handle custom scheme deep links like todoapp://reset-password?token=...
      if (state.uri.host == 'reset-password' &&
          state.matchedLocation != RouteNames.resetPassword) {
        final query = state.uri.query;
        return query.isNotEmpty
            ? '${RouteNames.resetPassword}?$query'
            : RouteNames.resetPassword;
      }

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
            isGoingToForgotPassword) {
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
                icon: const Icon(Icons.format_list_bulleted),
                tooltip: 'Görev Listeleri',
                onPressed: () {
                  context.push(RouteNames.todoLists);
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Profil & Hesap',
                onPressed: () {
                  context.push(RouteNames.profile);
                },
              ),
              IconButton(
                icon: const Icon(Icons.shield_outlined),
                tooltip: 'İki Faktörlü Doğrulama (2FA)',
                onPressed: () {
                  context.push(RouteNames.twoFactorSettings);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Çıkış Yap',
                onPressed: () {
                  context.read<AuthBloc>().add(LoggedOut());
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => context.push(RouteNames.todoLists),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.format_list_bulleted,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Görev Listeleri',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Listelerinizi oluşturun ve düzenleyin.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.todoLists,
        builder: (context, state) => BlocProvider(
          create: (_) => TodoListsCubit(repository: todoListsRepository),
          child: TodoListsScreen(repository: todoListsRepository),
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProfileCubit(authRepository)),
            BlocProvider(create: (_) => ChangePasswordCubit(authRepository)),
          ],
          child: const ProfileScreen(),
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
        builder: (context, state) {
          final authState = authBloc.state;
          final twoFactorToken = authState is AuthTwoFactorRequiredState
              ? authState.twoFactorToken
              : '';
          return BlocProvider(
            create: (_) => Login2faCubit(authRepository, twoFactorToken),
            child: const Login2faScreen(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.twoFactorSettings,
        builder: (context, state) => BlocProvider(
          create: (_) => TwoFactorCubit(authRepository),
          child: const TwoFactorScreen(),
        ),
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
