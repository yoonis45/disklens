import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/DirM.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Dirmanager())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disklens',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.background,
      ),
      home: const Dirm(),
    );
  }
}
