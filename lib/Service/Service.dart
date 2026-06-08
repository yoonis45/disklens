import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Legacy init helper — prefer calling [Dirmanager.initHome] directly.
class Service {
  Future<void> initHome(BuildContext context, Directory homeDir) async {
    await Provider.of<Dirmanager>(
      context,
      listen: false,
    ).initHome(homeDir);
  }
}
