// ignore_for_file: public_member_api_docs

class Misc {
  static String getDocumentUrl(String baseUrl, Document document) {
    final String? documentName = _getDocumentName(document);
    return '$baseUrl/api/documents/$documentName';
  }

  static String? _getDocumentName(Document document) {
    switch (document) {
      case Document.contrattoPiva:
        return 'ContrattoAutonomo.html';
      case Document.contrattoEsercente:
        return 'ContrattoEsercente.html';
      case Document.contrattoGdo:
        return 'ContrattoGDO.html';
      case Document.contrattoDipendente:
        return 'ContrattoDipendente.html';
      case Document.allegatoA:
        return 'AllegatoA.html';
      case Document.privacy:
        return 'Privacy.html';
      default:
        return null;
    }
  }
}

enum Document {
  contrattoPiva,
  contrattoEsercente,
  contrattoGdo,
  contrattoDipendente,
  allegatoA,
  privacy,
  tos
}
