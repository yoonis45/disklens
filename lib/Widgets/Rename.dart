import 'dart:io';

import 'package:disklens/Provider/DirManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Rename extends StatefulWidget {
  final Directory path;
  final name;
  const Rename({super.key, required this.path, required this.name});

  @override
  State<Rename> createState() => _RenameState();
}

class _RenameState extends State<Rename> {
  final TextEditingController controller = TextEditingController();

  String? errorText;
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> createFolder() async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        errorText = "Folder name cannot be empty";
      });
      return;
    }

    if (name.contains("/") ||
        name.contains("\\") ||
        name.contains(":") ||
        name.contains("*") ||
        name.contains("?") ||
        name.contains('"') ||
        name.contains("<") ||
        name.contains(">") ||
        name.contains("|")) {
      setState(() {
        errorText = "Folder name contains invalid characters";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      context.read<Dirmanager>().Rename(widget.path.parent, widget.name, name);
      print(
        "${widget.path.parent.path}/${widget.name} to ${widget.path.parent.path}/${name}",
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF232327),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Rename",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => createFolder(),
              decoration: InputDecoration(
                hintText: "Name",
                hintStyle: const TextStyle(color: Colors.grey),
                errorText: errorText,
                filled: true,
                fillColor: const Color(0xFF121214),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: 150,
                height: 42,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createFolder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Rename"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
