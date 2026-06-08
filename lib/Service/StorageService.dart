import 'dart:io';

import 'package:disklens/Service/FileOperations.dart';
import 'package:flutter/material.dart';

class StorageCategory {
  final String name;
  final int bytes;

  const StorageCategory({required this.name, required this.bytes});

  double get gb => bytes / (1024 * 1024 * 1024);

  String get formattedSize {
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
  final List<StorageCategory> topCategories;

  const StorageStats({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
    required this.topCategories,
  });

  static const empty = StorageStats(
    totalBytes: 0,
    usedBytes: 0,
    freeBytes: 0,
    topCategories: [],
  );

  double get usedFraction => totalBytes > 0 ? usedBytes / totalBytes : 0;

  double bytesToGb(int bytes) => bytes / (1024 * 1024 * 1024);
}

class StorageService {
  // Muted greys for a minimal look — slight variation only
  static Color barColorAt(int index) {
    const shades = [
      Color(0xFFE0E0E0),
      Color(0xFFB0B0B0),
      Color(0xFF909090),
      Color(0xFF707070),
      Color(0xFF505050),
    ];
    return shades[index.clamp(0, shades.length - 1)];
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
        topCategories: const [],
      );
    } catch (_) {
      return StorageStats.empty;
    }
  }

  /// Uses `du` on each top-level item in home — fast and accurate on Linux.
  static Future<List<StorageCategory>> scanDynamicCategories(
    Directory root, {
    int topN = 4,
  }) async {
    final buckets = <String, int>{};

    if (!root.existsSync()) return [];

    await for (final entity in root.list(followLinks: false)) {
      final name = FileOperations.basename(entity.path);
      if (name.startsWith('.')) continue;

      final bytes = await _duSize(entity.path);
      if (bytes > 0) {
        buckets[name] = bytes;
      }
    }

    return _topCategories(buckets, topN: topN);
  }

  static Future<int> _duSize(String path) async {
    try {
      final result = await Process.run('du', ['-sb', path]);
      if (result.exitCode != 0) return 0;

      final line = (result.stdout as String).trim().split('\n').first;
      final tab = line.indexOf('\t');
      if (tab <= 0) return 0;

      return int.tryParse(line.substring(0, tab)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static List<StorageCategory> _topCategories(
    Map<String, int> buckets, {
    required int topN,
  }) {
    final sorted = buckets.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) return [];

    final top = sorted.take(topN).map((e) => StorageCategory(
          name: e.key,
          bytes: e.value,
        )).toList();

    final otherBytes = sorted
        .skip(topN)
        .fold<int>(0, (sum, e) => sum + e.value);

    if (otherBytes > 0) {
      top.add(StorageCategory(name: 'Other', bytes: otherBytes));
    }

    return top;
  }
}
