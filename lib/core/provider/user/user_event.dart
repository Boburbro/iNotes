enum UserEvents {
  getUserStart,
  getUserSuccess,
  getUserFailure,

  updateProfileStart,
  updateProfileSuccess,
  updateProfileFailure,
}

class UserEvent {
  UserEvents? type;
  dynamic payload;

  UserEvent.getUserStart({this.payload}) {
    type = UserEvents.getUserStart;
  }

  UserEvent.updateProfileStart({this.payload}) {
    type = UserEvents.updateProfileStart;
  }
}
