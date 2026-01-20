import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

class NoteVersion {
  final String id;
  final String noteId;
  final String title;
  final String content;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final String label; // Auto-save, Before conflict, Manual merge

  NoteVersion({
    required this.id,
    required this.noteId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.syncStatus,
    required this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'title': title,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'sync_status': syncStatus.index,
      'label': label,
    };
  }

  factory NoteVersion.fromMap(Map<String, dynamic> map) {
    return NoteVersion(
      id: map['id'],
      noteId: map['note_id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      syncStatus: SyncStatus.values[map['sync_status'] ?? 0],
      label: map['label'] ?? 'Auto-save',
    );
  }
}
