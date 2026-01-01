import 'package:flutter/material.dart';
import 'dart:io';

class Dirmanager extends ChangeNotifier {
  
  // Get list of directories in a given path
  Future<List<FileSystemEntity>> GetDirectories(Directory Home_dir) async {
    if (await Home_dir.existsSync()) {
      return Home_dir.listSync(followLinks: false);
    }
    return [];
  }

  // Trim the path to get only the directory or file names
  List<String> TrimPath(List<FileSystemEntity> entities) {
    List<String> names = [];
    if (entities.isNotEmpty) {
      for (var entity in entities) {
        names.add(entity.path.split('/').last);
      }
      return names;
    } else {
      return [];
    }
  }
}
