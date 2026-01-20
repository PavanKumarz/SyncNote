enum DiffType { same, local, remote }

class DiffChunk {
  final String text;
  final DiffType type;

  DiffChunk({required this.text, required this.type});

  bool get isLocal => type == DiffType.local;
  bool get isRemote => type == DiffType.remote;
}

class DiffUtils {
  /// Simple word-based diff (MVP but works well)
  static List<DiffChunk> diffWords(String remote, String local) {
    final r = remote.split(RegExp(r'\s+'));
    final l = local.split(RegExp(r'\s+'));

    final result = <DiffChunk>[];
    int i = 0, j = 0;

    while (i < r.length || j < l.length) {
      if (i < r.length && j < l.length && r[i] == l[j]) {
        result.add(DiffChunk(text: '${r[i]} ', type: DiffType.same));
        i++;
        j++;
      } else {
        if (j < l.length) {
          result.add(DiffChunk(text: '${l[j]} ', type: DiffType.local));
          j++;
        }
        if (i < r.length) {
          result.add(DiffChunk(text: '${r[i]} ', type: DiffType.remote));
          i++;
        }
      }
    }

    return result;
  }
}
