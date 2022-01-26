import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestisce l'accesso e l'interrogazione delle [SharedPreferences]
class Preferences {
  Preferences._() {
    _secureStorage = const FlutterSecureStorage();
  }

  /// Restituisce un [Future] che conclude quanto l'inizializzazione è terminata
  static Future<Preferences> get instance async {
    final instance = Preferences._();
    await instance._init();
    return instance;
  }

  /// Punto di accesso al secure storage
  FlutterSecureStorage _secureStorage;

  /// Inizializza il secure storage e, in caso di prima run, cancella
  /// tutti i dati dalla memoria sicura
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      debugPrint('Deleting everything from secure storage');
      _secureStorage.deleteAll();
      prefs.setBool('first_run', false);
    }
  }

  /// Elimina tutto il contenuto del [SecureStorage]
  Future<void> cleanSecureStorage() async => _secureStorage.deleteAll();

  /// Salva i dati [data] nella [SecureStorage] sotto la chiave [key]
  Future<void> secureSave(String key, String data) async =>
      _secureStorage.write(key: key, value: data);

  /// Recupera i dati salvati in precedenza sotto la chiave [key]
  Future<String> getFromKey(String key) async => _secureStorage.read(key: key);

  /// Controlla se la chiave [key] sia contenuta o meno all'interno del
  /// [FlutterSecureStorage]
  ///
  /// Dev'essere utilizzato prima della [getFromKey] per evitare eccezzioni
  /// del tipo `BadDecrypt`
  Future<bool> containsKey(String key) => _secureStorage.containsKey(key: key);
}
