import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final bool isfavorite;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String createdAt;

  Note({
    required this.id,
    required this.isfavorite,
    required this.title,
    required this.description,
    required this.createdAt,
  });
}
