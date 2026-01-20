import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:syncnote_engine/core/utils/diff_utils.dart';
import 'package:syncnote_engine/core/utils/quill_preview.dart';
import 'package:syncnote_engine/features/domain/models/note.dart';
import 'package:syncnote_engine/features/domain/models/note_versions.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/inline_diff_widget.dart';
import 'package:syncnote_engine/features/presentation/pages/widgets/sync_status.dart';

class ConflictResolutionPage extends StatefulWidget {
  final NoteModel localNote;
  final NoteVersion remoteVersion;

  const ConflictResolutionPage({
    super.key,
    required this.localNote,
    required this.remoteVersion,
  });

  @override
  State<ConflictResolutionPage> createState() => _ConflictResolutionPageState();
}

class _ConflictResolutionPageState extends State<ConflictResolutionPage> {
  late final List<DiffChunk> diffs;
  final Set<int> accepted = {};
  final ScrollController _scrollController = ScrollController();

  int get localChanges => diffs.where((d) => d.type == DiffType.local).length;

  int get remoteChanges => diffs.where((d) => d.type == DiffType.remote).length;

  @override
  void initState() {
    super.initState();

    final remoteText = quillJsonToPlainText(widget.remoteVersion.content);

    final localText = quillJsonToPlainText(widget.localNote.content);

    diffs = DiffUtils.diffWords(remoteText, localText);

    _applySmartMerge(); //  DEFAULT SAFE MERGE
  }

  /// SMART MERGE STRATEGY
  /// - SAME always accepted
  /// - Prefer side with fewer changes
  void _applySmartMerge() {
    accepted.clear();

    final preferLocal = localChanges <= remoteChanges;

    for (int i = 0; i < diffs.length; i++) {
      final d = diffs[i];

      if (d.type == DiffType.same) {
        accepted.add(i);
      } else if (preferLocal && d.type == DiffType.local) {
        accepted.add(i);
      } else if (!preferLocal && d.type == DiffType.remote) {
        accepted.add(i);
      }
    }

    setState(() {});
  }

  void _toggle(int index) {
    setState(() {
      accepted.contains(index) ? accepted.remove(index) : accepted.add(index);
    });
  }

  void _acceptLocal() {
    setState(() {
      accepted.clear();
      for (int i = 0; i < diffs.length; i++) {
        if (diffs[i].type != DiffType.remote) {
          accepted.add(i);
        }
      }
    });
  }

  void _acceptRemote() {
    setState(() {
      accepted.clear();
      for (int i = 0; i < diffs.length; i++) {
        if (diffs[i].type != DiffType.local) {
          accepted.add(i);
        }
      }
    });
  }

  String _mergedText() {
    final buffer = StringBuffer();
    for (int i = 0; i < diffs.length; i++) {
      if (accepted.contains(i)) {
        buffer.write(diffs[i].text);
      }
    }
    return buffer.toString();
  }

  void _mergeAndSave() {
    // Convert merged plain text → Quill JSON (INLINE)
    final delta = Delta()..insert(_mergedText().trim() + '\n');
    final mergedJson = jsonEncode(delta.toJson());

    Navigator.pop(
      context,
      widget.localNote.copyWith(
        title: widget.localNote.title,
        content: mergedJson,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve conflict'),
        actions: [
          TextButton(onPressed: _applySmartMerge, child: const Text('SMART')),
          TextButton(onPressed: _acceptLocal, child: const Text('LOCAL')),
          TextButton(onPressed: _acceptRemote, child: const Text('REMOTE')),
          TextButton(onPressed: _mergeAndSave, child: const Text('MERGE')),
        ],
      ),
      body: Column(
        children: [
          ConflictSummaryBanner(local: localChanges, remote: remoteChanges),
          const ConflictLegend(),

          /// SIDE BY SIDE
          Expanded(
            child: Row(
              children: [
                _Side(
                  title: 'REMOTE',
                  color: Colors.blue.shade50,
                  text: quillJsonToPlainText(widget.remoteVersion.content),
                  controller: _scrollController,
                ),
                const VerticalDivider(width: 1),
                _Side(
                  title: 'LOCAL',
                  color: Colors.green.shade50,
                  text: quillJsonToPlainText(widget.localNote.content),

                  controller: _scrollController,
                ),
              ],
            ),
          ),

          /// INLINE MERGE
          Padding(
            padding: const EdgeInsets.all(12),
            child: InlineDiffWidget(
              diffs: diffs,
              accepted: accepted,
              onToggle: _toggle,
            ),
          ),

          /// PREVIEW
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MERGED PREVIEW',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(_mergedText().isEmpty ? '(empty)' : _mergedText()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------- UI PARTS ---------------------------- */

class ConflictSummaryBanner extends StatelessWidget {
  final int local;
  final int remote;

  const ConflictSummaryBanner({
    super.key,
    required this.local,
    required this.remote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Text(
        '$local local change(s), $remote remote change(s). '
        'A safe merge has been suggested.',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ConflictLegend extends StatelessWidget {
  const ConflictLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _LegendItem(color: Colors.green, label: 'Local'),
          SizedBox(width: 12),
          _LegendItem(color: Colors.blue, label: 'Remote'),
          SizedBox(width: 12),
          _LegendItem(color: Colors.grey, label: 'Ignored'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  final String title;
  final Color color;
  final String text;
  final ScrollController controller;

  const _Side({
    required this.title,
    required this.color,
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Text(text.isEmpty ? '(empty)' : text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
