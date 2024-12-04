import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/user/user_event.dart';
import 'package:inotes/core/provider/user/user_state.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/core/utils/log_service.dart';
import 'package:inotes/core/service/remote/user_service.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserState.initial()) {
    on<UserEvent>((event, emit) async {
      switch (event.type) {
        case UserEvents.getUserStart:
          await _onGetUserStart(event, emit);
          break;
        case UserEvents.updateProfileStart:
          await _onUpdateProfileStart(event, emit);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _onGetUserStart(UserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(event: UserEvents.getUserStart));

    try {
      await _userService.getUser(userId: event.payload).then((user) async {
        if (user == null) {
          emit(state.copyWith(event: UserEvents.getUserFailure));
          return;
        }
        await _secureStorageCacheService.setUser(user);
        emit(state.copyWith(event: UserEvents.getUserSuccess, user: user));
      });
      final user = await _secureStorageCacheService.getUser();
      emit(state.copyWith(event: UserEvents.getUserSuccess, user: user));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to get user',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: UserEvents.getUserFailure,
      ));
    }
  }

  Future<void> _onUpdateProfileStart(UserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(event: UserEvents.updateProfileStart));

    try {
      await _userService.updateProfilePicture(userJson: event.payload).then((user) async {
        if (user == null) {
          emit(state.copyWith(event: UserEvents.updateProfileFailure));
          return;
        }
        await _secureStorageCacheService.setUser(user);
        emit(state.copyWith(event: UserEvents.updateProfileSuccess, user: user));
      });
      final user = await _secureStorageCacheService.getUser();
      emit(state.copyWith(event: UserEvents.getUserSuccess, user: user));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to edit user',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: UserEvents.updateProfileFailure,
      ));
    }
  }

  final _secureStorageCacheService = SecureStorageCacheService.instance;
  final _userService = UserService.instance;
}
