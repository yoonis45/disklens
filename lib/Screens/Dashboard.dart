import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (BuildContext context, Dirmanager, Widget? child) {
        return Scaffold(
          
        );
      },
    );
  }
}
