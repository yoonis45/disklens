import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:disklens/Widgets/Properties.dart';
import 'package:disklens/Widgets/Rename.dart';
import 'package:disklens/Widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileContextMenu {
  static Future<void> show({
    required BuildContext context,
    required Offset position,
    FileSystemEntity? target,
    bool backgroundMenu = false,
  }) async {
    final manager = context.read<Dirmanager>();
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    if (target != null) {
      manager.selectEntity(target);
    }

    await showMenu<String>(
      context: context,
      color: AppTheme.menu,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: _buildItems(
        context: context,
        manager: manager,
        target: target,
        backgroundMenu: backgroundMenu,
      ),
    );
  }

  static List<PopupMenuEntry<String>> _buildItems({
    required BuildContext context,
    required Dirmanager manager,
    FileSystemEntity? target,
    required bool backgroundMenu,
  }) {
    final items = <PopupMenuEntry<String>>[];

    void addItem({
      required String label,
      String? shortcut,
      required VoidCallback onTap,
      bool enabled = true,
    }) {
      items.add(
        PopupMenuItem<String>(
          enabled: enabled,
          onTap: enabled ? () => Future.microtask(onTap) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: enabled ? Colors.white : Colors.grey),
              ),
              if (shortcut != null)
                Text(
                  shortcut,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
      );
    }

    final dest = manager.pasteTarget(clicked: target);

    addItem(
      label: 'New Folder',
      shortcut: 'Ctrl+Shift+N',
      onTap: () => _showNewFolderDialog(context, manager.newFolderTarget()),
    );

    if (!backgroundMenu && target != null) {
      addItem(label: 'Copy', shortcut: 'Ctrl+C', onTap: manager.copySelection);
      addItem(label: 'Cut', shortcut: 'Ctrl+X', onTap: manager.cutSelection);
      addItem(
        label: 'Rename',
        shortcut: 'F2',
        onTap: () => _showRenameDialog(context, target),
      );
      addItem(
        label: 'Delete',
        shortcut: 'Delete',
        onTap: () => manager.deleteSelection(),
      );
      addItem(
        label: 'Properties',
        shortcut: 'Alt+Enter',
        onTap: () => _showPropertiesDialog(context, target),
      );

      if (target is Directory) {
        final isFav = manager.isFavorite(target.path);
        addItem(
          label: isFav ? 'Remove from Favorites' : 'Add to Favorites',
          onTap: () {
            if (isFav) {
              manager.removeFavorite(target.path);
            } else {
              manager.addFavorite(target.path);
            }
          },
        );
      }
    }

    addItem(
      label: 'Paste',
      shortcut: 'Ctrl+V',
      enabled: manager.hasClipboard,
      onTap: () => manager.pasteInto(dest),
    );

    return items;
  }

  static void _showNewFolderDialog(BuildContext context, Directory parent) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => Popup(parent: parent),
    );
  }

  static void _showRenameDialog(BuildContext context, FileSystemEntity entity) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => Rename(
        entity: entity,
        name: entity.path.split('/').last,
      ),
    );
  }

  static void _showPropertiesDialog(
    BuildContext context,
    FileSystemEntity entity,
  ) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => Properties(entity: entity),
    );
  }
}
