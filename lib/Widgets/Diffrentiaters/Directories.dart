import 'dart:io';

import 'package:flutter/material.dart';

class Directories extends StatefulWidget {
  final String name;
  final Entrylink;
  const Directories({super.key, required this.name, required this.Entrylink});

  @override
  State<Directories> createState() => _DirectoriesState();
}

class _DirectoriesState extends State<Directories> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.Entrylink is Directory)
            Container(color: Colors.blue, child: Text("Directory"))
          else if (widget.Entrylink is File)
            Container(color: Colors.amber, child: Text("File"))
          else
            // This displays if the type is unknown or something else entirely
            Container(color: Colors.grey, child: Text("Other")),

          Text(widget.name),
        ],
      ),
    );
  }
}
