import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? _]) async {
      final dir = Directory('docs');
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('docs/$name.png');
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
