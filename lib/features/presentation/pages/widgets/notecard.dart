import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/bottomsheet.dart';
import 'package:syncnote_engine/core/utils/quill_preview.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content; // this is Quill JSON
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool offline;
  final bool conflict;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.onDelete,
    this.onTap,
    this.offline = false,
    this.conflict = false,
  });

  @override
  Widget build(BuildContext context) {
    // CONVERT JSON → PLAIN TEXT HERE
    final previewText = quillJsonToPlainText(content);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      onLongPress: () {
        DeleteBottomSheet.show(context, onDelete: onDelete);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  TOP CONTENT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Untitled note' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  previewText.isEmpty ? 'No data' : previewText, //  FIX
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            //  BOTTOM ROW
            Row(
              children: [
                const Icon(Icons.schedule, size: 14),
                const SizedBox(width: 4),
                const Text('Just now', style: TextStyle(fontSize: 12)),
                const Spacer(),
                if (offline) const Icon(Icons.wifi_off, size: 16),
                if (conflict)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.error, color: Colors.red, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
