import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String> copyFileAndGetPath(String path) async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = dir.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampString = timestamp.toString();
    File newImg = await File(path).copy("$dirPath/$timestampString.jpg");
    return newImg?.path;
  }
}