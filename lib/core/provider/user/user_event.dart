enum UserEvents {
  getUserStart,
  getUserSuccess,
  getUserFailure,

  updateProfileStart,
  updateProfileSuccess,
  updateProfileFailure,
}

class UserEvent {
  UserEvents? event;
  dynamic type;

  UserEvent.getUserStart({this.type}) {
    event = UserEvents.getUserStart;
  }

  UserEvent.updateProfileStart({this.type}) {
    event = UserEvents.updateProfileStart;
  }
}
