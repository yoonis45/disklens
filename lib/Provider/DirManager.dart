import 'package:disklens/Service/FavoritesService.dart';
import 'package:disklens/Service/FileOperations.dart';
import 'package:disklens/Service/StorageService.dart';
import 'package:disklens/Service/TrashService.dart';
import 'package:flutter/material.dart';
import 'dart:io';

enum ClipboardOp { copy, cut }

enum AppView { home, favorites, trash, browse }

class Dirmanager extends ChangeNotifier {
  final home = Platform.environment['HOME'];
  late Directory homeDir = Directory(home!);
  late Directory downloads = Directory("${home!}/Downloads");
  late Directory documents = Directory("${home!}/Documents");
  late Directory pictures = Directory("${home!}/Pictures");
  late Directory trashDir = Directory("${home!}/.local/share/Trash/files");

  AppView currentView = AppView.home;
  Directory parent = Directory("");
  List<FileSystemEntity> entities = [];
  Directory selectedPath = Directory("");

  FileSystemEntity? selectedEntity;
  List<FileSystemEntity> clipboard = [];
  ClipboardOp? clipboardOp;

  List<String> favoritePaths = [];
  List<TrashItem> trashItems = [];

  bool isGrid = true;
  bool showHidden = false;
  bool isLoading = false;
  bool isStorageLoading = false;
  String? lastError;
  String? lastMessage;

  StorageStats storageStats = StorageStats.empty;

  bool get isAtHome => currentView == AppView.home && parent.path == homeDir.path;
  bool get hasClipboard => clipboard.isNotEmpty && clipboardOp != null;

  bool isFavorite(String path) => favoritePaths.contains(path);

  void toggle() {
    isGrid = !isGrid;
    notifyListeners();
  }

  void selectEntity(FileSystemEntity? entity) {
    selectedEntity = entity;
    if (entity is Directory) {
      selectedPath = entity;
    }
    notifyListeners();
  }

  void clearFeedback() {
    lastError = null;
    lastMessage = null;
  }

  void setError(String message) {
    lastError = message;
    lastMessage = null;
    notifyListeners();
  }

  List<FileSystemEntity> _applyHiddenFilter(List<FileSystemEntity> list) {
    if (showHidden) return list;
    return list
        .where((e) => !FileOperations.basename(e.path).startsWith('.'))
        .toList();
  }

  Map<String, FileSystemEntity> trimPath(List<FileSystemEntity> list) {
    final result = <String, FileSystemEntity>{};
    for (final entity in list) {
      result[FileOperations.basename(entity.path)] = entity;
    }
    return result;
  }

  Future<void> refreshCurrentDirectory() async {
    if (currentView == AppView.favorites || currentView == AppView.trash) return;
    if (!parent.existsSync()) return;

    isLoading = true;
    notifyListeners();

    try {
      final listed = await parent.list(followLinks: false).toList();
      entities = _applyHiddenFilter(listed);
    } catch (e) {
      lastError = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> goToDashboard() async {
    currentView = AppView.home;
    parent = homeDir;
    selectedEntity = null;
    await refreshCurrentDirectory();
    await loadStorageStats();
  }

  Future<void> openFavorites() async {
    currentView = AppView.favorites;
    selectedEntity = null;
    await loadFavorites();
    notifyListeners();
  }

  Future<void> openTrash() async {
    currentView = AppView.trash;
    selectedEntity = null;
    await loadTrash();
    notifyListeners();
  }

  Future<void> navigateTo(Directory dirPath) async {
    if (!dirPath.existsSync()) return;
    currentView = AppView.browse;
    parent = dirPath;
    selectedEntity = null;
    await refreshCurrentDirectory();
    if (dirPath.path == homeDir.path) {
      currentView = AppView.home;
      await loadStorageStats();
    }
  }

  void showHiddenFiles(bool value) {
    showHidden = value;
    refreshCurrentDirectory();
  }

  Future<void> initHome(Directory homeDirectory) async {
    parent = homeDirectory;
    currentView = AppView.home;
    showHidden = false;
    await loadFavorites();
    await refreshCurrentDirectory();
    await loadStorageStats();
  }

  Future<void> loadFavorites() async {
    favoritePaths = await FavoritesService.load();
    notifyListeners();
  }

  Future<void> addFavorite(String path) async {
    if (favoritePaths.contains(path)) {
      lastMessage = 'Already in favorites';
      notifyListeners();
      return;
    }
    favoritePaths = [...favoritePaths, path];
    await FavoritesService.save(favoritePaths);
    lastMessage = 'Added to favorites';
    lastError = null;
    notifyListeners();
  }

  Future<void> removeFavorite(String path) async {
    favoritePaths = favoritePaths.where((p) => p != path).toList();
    await FavoritesService.save(favoritePaths);
    lastMessage = 'Removed from favorites';
    lastError = null;
    notifyListeners();
  }

  Future<void> loadTrash() async {
    isLoading = true;
    notifyListeners();
    trashItems = await TrashService.listItems();
    isLoading = false;
    notifyListeners();
  }

  Future<void> restoreFromTrash(TrashItem item) async {
    isLoading = true;
    notifyListeners();
    try {
      await TrashService.restore(item);
      lastMessage = 'Restored ${item.name}';
      lastError = null;
      await loadTrash();
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteForever(TrashItem item) async {
    isLoading = true;
    notifyListeners();
    try {
      await TrashService.deletePermanently(item);
      lastMessage = 'Permanently deleted ${item.name}';
      lastError = null;
      await loadTrash();
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> emptyTrash() async {
    isLoading = true;
    notifyListeners();
    try {
      await TrashService.emptyTrash();
      lastMessage = 'Trash emptied';
      lastError = null;
      await loadTrash();
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStorageStats() async {
    isStorageLoading = true;
    notifyListeners();

    try {
      final disk = await StorageService.getDiskStats(homeDir.path);
      storageStats = disk;
      notifyListeners();

      final categories = await StorageService.scanDynamicCategories(
        homeDir,
        topN: 4,
      );
      storageStats = StorageStats(
        totalBytes: disk.totalBytes,
        usedBytes: disk.usedBytes,
        freeBytes: disk.freeBytes,
        topCategories: categories,
      );
    } catch (e) {
      lastError = 'Storage scan failed: $e';
    }

    isStorageLoading = false;
    notifyListeners();
  }

  void copySelection() {
    if (selectedEntity == null) {
      lastError = 'Nothing selected';
      notifyListeners();
      return;
    }
    clipboard = [selectedEntity!];
    clipboardOp = ClipboardOp.copy;
    lastMessage = 'Copied ${FileOperations.basename(selectedEntity!.path)}';
    lastError = null;
    notifyListeners();
  }

  void cutSelection() {
    if (selectedEntity == null) {
      lastError = 'Nothing selected';
      notifyListeners();
      return;
    }
    clipboard = [selectedEntity!];
    clipboardOp = ClipboardOp.cut;
    lastMessage = 'Cut ${FileOperations.basename(selectedEntity!.path)}';
    lastError = null;
    notifyListeners();
  }

  Future<void> pasteInto(Directory destDir) async {
    if (!hasClipboard) {
      lastError = 'Clipboard is empty';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      for (final item in clipboard) {
        if (!item.existsSync()) {
          throw Exception('Source no longer exists');
        }
        if (clipboardOp == ClipboardOp.copy) {
          await FileOperations.copyEntity(item, destDir);
        } else {
          await FileOperations.moveEntity(item, destDir);
        }
      }

      if (clipboardOp == ClipboardOp.cut) {
        clipboard = [];
        clipboardOp = null;
        selectedEntity = null;
      }

      lastMessage = 'Pasted successfully';
      lastError = null;
      if (currentView == AppView.trash) {
        await loadTrash();
      } else {
        await refreshCurrentDirectory();
      }
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelection() async {
    if (selectedEntity == null) {
      lastError = 'Nothing selected';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await FileOperations.moveToTrash(selectedEntity!);
      selectedEntity = null;
      lastMessage = 'Moved to Trash';
      lastError = null;
      await refreshCurrentDirectory();
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(Directory path, String name) async {
    final folderPath = '${path.path}/$name';
    final newFolder = Directory(folderPath);

    if (newFolder.existsSync()) {
      throw Exception('Folder already exists');
    }

    await newFolder.create(recursive: true);
    lastMessage = 'Folder created';
    lastError = null;
    await refreshCurrentDirectory();
  }

  Future<void> rename(Directory parentPath, String oldName, String newName) async {
    final oldPath = '${parentPath.path}/$oldName';
    final newPath = '${parentPath.path}/$newName';

    if (FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      throw Exception('Name already exists');
    }

    FileSystemEntity entity = File(oldPath);
    if (!entity.existsSync()) {
      entity = Directory(oldPath);
    }

    await entity.rename(newPath);
    selectedEntity = FileSystemEntity.typeSync(newPath) ==
            FileSystemEntityType.directory
        ? Directory(newPath)
        : File(newPath);
    lastMessage = 'Renamed successfully';
    lastError = null;
    await refreshCurrentDirectory();
  }

  Directory pasteTarget({FileSystemEntity? clicked}) {
    if (clicked is Directory) return clicked;
    return parent;
  }

  Directory newFolderTarget() => parent;
}
