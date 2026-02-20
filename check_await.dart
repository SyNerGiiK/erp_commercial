// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final dirs = [
    Directory('lib/views'),
    Directory('lib/widgets'),
  ];

  for (final dir in dirs) {
    if (!dir.existsSync()) continue;
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains(' await ') ||
            line.contains('= await ') ||
            line.contains('(await ') ||
            line.contains('await\n') ||
            line.contains('\tawait ')) {
          bool foundMounted = false;
          bool usesContext = false;

          for (int j = i + 1; j < i + 15 && j < lines.length; j++) {
            final nline = lines[j];
            if (nline.contains('mounted')) {
              foundMounted = true;
              break;
            }
            if (nline.contains('context') ||
                nline.contains('setState') ||
                nline.contains('Navigator') ||
                nline.contains('ScaffoldMessenger') ||
                nline.contains('Provider.of')) {
              // Wait, if it's context.read, context.go, Navigator.pop(context), setState(() {})
              if (!nline.contains('//')) {
                usesContext = true;
                break;
              }
            }
            if (nline.contains('}') &&
                !nline.contains('{') &&
                !nline.contains(';')) {
              // rough heuristic for end of block
              break;
            }
          }

          if (usesContext && !foundMounted) {
            print('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }
  }
}
