import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/Rename.dart';
import 'package:disklens/Widgets/popup.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Grid extends StatefulWidget {
  final List<FileSystemEntity> Entities;
  const Grid({super.key, required this.Entities});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  dynamic selectedPath;
  @override
  Widget build(BuildContext context) {
    // final service srv = service();

    Map Trimed_Entities = Dirmanager().TrimPath(widget.Entities);
    final entries = Trimed_Entities.entries.toList();

    return Consumer<Dirmanager>(
      builder: (context, Dirmanager, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),

          itemCount: entries
              .length, // change it to dynamic now we only have the non dot starters
          itemBuilder: (BuildContext context, int index) {
            return Listener(
              onPointerDown: (event) {
                if (event.buttons == kSecondaryMouseButton) {
                  final overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  setState(() {
                    selectedPath = entries[index].value;
                    Dirmanager.update_selected_path(selectedPath);
                  });

                  showMenu(
                    context: context,
                    color: Color.fromARGB(255, 35, 35, 39),
                    position: RelativeRect.fromRect(
                      Rect.fromPoints(event.position, event.position),
                      Offset.zero & overlay.size,
                    ),
                    menuPadding: EdgeInsets.all(10),
                    items: [
                      PopupMenuItem(
                        value: 'New Folder',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('New Folder'),
                            Text(
                              'Ctrl + Shift + N',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Popup(path: entries[index].value);
                            },
                          );
                        },
                      ),

                      PopupMenuItem(
                        value: 'Copy',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Copy'),
                            Text(
                              'Ctrl + C',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          print(entries[index].key);
                        },
                      ),
                      PopupMenuItem(
                        value: 'Paste',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paste'),
                            Text(
                              'Ctrl + V',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          print(entries[index].key);
                        },
                      ),
                      PopupMenuItem(
                        value: 'Move',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Move'),
                            Text(
                              'Cltr + X',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          print(entries[index].key);
                        },
                      ),
                      PopupMenuItem(
                        value: 'Rename',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rename'),
                            Text('F2', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Rename(
                                path: entries[index].value,
                                name: entries[index].key,
                              );
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                        value: 'Delete',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delete'),
                            Text(
                              'delete',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          Dirmanager.Delete(entries[index].value);
                        },
                      ),
                      PopupMenuItem(
                        value: 'Proberties',
                        child: const Text('Proberties'),
                        onTap: () {
                          print(entries[index].key);
                        },
                      ),
                    ],
                  );
                }
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      selectedPath = entries[index].value;
                      Dirmanager.update_selected_path(selectedPath);
                    });
                  },
                  onDoubleTap: () {
                    if (entries[index].value is Directory) {
                      if (entries[index].value.path ==
                          Dirmanager.homeDir.path) {
                        print("solved");
                        Dirmanager.Go_To_Dashboard();
                      } else {
                        print("Meeh");
                        Dirmanager.navigate_to(entries[index].value);
                        Dirmanager.parent = entries[index].value;
                      }
                    } else {
                      print("its not dir ");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedPath == entries[index].value
                          ? Colors.grey[800]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entries[index].value is Directory
                              ? Icons.folder
                              : Icons.feed_outlined,
                          color: entries[index].value is Directory
                              ? Colors.blue
                              : Colors.grey,
                          size: 50,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          entries[index].key,
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
        );
      },
    );
  }
}
