/// Specifica le regex per validare alcuni campi
class Patterns {
  /// [RegExp] che controlla la validità di una email
  static RegExp get email => RegExp(
        r'[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z_+])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9}$',
        caseSensitive: false,
      );

  /// [RegExp] che controlla la validità di un numero di telefono
  ///
  /// Ignora però il prefisso
  static RegExp get phoneNumber => RegExp(r'[0-9]{3}[0-9]{6,7}$');

  /// [RegExp] che controlla la validità di una partita iva
  static RegExp get piva => RegExp(r'^[0-9]{11}$');

  /// [RegExp] che controlla la validità di un codice fiscale
  static RegExp get codiceFiscale => RegExp(
        r'^[a-z]{6}[0-9]{2}[a-z][0-9]{2}[a-z][0-9]{3}[a-z]$',
        caseSensitive: false,
      );

  /// [RegExp] che controlla la validità di un IBAN
  static RegExp get iban => RegExp(
        r'IT\d{2}[ ][a-zA-Z]\d{3}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{3}|IT\d{2}[a-zA-Z]\d{22}',
      );

  /// [RegExp] che controlla la validità di un IBAN
  static RegExp get password => RegExp(
        r'^(?=.*\d).{8,}$',
      );

  /// Validatore per nome e cognome
  static RegExp get name => RegExp(
        r"^[a-z ,.'-]+$",
        caseSensitive: false,
      );
}
