import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/Diffrentiaters/Directories.dart';
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
            return ListTile(
              title: GestureDetector(
                onTap: () {
                  Dirmanager.navigate_to(entries[index].value);

                  print(
                    "Trimed ${entries[index].key} the path: ${entries[index].value} Type of path: ${entries[index].value.runtimeType}",
                  );

                  Dirmanager.parent = entries[index].value;
                },
                child: Directories(
                  name: entries[index].key,
                  Entrylink: entries[index].value,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
