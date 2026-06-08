import 'dart:io';

import 'package:disklens/Service/FileOperations.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';

class Properties extends StatefulWidget {
  final FileSystemEntity entity;

  const Properties({super.key, required this.entity});

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  int? sizeBytes;
  bool isLoadingSize = true;
  String? statError;
  FileStat? stat;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      stat = widget.entity.statSync();
    } catch (e) {
      statError = 'Could not read file info';
    }

    try {
      final bytes = await FileOperations.entitySize(widget.entity);
      if (mounted) {
        setState(() {
          sizeBytes = bytes;
          isLoadingSize = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoadingSize = false;
          sizeBytes = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = FileOperations.basename(widget.entity.path);
    final type = widget.entity is Directory ? 'Folder' : 'File';

    return Dialog(
      backgroundColor: AppTheme.dialog,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.entity is Directory
                      ? Icons.folder
                      : Icons.insert_drive_file_outlined,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Properties',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row('Name', name),
            _row('Location', widget.entity.path),
            _row('Type', type),
            _row(
              'Size',
              isLoadingSize
                  ? 'Calculating...'
                  : FileOperations.formatBytes(sizeBytes ?? 0),
            ),
            if (stat != null) ...[
              _row(
                'Modified',
                stat!.modified.toLocal().toString().split('.').first,
              ),
              _row(
                'Permissions',
                FileOperations.formatPermissions(stat!.mode),
              ),
            ],
            if (statError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(statError!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
