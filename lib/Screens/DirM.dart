import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/Dashboard.dart';
import 'package:disklens/Service/Service.dart';
import 'package:disklens/Widgets/Listers/Grid.dart';
import 'package:disklens/Widgets/Listers/List.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dirm extends StatefulWidget {
  const Dirm({super.key});

  @override
  State<Dirm> createState() => _DirmState();
}

class _DirmState extends State<Dirm> {
  final home = Platform.environment['HOME'];
  late Directory homeDir = Directory(home!);
  late Directory Downloads = Directory("${home!}/Downloads");
  late Directory Documents = Directory("${home!}/Documents");
  late Directory Pictures = Directory("${home!}/Pictures");
  final service srv = service();
  late final TextEditingController tcon;
  final sidebarButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    alignment: Alignment.centerLeft,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tcon = TextEditingController();
    srv.initwithtimer(homeDir, context);
    srv.check_system_panel(Downloads);
    srv.check_system_panel(Documents);
    srv.check_system_panel(Pictures);
  }

  @override
  void dispose() {
    tcon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, Dirmanager, child) {
        tcon.text = Dirmanager.parent.path;
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "D I S K L E N S",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 50),
                        Text(
                          "Quick Access",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.star_border,
                              color: Colors.yellow,
                            ),
                            label: const Text(
                              "Favorites",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("System", style: TextStyle(color: Colors.grey)),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {
                              Dirmanager.navigate_to(homeDir);
                            },
                            icon: const Icon(Icons.home, color: Colors.blue),
                            label: const Text(
                              "Home",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {
                              Dirmanager.navigate_to(Downloads);
                            },
                            icon: const Icon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Downloads",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {
                              Dirmanager.navigate_to(Documents);
                            },
                            icon: const Icon(
                              Icons.feed_outlined,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Document",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {
                              Dirmanager.navigate_to(Pictures);
                            },
                            icon: const Icon(
                              Icons.image_outlined,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Pictures",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        Text("External", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {},
                            icon: const Icon(Icons.usb, color: Colors.green),
                            label: const Text(
                              "Extarnal Drive",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 150),
                        Divider(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: sidebarButtonStyle,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Trash",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          spacing: 3,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (Dirmanager.parent.parent.path ==
                                    homeDir.path) {
                                  setState(() {
                                    Dirmanager.parent = homeDir;
                                    Dirmanager.navigate_to(homeDir);
                                  });
                                } else {
                                  Dirmanager.navigate_to(
                                    Dirmanager.parent.parent,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Dirmanager.selected_path.toString().isEmpty
                                ? IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      size: 20,
                                      Icons.arrow_forward,
                                      color: Colors.grey,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      if (Dirmanager.selected_path.path ==
                                          homeDir.path) {
                                        setState(() {
                                          Dirmanager.parent = homeDir;
                                          Dirmanager.navigate_to(homeDir);
                                        });
                                      } else {
                                        Dirmanager.navigate_to(
                                          Dirmanager.selected_path,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      size: 20,
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ),
                            SizedBox(height: 10),
                            Flexible(
                              child: TextFormField(
                                controller: tcon,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            IconButton(
                              onPressed: () {
                                Dirmanager.toggle();
                              },
                              icon: Icon(
                                size: 20,
                                color: Colors.white,
                                Dirmanager.Is_Grid
                                    ? Icons.grid_view
                                    : Icons.view_list,
                              ),
                            ),
                            MenuAnchor(
                              builder: (context, controller, child) {
                                return IconButton(
                                  icon: const Icon(
                                    size: 20,
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.isOpen
                                        ? controller.close()
                                        : controller.open();
                                  },
                                );
                              },
                              menuChildren: [
                                MenuItemButton(
                                  child: const Text('Option 1'),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        color: const Color.fromARGB(31, 32, 30, 30),
                        child: Dirmanager.parent == homeDir
                            ? Dashboard()
                            : (Dirmanager.Is_Grid
                                  ? Grid(Entities: Dirmanager.Entities)
                                  : lis(Entities: Dirmanager.Entities)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
