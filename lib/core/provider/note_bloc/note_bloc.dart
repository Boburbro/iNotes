import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/models/category.dart';
import 'package:inotes/core/models/note.dart';
import 'package:inotes/core/models/response.dart';
import 'package:inotes/core/service/local/cache_service.dart';
import 'package:inotes/core/service/log_service.dart';
import 'package:inotes/core/service/remote/note.dart';
import 'package:inotes/core/types.dart';
import 'package:inotes/main.dart';

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
        // case NoteEvents.fetchNotesStart:
        //   await _onfetchNotesStart(event, emit);
        //   break;
        case NoteEvents.fetchNotesByCategoryStart:
          await _onfetchNotesByCategoryStart(event, emit);
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
        final categories = state.categories?.data;
        final index = categories!.indexWhere((category) => category.name == note.category);
        final category = categories[index];
        final updatedCategory = category.copyWith(notesCount: category.notesCount + 1);
        categories[index] = updatedCategory;

        emit(state.copyWith(
          event: NoteEvents.addNoteSuccess,
        ));
        if (state.recentNotes!.data.isNotEmpty && state.recentNotes!.data.length > 2) {
          state.recentNotes!.data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          state.recentNotes!.data.removeLast();
        }
        state.recentNotes!.data.insert(0, note);
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

  // Future<void> _onfetchNotesStart(NoteEvent event, Emitter<NoteState> emit) async {
  //   emit(state.copyWith(
  //     event: NoteEvents.fetchNotesStart,
  //   ));

  //   final bool isForceRefresh = event.payload['is_force_refresh'];

  //   final data = state.notes?.data;
  //   final isExistData = data != null && data.isNotEmpty;

  //   // If there's existing data and it's not a forced refresh, emit the current state
  //   if (isExistData && !isForceRefresh) {
  //     emit(state.copyWith(event: NoteEvents.fetchNotesSuccess));
  //     return;
  //   }

  //   // Proceed to fetch fresh data
  //   try {
  //     final PaginatedDataResponse<Note>? notes = await _service.fetchNotes(userId: event.payload['user_id']);

  //     emit(state.copyWith(
  //       notes: notes,
  //       event: NoteEvents.fetchNotesSuccess,
  //     ));
  //   } catch (error, stackTrace) {
  //     CSLog.instance.error(
  //       'Failed to fetch notes',
  //       error: error,
  //       stackTrace: stackTrace,
  //     );

  //     emit(state.copyWith(
  //       event: NoteEvents.fetchNotesFailure,
  //     ));
  //   }
  // }

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

  Future<void> _onfetchNotesByCategoryStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchNotesByCategoryStart,
    ));

    final data = state.notesByCategory![event.payload['category']]?.data;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (data != null && data.isNotEmpty) {
      emit(state.copyWith(event: NoteEvents.fetchNotesByCategorySuccess));
      return;
    }

    // Proceed to fetch fresh data
    try {
      final PaginatedDataResponse<Note>? notesByCategory = await _service.fetchNotesByCategory(
        userId: event.payload['user_id'],
        categoryId: event.payload['category_id'],
      );

      emit(state.copyWith(
        notesByCategory: {
          ...state.notesByCategory!,
          event.payload['category']: notesByCategory,
        },
        event: NoteEvents.fetchNotesByCategorySuccess,
      ));
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to fetch recent notes',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.fetchNotesByCategoryFailure,
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
        userId: event.payload['user_id'],
        categoryId: event.payload['category_id'],
      );

      if (isDeleted) {
        emit(state.copyWith(
          event: NoteEvents.deleteNoteSuccess,
        ));

        _removeFromRecentNotes(event.payload['note_id'], event.payload['user_id']);
        _removeFromNotesByCategory(event.payload['category'], event.payload['note_id']);
        _decrementCategoryNotesCount(event.payload['category']);
      }

      emit(state);
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to delete note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.deleteNoteFailure,
      ));
    }
  }

  void _removeFromRecentNotes(int noteId, int userId) {
    final recentNotes = state.recentNotes?.data;
    final recentNoteIndex = recentNotes?.indexWhere((note) => note.id == noteId);
    if (recentNoteIndex != null && recentNoteIndex != -1) {
      recentNotes!.removeAt(recentNoteIndex);
    }

    if (recentNotes!.length < 3) {
      final payload = {'user_id': userId, 'is_force_refresh': true};
      final event = NoteEvent.fetchRecentNotesStart(payload: payload);
      navigatorKey.currentContext!.read<NoteBloc>().add(event);
    }
  }

  void _removeFromNotesByCategory(String category, int noteId) {
    final notesByCategory = state.notesByCategory?[category];
    final noteIndex = notesByCategory?.data.indexWhere((note) => note.id == noteId);
    if (noteIndex != null && noteIndex != -1) {
      notesByCategory?.data.removeAt(noteIndex);
    }
  }

  void _decrementCategoryNotesCount(String categoryName) {
    final categories = state.categories?.data;
    final index = categories?.indexWhere((category) => category.name == categoryName);
    if (index != null && index != -1) {
      final category = categories![index];
      categories[index] = category.copyWith(notesCount: category.notesCount - 1);
    }
  }

  Future<void> _onUpdateNoteStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.updateNoteStart,
    ));

    try {
      final Note? note = await _service.updateNote(
        noteId: event.payload['id'],
        userId: event.payload['user_id'],
        title: event.payload['title'],
        content: event.payload['content'],
        delta: event.payload['delta'],
      );

      if (note != null) {
        emit(state.copyWith(
          event: NoteEvents.updateNoteSuccess,
        ));

        _updateRecentNotes(note);
        _updateNotesByCategory(event.payload['category'], note);
      }

      emit(state);
    } catch (error, stackTrace) {
      CSLog.instance.error(
        'Failed to update note',
        error: error,
        stackTrace: stackTrace,
      );

      emit(state.copyWith(
        event: NoteEvents.updateNoteFailure,
      ));
    }
  }

  void _updateRecentNotes(Note updatedNote) {
    final recentNoteIndex = state.recentNotes?.data.indexWhere((note) => note.id == updatedNote.id);
    if (recentNoteIndex != null && recentNoteIndex != -1) {
      state.recentNotes!.data[recentNoteIndex] = updatedNote;
    }
  }

  void _updateNotesByCategory(String category, Note updatedNote) {
    final notesByCategory = state.notesByCategory?[category];
    if (notesByCategory != null) {
      final noteIndex = notesByCategory.data.indexWhere((note) => note.id == updatedNote.id);
      if (noteIndex != -1) {
        notesByCategory.data[noteIndex] = updatedNote;
      }
    }
  }

  Future<void> _onfetchCategoriesStart(NoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(
      event: NoteEvents.fetchCategoriesStart,
    ));

    final bool isForceRefresh = event.payload['is_force_refresh'];

    final data = state.categories?.data;
    final isExistData = data != null && data.isNotEmpty;

    // If there's existing data and it's not a forced refresh, emit the current state
    if (isExistData && !isForceRefresh) {
      emit(state.copyWith(event: NoteEvents.fetchCategoriesSuccess));
      return;
    }

    // Proceed to fetch fresh data
    try {
      final PaginatedDataResponse<Category>? categories = await _service.fetchCategories(userId: event.payload['user_id']);
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
        state.categories!.data.add(category);
        emit(state.copyWith(event: NoteEvents.addCategorySuccess));

        await CacheService().setCategory(category.toJson());
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
