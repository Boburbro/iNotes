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
  }

  _onAddNoteEvent(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.addNote(event.note.id, event.note);
    final notes = await _cacheService.getNotes();
    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onFetchNotesEvent(FetchNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    final notes = await _cacheService.getNotes();

    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onDeleteNoteEvent(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.deleteNote(event.note.id);
    final notes = await _cacheService.getNotes();

    emit(state.copyWith(isloading: false, notes: notes));
  }

  _onUpdateNoteEvent(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    await _cacheService.updateNote(event.note);
    final notes = await _cacheService.getNotes();

    emit(state.copyWith(isloading: false, notes: notes));
  }

  late final CacheServiceImpl _cacheService;
}
