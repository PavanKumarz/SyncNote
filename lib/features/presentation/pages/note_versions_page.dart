import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';
import 'package:syncnote_engine/features/presentation/pages/version_diff_page.dart';
import 'package:syncnote_engine/features/presentation/pages/version_preview_page.dart';

class NoteVersionsPage extends StatelessWidget {
  final NoteModel currentNote;
  final List<NoteVersion> versions;
  final Function(NoteVersion) onRestore;

  const NoteVersionsPage({
    super.key,
    required this.currentNote,
    required this.versions,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Version history')),
      body: versions.isEmpty
          ? const Center(child: Text('No versions yet'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: versions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final v = versions[i];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      // TITLE
                      title: Text(
                        v.title.isEmpty ? '(Untitled)' : v.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      // METADATA
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          v.label.isEmpty
                              ? v.createdAt.toString()
                              : '${v.label} • ${v.createdAt}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                      // PREVIEW
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VersionPreviewPage(version: v),
                          ),
                        );
                      },

                      // ACTIONS
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Compare with current',
                            icon: const Icon(Icons.compare),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VersionDiffPage(
                                    currentNote: currentNote,
                                    oldVersion: v,
                                  ),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () => onRestore(v),
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
