import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/search/search_event.dart';
import 'package:inotes/core/provider/search/search_state.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/service/remote/note_service.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState.initial()) {
    on<SearchEvent>((event, emit) async {
      switch (event.type) {
        case SearchEvents.fetchSearchResults:
          await _onfetchSearchResults(event, emit);
          break;
        default:
      }
    });
  }
  Future<void> _onfetchSearchResults(SearchEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(event: SearchEvents.fetchSearchResults));
    try {
      if (event.query.isEmpty) {
        state.notes?.data.clear();
        emit(state.copyWith(event: SearchEvents.successSearchResult));
        return;
      }
      final notes = await _noteService.searchforNotes(query: event.query);
      if (notes == null) return;

      emit(state.copyWith(notes: notes, event: SearchEvents.successSearchResult));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to fetch search results',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: SearchEvents.failedSearchResults,
      ));
    }
  }

  final _noteService = NoteService.instance;
}
