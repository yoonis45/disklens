import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gotodir extends StatefulWidget {
  const Gotodir({super.key});

  @override
  State<Gotodir> createState() => _GotodirState();
}

class _GotodirState extends State<Gotodir> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager value, Widget? child) {
        return Scaffold();
      },
    );
  }
}
