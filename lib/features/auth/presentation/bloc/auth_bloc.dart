// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  Timer? _refreshTimer;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<TwoFactorRequired>(_onTwoFactorRequired);
    on<LoggedOut>(_onLoggedOut);
    on<SessionExpired>(_onSessionExpired);
    on<RefreshRequested>(_onRefreshRequested);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  void _startRefreshTimer(DateTime expiresAt) {
    _refreshTimer?.cancel();
    final now = DateTime.now();
    // Refresh 5 minutes before expiry
    var timeUntilRefresh = expiresAt
        .subtract(const Duration(minutes: 5))
        .difference(now);

    if (timeUntilRefresh.isNegative) {
      timeUntilRefresh = Duration.zero;
    }

    _refreshTimer = Timer(timeUntilRefresh, () {
      add(RefreshRequested());
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final session = await _authRepository.checkInitialSession();
      if (session != null) {
        _startRefreshTimer(session.expiresAt);
        emit(Authenticated(session.userId));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    // In a full app, LoggedIn event should pass the AuthSession object
    // For now we assume we just check the session again to get expiresAt
    final session = await _authRepository.checkInitialSession();
    if (session != null) {
      _startRefreshTimer(session.expiresAt);
    }
    emit(Authenticated(event.userId));
  }

  void _onTwoFactorRequired(TwoFactorRequired event, Emitter<AuthState> emit) {
    emit(
      AuthTwoFactorRequiredState(
        twoFactorToken: event.twoFactorToken,
        email: event.email,
      ),
    );
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    _refreshTimer?.cancel();
    await _authRepository.logout('');
    emit(Unauthenticated());
  }

  void _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) {
    _refreshTimer?.cancel();
    emit(Unauthenticated());
  }

  Future<void> _onRefreshRequested(
    RefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    try {
      // In a real app we would get the actual refresh token from secure storage,
      // but the TokenRefreshInterceptor uses it internally.
      // Wait, our repository needs the refresh token explicitly!
      // Let's rely on checkInitialSession to get the session again or just have the UI pass it.
      final session = await _authRepository.checkInitialSession();
      if (session != null) {
        await _authRepository.refreshToken(session.refreshToken);
        final newSession = await _authRepository.checkInitialSession();
        if (newSession != null) {
          _startRefreshTimer(newSession.expiresAt);
        }
      } else {
        add(SessionExpired());
      }
    } catch (_) {
      // If proactive refresh fails, we can let the interceptor handle it on the next request,
      // or we can expire the session. But often network issues shouldn't log out immediately.
      // We will try again in 1 minute.
      _refreshTimer = Timer(const Duration(minutes: 1), () {
        add(RefreshRequested());
      });
    }
  }
}
