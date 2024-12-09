import 'package:inotes/core/models/category.dart';

class Note {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String content;
  final Category category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? delta;
  final int color;

  Note({
    required this.title,
    required this.categoryId,
    required this.userId,
    required this.category,
    required this.id,
    required this.content,
    DateTime? createdAt,
    this.delta,
    required this.color,
    required this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      delta: json['delta'],
      color: int.parse(json['color']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'content': content,
        'title': title,
        'category': category.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'delta': delta,
        'color': color.toString(),
      };
}

class NewNote {
  final int userId;
  final int categoryId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? delta;
  final int color;

  NewNote({
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.category,
    required this.content,
    DateTime? createdAt,
    this.delta,
    required this.color,
    required this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NewNote.fromJson(Map<String, dynamic> json) {
    return NewNote(
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      category: json['category'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      delta: json['delta'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'category_id': categoryId,
        'content': content,
        'title': title,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'delta': delta,
        'color': color,
      };
}
