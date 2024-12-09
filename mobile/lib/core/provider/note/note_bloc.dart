import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/provider/category/category_bloc.dart';
import 'package:inotes/main.dart';
import '../../models/note.dart';
import '../../models/response.dart';
import '../../utils/note_helper.dart';
import '../../service/log_service.dart';
import '../../service/remote/note_service.dart';
import '../../types.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteState.initial()) {
    on<NoteEvent>((event, emit) async {
      switch (event.event) {
        case NoteEvents.addNoteStart:
          await _onAddNoteStart(event, emit);
          break;
        case NoteEvents.fetchRecentNotesStart:
          await _onfetchRecentNotesStart(event, emit);
          break;
        case NoteEvents.deleteNoteStart:
          await _onDeleteNoteStart(event, emit);
          break;
        case NoteEvents.updateNoteStart:
          await _onUpdateNoteStart(event, emit);
          break;
        case NoteEvents.deleteNotesStart:
          await _onDeleteNotesStart(event, emit);
          break;
        case NoteEvents.fetchSearchedNotesStart:
          await _onfetchSearchResult(event, emit);
          break;
        case NoteEvents.fetchSearchedNotesByCategoryStart:
          await _onfetchSearchResultByCategory(event, emit);
          break;
        default:
      }
    });
  }

  Future<void> _onAddNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(event: NoteEvents.addNoteStart));

    try {
      final Note? note = await _service.addNote(noteJson: event.payload);
      if (note == null) return;

      final payload = {'category_name': note.category.name};
      final event0 = CategoryEvent.incrementNotesCountStart(payload: payload);
      navigatorKey.currentContext?.read<CategoryBloc>().add(event0);

      final recentNotes = state.recentNotes?.data;
      if (recentNotes != null) {
        ListHelper.addItem(
          recentNotes,
          note,
          uniqueChecker: (note0) => note0.id == note.id,
        );
      }

      emit(state.copyWith(event: NoteEvents.addNoteSuccess));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to add note',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(event: NoteEvents.addNoteFailure));
    }
  }

  Future<void> _onfetchRecentNotesStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchRecentNotesStart,
    ));

    final bool isForceRefresh = event.payload['is_force_refresh'];

    final data = state.recentNotes?.data;
    final isExistData = data != null && data.isNotEmpty;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: NoteEvents.fetchRecentNotesSuccess));
      return;
    }

    try {
      final PaginatedDataResponse<Note>? recentNotes = await _service.fetchRecentNotes(userId: event.payload['user_id']);
      if (recentNotes == null) return;

      emit(state.copyWith(
        recentNotes: recentNotes,
        event: NoteEvents.fetchRecentNotesSuccess,
      ));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to fetch recent notes',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.fetchRecentNotesFailure,
      ));
    }
  }

  Future<void> _onDeleteNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.deleteNoteStart,
    ));

    try {
      final bool isDeleted = await _service.deleteNote(
        noteId: event.payload['note_id'],
        category: event.payload['category'],
      );

      if (isDeleted) {
        emit(state.copyWith(
          event: NoteEvents.deleteNoteSuccess,
        ));

        final recentNotes = state.recentNotes?.data;
        if (recentNotes != null) {
          ListHelper.removeItem(
            recentNotes,
            (note) => note.id == event.payload['note_id'],
          );
        }
        final searchedNotes = state.searchedNotes?.data;
        if (searchedNotes != null) {
          ListHelper.removeItem(
            searchedNotes,
            (note) => note.id == event.payload['note_id'],
          );
          emit(state.copyWith(event: NoteEvents.fetchSearchedNotesByCategorySuccess));
        }

        final category = event.payload['category'];
        final payload = {'category_name': category.name};
        final event0 = CategoryEvent.decrementNotesCountStart(payload: payload);
        navigatorKey.currentContext?.read<CategoryBloc>().add(event0);
      }

      emit(state);
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to delete note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.deleteNoteFailure,
      ));
    }
  }

  Future<void> _onUpdateNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.updateNoteStart,
    ));

    try {
      final Note? updateNote = await _service.updateNote(
        noteId: event.payload['id'],
        userId: event.payload['user_id'],
        title: event.payload['title'],
        content: event.payload['content'],
        delta: event.payload['delta'],
      );

      if (updateNote != null) {
        emit(state.copyWith(
          event: NoteEvents.updateNoteSuccess,
        ));

        final recentNotes = state.recentNotes?.data;
        if (recentNotes != null) {
          ListHelper.updateItem(
            recentNotes,
            (note) => note.id == updateNote.id,
            updateNote,
          );
        }

        final searchedNotes = state.searchedNotes?.data;
        if (searchedNotes != null) {
          ListHelper.updateItem(
            searchedNotes,
            (note) => note.id == updateNote.id,
            updateNote,
          );
        }
      }

      // if you back to `notes view` from `note editor view`, you need to fetch notes again
      emit(state.copyWith(event: NoteEvents.fetchSearchedNotesByCategorySuccess));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to update note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.updateNoteFailure,
      ));
    }
  }

  Future<void> _onDeleteNotesStart(NoteEvent event, Emitter<NoteState> emit) async {
    final ctr = event.payload['category'];
    try {
      final recentNotes = state.recentNotes?.data;
      if (recentNotes != null) {
        ListHelper.removeItems(
          recentNotes,
          (note) => note.categoryId == ctr.id,
        );
      }

      emit(state.copyWith(event: NoteEvents.fetchRecentNotesSuccess));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to delete note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.deleteNoteFailure,
      ));
    }
  }

  Future<void> _onfetchSearchResult(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(event: NoteEvents.fetchSearchedNotesStart));
    try {
      if (event.payload['query'].isEmpty) {
        state.searchedNotes?.data.clear();
        emit(state.copyWith(event: NoteEvents.fetchSearchedNotesSuccess));
        return;
      }
      final searchedNotes = await _service.searchforNotes(query: event.payload['query']);
      if (searchedNotes == null) return;

      emit(state.copyWith(
        searchedNotes: searchedNotes,
        event: NoteEvents.fetchSearchedNotesSuccess,
      ));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to fetch search results',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.fetchSearchedNotesFailed,
      ));
    }
  }

  Future<void> _onfetchSearchResultByCategory(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(event: NoteEvents.fetchSearchedNotesByCategoryStart));
    try {
      final searchedNotes = await _service.searchforNotesByCategory(
        query: event.payload['query'],
        category: event.payload['category'],
      );
      if (searchedNotes == null) return;

      emit(state.copyWith(
        searchedNotes: searchedNotes,
        event: NoteEvents.fetchSearchedNotesByCategorySuccess,
      ));
    } catch (error, stackTrace) {
      AppLog.instance.error(
        'Failed to fetch search results',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.fetchSearchedNotesByCategoryFailed,
      ));
    }
  }

  final _service = NoteService.instance;
}
