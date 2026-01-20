import 'package:flutter/material.dart';
import 'package:syncnote_engine/core/utils/quill_preview.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';

class VersionDiffPage extends StatelessWidget {
  final NoteModel currentNote;
  final NoteVersion oldVersion;

  const VersionDiffPage({
    super.key,
    required this.currentNote,
    required this.oldVersion,
  });

  @override
  Widget build(BuildContext context) {
    final oldText = quillJsonToPlainText(oldVersion.content);
    final newText = quillJsonToPlainText(currentNote.content);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare versions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Previous version'),
            _diffBox(oldText, Colors.red.shade50),

            const SizedBox(height: 16),

            _sectionTitle('Current version'),
            _diffBox(newText, Colors.green.shade50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _diffBox(String text, Color bg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text.isEmpty ? 'No content' : text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
