import 'package:bloc/bloc.dart';
import 'package:inotes/core/models/category.dart';
import 'package:inotes/core/models/note.dart';
import 'package:inotes/core/models/response.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/service/remote/note.dart';
import 'package:inotes/core/types.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc()
      : _service = NoteService.instance,
        super(NoteState.initial()) {
    on<NoteEvent>((event, emit) async {
      switch (event.event) {
        case NoteEvents.addNoteStart:
          await _onAddNoteStart(event, emit);
          break;
        case NoteEvents.fetchNotesStart:
          await _onfetchNotesStart(event, emit);
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
        case NoteEvents.fetchCategoriesStart:
          await _onfetchCategoriesStart(event, emit);
          break;
        case NoteEvents.addCategoryStart:
          await _onAddCategoryStart(event, emit);
          break;

        default:
      }
    });
  }

  Future<void> _onAddNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.addNoteStart,
    ));

    try {
      final Note? note = await _service.addNote(noteJson: event.payload);

      if (note != null) {
        emit(state.copyWith(
          event: NoteEvents.addNoteSuccess,
        ));
        if (state.recentNotes!.data.isNotEmpty) {
          state.recentNotes!.data.removeLast();
        }
        state.recentNotes!.data.add(note);
      }

      emit(state);
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to add note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.addNoteFailure,
      ));
    }
  }

  Future<void> _onfetchNotesStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchNotesStart,
    ));

    final bool isForceRefresh = event.payload;

    final data = state.notes?.data;
    final isExistData = data != null && data.isNotEmpty;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: NoteEvents.fetchNotesSuccess));
      return;
    }

    // Proceed to fetch fresh data
    try {
      final PaginatedDataResponse<Note>? notes = await _service.fetchNotes();

      emit(state.copyWith(
        notes: notes,
        event: NoteEvents.fetchNotesSuccess,
      ));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to fetch notes',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.fetchNotesFailure,
      ));
    }
  }

  Future<void> _onfetchRecentNotesStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchRecentNotesStart,
    ));

    final bool isForceRefresh = event.payload;

    final data = state.recentNotes?.data;
    final isExistData = data != null && data.isNotEmpty;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: NoteEvents.fetchRecentNotesSuccess));
      return;
    }

    // Proceed to fetch fresh data
    try {
      final PaginatedDataResponse<Note>? recentNotes = await _service.fetchRecentNotes();

      emit(state.copyWith(
        recentNotes: recentNotes,
        event: NoteEvents.fetchRecentNotesSuccess,
      ));
    } catch (error, stackTrace) {
      CSLog.instance.error(
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
    // emit(state.copyWith(
    //   event: NoteEvents.deleteNoteStart,
    // ));

    // try {
    //   final bool isDeleted = await _service.deleteNote(
    //     noteId: event.payload['noteId'],
    //   );

    //   if (isDeleted) {
    //     emit(state.copyWith(
    //       event: NoteEvents.deleteNoteSuccess,
    //     ));
    //     state.notes!.data.removeWhere((note) => note.id == event.payload['noteId']);
    //     state.recentNotes!.data.removeWhere((note) => note.id == event.payload['noteId']);
    //   }

    //   emit(state);
    // } catch (error, stackTrace) {
    //   CSLog.instance.error(
    //     'Failed to delete note',
    //     error: error,
    //     stackTrace: stackTrace,
    //   );

    //   emit(state.copyWith(
    //     event: NoteEvents.deleteNoteFailure,
    //   ));
    // }
  }

  Future<void> _onUpdateNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    // emit(state.copyWith(
    //   event: NoteEvents.updateNoteStart,
    // ));

    // try {
    //   final Note? note = await _service.updateNote(
    //     noteId: event.payload['noteId'],
    //     noteJson: event.payload['noteJson'],
    //   );

    //   if (note != null) {
    //     emit(state.copyWith(
    //       event: NoteEvents.updateNoteSuccess,
    //     ));
    //     final noteIndex = state.notes!.data.indexWhere((note) => note.id == event.payload['noteId']);
    //     state.notes!.data[noteIndex] = note;
    //     final recentNoteIndex = state.recentNotes!.data.indexWhere((note) => note.id == event.payload['noteId']);
    //     state.recentNotes!.data[recentNoteIndex] = note;
    //   }

    //   emit(state);
    // } catch (error, stackTrace) {
    //   CSLog.instance.error(
    //     'Failed to update note',
    //     error: error,
    //     stackTrace: stackTrace,
    //   );

    //   emit(state.copyWith(
    //     event: NoteEvents.updateNoteFailure,
    //   ));
    // }
  }

  Future<void> _onfetchCategoriesStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchCategoriesStart,
    ));

    final bool isForceRefresh = event.payload;

    final data = state.categories?.data;
    final isExistData = data != null && data.isNotEmpty;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: NoteEvents.fetchCategoriesSuccess));
      return;
    }

    // Proceed to fetch fresh data
    try {
      final PaginatedDataResponse<Category>? categories = await _service.fetchCategories();

      emit(state.copyWith(
        categories: categories,
        event: NoteEvents.fetchCategoriesSuccess,
      ));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to fetch categories',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        errorMessage: error.toString(),
        event: NoteEvents.fetchCategoriesFailure,
      ));
    }
  }

  Future<void> _onAddCategoryStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.addCategoryStart,
    ));

    try {
      final Category? category = await _service.addCategory(categoryJson: event.payload);

      if (category != null) {
        emit(state.copyWith(
          event: NoteEvents.addCategorySuccess,
        ));

        state.categories!.data.add(category);
      }

      emit(state);
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to add note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.addCategoryFailure,
      ));
    }
  }

  late final NoteService _service;
}
