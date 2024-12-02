part of 'note_bloc.dart';

class NoteState {
  // final PaginatedDataResponse<Note>? notes;
  final PaginatedDataResponse<Note>? recentNotes;
  final PaginatedDataResponse<Category>? categories;
  final Map<String, PaginatedDataResponse<Note>?>? notesByCategory;
  final NoteEvents? event;
  final String? errorMessage;

  NoteState({
    // this.notes,
    this.recentNotes,
    this.notesByCategory,
    this.categories,
    this.event,
    this.errorMessage,
  });

  NoteState copyWith({
    // PaginatedDataResponse<Note>? notes,
    PaginatedDataResponse<Note>? recentNotes,
    PaginatedDataResponse<Category>? categories,
    Map<String, PaginatedDataResponse<Note>?>? notesByCategory,
    NoteEvents? event,
    String? errorMessage,
  }) {
    return NoteState(
      // notes: notes ?? this.notes,
      recentNotes: recentNotes ?? this.recentNotes,
      categories: categories ?? this.categories,
      notesByCategory: notesByCategory ?? this.notesByCategory,
      event: event ?? this.event,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory NoteState.initial() {
    return NoteState(
      // notes: null,
      recentNotes: null,
      categories: null,
      event: null,
      errorMessage: null,
      notesByCategory: {},
    );
  }
}
