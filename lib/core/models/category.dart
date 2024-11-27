class Category {
  final int id;
  final String name;
  final String avatar;
  final int notesCount;

  Category({
    required this.id,
    required this.name,
    required this.avatar,
    required this.notesCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      notesCount: json['notes_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'notes_count': notesCount,
    };
  }
}
