import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class lis extends StatefulWidget {
  final List<FileSystemEntity> Entities;

  const lis({super.key, required this.Entities});

  @override
  State<lis> createState() => _lisState();
}

class _lisState extends State<lis> {
  @override
  Widget build(BuildContext context) {
    Map Trimed_Entities = Dirmanager().TrimPath(widget.Entities);
    final entries = Trimed_Entities.entries.toList();

    return Consumer<Dirmanager>(
      builder: (context, Dirmanager, child) {
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            dynamic selectedPath;
            return Material(
              //color: Colors.transparent,
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

                child: ListTile(
                  tileColor: selectedPath == entries[index].value
                      ? Colors.grey[800]
                      : Colors.transparent,
                  selected: selectedPath == entries[index].value.path,
                  leading: entries[index].value is Directory
                      ? Icon(Icons.folder, color: Colors.blue)
                      : Icon(Icons.feed_outlined, color: Colors.grey),
                  title: Text(entries[index].key),
                  trailing: Text(entries[index].value.toString()),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
