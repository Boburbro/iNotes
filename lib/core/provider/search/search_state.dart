import 'package:inotes/core/models/note.dart';
import 'package:inotes/core/models/response.dart';
import 'package:inotes/core/provider/search/search_event.dart';

class SearchState {
  final SearchEvents? event;
  final PaginatedDataResponse<Note>? notes;

  SearchState({
    required this.event,
    required this.notes,
  });

  SearchState copyWith({
    SearchEvents? event,
    PaginatedDataResponse<Note>? notes,
  }) {
    return SearchState(
      event: event ?? this.event,
      notes: notes ?? this.notes,
    );
  }

  factory SearchState.initial() {
    return SearchState(event: null, notes: null);
  }
}
