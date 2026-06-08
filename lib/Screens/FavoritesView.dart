import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, manager, child) {
        final favorites = manager.favoritePaths;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade800),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Text(
                        'Right-click a folder → Add to Favorites',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : manager.isGrid
                      ? _FavoritesGrid(paths: favorites)
                      : _FavoritesList(paths: favorites),
            ),
          ],
        );
      },
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<String> paths;

  const _FavoritesList({required this.paths});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: paths.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 56,
        color: Colors.grey.shade900,
      ),
      itemBuilder: (context, index) => _FavoriteTile(path: paths[index]),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  final List<String> paths;

  const _FavoritesGrid({required this.paths});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: paths.length,
      itemBuilder: (context, index) => _FavoriteGridItem(path: paths[index]),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final String path;

  const _FavoriteTile({required this.path});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<Dirmanager>();
    final isDir = FileSystemEntity.typeSync(path) ==
        FileSystemEntityType.directory;

    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      leading: Icon(
        isDir ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
        color: Colors.grey.shade500,
        size: 22,
      ),
      title: Text(
        path.split('/').last,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        path,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _FavoriteMenu(path: path, isDir: isDir),
      onTap: () {
        if (isDir) manager.navigateTo(Directory(path));
      },
    );
  }
}

class _FavoriteGridItem extends StatelessWidget {
  final String path;

  const _FavoriteGridItem({required this.path});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<Dirmanager>();
    final isDir = FileSystemEntity.typeSync(path) ==
        FileSystemEntityType.directory;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isDir) manager.navigateTo(Directory(path));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            children: [
              Icon(
                isDir ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
                color: Colors.grey.shade500,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                path.split('/').last,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: _FavoriteMenu(path: path, isDir: isDir),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteMenu extends StatelessWidget {
  final String path;
  final bool isDir;

  const _FavoriteMenu({required this.path, required this.isDir});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<Dirmanager>();

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey.shade500, size: 20),
      color: AppTheme.menu,
      onSelected: (value) {
        if (value == 'open' && isDir) {
          manager.navigateTo(Directory(path));
        } else if (value == 'remove') {
          manager.removeFavorite(path);
        }
      },
      itemBuilder: (_) => [
        if (isDir)
          const PopupMenuItem(
            value: 'open',
            child: Text('Open', style: TextStyle(color: Colors.white)),
          ),
        PopupMenuItem(
          value: 'remove',
          child: Text(
            'Remove',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }
}
