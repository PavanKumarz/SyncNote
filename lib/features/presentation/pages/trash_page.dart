import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/notecard.dart';
import '../../domain/models/note.dart';

class TrashPage extends StatelessWidget {
  final List<NoteModel> trashedNotes;
  final Function(NoteModel) onRestore;
  final Function(NoteModel) onDeleteForever;

  const TrashPage({
    super.key,
    required this.trashedNotes,
    required this.onRestore,
    required this.onDeleteForever,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: trashedNotes.isEmpty
          ? const Center(child: Text('Trash is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: trashedNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final note = trashedNotes[i];

                return NoteCard(
                  title: note.title,
                  content: note.content,
                  color: note.color,

                  syncStatus: note.syncStatus,

                  onTap: null,
                  onDelete: () => _showTrashActions(context, note),
                );
              },
            ),
    );
  }

  void _showTrashActions(BuildContext context, NoteModel note) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore'),
            onTap: () {
              Navigator.pop(context);
              onRestore(note);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete forever'),
            onTap: () {
              Navigator.pop(context);
              onDeleteForever(note);
            },
          ),
        ],
      ),
    );
  }
}
