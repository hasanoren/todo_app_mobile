# Tasks: FEAT-13 — SignalR Real-Time Notifications

## 1. Foundation & Models
- [x] T001: Add `signalRHub` endpoint to `lib/core/constants/api_constants.dart`
- [x] T002: Create domain events `RealtimeEvent` hierarchy in `lib/features/realtime/domain/models/realtime_event.dart`

## 2. Data Layer
- [x] T003: Create `RealtimeRemoteDataSource` interface and `SignalRRemoteDataSourceImpl` using `signalr_netcore`
- [x] T004: Create `RealtimeRepository` interface and `RealtimeRepositoryImpl`

## 3. Presentation Layer
- [x] T005: Create `RealtimeState` and `RealtimeCubit` managing connection lifecycle and event streams
- [x] T006: Create `RealtimeNotificationListener` widget to show in-app SnackBar alerts and refresh tasks/transfers

## 4. Integration
- [x] T007: Register `RealtimeRepository` and `RealtimeCubit` in `lib/main.dart`
- [x] T008: Integrate `RealtimeNotificationListener` into MaterialApp builder / router shell

## 5. Testing & Verification
- [x] T009: Create comprehensive unit & widget tests in `test/features/realtime/realtime_test.dart`
- [x] T010: Verify with `dart analyze lib test` and `flutter test`

