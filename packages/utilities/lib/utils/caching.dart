import 'dart:convert';

import 'package:utilities/interfaces/serializable.dart';
import 'package:utilities/utils/cache_manager.dart';

/// Viene richiamato ogni volta che viene
/// ricaricata una nuova pagina
///
/// Ha come parametri `(numero_di_pagina_attuale, lista_degli_elementi)`
typedef SavingCallback<T> = void Function(int, List<T>);

/// Viene richiamato ogni volta che si ricarica il [Widget]
typedef LoadingCallback<T> = Future<List<T>> Function();

/// Deserializzatore custom per il [CustomCaching]
///
/// Necessario per deserializzare da json a un oggetto `T`
typedef Deserializer<T> = T Function(Map<String, dynamic>);

/// Permette di definire facilmente dei sistemi di caching
///
/// Utilizzata nel caso della [PagingListview] per salvare
/// in cache i dati caricati man mano
///
/// Le implementazioni sono:
/// - [MemoryCaching] -> salva i dati nella cache del device con un delay custom
/// - [CustomCaching] -> permette di definire delle
/// funzioni `onSave` e `onLoad` custom per avere il massimo della flessibilità
abstract class Caching<T extends Serializable> {
  /// Viene richiamato ogni volta che viene
  /// ricaricata una nuova pagina
  ///
  /// Ha come parametri `(numero_di_pagina_attuale, lista_degli_elementi)`
  void onSave(int page, List<T> item);

  /// Viene richiamato ogni volta che si ricarica il [Widget]
  Future<List<T>> onLoad();
}

/// Salva gli elementi all'interno della cache del device
class MemoryCaching<T extends Serializable> with Caching<T> {
  // ignore: public_member_api_docs
  MemoryCaching({
    required this.cacheKey,
    required this.deserializer,
    this.cacheTtl = const Duration(minutes: 10),
  }) : _cacheManager = MyCacheManager();

  /// Viene richiamata dopo che è stato caricato il json dalla memoria interna
  ///
  /// Deve mappare il [JsonObject] salvato in cache all'oggetto vero e proprio
  final Deserializer<T> deserializer;

  /// Specifica per quanto tempo mantenere validi i dati in cache
  final Duration cacheTtl;

  /// Specifica la chiave sotto la quale salvare i dati
  final String cacheKey;

  final MyCacheManager _cacheManager;

  @override
  Future<List<T>> onLoad() async {
    final data =
        jsonDecode(await _cacheManager.getString(cacheKey) ?? '{}') as Map;
    if (data.isEmpty) return [];

    final expiration =
        DateTime.fromMillisecondsSinceEpoch(data['expiration'] as int);
    if (expiration.isBefore(DateTime.now())) return [];

    return (data['data'] as List<dynamic>)
        .map((e) => deserializer(e as Map<String, dynamic>))
        .toList();
  }

  @override
  void onSave(int page, List<T> item) {
    final toSave = item.map((e) => e.toMap()).toList();
    _cacheManager.saveString(
      cacheKey,
      jsonEncode({
        'expiration':
            DateTime.now().millisecondsSinceEpoch + cacheTtl.inMilliseconds,
        'data': toSave,
      }),
    );
  }
}

/// Permette di avere più flessibilità sul salvataggio
/// e caricamento dei dati salvati
class CustomCaching<T extends Serializable> with Caching<T> {
  // ignore: public_member_api_docs
  CustomCaching.fromFunctions({
    required this.loadCallback,
    required this.saveCallback,
  });

  /// Viene richiamato ogni volta che viene
  /// ricaricata una nuova pagina
  ///
  /// Ha come parametri `(numero_di_pagina_attuale, lista_degli_elementi)`
  final SavingCallback<T> saveCallback;

  /// Viene richiamato ogni volta che si ricarica il [Widget]
  final LoadingCallback<T> loadCallback;

  @override
  Future<List<T>> onLoad() async => loadCallback();

  @override
  void onSave(int page, List<T> item) => saveCallback(page, item);
}
