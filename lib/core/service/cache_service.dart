import 'package:note_app/core/boxes.dart';
import 'package:note_app/core/models/note/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CacheService {
  Future<void> addNote(String id, Note note);
  Future<List<Note>> fetchNotes();
  Future<void> deleteNote(String id);
  Future<void> updateNote(Note note);

  Future<void> addNoteToFavorite(Note note);
  Future<void> removeNoteFromFavorites(Note note);
  Future<List<Note>> fetchFavoriteNotes();

  Future<List<Note>> searchNote(String keyword);

  Future<void> changeTheme(String theme);
  Future<String?> getTheme();
}

class CacheServiceImpl implements CacheService {
  CacheServiceImpl() {
    boxes = Boxes();
    _sharedPreferences = SharedPreferences.getInstance();
  }

  late Boxes boxes;
  late Future<SharedPreferences> _sharedPreferences;

  @override
  Future<void> addNote(String id, Note note) async {
    await boxes.notes.put(id, note);
  }

  @override
  Future<List<Note>> fetchNotes() async {
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

  @override
  Future<void> addNoteToFavorite(Note favoriteNote) async {
    await boxes.notes.put(favoriteNote.id, favoriteNote);
  }

  @override
  Future<void> removeNoteFromFavorites(Note favoriteNote) async {
    await boxes.notes.put(favoriteNote.id, favoriteNote);
  }

  @override
  Future<List<Note>> fetchFavoriteNotes() async {
    final notes = await fetchNotes();
    final favoriteNotes = notes.where((note) => note.isfavorite).toList();
    return favoriteNotes;
  }

  @override
  Future<List<Note>> searchNote(String keyword) async {
    final notes = await fetchNotes();
    final searchedNotes = notes.where((note) => note.title.startsWith(keyword));
    return searchedNotes.toList();
  }

  @override
  Future changeTheme(String theme) async {
    (await _sharedPreferences).setString('theme', theme);
  }

  @override
  Future<String?> getTheme() async {
    return (await _sharedPreferences).getString('theme');
  }
}
