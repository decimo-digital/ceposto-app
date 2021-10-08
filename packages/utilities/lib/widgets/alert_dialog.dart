import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Componente adattiva per [AdaptiveAlertDialog]
class AdaptiveAlertDialogAction {
  // ignore: public_member_api_docs
  AdaptiveAlertDialogAction({
    required this.label,
    this.onPressed,
  });

  /// Crea l'action di default per chiudere l'alert
  AdaptiveAlertDialogAction.back({required this.label}) {
    onPressed = () => Get.back();
  }

  /// L'azione da compiere quando il tasto viene premuto
  late final VoidCallback? onPressed;

  /// La label da mostrare per il tasto
  final String label;
}

/// Dialog adattivo che cabmia in base al sistema operativo
/// in uso
class AdaptiveAlertDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const AdaptiveAlertDialog({
    required this.actions,
    this.title,
    this.content,
    Key? key,
  })  : assert(actions.length >= 1),
        super(key: key);

  /// Il titolo del dialog
  final Widget? title;

  /// Il contenuto da mostrare al centro del dialog
  final Widget? content;

  /// La lista di azioni che si possono compiere con il dialog
  ///
  /// Dev'esserne specificata almeno una
  final List<AdaptiveAlertDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    StatelessWidget dialog;
    if (Platform.isAndroid) {
      dialog = AlertDialog(
        title: title,
        content: content,
        actions: actions
            .map(
              (e) => TextButton(onPressed: e.onPressed, child: Text(e.label)),
            )
            .toList(),
      );
    } else {
      dialog = CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions
            .map(
              (e) => CupertinoDialogAction(
                onPressed: e.onPressed,
                child: Text(e.label),
              ),
            )
            .toList(),
      );
    }
    return dialog;
  }
}
