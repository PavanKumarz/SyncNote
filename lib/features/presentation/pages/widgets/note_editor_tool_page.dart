import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoteToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onDelete;

  const NoteToolbar({
    super.key,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 50,
        width: double.infinity,

        //  FULL TOOLBAR BACKGROUND COLOR
        decoration: BoxDecoration(
          color: Colors.yellow[300],
          border: Border(top: BorderSide(color: Colors.yellow.shade300)),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            ///  CENTERED QUILL TOOLS
            Padding(
              // keeps tools visually centered
              padding: const EdgeInsets.only(left: 5, right: 50),
              child: Material(
                // so the yellow background shows through
                color: Colors.yellow,

                child: QuillSimpleToolbar(
                  controller: controller,
                  config: QuillSimpleToolbarConfig(
                    multiRowsDisplay: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showSmallButton: false,
                    showInlineCode: false,
                    showAlignmentButtons: false,
                    showDirection: false,
                    showDividers: false,
                    showHeaderStyle: false,
                    showCodeBlock: false,
                    showQuote: false,
                    showIndent: false,
                    showLink: true,
                    showListCheck: true,

                    buttonOptions: const QuillSimpleToolbarButtonOptions(
                      undoHistory: QuillToolbarHistoryButtonOptions(
                        iconData: FontAwesomeIcons.arrowRotateLeft,
                        iconSize: 16,
                      ),
                      redoHistory: QuillToolbarHistoryButtonOptions(
                        iconData: FontAwesomeIcons.arrowRotateRight,
                        iconSize: 16,
                      ),
                      bold: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.bold,
                        iconSize: 16,
                      ),
                      italic: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.italic,
                        iconSize: 16,
                      ),
                      underLine: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.underline,
                        iconSize: 16,
                      ),
                      strikeThrough: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.strikethrough,
                        iconSize: 16,
                      ),
                      color: QuillToolbarColorButtonOptions(
                        iconData: FontAwesomeIcons.palette,
                        iconSize: 16,
                      ),
                      backgroundColor: QuillToolbarColorButtonOptions(
                        iconData: FontAwesomeIcons.fillDrip,
                        iconSize: 16,
                      ),
                      clearFormat: QuillToolbarClearFormatButtonOptions(
                        iconData: FontAwesomeIcons.textSlash,
                        iconSize: 16,
                      ),
                      listNumbers: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.listOl,
                        iconSize: 16,
                      ),
                      listBullets: QuillToolbarToggleStyleButtonOptions(
                        iconData: FontAwesomeIcons.listUl,
                        iconSize: 16,
                      ),
                      search: QuillToolbarSearchButtonOptions(
                        iconData: FontAwesomeIcons.magnifyingGlass,
                        iconSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///  FIXED MORE OPTIONS ICON (BOTTOM-RIGHT)
            Positioned(
              right: 4,
              bottom: 4,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///  Bottom sheet actions
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.color_lens_outlined),
              title: Text('Change color'),
            ),
            const ListTile(
              leading: Icon(Icons.label_outline),
              title: Text('Labels'),
            ),
            const ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text('Share'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                onDelete(); // trigger delete
              },
            ),
          ],
        ),
      ),
    );
  }
}
