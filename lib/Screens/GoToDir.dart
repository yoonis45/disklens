import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/Directories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gotodir extends StatefulWidget {
  final Directory Destination;
  const Gotodir({super.key, required this.Destination});

  @override
  State<Gotodir> createState() => _GotodirState();
}

class _GotodirState extends State<Gotodir> {
  List<FileSystemEntity> entity = [];

  void initwithtimer() async {
    final data = await Provider.of<Dirmanager>(
      context,
      listen: false,
    ).GetDirectories(widget.Destination);

    setState(() {
      entity = data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initwithtimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager value, Widget? child) {
        return Scaffold(
          appBar: AppBar(title: Text('${widget.Destination.path}')),
          body: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: entity
                  .length, // change it to dynamic now we only have the non dot starters
              itemBuilder: (BuildContext context, int index) {
                List<String> names = [];
                names = value.TrimPath(entity);
                print(names);

                return GestureDetector(
                  onTap: () {
                    Directory newDir = Directory(
                      '${widget.Destination.path}/${names[index]}',
                    );
                    print(newDir.path);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Gotodir(Destination: newDir),
                      ),
                    );
                  },
                  child: Directories(name: names[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
