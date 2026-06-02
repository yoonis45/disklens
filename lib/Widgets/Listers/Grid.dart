import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Service/Service.dart';
import 'package:disklens/Widgets/Diffrentiaters/Directories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Grid extends StatefulWidget {
  final List<FileSystemEntity> Entities;
  const Grid({super.key, required this.Entities});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  Widget build(BuildContext context) {
    // final service srv = service();

    Map Trimed_Entities = Dirmanager().TrimPath(widget.Entities);
    final entries = Trimed_Entities.entries.toList();

    return Consumer<Dirmanager>(
      builder: (context, Dirmanager, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: entries
              .length, // change it to dynamic now we only have the non dot starters
          itemBuilder: (BuildContext context, int index) {
            dynamic selectedPath;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedPath = entries[index].value;
                    print(selectedPath);
                    Dirmanager.update_selected_path(selectedPath);
                  });
                },
                onDoubleTap: () {
                  Dirmanager.navigate_to(entries[index].value);

                  print(
                    "Trimed ${entries[index].key} the path: ${entries[index].value} Type of path: ${entries[index].value.runtimeType}",
                  );

                  Dirmanager.parent = entries[index].value;
                },
                splashColor: Colors.grey[10],
                hoverColor: const Color.fromARGB(255, 70, 69, 69),
                // entries[index].value is Directory
                //                       ? Icon(Icons.folder, color: Colors.blue)
                //                       : Icon(Icons.feed_outlined, color: Colors.grey),
                //Text(entries[index].key),
                child: Container(
                  child: Column(
                    children: [
                      if (entries[index].value is Directory)
                        Expanded(child: Icon(Icons.folder, color: Colors.blue))
                      else
                        Expanded(
                          child: Icon(Icons.feed_outlined, color: Colors.grey),
                        ),

                      Text(entries[index].key),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
