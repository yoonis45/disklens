import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Service/FileOperations.dart';
import 'package:disklens/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Rename extends StatefulWidget {
  final FileSystemEntity entity;
  final String name;

  const Rename({super.key, required this.entity, required this.name});

  @override
  State<Rename> createState() => _RenameState();
}

class _RenameState extends State<Rename> {
  late final TextEditingController controller;
  String? errorText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _isValidName(String name) {
    const invalid = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    return !invalid.any(name.contains);
  }

  Future<void> submit() async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() => errorText = 'Name cannot be empty');
      return;
    }

    if (!_isValidName(name)) {
      setState(() => errorText = 'Name contains invalid characters');
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      await context.read<Dirmanager>().rename(
            FileOperations.parentDirectory(widget.entity.path),
            widget.name,
            name,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorText = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.dialog,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Rename',
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
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: const TextStyle(color: Colors.grey),
                errorText: errorText,
                filled: true,
                fillColor: AppTheme.inputFill,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 42,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Rename'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
