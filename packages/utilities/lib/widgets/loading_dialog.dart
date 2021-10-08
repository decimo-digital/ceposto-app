import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialog che viene mostrato durante un caricamento
class LoadingDialog extends StatefulWidget {
  // ignore: public_member_api_docs
  const LoadingDialog({
    this.onInit,
    Key? key,
    this.backgroundColor,
  }) : super(key: key);

  /// Funzione che viene chiamata nell'initState
  final Future<void> Function()? onInit;

  /// Colore di sfondo custom per il dialog
  final Color? backgroundColor;

  @override
  LoadingDialogState createState() => LoadingDialogState();
}

// ignore: public_member_api_docs
class LoadingDialogState extends State<LoadingDialog> {
  /// Dialog che è attualmente mostrato
  late Rx<Widget> _dialog;

  /// Sostituisce il [LoadingDialogState._dialog] attuale con [newDialog]
  set dialog(Widget newDialog) => _dialog.trigger(newDialog);

  @override
  void initState() {
    super.initState();

    widget.onInit?.call();

    _dialog = FractionallySizedBox(
      widthFactor: .5,
      heightFactor: .3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    ).obs;
  }

  @override
  Widget build(BuildContext context) => Obx(() => _dialog.value);
}
