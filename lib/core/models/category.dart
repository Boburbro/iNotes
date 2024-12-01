class Category {
  final int id;
  final String name;
  final String avatar;
  final int notesCount;
  final int color;

  Category({
    required this.id,
    required this.name,
    required this.avatar,
    required this.notesCount,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      notesCount: json['notes_count'],
      color: int.parse(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'notes_count': notesCount,
      'color': color.toString(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? avatar,
    int? notesCount,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      notesCount: notesCount ?? this.notesCount,
      color: color ?? this.color,
    );
  }
}
