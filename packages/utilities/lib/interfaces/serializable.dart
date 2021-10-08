/// Aggiunge i metodi [toMap] e [from] per serializzare e deserializzare
/// gli elementi che possono essere salvati in cache
mixin Serializable {
  /// Deve serializzare l'oggetto in una mappa corrispondente
  Map<String, dynamic> toMap();
}

/// Aggiunge la funzione di `match` per effettuare delle ricerche sull'elemento
mixin Searchable {
  /// Deve fornire un criterio di query data una [query]
  bool match(String query);
}

/// Classe astratta per gli oggetti da mettere nella [PagingListview]
abstract class ForPaging with Searchable, Serializable {}
