import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Classe di utility che espone API di cifratura
class Crypto {
  /// Cifra la stringa [text] usando lo [sha256]
  static String encryptWithSHA256(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
