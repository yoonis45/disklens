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
  List<FileSystemEntity> recycleBin = [];
  Directory Current_path = Directory("");
  Directory selected_path = Directory("");
  bool Is_Grid = true;
  bool showHidden = false;
  List hi = [];

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

  void Get_size(Directory Home_dir) {
    hi = Home_dir.listSync();
  }

  void Create(Directory path, String name) {
    try {
      final folderPath = "${path.path}/$name";

      final newFolder = Directory(folderPath);

      if (newFolder.existsSync()) {
        throw Exception("Folder already exists");
      }

      newFolder.createSync();

      if (showHidden || !name.startsWith('.')) {
        Entities.add(newFolder);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void Rename(Directory parentPath, String oldName, String newName) {
    try {
      final oldPath = "${parentPath.path}/$oldName";
      final newPath = "${parentPath.path}/$newName";

      // check if target already exists
      if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
        throw Exception("Name already exists");
      }

      // rename (works for both file + folder)
      FileSystemEntity entity = File(oldPath);

      if (!entity.existsSync()) {
        entity = Directory(oldPath);
      }

      entity.renameSync(newPath);

      // update UI list
      final index = Entities.indexWhere((e) => e.path == oldPath);

      if (index != -1) {
        Entities[index] =
            FileSystemEntity.typeSync(newPath) == FileSystemEntityType.directory
            ? Directory(newPath)
            : File(newPath);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void Delete(FileSystemEntity entity) {
    try {
      // remove from current view
      Entities.removeWhere((e) => e.path == entity.path);

      // add to recycle bin
      recycleBin.add(entity);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void Restore(FileSystemEntity entity) {
    try {
      recycleBin.removeWhere((e) => e.path == entity.path);

      // only restore if still inside current directory view
      if (entity.path.startsWith(parent.path)) {
        Entities.add(entity);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
