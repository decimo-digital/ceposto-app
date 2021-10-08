import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' show MemoryImage;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Utility che espone alcune API per la gestione delle immagini
class ImageUtilities {
  /// Comprime un'immagine passata in [imageData] e crea un header
  /// con la sua estensione [ext]
  ///
  /// Restituisce il binario cifrato in `base64` da caricare
  static Future<String> compressImage(
    Uint8List imageData,
    String ext, {
    bool withHeader = true,
  }) async {
    final result = await FlutterImageCompress.compressWithList(
      imageData,
      minHeight: 512,
      keepExif: true,
      //format: CompressFormat.jpeg,
      minWidth: 288,
      quality: 96,
    );

    if (withHeader) {
      final String header = '/data:image/$ext;base64,';
      return header + base64.encode(result);
    }
    return base64.encode(result);
  }

  /// Croppa l'immagine in un quadrato `1:1`
  static Future<File?> cropImage(XFile image) async {
    final croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      iosUiSettings: const IOSUiSettings(
        aspectRatioLockEnabled: true,
        rectHeight: 200,
        rectWidth: 200,
      ),
    );
    return croppedFile;
  }

  /// Apre un [ImagePicker] per scegliere una immagine da caricare
  /// e ritorna il file compresso e convertito in [base64] usando
  /// il metodo [ImageUtilities.compressImage]
  static Future<ImageData?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
    );
    if (pickedFile != null) {
      final cropped = await cropImage(pickedFile);

      if (cropped == null) {
        return null;
      }

      final bytes = await cropped.readAsBytes();
      final path = cropped.path;
      final ext = path.substring(path.length - 3);
      return ImageData(
        withHeader: await compressImage(bytes, ext),
        withoutHeader: await compressImage(bytes, ext, withHeader: false),
      );
    }
    return null;
  }
}

/// Rappresenta un'immagine recuperata da [ImageUtilities.pickImage]
class ImageData {
  // ignore: public_member_api_docs
  ImageData({
    required this.withHeader,
    required this.withoutHeader,
  });

  /// Contiene il [base64] dell'immagine con tanto di header
  /// pronta da caricare sul server
  final String withHeader;

  /// Rappresenta la stessa immagine di [withHeader] ma senza appunto
  /// l'header così da farlo andare anche con il [MemoryImage]
  final String withoutHeader;
}
