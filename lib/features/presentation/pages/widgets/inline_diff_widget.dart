import 'package:flutter/material.dart';
import 'package:syncnote_engine/core/utils/diff_utils.dart';

class InlineDiffWidget extends StatelessWidget {
  final List<DiffChunk> diffs;
  final Set<int> accepted;
  final Function(int index) onToggle;

  const InlineDiffWidget({
    super.key,
    required this.diffs,
    required this.accepted,
    required this.onToggle,
  });

  Color _bgColor(DiffChunk diff, bool isAccepted) {
    if (!isAccepted) {
      return Colors.grey.shade200;
    }

    if (diff.type == DiffType.local) {
      return Colors.green.shade200;
    }

    if (diff.type == DiffType.remote) {
      return Colors.blue.shade200;
    }

    return Colors.transparent;
  }

  Color _borderColor(DiffChunk diff, bool isAccepted) {
    if (!isAccepted) return Colors.grey.shade400;

    if (diff.type == DiffType.local) return Colors.green.shade700;
    if (diff.type == DiffType.remote) return Colors.blue.shade700;

    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 6,
      children: List.generate(diffs.length, (i) {
        final diff = diffs[i];
        final isAccepted = accepted.contains(i);

        return GestureDetector(
          onTap: () => onToggle(i),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isAccepted ? 1.0 : 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _bgColor(diff, isAccepted),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _borderColor(diff, isAccepted),
                  width: isAccepted ? 1.2 : 0.8,
                ),
              ),
              child: Text(
                diff.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  decoration: isAccepted ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
