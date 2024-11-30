import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/models/auth_form.dart';
import 'package:inotes/core/models/user.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/service/remote/auth.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationState.initial()) {
    on<AuthenticationEvent>((event, emit) async {
      switch (event.type) {
        case AuthenticationEvents.loginStart:
          await _onLogin(event, emit);
          break;
        case AuthenticationEvents.registerStart:
          await _onRegister(event, emit);
          break;
        case AuthenticationEvents.logoutStart:
          await _onLogout(event, emit);
          break;
        case AuthenticationEvents.checkAuthentication:
          await _onCheckAuthentication(event, emit);
          break;
        default:
      }
    });
  }

  Future<void> _onCheckAuthentication(AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(event: AuthenticationEvents.checkAuthentication));
    await Future.delayed(Durations.extralong4 * 2);
    try {
      final user = await _secureStorageCacheService.getUser();
      if (user != null) {
        emit(state.copyWith(event: AuthenticationEvents.authenticated, user: user));
      } else {
        emit(state.copyWith(event: AuthenticationEvents.unauthenticated));
      }
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Error during authentication check',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(event: AuthenticationEvents.unauthenticated));
    }
  }

  Future<void> _onLogin(AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(state.copyWith(event: AuthenticationEvents.loginStart));
      final loginForm = LoginForm(
        username: event.payload.username,
        password: event.payload.password,
      );
      final loginResponse = await _authenticationService.login(loginForm);

      if (loginResponse.successResponse != null) {
        final user = loginResponse.successResponse!.user;
        await _secureStorageCacheService.setUser(user);

        emit(state.copyWith(
          event: AuthenticationEvents.loginSuccess,
          authResponse: loginResponse,
        ));
      } else {
        emit(state.copyWith(
          event: AuthenticationEvents.loginFailure,
          authResponse: loginResponse,
        ));
      }
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Login error occurred',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: AuthenticationEvents.loginFailure,
        authResponse: AuthResponse(failureResponse: FailureResponse(error: error.toString())),
      ));
    }
  }

  Future<void> _onRegister(AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(state.copyWith(event: AuthenticationEvents.registerStart));
      final registerForm = RegisterForm(
        email: event.payload.email,
        username: event.payload.username,
        password: event.payload.password,
      );
      final registerResponse = await _authenticationService.register(registerForm);

      if (registerResponse.successResponse != null) {
        final user = registerResponse.successResponse!.user;
        await _secureStorageCacheService.setUser(user);

        emit(state.copyWith(
          event: AuthenticationEvents.registerSuccess,
          authResponse: registerResponse,
        ));
      } else {
        emit(state.copyWith(
          event: AuthenticationEvents.registerFailure,
          authResponse: registerResponse,
        ));
      }
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Register error occurred',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: AuthenticationEvents.registerFailure,
        authResponse: AuthResponse(failureResponse: FailureResponse(error: error.toString())),
      ));
    }
  }

  Future<void> _onLogout(AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(event: AuthenticationEvents.logoutStart));
    try {
      await _secureStorageCacheService.clearCache();
      emit(state.copyWith(event: AuthenticationEvents.unauthenticated));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Login error occurred',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        event: AuthenticationEvents.logoutFailure,
      ));
    }
  }

  final AuthenticationService _authenticationService = AuthenticationService.instance;
  final SecureStorageCacheService _secureStorageCacheService = SecureStorageCacheService.instance;
}
