class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? delta;

  Note({
    required this.title,
    required this.category,
    required this.id,
    required this.content,
    DateTime? createdAt,
    this.delta,
    required this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      delta: json['delta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'title': title,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'delta': delta,
      };
}
