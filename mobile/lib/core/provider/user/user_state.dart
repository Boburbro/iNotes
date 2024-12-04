import '../../models/user.dart';
import 'user_event.dart';

class UserState {
  final User? user;
  final UserEvents? event;

  UserState({this.user, this.event});

  UserState copyWith({User? user, UserEvents? event}) {
    return UserState(user: user ?? this.user, event: event ?? this.event);
  }

  factory UserState.initial() {
    return UserState(user: null, event: null);
  }
}
