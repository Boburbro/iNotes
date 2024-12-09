part of 'note_bloc.dart';

enum NoteEvents {
  addNoteStart,
  addNoteSuccess,
  addNoteFailure,

  // fetchNotesByCategoryStart,
  // fetchNotesByCategorySuccess,
  // fetchNotesByCategoryFailure,

  fetchRecentNotesStart,
  fetchRecentNotesSuccess,
  fetchRecentNotesFailure,

  deleteNoteStart,
  deleteNoteSuccess,
  deleteNoteFailure,

  updateNoteStart,
  updateNoteSuccess,
  updateNoteFailure,

  deleteNotesStart,

  fetchSearchedNotesStart,
  fetchSearchedNotesSuccess,
  fetchSearchedNotesFailed,

  fetchSearchedNotesByCategoryStart,
  fetchSearchedNotesByCategorySuccess,
  fetchSearchedNotesByCategoryFailed,
}

class NoteEvent {
  NoteEvents? event;
  dynamic payload;

  NoteEvent.addNoteStart({required Json noteJson}) {
    event = NoteEvents.addNoteStart;
    payload = noteJson;
  }

  // NoteEvent.fetchNotesByCategoryStart({required this.payload}) {
  //   // payload - categoryId, userId, categoryName
  //   event = NoteEvents.fetchNotesByCategoryStart;
  // }

  NoteEvent.fetchRecentNotesStart({this.payload}) {
    event = NoteEvents.fetchRecentNotesStart;
  }

  NoteEvent.deleteNoteStart({required this.payload}) {
    event = NoteEvents.deleteNoteStart;
  }

  NoteEvent.updateNoteStart({required this.payload}) {
    event = NoteEvents.updateNoteStart;
  }

  NoteEvent.deleteNotesStart({required this.payload}) {
    event = NoteEvents.deleteNotesStart;
  }

  NoteEvent.fetchSearchedNotesStart({required this.payload}) {
    event = NoteEvents.fetchSearchedNotesStart;
  }

  NoteEvent.fetchSearchedNotesByCategoryStart({required this.payload}) {
    event = NoteEvents.fetchSearchedNotesByCategoryStart;
  }
}
