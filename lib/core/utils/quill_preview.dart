import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

String quillJsonToPlainText(String jsonContent) {
  try {
    final decoded = jsonDecode(jsonContent);
    final delta = Delta.fromJson(decoded);
    final doc = Document.fromDelta(delta);

    return doc.toPlainText().trim();
  } catch (e) {
    // fallback if empty or corrupted
    return '';
  }
}
