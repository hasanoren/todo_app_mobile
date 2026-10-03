import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/secure_storage_service.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'core/router/app_router.dart';

import 'features/auth/presentation/cubits/login_cubit.dart';
import 'features/auth/presentation/cubits/register_cubit.dart';
import 'features/auth/presentation/cubits/two_factor_cubit.dart';
import 'features/todo_lists/data/datasources/todo_lists_remote_data_source.dart';
import 'features/todo_lists/data/repositories/todo_lists_repository_impl.dart';
import 'features/todo_lists/domain/repositories/todo_lists_repository.dart';
import 'features/tasks/data/datasources/todo_items_remote_data_source.dart';
import 'features/tasks/data/repositories/todo_items_repository_impl.dart';
import 'features/tasks/domain/repositories/todo_items_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DI setup
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

  final todoListsRemoteDS = TodoListsRemoteDataSourceImpl(dio: dioClient.dio);
  final todoListsRepo =
      TodoListsRepositoryImpl(remoteDataSource: todoListsRemoteDS);

  final todoItemsRemoteDS = TodoItemsRemoteDataSourceImpl(dio: dioClient.dio);
  final todoItemsRepo =
      TodoItemsRepositoryImpl(remoteDataSource: todoItemsRemoteDS);

  authBloc = AuthBloc(authRepository: authRepo);
  authBloc.add(AppStarted());

  final appRouter =
      AppRouter(authBloc, authRepo, todoListsRepo, todoItemsRepo);

  runApp(
    MyApp(
      authBloc: authBloc,
      appRouter: appRouter,
      authRepo: authRepo,
      todoListsRepo: todoListsRepo,
      todoItemsRepo: todoItemsRepo,
      scaffoldMessengerKey: scaffoldMessengerKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AppRouter appRouter;
  final AuthRepository authRepo;
  final TodoListsRepository todoListsRepo;
  final TodoItemsRepository todoItemsRepo;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.appRouter,
    required this.authRepo,
    required this.todoListsRepo,
    required this.todoItemsRepo,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<TodoListsRepository>.value(value: todoListsRepo),
        RepositoryProvider<TodoItemsRepository>.value(value: todoItemsRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(create: (_) => LoginCubit(authRepo)),
          BlocProvider(create: (_) => RegisterCubit(authRepo)),
          BlocProvider(create: (_) => TwoFactorCubit(authRepo)),
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
      ),
    );
  }
}

