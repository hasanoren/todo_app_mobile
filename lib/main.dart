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
import 'features/subtasks/data/datasources/subtasks_remote_data_source.dart';
import 'features/subtasks/data/repositories/subtasks_repository_impl.dart';
import 'features/subtasks/domain/repositories/subtasks_repository.dart';
import 'features/tags/data/datasources/tags_remote_data_source.dart';
import 'features/tags/data/repositories/tags_repository_impl.dart';
import 'features/tags/domain/repositories/tags_repository.dart';
import 'features/tags/presentation/cubits/system_tags_cubit.dart';
import 'features/task_shares/data/datasources/task_shares_remote_data_source.dart';
import 'features/task_shares/data/repositories/task_shares_repository_impl.dart';
import 'features/task_shares/domain/repositories/task_shares_repository.dart';
import 'features/ownership_transfer/data/datasources/ownership_transfer_remote_data_source.dart';
import 'features/ownership_transfer/data/repositories/ownership_transfer_repository_impl.dart';
import 'features/ownership_transfer/domain/repositories/ownership_transfer_repository.dart';
import 'features/ownership_transfer/presentation/cubits/pending_transfers_cubit.dart';
import 'features/task_activities/data/datasources/task_activities_remote_data_source.dart';
import 'features/task_activities/data/repositories/task_activities_repository_impl.dart';
import 'features/task_activities/domain/repositories/task_activities_repository.dart';

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
  final todoListsRepo = TodoListsRepositoryImpl(
    remoteDataSource: todoListsRemoteDS,
  );

  final todoItemsRemoteDS = TodoItemsRemoteDataSourceImpl(dio: dioClient.dio);
  final todoItemsRepo = TodoItemsRepositoryImpl(
    remoteDataSource: todoItemsRemoteDS,
  );

  final subtasksRemoteDS = SubtasksRemoteDataSourceImpl(dio: dioClient.dio);
  final subtasksRepo =
      SubtasksRepositoryImpl(remoteDataSource: subtasksRemoteDS);

  final tagsRemoteDS = TagsRemoteDataSourceImpl(dio: dioClient.dio);
  final tagsRepo = TagsRepositoryImpl(remoteDataSource: tagsRemoteDS);

  final taskSharesRemoteDS = TaskSharesRemoteDataSourceImpl(dio: dioClient.dio);
  final taskSharesRepo =
      TaskSharesRepositoryImpl(remoteDataSource: taskSharesRemoteDS);

  final ownershipTransferRemoteDS =
      OwnershipTransferRemoteDataSourceImpl(dio: dioClient.dio);
  final ownershipTransferRepo = OwnershipTransferRepositoryImpl(
    remoteDataSource: ownershipTransferRemoteDS,
    storage: secureStorage,
  );

  final taskActivitiesRemoteDS =
      TaskActivitiesRemoteDataSourceImpl(dio: dioClient.dio);
  final taskActivitiesRepo =
      TaskActivitiesRepositoryImpl(remoteDataSource: taskActivitiesRemoteDS);

  authBloc = AuthBloc(authRepository: authRepo);
  authBloc.add(AppStarted());

  final appRouter = AppRouter(authBloc, authRepo, todoListsRepo, todoItemsRepo);

  runApp(
    MyApp(
      authBloc: authBloc,
      appRouter: appRouter,
      authRepo: authRepo,
      todoListsRepo: todoListsRepo,
      todoItemsRepo: todoItemsRepo,
      subtasksRepo: subtasksRepo,
      tagsRepo: tagsRepo,
      taskSharesRepo: taskSharesRepo,
      ownershipTransferRepo: ownershipTransferRepo,
      taskActivitiesRepo: taskActivitiesRepo,
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
  final SubtasksRepository subtasksRepo;
  final TagsRepository tagsRepo;
  final TaskSharesRepository taskSharesRepo;
  final OwnershipTransferRepository ownershipTransferRepo;
  final TaskActivitiesRepository taskActivitiesRepo;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.appRouter,
    required this.authRepo,
    required this.todoListsRepo,
    required this.todoItemsRepo,
    required this.subtasksRepo,
    required this.tagsRepo,
    required this.taskSharesRepo,
    required this.ownershipTransferRepo,
    required this.taskActivitiesRepo,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<TodoListsRepository>.value(value: todoListsRepo),
        RepositoryProvider<TodoItemsRepository>.value(value: todoItemsRepo),
        RepositoryProvider<SubtasksRepository>.value(value: subtasksRepo),
        RepositoryProvider<TagsRepository>.value(value: tagsRepo),
        RepositoryProvider<TaskSharesRepository>.value(value: taskSharesRepo),
        RepositoryProvider<OwnershipTransferRepository>.value(
          value: ownershipTransferRepo,
        ),
        RepositoryProvider<TaskActivitiesRepository>.value(
          value: taskActivitiesRepo,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(create: (_) => LoginCubit(authRepo)),
          BlocProvider(create: (_) => RegisterCubit(authRepo)),
          BlocProvider(create: (_) => TwoFactorCubit(authRepo)),
          BlocProvider(create: (_) => SystemTagsCubit(tagsRepository: tagsRepo)),
          BlocProvider(
            create: (_) => PendingTransfersCubit(
              repository: ownershipTransferRepo,
            )..loadPendingTransfers(),
          ),
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

