import 'dart:ui';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool? offline;
  final bool? conflict;
  final Color color;
  final bool isTrashed;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.offline,
    this.conflict,
    required this.color,
    this.isTrashed = false,
  });

  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? offline,
    bool? conflict,
    Color? color,
    bool? isTrashed,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      offline: offline ?? this.offline,
      conflict: conflict ?? this.conflict,
      color: color ?? this.color,
      isTrashed: isTrashed ?? this.isTrashed,
    );
  }

  /// Convert NoteModel → SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value, //  store int
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_trashed': isTrashed ? 1 : 0,
    };
  }

  /// Convert SQLite Map → NoteModel
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      color: Color(map['color'] as int), // int → Color
      isTrashed: (map['is_trashed'] as int? ?? 0) == 1,
    );
  }
}
