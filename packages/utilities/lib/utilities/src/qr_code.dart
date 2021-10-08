// ignore_for_file: prefer_void_to_null

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

/// Utility che espone le API per cifrare e decifrare
/// i dati contenuti in un QR
class QrCodeEncrypter {
  /// Decifra i dati [qrCodeString] del qr scannerizzato usando
  /// la [password]
  static Future<String?> decrypt(String password, String qrCodeString) async {
    final key = await _getKey(password);
    final iv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    final cipher = CBCBlockCipher(AESFastEngine());
    final ivParams =
        ParametersWithIV(KeyParameter(key), Uint8List.fromList(iv));
    final paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ivParams,
      null,
    );
    final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    paddedCipher.init(false, paddingParams);

    try {
      final uint8list = Uint8List.fromList(base64.decode(qrCodeString));
      final result = paddedCipher.process(uint8list);
      final res = String.fromCharCodes(result);
      return res;
    } catch (e) {
      debugPrint('Decrypt error: $e');
      return null;
    }
  }

  /// Cifra i dati [data] che andranno a popolare il QR con la [password]
  static Future<String> encrypt(
    String password,
    Map<String, dynamic> data,
  ) async {
    final key = await _getKey(password);
    final iv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    final cipher = CBCBlockCipher(AESFastEngine());
    final ivParams =
        ParametersWithIV(KeyParameter(key), Uint8List.fromList(iv));
    final paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ivParams,
      null,
    );
    final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    paddedCipher.init(true, paddingParams);
    final dataAsString = jsonEncode(data);
    try {
      final result =
          paddedCipher.process(utf8.encode(dataAsString) as Uint8List?);
      return base64.encode(result);
    } catch (e) {
      debugPrint('Encryption error: $e');
      return '';
    }
  }

  static Future<Uint8List> _getKey(String password) async {
    const keyLength = 256;
    final keyBytes =
        Uint8List.fromList(List.generate(keyLength ~/ 8, (index) => 0x0));
    final passwordBytes = utf8.encode(password);
    final length = min(passwordBytes.length, keyBytes.length);
    List.copyRange(keyBytes, 0, passwordBytes, 0, length);
    return keyBytes;
  }
}
