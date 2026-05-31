import 'dart:io';
import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/GoToDir.dart';
import 'package:disklens/Widgets/Directories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //Directory Home_dir = Directory('/home/darkness/');
  final home = Platform.environment['HOME'];
  late Directory homeDir = Directory(home!);
  List<String> Non_Hidden_Entities = [];
  List<String> Entity_Names = [];

  void initwithtimer() async {
    Provider.of<Dirmanager>(
      context,
      listen: false,
    ).Get_Home_D_Entities(homeDir);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initwithtimer();
    print(home);
    print(homeDir);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager, Widget? child) {
        Entity_Names = Dirmanager.TrimPath(Dirmanager.Home_D_Entities);
        for (var name in Entity_Names) {
          if (!name.startsWith('.')) {
            Non_Hidden_Entities.add(name);
          }
        }
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: Non_Hidden_Entities
                  .length, // change it to dynamic now we only have the non dot starters
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Directory newDir = Directory(
                      '${homeDir.path}${Non_Hidden_Entities[index]}',
                    );
                    print(newDir.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Gotodir(Destination: newDir),
                      ),
                    );
                  },
                  child: Directories(name: Non_Hidden_Entities[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
