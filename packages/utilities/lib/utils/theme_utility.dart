import 'package:flutter/material.dart';

/// Raggruppa dele funzioni che possono tornare utili per
/// customizzare delle componenti
class ThemeUtility {
  /// Fornisce un tema mappato per i vari [MaterialState]
  /// ```dart
  ///ElevatedButton(
  /// onPressed: onPressed,
  /// child: Text(label, style: textStyle, maxLines: 1),
  /// style: ButtonStyle(
  ///   backgroundColor: ThemeUtility.getFor({
  ///     MaterialState.pressed: Colors.green,
  ///     MaterialState.disabled: Colors.grey[350],
  ///   }, Colors.red),
  /// ),
  ///)
  /// ```
  ///
  /// [values] è una mappa {MaterialState, Valore} per mappare un certo valore
  /// allo stato della componente.
  ///
  /// [defaultValue] è il valore che viene restituito
  /// quando il componente è in 'idle', ovvero
  /// se l'utente non sta interagendo con la componente
  ///
  /// Se [values] è vuoto, verrà restituito sempre [defaultValue]
  static MaterialStateProperty<T?> getFor<T>(
    T? defaultValue, {
    final Map<MaterialState?, T?> values = const {},
  }) {
    if (values.isEmpty) return MaterialStateProperty.all(defaultValue);
    return MaterialStateProperty.resolveWith(
      (states) {
        T? value;
        if (states.isEmpty) {
          value = values.entries
              .firstWhere(
                (e) => e.key == null,
                orElse: () => MapEntry(null, defaultValue),
              )
              .value;
        } else {
          value = values[states.last] ?? defaultValue;
        }

        return value;
      },
    );
  }
}
