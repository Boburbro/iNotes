import 'package:note_app/core/boxes.dart';
import 'package:note_app/core/models/note/note.dart';

abstract class CacheService {
  Future<void> addNote(String id, Note note);
  Future<List<Note>> getNotes();
  Future<void> deleteNote(String id);
  Future<void> updateNote(Note note);
}

class CacheServiceImpl implements CacheService {
  CacheServiceImpl() {
    boxes = Boxes();
  }

  @override
  Future<void> addNote(String key, Note note) async {
    await boxes.notes.put(key, note);
  }

  @override
  Future<List<Note>> getNotes() async {
    return boxes.notes.values.toList();
  }

  @override
  Future<void> deleteNote(String id) async {
    await boxes.notes.delete(id);
  }

  @override
  Future<void> updateNote(Note note) async {
    await boxes.notes.put(note.id, note);
  }

  late Boxes boxes;
}
