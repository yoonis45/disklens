import 'package:disklens/Provider/DirManager.dart';
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
        final used = 150;
        final total = 450;

        return Scaffold(
          backgroundColor: Color(0xFF0B0C0D),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF171719),
                    ),

                    child: Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Storage Overview",
                            style: TextStyle(color: Colors.grey),
                          ),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$used',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' of ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: '$total',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' GB used',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            color: Colors.blue,
                            thickness: 5,
                            radius: BorderRadius.circular(10),
                          ),

                          Expanded(
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

                Text(
                  "Directories And Files",
                  style: TextStyle(color: Colors.grey),
                ),

                Dirmanager.Is_Grid
                    ? Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Grid(Entities: Dirmanager.Entities),
                        ),
                      )
                    : Expanded(
                        flex: 2,
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
