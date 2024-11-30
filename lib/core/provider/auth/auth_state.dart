part of 'auth_bloc.dart';

class AuthenticationState {
  final AuthenticationEvents? event;
  final AuthResponse? authResponse;
  final User? user;

  AuthenticationState({required this.event, required this.authResponse, this.user});

  AuthenticationState copyWith({AuthenticationEvents? event, AuthResponse? authResponse, User? user}) {
    return AuthenticationState(
      event: event ?? this.event,
      authResponse: authResponse ?? this.authResponse,
      user: user ?? this.user,
    );
  }

  factory AuthenticationState.initial() {
    return AuthenticationState(event: null, authResponse: null);
  }
}
