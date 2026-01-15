import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/presentation/pages/trash_page.dart';

class SidebarMenu extends StatelessWidget {
  final List<NoteModel> trashedNotes;
  final Function(NoteModel) onRestore;
  final Function(NoteModel) onDeleteForever;

  const SidebarMenu({
    super.key,
    required this.trashedNotes,
    required this.onRestore,
    required this.onDeleteForever,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(
                    Icons.note_alt_rounded,
                    size: 48,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SyncNote Engine',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView(
                children: [
                  _DrawerItem(
                    icon: Icons.notes,
                    title: 'All Notes',
                    onTap: () => Navigator.pop(context),
                  ),

                  /// TRASH
                  _DrawerItem(
                    icon: Icons.delete_outline,
                    title: 'Trash',
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrashPage(
                            trashedNotes: trashedNotes,
                            onRestore: onRestore,
                            onDeleteForever: onDeleteForever,
                          ),
                        ),
                      );
                    },
                  ),

                  _DrawerItem(icon: Icons.settings_outlined, title: 'Settings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _DrawerItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
