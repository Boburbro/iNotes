part of 'note_bloc.dart';

class NoteState {
  final PaginatedDataResponse<Note>? recentNotes;
  final PaginatedDataResponse<Category>? categories;
  final Map<String, PaginatedDataResponse<Note>?>? notesByCategory;
  final NoteEvents? event;
  final String? errorMessage;

  NoteState({
    this.recentNotes,
    this.notesByCategory,
    this.categories,
    this.event,
    this.errorMessage,
  });

  NoteState copyWith({
    PaginatedDataResponse<Note>? recentNotes,
    PaginatedDataResponse<Category>? categories,
    Map<String, PaginatedDataResponse<Note>?>? notesByCategory,
    NoteEvents? event,
    String? errorMessage,
  }) {
    return NoteState(
      recentNotes: recentNotes ?? this.recentNotes,
      categories: categories ?? this.categories,
      notesByCategory: notesByCategory ?? this.notesByCategory,
      event: event ?? this.event,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory NoteState.initial() {
    return NoteState(
      recentNotes: null,
      categories: null,
      event: null,
      errorMessage: null,
      notesByCategory: {},
    );
  }
}
