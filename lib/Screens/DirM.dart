import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
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
  final service srv = service();
  late final TextEditingController tcon;
  bool Is_Grid = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tcon = TextEditingController();
    srv.initwithtimer(homeDir, context);
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DISKLENS", style: TextStyle(color: Colors.white)),
                        SizedBox(height: 20),
                        Text(
                          "Quick Access",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text("Favorites"),
                          icon: Icon(Icons.star_border),
                        ),
                        SizedBox(height: 20),

                        Text("System", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ButtonStyle(),
                          onPressed: () {},
                          label: Text("Home"),
                          icon: Icon(Icons.home),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text("Downloads"),
                          icon: Icon(Icons.file_download_outlined),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text("Document"),
                          icon: Icon(Icons.feed_outlined),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text("Pictures"),
                          icon: Icon(Icons.image_outlined),
                        ),
                        SizedBox(height: 20),
                        Text("External", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        Divider(color: Colors.white),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text("Trash"),
                          icon: Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Dirmanager.navigate_to(Dirmanager.parent.parent);
                              Dirmanager.parent = Dirmanager.parent.parent;
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_forward),
                          ),
                          Flexible(
                            child: TextFormField(
                              controller: tcon,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                Is_Grid = !Is_Grid;
                              });
                            },
                            icon: Icon(
                              Is_Grid ? Icons.grid_view : Icons.view_list,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        color: const Color.fromARGB(31, 32, 30, 30),
                        child: Is_Grid
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Grid(Entities: Dirmanager.Entities),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: lis(Entities: Dirmanager.Entities),
                              ),
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
