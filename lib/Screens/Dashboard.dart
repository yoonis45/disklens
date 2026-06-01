import 'dart:io';
import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/GoToDir.dart';
import 'package:disklens/Service/Service.dart';
import 'package:disklens/Widgets/Diffrentiaters/Directories.dart';
import 'package:disklens/Widgets/Listers/Grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // final home = Platform.environment['HOME'];
  // late Directory homeDir = Directory(home!);
  // final service srv = service();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   srv.initwithtimer(homeDir, context);
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager, Widget? child) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Grid(Entities: Dirmanager.Entities),
          ),
        );
      },
    );
  }
}
