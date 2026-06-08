import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/FileContextMenu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Grid extends StatelessWidget {
  final List<FileSystemEntity> entities;
  const Grid({super.key, required this.entities});

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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
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
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => manager.selectEntity(entity),
                    onDoubleTap: () {
                      if (entity is Directory) {
                        if (entity.path == manager.homeDir.path) {
                          manager.goToDashboard();
                        } else {
                          manager.navigateTo(entity);
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.grey[800]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            entity is Directory
                                ? Icons.folder
                                : Icons.feed_outlined,
                            color: entity is Directory
                                ? Colors.blue
                                : Colors.grey,
                            size: 50,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.key,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
