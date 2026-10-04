# Tasks: FEAT-10 — Ownership Transfer

## Task Overview

- [ ] Task 1: API Constants & Data Layer Models
  - Add 5 ownership transfer endpoints to `lib/core/constants/api_constants.dart`
  - Create `CreateTransferRequestDto` in `lib/features/ownership_transfer/data/models/`
  - Create `TransferRequestResponseDto` in `lib/features/ownership_transfer/data/models/`
  - Create `TransferRequestsCollectionResponseDto` in `lib/features/ownership_transfer/data/models/`
  - Create `TransferActionResponseDto` in `lib/features/ownership_transfer/data/models/`

- [ ] Task 2: Remote Data Source & Repository
  - Create `OwnershipTransferRemoteDataSource` & implementation in `lib/features/ownership_transfer/data/datasources/`
  - Create `OwnershipTransferRepository` interface in `lib/features/ownership_transfer/domain/repositories/`
  - Create `OwnershipTransferRepositoryImpl` in `lib/features/ownership_transfer/data/repositories/`

- [ ] Task 3: State Management
  - Create `PendingTransfersCubit` & `PendingTransfersState` for incoming requests & badge count
  - Create `TransferRequestCubit` & `TransferRequestState` for initiating / cancelling transfers

- [ ] Task 4: UI Widgets & Screens
  - Create `TransferOwnershipDialog`
  - Create `TransferRequestCard`
  - Create `TransferRequestsScreen`
  - Add "Sahipliği Devret" action to `TaskDetailScreen`
  - Add pending transfers badge button to `HomeScreen` and `TasksScreen`

- [ ] Task 5: Routing & DI
  - Add `RouteNames.transferRequests` and route definition in `app_router.dart`
  - Register `OwnershipTransferRepository` and `PendingTransfersCubit` in `main.dart`

- [ ] Task 6: Unit Testing & Verification
  - Unit tests in `test/features/ownership_transfer/ownership_transfer_test.dart`
  - Run `dart analyze lib test` (0 issues)
  - Run `flutter test` (all tests passing)
  - Build debug APK and install on Samsung Galaxy A71

