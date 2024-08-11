import 'package:note_app/core/models/note/note.dart';

class NoteState {
  final bool isloading;
  final List<Note> notes;
  final List<Note> favoriteNotes;

  NoteState({
    required this.isloading,
    required this.notes,
    required this.favoriteNotes,
  });

  NoteState copyWith({
    bool? isloading,
    List<Note>? notes,
    List<Note>? favoriteNotes,
  }) {
    return NoteState(
      isloading: isloading ?? this.isloading,
      notes: notes ?? this.notes,
      favoriteNotes: favoriteNotes ?? this.favoriteNotes,
    );
  }

  factory NoteState.initial() {
    return NoteState(isloading: false, notes: [], favoriteNotes: []);
  }
}
