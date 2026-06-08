import 'dart:io';

import 'package:disklens/Service/FileOperations.dart';

class TrashItem {
  final FileSystemEntity entity;
  final String originalPath;
  final DateTime? deletedAt;

  const TrashItem({
    required this.entity,
    required this.originalPath,
    this.deletedAt,
  });

  String get name => FileOperations.basename(entity.path);
}

class TrashService {
  static Directory get _trashFiles {
    final home = Platform.environment['HOME']!;
    return Directory('$home/.local/share/Trash/files');
  }

  static Directory get _trashInfo {
    final home = Platform.environment['HOME']!;
    return Directory('$home/.local/share/Trash/info');
  }

  static Future<List<TrashItem>> listItems() async {
    final filesDir = _trashFiles;
    if (!filesDir.existsSync()) return [];

    final items = <TrashItem>[];
    await for (final entity in filesDir.list(followLinks: false)) {
      final infoName = '${FileOperations.basename(entity.path)}.trashinfo';
      final infoFile = File('${_trashInfo.path}/$infoName');

      var originalPath = entity.path;
      DateTime? deletedAt;

      if (infoFile.existsSync()) {
        final content = await infoFile.readAsString();
        for (final line in content.split('\n')) {
          if (line.startsWith('Path=')) {
            originalPath = line.substring(5);
          } else if (line.startsWith('DeletionDate=')) {
            deletedAt = DateTime.tryParse(line.substring(13));
          }
        }
      }

      items.add(TrashItem(
        entity: entity,
        originalPath: originalPath,
        deletedAt: deletedAt,
      ));
    }

    items.sort((a, b) {
      final ad = a.deletedAt ?? DateTime(1970);
      final bd = b.deletedAt ?? DateTime(1970);
      return bd.compareTo(ad);
    });

    return items;
  }

  static Future<void> restore(TrashItem item) async {
    final original = item.originalPath;
    final destDir = FileOperations.parentDirectory(original);
    if (!destDir.existsSync()) {
      await destDir.create(recursive: true);
    }

    final destName = FileOperations.basename(original);
    final unique = FileOperations.uniqueName(destDir, destName);
    final destPath = '${destDir.path}/$unique';

    await item.entity.rename(destPath);

    final infoFile = File(
      '${_trashInfo.path}/${item.name}.trashinfo',
    );
    if (infoFile.existsSync()) {
      await infoFile.delete();
    }
  }

  static Future<void> deletePermanently(TrashItem item) async {
    await item.entity.delete(recursive: true);
    final infoFile = File('${_trashInfo.path}/${item.name}.trashinfo');
    if (infoFile.existsSync()) {
      await infoFile.delete();
    }
  }

  static Future<void> emptyTrash() async {
    final items = await listItems();
    for (final item in items) {
      await deletePermanently(item);
    }
  }
}
