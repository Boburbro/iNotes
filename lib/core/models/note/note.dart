import 'package:hive/hive.dart';
part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;

  Note({
    required this.id,
    required this.title,
    required this.description,
  });
}
