import 'dart:io';

class FileOperations {
  static String basename(String path) {
    if (path.isEmpty) return path;
    return path.split('/').last;
  }

  static Directory parentDirectory(String path) {
    final index = path.lastIndexOf('/');
    if (index <= 0) return Directory('/');
    return Directory(path.substring(0, index));
  }

  static String uniqueName(Directory destDir, String baseName) {
    var name = baseName;
    var counter = 1;
    final dot = baseName.lastIndexOf('.');
    final hasExt = dot > 0;
    final stem = hasExt ? baseName.substring(0, dot) : baseName;
    final ext = hasExt ? baseName.substring(dot) : '';

    while (FileSystemEntity.typeSync('${destDir.path}/$name') !=
        FileSystemEntityType.notFound) {
      name = '$stem ($counter)$ext';
      counter++;
    }
    return name;
  }

  static Future<void> copyEntity(
    FileSystemEntity source,
    Directory destDir,
  ) async {
    final name = uniqueName(destDir, basename(source.path));
    final destPath = '${destDir.path}/$name';

    if (source is File) {
      await source.copy(destPath);
    } else if (source is Directory) {
      final dest = Directory(destPath);
      await dest.create(recursive: true);
      await for (final child in source.list(followLinks: false)) {
        await copyEntity(child, dest);
      }
    }
  }

  static Future<void> moveEntity(
    FileSystemEntity source,
    Directory destDir,
  ) async {
    final name = uniqueName(destDir, basename(source.path));
    final destPath = '${destDir.path}/$name';

    try {
      await source.rename(destPath);
    } on FileSystemException {
      await copyEntity(source, destDir);
      await source.delete(recursive: true);
    }
  }

  static Future<void> moveToTrash(FileSystemEntity entity) async {
    final home = Platform.environment['HOME'];
    if (home == null) {
      throw Exception('HOME not set');
    }

    final trashFiles = Directory('$home/.local/share/Trash/files');
    final trashInfo = Directory('$home/.local/share/Trash/info');

    if (!trashFiles.existsSync()) {
      trashFiles.createSync(recursive: true);
    }
    if (!trashInfo.existsSync()) {
      trashInfo.createSync(recursive: true);
    }

    final baseName = basename(entity.path);
    final unique = uniqueName(trashFiles, baseName);
    final trashPath = '${trashFiles.path}/$unique';
    final originalPath = entity.path;

    await entity.rename(trashPath);

    final infoFile = File('${trashInfo.path}/$unique.trashinfo');
    final deletionDate = DateTime.now().toUtc().toIso8601String();
    await infoFile.writeAsString(
      '[Trash Info]\n'
      'Path=$originalPath\n'
      'DeletionDate=$deletionDate\n',
    );
  }

  static Future<int> directorySize(Directory dir) async {
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  static Future<int> entitySize(FileSystemEntity entity) async {
    if (entity is File) {
      return entity.length();
    }
    if (entity is Directory) {
      return directorySize(entity);
    }
    return 0;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatPermissions(int mode) {
    String triplet(int value) {
      return '${(value & 4) != 0 ? 'r' : '-'}'
          '${(value & 2) != 0 ? 'w' : '-'}'
          '${(value & 1) != 0 ? 'x' : '-'}';
    }

    final perm = mode & 0xFFF;
    return '${triplet(perm >> 6)}${triplet(perm >> 3)}${triplet(perm)} '
        '(${perm.toRadixString(8)})';
  }
}
