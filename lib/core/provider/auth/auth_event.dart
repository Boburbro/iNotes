part of 'auth_bloc.dart';

enum AuthenticationEvents {
  loginStart,
  loginSuccess,
  loginFailure,

  registerStart,
  registerSuccess,
  registerFailure,

  logoutStart,
  logoutFailure,

  checkAuthentication,
  authenticated,
  unauthenticated,
}

class AuthenticationEvent {
  AuthenticationEvents? type;
  dynamic payload;

  AuthenticationEvent.loginStart(LoginForm loginform) {
    type = AuthenticationEvents.loginStart;
    payload = loginform;
  }

  AuthenticationEvent.registerStart(RegisterForm registerform) {
    type = AuthenticationEvents.registerStart;
    payload = registerform;
  }

  AuthenticationEvent.logoutStart() {
    type = AuthenticationEvents.logoutStart;
  }

  AuthenticationEvent.checkAuthentication() {
    type = AuthenticationEvents.checkAuthentication;
  }
}
