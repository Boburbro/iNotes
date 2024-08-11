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

class UpdateNoteEvent extends NoteEvent {
  final Note note;

  UpdateNoteEvent({required this.note});
}

class AddNoteToFavoriteEvent extends NoteEvent {
  final Note note;

  AddNoteToFavoriteEvent({required this.note});
}

class RemoveNoteFromFavoriteEvent extends NoteEvent {
  final Note note;

  RemoveNoteFromFavoriteEvent({required this.note});
}

class FetchFavoriteNotesEvent extends NoteEvent {}
