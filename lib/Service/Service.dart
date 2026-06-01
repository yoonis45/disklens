import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
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
}
