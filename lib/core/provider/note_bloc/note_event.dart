part of 'note_bloc.dart';

enum NoteEvents {
  addNoteStart,
  addNoteSuccess,
  addNoteFailure,

  fetchNotesStart,
  fetchNotesSuccess,
  fetchNotesFailure,

  fetchRecentNotesStart,
  fetchRecentNotesSuccess,
  fetchRecentNotesFailure,

  deleteNoteStart,
  deleteNoteSuccess,
  deleteNoteFailure,

  updateNoteStart,
  updateNoteSuccess,
  updateNoteFailure,

  fetchCategoriesStart,
  fetchCategoriesSuccess,
  fetchCategoriesFailure,

  addCategoryStart,
  addCategorySuccess,
  addCategoryFailure,
}

class NoteEvent {
  NoteEvents? event;
  dynamic payload;

  NoteEvent.addNoteStart({required Json noteJson}) {
    event = NoteEvents.addNoteStart;
    payload = noteJson;
  }

  NoteEvent.fetchNotesStart({bool? isForceRefresh = false}) {
    event = NoteEvents.fetchNotesStart;
    payload = isForceRefresh;
  }

  NoteEvent.fetchRecentNotesStart({bool? isForceRefresh = false}) {
    event = NoteEvents.fetchRecentNotesStart;
    payload = isForceRefresh;
  }

  NoteEvent.deleteNoteStart({required this.payload}) {
    event = NoteEvents.deleteNoteStart;
  }

  NoteEvent.updateNoteStart({required this.payload}) {
    event = NoteEvents.updateNoteStart;
  }

  NoteEvent.fetchCategoriesStart({bool? isForceRefresh = false}) {
    event = NoteEvents.fetchCategoriesStart;
    payload = isForceRefresh;
  }

  NoteEvent.addCategoryStart({required Json categoryJson}) {
    event = NoteEvents.addCategoryStart;
    payload = categoryJson;
  }
}
