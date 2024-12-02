part of 'note_bloc.dart';

enum NoteEvents {
  addNoteStart,
  addNoteSuccess,
  addNoteFailure,

  fetchNotesStart,
  fetchNotesSuccess,
  fetchNotesFailure,

  fetchNotesByCategoryStart,
  fetchNotesByCategorySuccess,
  fetchNotesByCategoryFailure,

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

  // NoteEvent.fetchNotesStart({this.payload}) {
  //   event = NoteEvents.fetchNotesStart;
  // }

  NoteEvent.fetchNotesByCategoryStart({required this.payload}) {
    // payload - categoryId, userId, categoryName
    event = NoteEvents.fetchNotesByCategoryStart;
  }

  NoteEvent.fetchRecentNotesStart({this.payload}) {
    event = NoteEvents.fetchRecentNotesStart;
  }

  NoteEvent.deleteNoteStart({required this.payload}) {
    event = NoteEvents.deleteNoteStart;
  }

  NoteEvent.updateNoteStart({required this.payload}) {
    event = NoteEvents.updateNoteStart;
  }

  NoteEvent.fetchCategoriesStart({this.payload}) {
    event = NoteEvents.fetchCategoriesStart;
  }

  NoteEvent.addCategoryStart({required Json categoryJson}) {
    event = NoteEvents.addCategoryStart;
    payload = categoryJson;
  }
}
