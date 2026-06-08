import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:provider/provider.dart';

class service {
  List<FileSystemEntity> Entities = [];
  List<String> Non_Hidden_Entities = [];
  Map Entity_Names = {};

  void initwithtimer(Directory homeDir, context) async {
    Provider.of<Dirmanager>(
      context,
      listen: false,
    ).Get_Home_D_Entities(homeDir);
  }

  void check_system_panel(Directory path) {
    if (path.existsSync()) {
      print("they exsist");
    } else {
      print("they dont ");
    }
  }

  void showHidden_Files(context) async {
    Provider.of<Dirmanager>(context, listen: false).showHiddenFiles(false);
  }

  void Create_Directory(Directory Path) {}
}
