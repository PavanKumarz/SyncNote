import 'package:flutter/material.dart';
import 'package:syncnote_engine/core/utils/quill_preview.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';

class VersionPreviewPage extends StatelessWidget {
  final NoteVersion version;

  const VersionPreviewPage({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final previewText = quillJsonToPlainText(version.content);

    return Scaffold(
      appBar: AppBar(title: const Text('Version preview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // META INFO (label + timestamp)
            if (version.label.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  version.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // TITLE
            Text(
              version.title.isEmpty ? '(Untitled)' : version.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Divider(),

            const SizedBox(height: 12),

            // CONTENT
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    previewText.isEmpty ? '(empty)' : previewText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
