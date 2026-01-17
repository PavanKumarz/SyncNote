import 'package:flutter/material.dart';
import 'features/presentation/pages/root_page.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runApp(const SyncNoteApp());
}

class SyncNoteApp extends StatelessWidget {
  const SyncNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // REQUIRED for flutter_quill (otherwise crash)
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      supportedLocales: const [Locale('en')],

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const RootPage(),
    );
  }
}
