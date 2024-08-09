import 'package:note_app/core/models/note/note.dart';

sealed class NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final Note note;

  AddNoteEvent({required this.note});
}

class FetchNotesEvent extends NoteEvent {}

class DeleteNoteEvent extends NoteEvent {
  final Note note;

  DeleteNoteEvent({required this.note});
}

class EditNoteEvent extends NoteEvent {
  final Note note;

  EditNoteEvent({required this.note});
}
