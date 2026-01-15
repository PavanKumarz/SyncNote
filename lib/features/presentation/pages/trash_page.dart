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
          ? const Center(
              child: Text('Trash is empty', style: TextStyle(fontSize: 16)),
            )
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
                  offline: note.offline ?? false,
                  conflict: note.conflict ?? false,

                  //  Tap does nothing in trash
                  onTap: null,

                  //  Long press → options
                  onDelete: () {
                    _showTrashActions(
                      context,
                      note,
                      onRestore,
                      onDeleteForever,
                    );
                  },
                );
              },
            ),
    );
  }

  /// Bottom sheet for trash actions
  void _showTrashActions(
    BuildContext context,

    NoteModel note,
    Function(NoteModel) onRestore,
    Function(NoteModel) onDeleteForever,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Delete forever',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteForever(note);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
