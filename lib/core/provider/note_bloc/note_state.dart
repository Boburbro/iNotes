import 'package:note_app/core/models/note/note.dart';

class NoteState {
  final bool isloading;
  final List<Note> notes;

  NoteState({
    required this.isloading,
    required this.notes,
  });

  NoteState copyWith({
    bool? isloading,
    List<Note>? notes,
  }) {
    return NoteState(
      isloading: isloading ?? this.isloading,
      notes: notes ?? this.notes,
    );
  }

  factory NoteState.initial() {
    return NoteState(isloading: false, notes: []);
  }
}
