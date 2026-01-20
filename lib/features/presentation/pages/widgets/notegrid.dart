import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/notecard.dart';

class NoteGrid extends StatelessWidget {
  final List<NoteModel> notes;
  final Function(int) onNoteTap;
  final Function(int) onDelete;
  final Function(int)? onViewHistory;

  const NoteGrid({
    super.key,
    required this.notes,
    required this.onNoteTap,
    required this.onDelete,
    this.onViewHistory, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final note = notes[i];

        return NoteCard(
          title: note.title,
          content: note.content,
          color: note.color,

          // single source of truth for sync UI
          syncStatus: note.syncStatus,

          onTap: () => onNoteTap(i),
          onDelete: () => onDelete(i),
          // PASS HISTORY
          onViewHistory: onViewHistory == null ? null : () => onViewHistory!(i),
        );
      },
    );
  }
}
