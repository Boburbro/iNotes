import 'package:bloc/bloc.dart';
import 'package:note_app/core/models/note/note.dart';
import 'package:note_app/core/provider/note_bloc/note_event.dart';
import 'package:note_app/core/provider/note_bloc/note_state.dart';
import 'package:note_app/core/service/cache_service.dart';

List<Note> _notes = <Note>[];

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc()
      : _cacheService = CacheServiceImpl(),
        super(NoteState.initial()) {
    on<AddNoteEvent>(_onAddNoteEvent);
    on<FetchNotesEvent>(_onFetchNotesEvent);
    on<DeleteNoteEvent>(_onDeleteNoteEvent);
    on<EditNoteEvent>(_onEditNoteEvent);
  }

  _onAddNoteEvent(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    _cacheService.addNote(event.note.id, event.note);
    _notes.add(event.note);

    emit(state.copyWith(isloading: false, notes: _notes));
  }

  _onFetchNotesEvent(FetchNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));
    final notes = await _cacheService.getNotes();
    _notes.addAll(notes);

    emit(state.copyWith(isloading: false, notes: _notes));
  }

  _onDeleteNoteEvent(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));

    await _cacheService.deleteNote(event.note.id);
    _notes.removeWhere((note) => note.id == event.note.id);

    emit(state.copyWith(isloading: false, notes: _notes));
  }

  _onEditNoteEvent(EditNoteEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(isloading: true));

    await _cacheService.updateNote(event.note);
    final index = _notes.indexWhere((note) => note.id == event.note.id);
    if (index != -1) {
      _notes[index] = event.note;
    }

    emit(state.copyWith(isloading: false, notes: _notes));
  }

  late final CacheServiceImpl _cacheService;
}
