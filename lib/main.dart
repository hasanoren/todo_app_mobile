import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'core/storage/secure_storage_service.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'core/router/app_router.dart';

// Providers for other screens
import 'features/auth/presentation/cubits/login_cubit.dart';
import 'features/auth/presentation/cubits/register_cubit.dart';
import 'features/auth/presentation/cubits/two_factor_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DI setup (normally done via get_it)
  final secureStorage = SecureStorageService();

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late final AuthBloc authBloc;

  final dioClient = DioClient(
    secureStorage,
    onRefreshFailed: () {
      authBloc.add(SessionExpired());
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Oturumunuzun süresi doldu, lütfen tekrar giriş yapın.',
          ),
        ),
      );
    },
  );

  final authRemoteDS = AuthRemoteDataSourceImpl(dioClient.dio);
  final authRepo = AuthRepositoryImpl(authRemoteDS, secureStorage);

  authBloc = AuthBloc(authRepository: authRepo);
  // Wait for initial session check
  authBloc.add(AppStarted());

  // Wait for state to not be initial before running app if possible
  // In a real app we'd use a splash screen for this, but for now we just runApp

  final appRouter = AppRouter(authBloc);

  runApp(
    MyApp(
      authBloc: authBloc,
      appRouter: appRouter,
      authRepo: authRepo, // Provided just for Cubits in this simple setup
      scaffoldMessengerKey: scaffoldMessengerKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AppRouter appRouter;
  final AuthRepositoryImpl authRepo;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.appRouter,
    required this.authRepo,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        // Just for simplicity, we provide these globally here for the dummy screens
        BlocProvider(create: (_) => LoginCubit(authRepo)),
        BlocProvider(create: (_) => RegisterCubit(authRepo)),
        BlocProvider(
          create: (_) => TwoFactorCubit(authRepo, ''),
        ), // Token injected dynamically usually
      ],
      child: MaterialApp.router(
        title: 'Todo App',
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
