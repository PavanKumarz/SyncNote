import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/notecard.dart';

class NoteGrid extends StatelessWidget {
  final List<NoteModel> notes;
  final Function(int) onNoteTap;
  final Function(int) onDelete;

  const NoteGrid({
    super.key,
    required this.notes,
    required this.onNoteTap,
    required this.onDelete,
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
      itemBuilder: (_, i) => NoteCard(
        title: notes[i].title,
        content: notes[i].content,
        color: notes[i].color,
        onTap: () => onNoteTap(i),
        onDelete: () => onDelete(i),
      ),
    );
  }
}
