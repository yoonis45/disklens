import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/FileContextMenu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileList extends StatelessWidget {
  final List<FileSystemEntity> entities;

  const FileList({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    return Consumer<Dirmanager>(
      builder: (context, manager, child) {
        final entries = manager.trimPath(entities).entries.toList();

        return GestureDetector(
          onSecondaryTapUp: (details) {
            FileContextMenu.show(
              context: context,
              position: details.globalPosition,
              backgroundMenu: true,
            );
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final entity = entry.value;
              final isSelected = manager.selectedEntity?.path == entity.path;

              return GestureDetector(
                onSecondaryTapUp: (details) {
                  FileContextMenu.show(
                    context: context,
                    position: details.globalPosition,
                    target: entity,
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => manager.selectEntity(entity),
                    onDoubleTap: () {
                      if (entity is Directory) {
                        manager.navigateTo(entity);
                      }
                    },
                    child: ListTile(
                      dense: true,
                      tileColor: Colors.transparent,
                      selected: isSelected,
                      selectedTileColor: Colors.grey[800],
                      leading: Icon(
                        entity is Directory
                            ? Icons.folder_outlined
                            : Icons.insert_drive_file_outlined,
                        color: entity is Directory
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        entity.path,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
