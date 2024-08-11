import 'package:bloc/bloc.dart';
import 'package:note_app/core/provider/note_bloc/note_event.dart';
import 'package:note_app/core/provider/note_bloc/note_state.dart';
import 'package:note_app/core/service/cache_service.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc()
      : _cacheService = CacheServiceImpl(),
        super(NoteState.initial()) {
    on<AddNoteEvent>(_onAddNoteEvent);
    on<FetchNotesEvent>(_onFetchNotesEvent);
    on<DeleteNoteEvent>(_onDeleteNoteEvent);
    on<UpdateNoteEvent>(_onUpdateNoteEvent);

    on<AddNoteToFavoriteEvent>(_onAddNoteToFavoriteEvent);
    on<RemoveNoteFromFavoriteEvent>(_onRemoveNoteFromFavoriteEvent);
    on<FetchFavoriteNotesEvent>(_onFetchFavoriteNotesEvent);
  }

  _onAddNoteEvent(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.addNote(event.note.id, event.note);
    final notes = state.notes..add(event.note);
    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onFetchNotesEvent(FetchNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    final notes = await _cacheService.fetchNotes();

    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onDeleteNoteEvent(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.deleteNote(event.note.id);
    final notes = state.notes..removeWhere((note) => note.id == event.note.id);
    final favoriteNotes = state.favoriteNotes..removeWhere((note) => note.id == event.note.id);

    emit(state.copyWith(isloading: false, notes: notes, favoriteNotes: favoriteNotes));
  }

  _onUpdateNoteEvent(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.updateNote(event.note);

    final notes = state.notes.map((note) {
      return note.id == event.note.id ? event.note : note;
    }).toList();

    final favoriteNotes = state.favoriteNotes.map((note) {
      return note.id == event.note.id ? event.note : note;
    }).toList();

    emit(state.copyWith(isloading: false, notes: notes, favoriteNotes: favoriteNotes));
  }

  // ================== Favorite notes =====================

  _onAddNoteToFavoriteEvent(AddNoteToFavoriteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.addNoteToFavorite(event.note);

    final notes = state.notes.map((note) {
      return note.id == event.note.id ? event.note : note;
    }).toList();

    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onRemoveNoteFromFavoriteEvent(RemoveNoteFromFavoriteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.removeNoteFromFavorites(event.note);

    final notes = state.notes.map((note) {
      return note.id == event.note.id ? event.note : note;
    }).toList();

    final favoriteNotes = state.favoriteNotes..removeWhere((note) => note.id == event.note.id);

    emit(state.copyWith(isloading: false, notes: notes, favoriteNotes: favoriteNotes));
  }

  _onFetchFavoriteNotesEvent(FetchFavoriteNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    final favoriteNotes = await _cacheService.fetchFavoriteNotes();

    emit(state.copyWith(isloading: false, favoriteNotes: favoriteNotes));
  }

  late final CacheServiceImpl _cacheService;
}
