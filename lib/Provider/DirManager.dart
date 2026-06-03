import 'package:flutter/material.dart';
import 'dart:io';

class Dirmanager extends ChangeNotifier {
  final home = Platform.environment['HOME'];
  late Directory homeDir = Directory(home!);
  late Directory Downloads = Directory("${home!}/Downloads");
  late Directory Documents = Directory("${home!}/Documents");
  late Directory Pictures = Directory("${home!}/Pictures");
  Directory parent = Directory("");
  List<FileSystemEntity> AllEntities = [];
  List<FileSystemEntity> NonHiddenEntities = [];
  List<FileSystemEntity> Entities = [];
  List<FileSystemEntity> Home_D_Entities = [];
  Directory Current_path = Directory("");
  Directory selected_path = Directory("");
  bool Is_Grid = true;
  bool showHidden = false;

  // void showHiddenFiles(bool value) {
  //   showHidden = value;

  //   if (showHidden) {
  //     Entities = List<FileSystemEntity>.from(AllEntities);
  //   } else {
  //     Entities = List<FileSystemEntity>.from(NonHiddenEntities);
  //   }

  //   notifyListeners();
  // }
  void showHiddenFiles(bool value) {
    showHidden = value;
    AllEntities = parent.listSync(followLinks: false);
    Entities = showHidden
        ? List<FileSystemEntity>.from(AllEntities)
        : AllEntities.where((entity) {
            return !entity.path.split('/').last.startsWith('.');
          }).toList();

    notifyListeners();
  }

  void toggle() {
    Is_Grid = !Is_Grid;

    notifyListeners();
  }

  void Go_To_Dashboard() {
    parent = homeDir;
    print(parent);
    Entities = homeDir.listSync(followLinks: false);
    notifyListeners();
  }

  void update_selected_path(dynamic path) {
    selected_path = path;
    notifyListeners();
  }

  // Get list of directories in a given path
  void Get_Home_D_Entities(Directory Home_dir) {
    if (Home_dir.existsSync()) {
      Home_D_Entities = Home_dir.listSync(followLinks: false);
      Current_path = Home_dir;
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
      parent = Dir_Path;
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
