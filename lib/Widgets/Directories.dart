import 'package:flutter/material.dart';

class Directories extends StatefulWidget {
  final String name;
  const Directories({super.key, required this.name});

  @override
  State<Directories> createState() => _DirectoriesState();
}

class _DirectoriesState extends State<Directories> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(child: Container(color: Colors.blue)),
            Text(widget.name),
          ],
        ),
      ),
    );
  }
}
