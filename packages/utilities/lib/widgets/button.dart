import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/utils/fonts.dart';
import 'package:utilities/utils/theme_utility.dart';

/// Specifica il tipo di bottone che si deve creare
enum ButtonType {
  /// Bottone primario
  elevated,

  /// Bottone secondario
  outlined,
}

/// Bottone custom per Toduba2
class CustomButton extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomButton.elevated({
    required this.label,
    Key? key,
    this.onPressed,
    this.fontColor,
    this.bgColor,
    TextStyle? textStyle,
    this.buttonWidth = 250,
    this.aspectRatio = 5.4,
    this.replaceOnPressed = false,
    this.progressIdicatorColor,
  })  : _type = ButtonType.elevated,
        borderWidth = 0,
        textStyle = textStyle ?? Fonts.buttonStyle,
        super(key: key);

  // ignore: public_member_api_docs
  const CustomButton.outlined({
    required this.label,
    Key? key,
    this.onPressed,
    this.fontColor,
    this.bgColor,
    TextStyle? textStyle,
    this.buttonWidth = 250,
    this.aspectRatio = 5.4,
    this.replaceOnPressed = false,
    this.borderWidth = 2,
    this.progressIdicatorColor,
  })  : _type = ButtonType.outlined,
        textStyle = textStyle ?? Fonts.buttonStyle,
        super(key: key);

  /// Specifica la larghezza del bordo
  ///
  /// Disponibile solo per [TodubaButton.outlined]
  final double borderWidth;

  final ButtonType _type;

  /// Se vale `true` rimpiazza il bottone con un [CircularProgressIndicator]
  /// finché la [onPressed] esegue
  final bool replaceOnPressed;

  /// Specifica il colore da utilizzare per il
  /// [CircularProgressIndicator] che sostituisce
  /// il bottone se [replaceOnPressed] vale `true`
  final Color? progressIdicatorColor;

  // ignore: public_member_api_docs
  final Future<void> Function()? onPressed;

  // ignore: public_member_api_docs
  final String label;

  /// Colore per il font della label
  ///
  /// Se non è definito verranno usati:
  /// - [ButtonType.outlined] ->  [ButtonThemeData.colorScheme.onBackground]
  /// - [ButtonType.elevated] -> [ButtonThemeData.colorScheme.onSurface]
  final Color? fontColor;

  /// Colore di sfondo per il bottone

  /// Se non è definito verranno usati:
  /// - [ButtonType.outlined] ->  [ButtonThemeData.colorScheme.background]
  /// - [ButtonType.elevated] -> [ButtonThemeData.colorScheme.surface]
  final Color? bgColor;

  // ignore: public_member_api_docs
  final TextStyle textStyle;

  // ignore: public_member_api_docs
  final double buttonWidth;

  // ignore: public_member_api_docs
  final double aspectRatio;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  /// Colore di sfondo per il tasto
  late Color _bgColor;

  /// Colore per il font del bottone
  late Color _fontColor;

  /// Colore da impostare al [CircularProgressIndicator]
  late Color _progressIdicatorColor;

  /// Specifica se mostrare oppure no il [CircularProgressIndicator]
  final _showLoadingIndicator = false.obs;

  /// Imposta il tema del bottone
  void _setTheme() {
    final theme = Theme.of(context);
    if (widget.bgColor != null) {
      _bgColor = widget.bgColor!;
    } else {
      _bgColor = (widget._type == ButtonType.outlined
              ? theme.buttonTheme.colorScheme?.background
              : theme.buttonTheme.colorScheme?.surface) ??
          theme.colorScheme.secondary;
    }

    if (widget.fontColor != null) {
      _fontColor = widget.fontColor!;
    } else {
      _fontColor = (widget._type == ButtonType.outlined
              ? theme.buttonTheme.colorScheme?.onBackground
              : theme.buttonTheme.colorScheme?.onSurface) ??
          theme.colorScheme.primary;
    }

    if (widget.progressIdicatorColor != null) {
      _progressIdicatorColor = widget.progressIdicatorColor!;
    } else {
      _progressIdicatorColor = (widget._type == ButtonType.elevated
              ? theme.buttonTheme.colorScheme?.surface
              : theme.buttonTheme.colorScheme?.onSurface) ??
          theme.colorScheme.secondary;
    }
  }

  /// Esegue l'azione collegata al bottone
  void _execute() {
    if (widget.replaceOnPressed) {
      _showLoadingIndicator.trigger(true);
    }
    widget.onPressed?.call().then((_) {
      if (widget.replaceOnPressed) {
        _showLoadingIndicator.trigger(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _setTheme();
    final height = widget.buttonWidth / widget.aspectRatio;

    return Obx(
      () {
        if (_showLoadingIndicator.value) {
          return SizedBox(
            width: height,
            height: height,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_progressIdicatorColor),
            ),
          );
        }

        final label = AutoSizeText(
          widget.label,
          maxLines: 1,
          textAlign: TextAlign.center,
          maxFontSize: widget.textStyle.fontSize ?? Fonts.buttonStyle.fontSize!,
          stepGranularity: .1,
        );

        return SizedBox(
          width: widget.buttonWidth,
          height: height,
          child: widget._type == ButtonType.outlined
              ? OutlinedButton(
                  onPressed: widget.onPressed == null ? null : _execute,
                  style: ButtonStyle(
                    elevation: ThemeUtility.getFor(4),
                    backgroundColor: ThemeUtility.getFor(_bgColor),
                    foregroundColor: ThemeUtility.getFor(_fontColor),
                    textStyle: ThemeUtility.getFor(widget.textStyle),
                    shape: ThemeUtility.getFor(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    side: ThemeUtility.getFor(
                      BorderSide(
                        color: _fontColor,
                        width: widget.borderWidth,
                      ),
                    ),
                    overlayColor: ThemeUtility.getFor(_fontColor.withAlpha(30)),
                  ),
                  child: label,
                )
              : ElevatedButton(
                  onPressed: widget.onPressed == null ? null : _execute,
                  style: ButtonStyle(
                    elevation: ThemeUtility.getFor(4),
                    backgroundColor: ThemeUtility.getFor(_bgColor),
                    foregroundColor: ThemeUtility.getFor(_fontColor),
                    textStyle: ThemeUtility.getFor(widget.textStyle),
                    shape: ThemeUtility.getFor(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: label,
                ),
        );
      },
    );
  }
}
