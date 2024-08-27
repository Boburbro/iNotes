import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/core/provider/search_note_bloc/search_event.dart';
import 'package:note_app/core/provider/search_note_bloc/search_state.dart';
import 'package:note_app/core/service/cache_service.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc()
      : _cacheService = CacheServiceImpl(),
        super(SearchState.initial()) {
    on<SearchNoteEvent>(_onSearchNoteEvent);
  }

  _onSearchNoteEvent(SearchNoteEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(isloading: true));
    // if keyword is empty
    if (event.keyword.isEmpty) {
      emit(state.copyWith(isloading: false, searchedNotes: []));
      return;
    }

    final searchedNotes = await _cacheService.searchNote(event.keyword);
    emit(state.copyWith(isloading: false, searchedNotes: searchedNotes));
  }

  late final CacheServiceImpl _cacheService;
}
