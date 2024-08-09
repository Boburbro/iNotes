import 'package:hive/hive.dart';
import 'package:note_app/core/models/note/note.dart';

class Boxes {
  Box<Note> get notes => Hive.box('notes');
}
