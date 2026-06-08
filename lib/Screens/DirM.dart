import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Screens/Dashboard.dart';
import 'package:disklens/Screens/FavoritesView.dart';
import 'package:disklens/Screens/TrashView.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:disklens/Widgets/FileShortcuts.dart';
import 'package:disklens/Widgets/Listers/Grid.dart';
import 'package:disklens/Widgets/Listers/List.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dirm extends StatefulWidget {
  const Dirm({super.key});

  @override
  State<Dirm> createState() => _DirmState();
}

class _DirmState extends State<Dirm> {
  final home = Platform.environment['HOME'];
  late final Directory homeDir;
  late final Directory downloads;
  late final Directory documents;
  late final Directory pictures;
  late final TextEditingController pathController;
  late final FocusNode _fileFocusNode;
  String selectedRadio = 'name';
  String? _lastSnack;

  final sidebarButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: const Color(0xFF2B2C2E),
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    alignment: Alignment.centerLeft,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  @override
  void initState() {
    super.initState();
    homeDir = Directory(home!);
    downloads = Directory('${home!}/Downloads');
    documents = Directory('${home!}/Documents');
    pictures = Directory('${home!}/Pictures');
    pathController = TextEditingController();
    _fileFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Dirmanager>().initHome(homeDir);
      _fileFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    pathController.dispose();
    _fileFocusNode.dispose();
    super.dispose();
  }

  void _showFeedback(Dirmanager manager) {
    final message = manager.lastError ?? manager.lastMessage;
    if (message == null || message == _lastSnack) return;
    _lastSnack = message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            manager.lastError != null ? Colors.red.shade800 : Colors.grey.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
    manager.clearFeedback();
  }

  void _goBack(Dirmanager manager) {
    if (manager.currentView == AppView.favorites ||
        manager.currentView == AppView.trash) {
      manager.goToDashboard();
      return;
    }
    final parent = manager.parent.parent;
    if (parent.path.isEmpty || parent.path == manager.parent.path) return;
    if (parent.path == manager.homeDir.path) {
      manager.goToDashboard();
    } else {
      manager.navigateTo(parent);
    }
  }

  void _goForward(Dirmanager manager) {
    final dest = manager.selectedPath;
    if (dest.path.isEmpty) return;
    if (dest.path == manager.homeDir.path) {
      manager.goToDashboard();
    } else {
      manager.navigateTo(dest);
    }
  }

  void _navigateFromPath(Dirmanager manager) {
    final path = pathController.text.trim();
    if (path.isEmpty) return;
    final dir = Directory(path);
    if (!dir.existsSync()) {
      manager.setError('Path does not exist');
      return;
    }
    if (path == manager.homeDir.path) {
      manager.goToDashboard();
    } else {
      manager.navigateTo(dir);
    }
  }

  Widget _buildContent(Dirmanager manager) {
    switch (manager.currentView) {
      case AppView.home:
        return const Dashboard();
      case AppView.favorites:
        return const FavoritesView();
      case AppView.trash:
        return const TrashView();
      case AppView.browse:
        return manager.isGrid
            ? Grid(entities: manager.entities)
            : FileList(entities: manager.entities);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, manager, child) {
        if (manager.currentView != AppView.favorites &&
            manager.currentView != AppView.trash &&
            pathController.text != manager.parent.path) {
          pathController.text = manager.parent.path;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFeedback(manager);
        });

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: AppTheme.sidebar,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'D I S K L E N S',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          'Quick Access',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.star,
                          iconColor: Colors.yellow,
                          label: 'Favorites',
                          active: manager.currentView == AppView.favorites,
                          onPressed: () => manager.openFavorites(),
                        ),
                        const SizedBox(height: 20),
                        const Text('System', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.home,
                          iconColor: Colors.blue,
                          label: 'Home',
                          active: manager.currentView == AppView.home,
                          onPressed: () => manager.goToDashboard(),
                        ),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.file_download_outlined,
                          label: 'Downloads',
                          onPressed: () => manager.navigateTo(downloads),
                        ),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.feed_outlined,
                          label: 'Documents',
                          onPressed: () => manager.navigateTo(documents),
                        ),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.image_outlined,
                          label: 'Pictures',
                          onPressed: () => manager.navigateTo(pictures),
                        ),
                        const SizedBox(height: 20),
                        const Text('External', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        _sidebarButton(
                          icon: Icons.usb,
                          iconColor: Colors.green,
                          label: 'External Drive',
                          onPressed: () {
                            manager.setError('External drives: coming soon');
                          },
                        ),
                        const Spacer(),
                        const Divider(),
                        _sidebarButton(
                          icon: Icons.delete_outline,
                          iconColor: Colors.red,
                          label: 'Trash',
                          active: manager.currentView == AppView.trash,
                          onPressed: () => manager.openTrash(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _goBack(manager),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: manager.selectedPath.path.isEmpty
                                ? null
                                : () => _goForward(manager),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: manager.selectedPath.path.isEmpty
                                  ? Colors.grey
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: pathController,
                              style: const TextStyle(color: Colors.white),
                              onFieldSubmitted: (_) =>
                                  _navigateFromPath(manager),
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search, size: 18),
                                  onPressed: () => _navigateFromPath(manager),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: manager.toggle,
                            icon: Icon(
                              size: 20,
                              color: Colors.white,
                              manager.isGrid
                                  ? Icons.grid_view
                                  : Icons.view_list,
                            ),
                          ),
                          MenuAnchor(
                            builder: (context, controller, child) {
                              return IconButton(
                                icon: const Icon(
                                  size: 20,
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  controller.isOpen
                                      ? controller.close()
                                      : controller.open();
                                },
                              );
                            },
                            menuChildren: [
                              RadioMenuButton<String>(
                                value: 'name',
                                groupValue: selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRadio = value!;
                                    manager.entities.sort(
                                      (a, b) => a.path.compareTo(b.path),
                                    );
                                  });
                                },
                                child: const Text('Sort by Name'),
                              ),
                              RadioMenuButton<String>(
                                value: 'type',
                                groupValue: selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRadio = value!;
                                    manager.entities.sort((a, b) {
                                      if (a is Directory && b is File) {
                                        return -1;
                                      }
                                      if (a is File && b is Directory) {
                                        return 1;
                                      }
                                      return 0;
                                    });
                                  });
                                },
                                child: const Text('Sort by Type'),
                              ),
                              CheckboxMenuButton(
                                value: manager.showHidden,
                                onChanged: (value) {
                                  manager.showHiddenFiles(value ?? false);
                                },
                                child: const Text('Show Hidden Files'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FileShortcutHandler(
                        focusNode: _fileFocusNode,
                        child: Stack(
                          children: [
                            Container(
                              color: AppTheme.contentOverlay,
                              child: _buildContent(manager),
                            ),
                            if (manager.isLoading)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sidebarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    bool active = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: sidebarButtonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            active ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
