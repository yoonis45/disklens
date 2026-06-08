import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/Widgets/Properties.dart';
import 'package:disklens/Widgets/Rename.dart';
import 'package:disklens/Widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Wraps the file content area and handles keyboard shortcuts.
/// Must wrap only the file pane — not the path text field — so Ctrl+C/V
/// aren't swallowed by the text input.
class FileShortcutHandler extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;

  const FileShortcutHandler({
    super.key,
    required this.child,
    required this.focusNode,
  });

  @override
  State<FileShortcutHandler> createState() => _FileShortcutHandlerState();
}

class _FileShortcutHandlerState extends State<FileShortcutHandler> {
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final manager = context.read<Dirmanager>();
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final alt = HardwareKeyboard.instance.isAltPressed;
    final key = event.logicalKey;

    if (ctrl && key == LogicalKeyboardKey.keyC) {
      manager.copySelection();
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyX) {
      manager.cutSelection();
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyV) {
      manager.pasteInto(manager.parent);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete) {
      manager.deleteSelection();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.f2) {
      _showRename(manager);
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isShiftPressed) {
      _showNewFolder(manager);
      return KeyEventResult.handled;
    }
    if (alt && key == LogicalKeyboardKey.enter) {
      _showProperties(manager);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _showRename(Dirmanager manager) {
    final entity = manager.selectedEntity;
    if (entity == null) return;
    showDialog(
      context: context,
      builder: (_) => Rename(
        entity: entity,
        name: entity.path.split('/').last,
      ),
    );
  }

  void _showNewFolder(Dirmanager manager) {
    showDialog(
      context: context,
      builder: (_) => Popup(parent: manager.newFolderTarget()),
    );
  }

  void _showProperties(Dirmanager manager) {
    final entity = manager.selectedEntity;
    if (entity == null) return;
    showDialog(
      context: context,
      builder: (_) => Properties(entity: entity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      behavior: HitTestBehavior.translucent,
      child: Focus(
        focusNode: widget.focusNode,
        onKeyEvent: _handleKey,
        child: widget.child,
      ),
    );
  }
}
