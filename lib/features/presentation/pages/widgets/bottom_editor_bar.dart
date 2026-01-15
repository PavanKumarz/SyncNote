import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class BottomEditorBar extends StatelessWidget {
  final QuillController controller;
  final FocusNode editorFocusNode;

  const BottomEditorBar({
    super.key,
    required this.controller,
    required this.editorFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),

        child: Row(
          children: [
            // SCROLLABLE TOOLBAR
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(Icons.keyboard),
                      onPressed: () => editorFocusNode.requestFocus(),
                    ),

                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () =>
                          controller.formatSelection(Attribute.bold),
                    ),

                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () =>
                          controller.formatSelection(Attribute.italic),
                    ),

                    IconButton(
                      icon: const Icon(Icons.check_box_outlined),
                      onPressed: () =>
                          controller.formatSelection(Attribute.unchecked),
                    ),

                    IconButton(
                      icon: const Icon(Icons.format_list_bulleted),
                      onPressed: () => controller.formatSelection(Attribute.ul),
                    ),

                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: controller.hasUndo ? controller.undo : null,
                    ),

                    IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed: controller.hasRedo ? controller.redo : null,
                    ),

                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            //FIXED MORE OPTIONS (STEADY)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Change color')),
            ListTile(title: Text('Labels')),
            ListTile(title: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
