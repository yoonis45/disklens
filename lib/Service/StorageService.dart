import 'dart:io';

import 'package:flutter/material.dart';

class StorageCategory {
  final String name;
  final int bytes;
  final Color color;
  final bool isScanning;

  const StorageCategory({
    required this.name,
    required this.bytes,
    required this.color,
    this.isScanning = false,
  });

  StorageCategory copyWith({int? bytes, bool? isScanning}) {
    return StorageCategory(
      name: name,
      bytes: bytes ?? this.bytes,
      color: color,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  double get gb => bytes / (1024 * 1024 * 1024);

  String get formattedSize {
    if (isScanning) return '…';
    if (bytes < 1024) return '0 MB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} MB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${gb.toStringAsFixed(1)} GB';
  }
}

class StorageStats {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final int homeBytes;
  final List<StorageCategory> topCategories;

  const StorageStats({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
    this.homeBytes = 0,
    required this.topCategories,
  });

  static const empty = StorageStats(
    totalBytes: 0,
    usedBytes: 0,
    freeBytes: 0,
    homeBytes: 0,
    topCategories: [],
  );

  StorageStats copyWith({
    int? totalBytes,
    int? usedBytes,
    int? freeBytes,
    int? homeBytes,
    List<StorageCategory>? topCategories,
  }) {
    return StorageStats(
      totalBytes: totalBytes ?? this.totalBytes,
      usedBytes: usedBytes ?? this.usedBytes,
      freeBytes: freeBytes ?? this.freeBytes,
      homeBytes: homeBytes ?? this.homeBytes,
      topCategories: topCategories ?? this.topCategories,
    );
  }

  double get usedFraction => totalBytes > 0 ? usedBytes / totalBytes : 0;

  int get categorizedBytes =>
      topCategories.fold<int>(0, (sum, c) => sum + c.bytes);

  double bytesToGb(int bytes) => bytes / (1024 * 1024 * 1024);
}

class _CategoryDef {
  final String name;
  final Color color;
  final Set<String> folderNames;
  final List<String> extensions;

  const _CategoryDef(
    this.name,
    this.color,
    this.folderNames,
    this.extensions,
  );
}

typedef StorageProgressCallback = void Function(List<StorageCategory> categories);

class StorageService {
  static const _excludeFromFileScan = [
    '.local',
    '.var',
    'snap',
    '.cache',
    '.config',
  ];

  static const _categories = [
    _CategoryDef('Videos', Color(0xFF4B8BF4), {
      'Videos',
      'Movies',
      'Music',
    }, [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.webm',
      '.flv',
      '.wmv',
      '.m4v',
      '.mp3',
      '.flac',
      '.wav',
      '.aac',
      '.ogg',
    ]),
    _CategoryDef('Images', Color(0xFF4CAF50), {
      'Pictures',
      'Photos',
      'Images',
    }, [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
      '.svg',
      '.ico',
      '.heic',
      '.raw',
      '.tiff',
    ]),
    _CategoryDef('Docs', Color(0xFFEAB308), {
      'Documents',
      'Downloads',
      'Desktop',
      'Templates',
      'Public',
    }, [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.odt',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.md',
      '.rtf',
      '.csv',
      '.json',
      '.xml',
      '.html',
      '.zip',
      '.tar',
      '.gz',
      '.7z',
      '.rar',
    ]),
    _CategoryDef('Apps', Color(0xFF9B59B6), {
      '.local',
      '.var',
      'snap',
      '.cache',
    }, []),
  ];

  static List<StorageCategory> placeholderCategories() {
    return [
      for (final def in _categories)
        StorageCategory(
          name: def.name,
          bytes: 0,
          color: def.color,
          isScanning: true,
        ),
    ];
  }

  static Future<StorageStats> getDiskStats(String path) async {
    try {
      final result = await Process.run('df', [
        '-B1',
        '--output=size,used,avail',
        path,
      ]);

      if (result.exitCode != 0) return StorageStats.empty;

      final lines = (result.stdout as String)
          .trim()
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.length < 2) return StorageStats.empty;

      final parts = lines.last.trim().split(RegExp(r'\s+'));
      if (parts.length < 3) return StorageStats.empty;

      return StorageStats(
        totalBytes: int.tryParse(parts[0]) ?? 0,
        usedBytes: int.tryParse(parts[1]) ?? 0,
        freeBytes: int.tryParse(parts[2]) ?? 0,
        topCategories: placeholderCategories(),
      );
    } catch (_) {
      return StorageStats.empty;
    }
  }

  static Future<int> getHomeTotalBytes(Directory home) async {
    if (!home.existsSync()) return 0;
    return _duBytes(home.path);
  }

  /// Scans home by real file types and streams updates as each category finishes.
  static Future<List<StorageCategory>> scanHomeCategories(
    Directory home, {
    StorageProgressCallback? onProgress,
  }) async {
    if (!home.existsSync()) return placeholderCategories();

    final categories = placeholderCategories();
    void emit() => onProgress?.call(categories.map((c) => c).toList());
    emit();

    final appPaths = <String>[];
    for (final name in _categories.last.folderNames) {
      final path = '${home.path}/$name';
      if (Directory(path).existsSync()) appPaths.add(path);
    }

    await Future.wait(
      List.generate(_categories.length, (index) async {
        final def = _categories[index];
        final bytes = def.extensions.isEmpty
            ? await _duBytes(appPaths)
            : await _sumExtensionsInHome(home.path, def.extensions);

        categories[index] = categories[index].copyWith(
          bytes: bytes,
          isScanning: false,
        );
        emit();
      }),
    );

    return categories;
  }

  static Future<int> _duBytes(dynamic paths) async {
    final args = <String>['-sb'];
    if (paths is String) {
      args.add(paths);
    } else if (paths is List<String>) {
      args.addAll(paths);
    } else {
      return 0;
    }

    try {
      final result = await Process.run('du', args);
      if (result.exitCode != 0) return 0;

      var total = 0;
      for (final line in (result.stdout as String).trim().split('\n')) {
        if (line.isEmpty) continue;
        final tab = line.indexOf('\t');
        if (tab <= 0) continue;
        total += int.tryParse(line.substring(0, tab)) ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  static Future<int> _sumExtensionsInHome(
    String homePath,
    List<String> extensions,
  ) async {
    if (extensions.isEmpty) return 0;

    final escapedHome = homePath.replaceAll("'", "'\\''");
    final extTests = extensions.map((e) => "-iname '*$e'").join(' -o ');
    final excludeTests = _excludeFromFileScan
        .map((d) => "-not -path '*/$d/*'")
        .join(' ');

    final script =
        "find '$escapedHome' -xdev -type f $excludeTests "
        "\\( $extTests \\) -printf '%s\\n' 2>/dev/null "
        "| awk '{s+=\$1} END {print s+0}'";

    try {
      final result = await Process.run('bash', ['-c', script]);
      if (result.exitCode != 0) return 0;
      return int.tryParse((result.stdout as String).trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

}
