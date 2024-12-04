class Category {
  final int id;
  final int userId;
  final String name;
  final String avatar;
  final int notesCount;
  final int color;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.notesCount,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      avatar: json['avatar'],
      notesCount: json['notes_count'],
      color: int.parse(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'avatar': avatar,
      'notes_count': notesCount,
      'color': color.toString(),
    };
  }

  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? avatar,
    int? notesCount,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      notesCount: notesCount ?? this.notesCount,
      color: color ?? this.color,
    );
  }
}
