import 'package:flutter/material.dart';
import 'dart:io';

class Dirmanager extends ChangeNotifier {
  Directory parent = Directory("");
  List<FileSystemEntity> Entities = [];
  List<FileSystemEntity> Home_D_Entities = [];
  var Home_dir_path = '';

  // Get list of directories in a given path
  void Get_Home_D_Entities(Directory Home_dir) {
    if (Home_dir.existsSync()) {
      Home_D_Entities = Home_dir.listSync(followLinks: false);
      parent = Home_dir;
      Entities = Home_D_Entities;
    }
  }

  // Navigating to directory
  void navigate_to(Directory Dir_Path) {
    List<FileSystemEntity> Nav_Entities = [];
    if (Dir_Path.existsSync()) {
      Nav_Entities = Dir_Path.listSync(followLinks: false);
      Entities.clear();
      Entities = Nav_Entities;
      notifyListeners();
    }
  }

  // Trim the path to get only the directory or file names
  Map TrimPath(List<FileSystemEntity> entities) {
    String Trimed_name = '';
    Map<String, FileSystemEntity> T_F_Entities = {};
    if (entities.isNotEmpty) {
      for (var entity in entities) {
        Trimed_name = entity.path.split('/').last;
        T_F_Entities.addAll({Trimed_name: entity});
      }
      return T_F_Entities;
    } else {
      return {};
    }
  }
}
