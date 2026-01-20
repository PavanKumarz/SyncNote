import 'package:flutter/material.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/bottomsheet.dart';
import 'package:syncnote_engine/core/utils/quill_preview.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool offline;

  /// Single source of truth
  final SyncStatus syncStatus;
  final VoidCallback? onViewHistory;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.onDelete,
    required this.syncStatus,
    this.onTap,
    this.offline = false,
    this.onViewHistory,
  });

  IconData _syncIcon() {
    switch (syncStatus) {
      case SyncStatus.synced:
        return Icons.check_circle_outline;
      case SyncStatus.pending:
        return Icons.sync;
      case SyncStatus.conflict:
        return Icons.error_outline;
    }
  }

  Color _syncColor() {
    switch (syncStatus) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.conflict:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewText = quillJsonToPlainText(content);

    /// derived state (correct)
    final isConflict = syncStatus == SyncStatus.conflict;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      onLongPress: () {
        DeleteBottomSheet.show(
          context,
          onDelete: onDelete,
          onViewHistory: onViewHistory,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP CONTENT
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
                  previewText.isEmpty ? 'No data' : previewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            // BOTTOM ROW
            Row(
              children: [
                const Icon(Icons.schedule, size: 14),
                const SizedBox(width: 4),
                const Text('Just now', style: TextStyle(fontSize: 12)),
                const Spacer(),

                Icon(_syncIcon(), size: 16, color: _syncColor()),

                if (offline)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.wifi_off, size: 16),
                  ),

                if (syncStatus == SyncStatus.conflict)
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
