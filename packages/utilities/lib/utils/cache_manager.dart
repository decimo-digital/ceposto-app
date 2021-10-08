// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const _defaultTtlDays = 15;

class MyCacheManager {
  factory MyCacheManager() => _instance;
  MyCacheManager._internal() {
    _cacheManager = CacheManager(
      Config(
        'toduba_cache',
        stalePeriod: const Duration(days: _defaultTtlDays),
      ),
    );
  }
  static final MyCacheManager _instance = MyCacheManager._internal();

  late CacheManager _cacheManager;

  void saveString(String key, String content) =>
      _cacheManager.putFile(key, utf8.encode(content) as Uint8List);

  Future<String?> getString(String key) async {
    final fileinfo = await _cacheManager.getFileFromCache(key);
    if (fileinfo == null) return null;
    final bytes = await fileinfo.file.readAsBytes();
    return utf8.decode(bytes);
  }

  /// Cancella il file salvato in cache con la chiave
  /// [key]
  Future<void> remove(String key) => _cacheManager.removeFile(key);
}
