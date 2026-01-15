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
    this.isTrashed = false, //  default
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
}
