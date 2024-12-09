part of 'note_bloc.dart';

class NoteState {
  final PaginatedDataResponse<Note>? recentNotes;
  final PaginatedDataResponse<Note>? searchedNotes;
  final NoteEvents? event;
  final String? errorMessage;

  NoteState({
    this.recentNotes,
    this.searchedNotes,
    this.event,
    this.errorMessage,
  });

  NoteState copyWith({
    PaginatedDataResponse<Note>? recentNotes,
    PaginatedDataResponse<Note>? searchedNotes,
    NoteEvents? event,
    String? errorMessage,
  }) {
    return NoteState(
      recentNotes: recentNotes ?? this.recentNotes,
      searchedNotes: searchedNotes ?? this.searchedNotes,
      event: event ?? this.event,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory NoteState.initial() {
    return NoteState(
      recentNotes: null,
      event: null,
      searchedNotes: null,
      errorMessage: null,
    );
  }
}
