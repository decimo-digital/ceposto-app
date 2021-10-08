import 'package:flutter/material.dart';
import 'package:utilities/widgets/button.dart';
import 'package:utilities/widgets/checkbox.dart';
import 'package:utilities/widgets/segmented_control.dart';

/// Contiene i pesi dei font chiamati come su figma
/// e alcuni stili comuni in tutta l'app
class Fonts {
  // ignore: public_member_api_docs
  static const FontWeight thin = FontWeight.w100;
  // ignore: public_member_api_docs
  static const FontWeight extraLight = FontWeight.w200;
  // ignore: public_member_api_docs
  static const FontWeight light = FontWeight.w300;
  // ignore: public_member_api_docs
  static const FontWeight regular = FontWeight.w400;
  // ignore: public_member_api_docs
  static const FontWeight medium = FontWeight.w500;
  // ignore: public_member_api_docs
  static const FontWeight semiBold = FontWeight.w600;
  // ignore: public_member_api_docs
  static const FontWeight bold = FontWeight.w700;
  // ignore: public_member_api_docs
  static const FontWeight extraBold = FontWeight.w800;
  // ignore: public_member_api_docs
  static const FontWeight black = FontWeight.w900;

  /// Restituisce un [FontWeight] dal suo [name], se esiste
  static FontWeight from(String name) {
    switch (name) {
      case 'thin':
        return thin;
      case 'extraLight':
        return extraLight;
      case 'light':
        return light;
      case 'regular':
        return regular;
      case 'medium':
        return medium;
      case 'semiBold':
        return semiBold;
      case 'bold':
        return bold;
      case 'extraBold':
        return extraBold;
      case 'black':
        return black;
      default:
        throw Exception('Missing fontSize $name');
    }
  }

  /// [TextStyle] utilizzato per le [Chip]
  static const chipStyle = TextStyle(
    color: Colors.white,
    fontSize: 8.5,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// [TextStyle] utilizzato per le label all'interno dei [SegmentedControl]
  static const segmentedLabelStyle = TextStyle(
    fontSize: 15.1,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// [TextStyle] utilizzato per il testo in [TodubaTextField]
  static const textBoxStyle = TextStyle(
    fontSize: 20,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// Lo stile del testo di [CustomButton]
  static const buttonStyle = TextStyle(
    fontFamily: 'montserrat',
    fontWeight: Fonts.bold,
    fontSize: 23,
  );

  /// Lo stile che viene usato nei [TextButton]
  static const textButtonStyle = TextStyle(
    fontSize: 16,
    fontWeight: Fonts.bold,
    fontFamily: 'montserrat',
  );

  /// Lo stile del testo di [TodubaCheckbox]
  static const checkboxStyle = TextStyle(
    fontSize: 15,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// Lo stile utilizzato per la label interna al [TodubaTextField]
  static const textLabelStyle = TextStyle(
    fontSize: 18,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// Stile che viene utilizzato per il titolo di una [ListTile]
  static const listTileTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );

  /// Stile che viene utilizzato per il sottotitolo di una [ListTile]
  static const listTileSubtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: Fonts.medium,
    fontFamily: 'montserrat',
  );
}
