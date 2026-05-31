import 'package:flutter/material.dart';
import 'dart:io';

class Dirmanager extends ChangeNotifier {
  List<FileSystemEntity> Home_D_Entities = [];

  // Get list of directories in a given path
  List<FileSystemEntity> Get_Home_D_Entities(Directory Home_dir) {
    if (Home_dir.existsSync()) {
      Home_D_Entities = (Home_dir.listSync(followLinks: false));
      print(Home_D_Entities);
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
