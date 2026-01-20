import 'dart:ui';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final Color color;
  final bool isTrashed;
  final SyncStatus syncStatus;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.color,
    this.isTrashed = false,
    this.syncStatus = SyncStatus.pending,
  });

  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    Color? color,
    bool? isTrashed,
    SyncStatus? syncStatus,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      isTrashed: isTrashed ?? this.isTrashed,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value,
      'is_trashed': isTrashed ? 1 : 0,
      'sync_status': syncStatus.index,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: Color(map['color']),
      isTrashed: (map['is_trashed'] ?? 0) == 1,
      syncStatus: SyncStatus.values[map['sync_status'] ?? 0],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
