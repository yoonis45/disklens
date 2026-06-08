import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Service/TrashService.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void _confirmDeleteForever(
  BuildContext context,
  Dirmanager manager,
  TrashItem item,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.dialog,
      title: const Text(
        'Delete permanently?',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: Text(
        '"${item.name}" cannot be recovered.',
        style: TextStyle(color: Colors.grey.shade500),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            manager.deleteForever(item);
          },
          child: Text('Delete', style: TextStyle(color: Colors.grey.shade300)),
        ),
      ],
    ),
  );
}

void _confirmEmpty(BuildContext context, Dirmanager manager) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.dialog,
      title: const Text(
        'Empty trash?',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: Text(
        'All items will be permanently deleted.',
        style: TextStyle(color: Colors.grey.shade500),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            manager.emptyTrash();
          },
          child: Text('Empty', style: TextStyle(color: Colors.grey.shade300)),
        ),
      ],
    ),
  );
}

class TrashView extends StatelessWidget {
  const TrashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, manager, child) {
        final items = manager.trashItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Trash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () => _confirmEmpty(context, manager),
                      child: Text(
                        'Empty all',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade800),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Trash is empty',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : manager.isGrid
                      ? _TrashGrid(items: items)
                      : _TrashList(items: items),
            ),
          ],
        );
      },
    );
  }
}

class _TrashList extends StatelessWidget {
  final List<TrashItem> items;

  const _TrashList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 56,
        color: Colors.grey.shade900,
      ),
      itemBuilder: (context, index) => _TrashTile(item: items[index]),
    );
  }
}

class _TrashGrid extends StatelessWidget {
  final List<TrashItem> items;

  const _TrashGrid({required this.items});

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
      itemCount: items.length,
      itemBuilder: (context, index) => _TrashGridItem(item: items[index]),
    );
  }
}

class _TrashTile extends StatelessWidget {
  final TrashItem item;

  const _TrashTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDir = item.entity is Directory;

    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      leading: Icon(
        isDir ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
        color: Colors.grey.shade500,
        size: 22,
      ),
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        item.originalPath,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _TrashMenu(item: item),
    );
  }
}

class _TrashGridItem extends StatelessWidget {
  final TrashItem item;

  const _TrashGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDir = item.entity is Directory;

    return Material(
      color: Colors.transparent,
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
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: _TrashMenu(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashMenu extends StatelessWidget {
  final TrashItem item;

  const _TrashMenu({required this.item});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<Dirmanager>();

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Colors.grey.shade500, size: 20),
      color: AppTheme.menu,
      onSelected: (value) {
        switch (value) {
          case 'restore':
            manager.restoreFromTrash(item);
          case 'delete':
            _confirmDeleteForever(context, manager, item);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'restore',
          child: Text('Restore', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete permanently',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }
}
