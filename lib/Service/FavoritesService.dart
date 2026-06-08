import 'dart:convert';
import 'dart:io';

class FavoritesService {
  static File get _configFile {
    final home = Platform.environment['HOME']!;
    final dir = Directory('$home/.config/disklens');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File('${dir.path}/favorites.json');
  }

  static Future<List<String>> load() async {
    try {
      final file = _configFile;
      if (!file.existsSync()) return [];
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return data.cast<String>().where((p) => Directory(p).existsSync() || File(p).existsSync()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<String> paths) async {
    await _configFile.writeAsString(jsonEncode(paths));
  }
}
