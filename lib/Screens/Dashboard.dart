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
  List<FileSystemEntity> entity = [];
  Directory Home_dir = Directory('/home/darkness');

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    entity = await Provider.of<Dirmanager>(
      context,
      listen: false,
    ).GetDirectories(Home_dir);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager, Widget? child) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount:
                  18, // change it to dynamic now we only have the non dot starters
              itemBuilder: (BuildContext context, int index) {
                List<String> nonDot = [];
                List<String> names = [];
                names = Dirmanager.TrimPath(entity);
                for (var name in names) {
                  if (!name.startsWith('.')) {
                    nonDot.add(name);
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Directory newDir = Directory(
                      '${Home_dir.path}/${nonDot[index]}',
                    );
                    print(newDir.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Gotodir(Destination: newDir),
                      ),
                    );
                  },
                  child: Directories(name: nonDot[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
