import 'dart:io';
import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/GoToDir.dart';
import 'package:disklens/Service/Service.dart';
import 'package:disklens/Widgets/Diffrentiaters/Directories.dart';
import 'package:disklens/Widgets/Listers/Grid.dart';
import 'package:disklens/Widgets/Listers/List.dart';
import 'package:disklens/Widgets/Storage_OverView_Size.dart';
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
        String size = "180";
        TextStyle s = TextStyle(fontSize: 28);

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),

                      child: Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Storage Overview",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5),
                            Text("${size} of ${"400"} GB Used"),
                            SizedBox(height: 20),
                            Divider(
                              color: Colors.blue,
                              thickness: 5,
                              radius: BorderRadius.circular(10),
                            ),
                            SizedBox(height: 20),
                            Flexible(
                              child: Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                    child: StorageOverviewSize(
                                      type: "Video",
                                      size: 80,
                                      colour: Colors.blue,
                                    ),
                                  ),
                                  Flexible(
                                    child: StorageOverviewSize(
                                      type: "Images",
                                      size: 50,
                                      colour: Colors.green,
                                    ),
                                  ),
                                  Flexible(
                                    child: StorageOverviewSize(
                                      type: "Docs",
                                      size: 30,
                                      colour: Colors.yellow,
                                    ),
                                  ),
                                  Flexible(
                                    child: StorageOverviewSize(
                                      type: "Apps",
                                      size: 40,
                                      colour: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Directories And Files",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10),
                Dirmanager.Is_Grid
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Grid(Entities: Dirmanager.Entities),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: lis(Entities: Dirmanager.Entities),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
