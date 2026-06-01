import 'package:flutter/material.dart';

class File extends StatefulWidget {
  final String name;
  const File({super.key, required this.name});

  @override
  State<File> createState() => _FileState();
}

class _FileState extends State<File> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(child: Container(color: Colors.orange)),
            Text(widget.name),
          ],
        ),
      ),
    );
  }
}
