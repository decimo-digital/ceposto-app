import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

import 'package:utilities/utilities/src/operators.dart';
import 'package:utilities/utils/fonts.dart';
import 'package:utilities/utils/patterns.dart';

// ignore: public_member_api_docs
const focusedColor = Colors.blue;

// ignore: public_member_api_docs
const unFocusedColor = Colors.grey;

/// Callback utilizzato per validare il contenuto della [TextField]
typedef Validator = String? Function(String?);

/// Callback utilizzato per salvare il contenuto della [TextField]
typedef OnSaveCallback = void Function(String?);

/// Callback che viene richiamato quando si preme sul tasto enter
typedef OnSubmitted = void Function(String);

enum _TextFieldType {
  /// Utilizza un [TextFormField] con il testo oscurato e l'[IconButton]
  /// per mostrare e nascondere il testo
  password,

  /// Equivale a [_TextFieldType.password] ma ignora i controlli
  /// di password sicura
  pin,

  /// Usa una [TextField] normale
  other,
}

/// [TextField] customizzata per `Toduba2`
class CustomTextField extends StatefulWidget {
  // ignore: public_member_api_docs
  CustomTextField({
    Key? key,
    this.labelText,
    this.controller,
    this.margin,
    this.textInputType,
    this.textInputAction,
    this.onChange,
    this.onSubmit,
    this.autocorrect = false,
    this.autoFillHints,
    this.enableSuggestions = true,
    this.formatters,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.hintText,
    this.enabled = true,
    this.onTap,
    this.prefixIcon,
    this.focusNode,
    TextStyle? fontStyle,
    this.textAlign = TextAlign.start,
    bool? readOnly,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.maxLines = 1,
    this.expands = false,
  })  : assert(
          (suffix == null && suffixIcon == null) ||
              xor(suffixIcon != null, suffix != null),
          'O sono entrambi null, o solo uno di questi è definito',
        ),
        assert(
          (prefix == null && prefixIcon == null) ||
              xor(prefixIcon != null, prefix != null),
          'O sono entrambi null, o solo uno di questi è definito',
        ),
        _isNormal = true,
        fontStyle = fontStyle ?? Fonts.textBoxStyle,
        _readOnly = readOnly ?? onTap != null,
        validator = null,
        onSaveCallback = null,
        _obscureText = false.obs,
        _type = _TextFieldType.other,
        super(key: key);
  // ignore: public_member_api_docs
  CustomTextField.formField({
    Key? key,
    this.labelText,
    this.controller,
    this.validator,
    this.onChange,
    this.margin,
    this.onSaveCallback,
    this.textInputAction,
    this.textInputType,
    this.formatters,
    this.onSubmit,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.prefixIcon,
    this.autoFillHints,
    TextStyle? fontStyle,
    this.enableSuggestions = true,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.hintText,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.focusNode,
    bool? readOnly,
    this.maxLength,
    this.maxLines = 1,
    this.expands = false,
  })  : assert(
          (suffix == null && suffixIcon == null) ||
              xor(suffixIcon != null, suffix != null),
          'O sono entrambi null, o solo uno di questi è definito',
        ),
        assert(
          (prefix == null && prefixIcon == null) ||
              xor(prefixIcon != null, prefix != null),
          'O sono entrambi null, o solo uno di questi è definito',
        ),
        _isNormal = false,
        fontStyle = fontStyle ?? Fonts.textBoxStyle,
        _readOnly = readOnly ?? onTap != null,
        _obscureText = false.obs,
        autocorrect = false,
        _type = _TextFieldType.other,
        super(key: key);

  /// `TextFormField` con la possibilità di mostrare e nascondere la password
  CustomTextField.passwordField({
    Key? key,
    this.labelText,
    this.controller,
    this.validator,
    this.margin,
    this.onChange,
    this.hintText,
    this.enabled = true,
    this.formatters,
    this.onSubmit,
    this.prefixIcon,
    this.onSaveCallback,
    this.enableSuggestions = true,
    this.textInputAction,
    TextStyle? fontStyle,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.autoFillHints = const [AutofillHints.password],
    bool? readOnly,
    this.maxLength,
    this.maxLines = 1,
    this.prefix,
    this.expands = false,
  })  : assert(
          (prefix == null && prefixIcon == null) ||
              xor(prefixIcon != null, prefix != null),
          'O sono entrambi null, o solo uno di questi è definito',
        ),
        suffix = null,
        textInputType = TextInputType.visiblePassword,
        _isNormal = false,
        fontStyle = fontStyle ?? Fonts.textBoxStyle,
        _readOnly = readOnly ?? onTap != null,
        _obscureText = true.obs,
        suffixIcon = null,
        textCapitalization = TextCapitalization.none,
        autocorrect = false,
        _type = _TextFieldType.password,
        super(key: key);

  /// `TextFormField` con la possibilità di mostrare e nascondere il pin
  CustomTextField.pinField({
    Key? key,
    this.labelText,
    this.controller,
    this.validator,
    this.margin,
    this.onChange,
    this.hintText,
    this.onSubmit,
    this.prefixIcon,
    this.onSaveCallback,
    this.enabled = true,
    this.enableSuggestions = true,
    this.textInputAction,
    TextStyle? fontStyle,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.onTap,
    bool? readOnly,
    this.maxLength = 8,
    this.maxLines = 1,
    this.expands = false,
  })  : textInputType = const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        suffix = null,
        prefix = null,
        textCapitalization = TextCapitalization.none,
        fontStyle = fontStyle ?? Fonts.textBoxStyle,
        formatters = [
          LengthLimitingTextInputFormatter(maxLength),
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        _isNormal = false,
        autoFillHints = const [],
        _readOnly = readOnly ?? onTap != null,
        _obscureText = true.obs,
        suffixIcon = null,
        autocorrect = false,
        _type = _TextFieldType.pin,
        super(key: key);

  late final _TextFieldType _type;

  /// Specifica la lunghezza massima del testo
  late final int? maxLength;

  /// Il numero massimo dirighe che il testo può
  /// assumere
  ///
  /// Se vale `null` è infinito
  final int? maxLines;

  /// Se vale `true` espande la [TextField] per fittare il padre
  final bool expands;

  /// Testo da mostrare all'interno della [TextField], scompare
  /// al primo inserimento
  final String? hintText;

  /// Testo da mostrare all'interno della [TextField], viene spostato
  /// verso l'alto al primo inserimento
  final String? labelText;

  /// Permette di definire un [FocusNode] custom per la [CustomTextField]
  final FocusNode? focusNode;

  /// Controller per gestire il testo
  final TextEditingController? controller;

  /// Specifica la policy per la quale capitalizzare il testo inserito
  final TextCapitalization textCapitalization;

  /// Callback che viene chiamato quando si preme sul tasto enter
  final OnSubmitted? onSubmit;

  /// Viene usato principalmente per l'implementazione di [TodubaDropdown]
  ///
  /// Se non è `null`, allora la testbox diventa in sola lettura
  final VoidCallback? onTap;
  final bool _readOnly;

  /// se `true` allora usa un [TextField]
  /// se `false` usa un [TextFormField]
  late final bool _isNormal;

  /// Funzione di validazione
  ///
  /// Viene usata in caso di [TodubaTextField.formField()]
  final Validator? validator;

  /// Callback per salvare il contenudo
  ///
  /// Viene usata in caso di [TodubaTextField.formField()]
  final OnSaveCallback? onSaveCallback;

  /// Callback che viene richiamato ad ogni inserimento all'interno della
  /// TextField
  final void Function(String?)? onChange;

  /// Margine esterno per spaziare i widget
  final EdgeInsets? margin;

  /// Il tipo di tastiera che bisogna utilizzare
  final TextInputType? textInputType;

  /// La funzione del tasto invio
  final TextInputAction? textInputAction;

  final RxBool _obscureText;

  /// Se vale `false` non è possibile interagire con la [TextField]
  final bool enabled;

  /// Informa il device quali valori servono per questa [TextField]
  final List<String>? autoFillHints;

  /// Specifica se mostrare o no i suggerimenti di correzione
  final bool autocorrect;

  /// Formattatori che vengono richiamati ad ogni inserimento
  final List<TextInputFormatter>? formatters;

  /// Abilita o disabilita i suggerimenti
  final bool enableSuggestions;

  /// Specifica come allineare il testo all'interno della [TextField]
  ///
  /// Funziona solo per il testo inserito
  final TextAlign textAlign;

  /// Specifica lo stile del testo che si inserisce
  late final TextStyle fontStyle;

  /// Icona che viene aggiunta al fondo della [TextField]
  ///
  /// In caso di [TodubaTextField.passwordField] di default è un [IconButton]
  /// con lucchetto
  ///
  /// Se non è `null`, [suffix] deve esserlo e viceversa
  final TextFieldIcon? suffixIcon;

  /// Widget che viene aggiunto al fondo della [TextField]
  ///
  /// Se non è `null`, [suffixIcon] deve esserlo e viceversa
  final Widget? suffix;

  /// Icona che viene posta all'inizio della [TextField]
  ///
  /// Se non è `null`, [prefix] deve esserlo e viceversa
  final TextFieldIcon? prefixIcon;

  /// Widget che viene posta all'inizio della [TextField]
  ///
  /// Se non è `null`, [prefixIcon] deve esserlo e viceversa
  final Widget? prefix;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Gestisce il cambio di colore dei componenti della textfield
  final RxBool _hasFocus = false.obs;

  final double _borderRadius = 5;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() => _hasFocus.call(_focusNode.hasFocus));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: Material(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_borderRadius),
              color: Colors.white,
            ),
            child: Obx(
              () => widget._isNormal
                  ? TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      keyboardType: widget.textInputType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autoFillHints,
                      inputFormatters: widget.formatters,
                      onChanged: widget.onChange,
                      autocorrect: widget.autocorrect,
                      onTap: widget.onTap,
                      expands: widget.expands,
                      textCapitalization: widget.textCapitalization,
                      maxLines: widget.maxLines,
                      maxLength: widget.maxLength,
                      style: widget.fontStyle,
                      readOnly: widget._readOnly,
                      onSubmitted: (val) {
                        if (widget.textInputAction == TextInputAction.done) {
                          _focusNode.unfocus();
                        }
                        widget.onSubmit?.call(val);
                      },
                      textAlign: widget.textAlign,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        hintMaxLines: 4,
                        suffixIcon:
                            widget.suffixIcon?.build(hasFocus: _hasFocus) ??
                                widget.suffix,
                        prefixIcon:
                            widget.prefixIcon?.build(hasFocus: _hasFocus) ??
                                widget.prefix,
                        labelStyle: Fonts.textLabelStyle.copyWith(
                          color:
                              _hasFocus.value ? focusedColor : unFocusedColor,
                        ),
                      ),
                    )
                  : TextFormField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      textInputAction: widget.textInputAction,
                      keyboardType: widget.textInputType,
                      textCapitalization: widget.textCapitalization,
                      onChanged: widget.onChange,
                      autofillHints: widget.autoFillHints,
                      expands: widget.expands,
                      maxLines: widget._type == _TextFieldType.password
                          ? 1
                          : widget.maxLines,
                      inputFormatters: widget.formatters,
                      autocorrect: widget.autocorrect,
                      obscureText: widget._obscureText.value,
                      onFieldSubmitted: (val) {
                        if (widget.textInputAction == TextInputAction.done) {
                          _focusNode.unfocus();
                        }
                        widget.onSubmit?.call(val);
                      },
                      onTap: widget.onTap,
                      style: widget.fontStyle,
                      textAlign: widget.textAlign,
                      readOnly: widget._readOnly,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        hintMaxLines: 4,
                        prefixIcon:
                            widget.prefixIcon?.build(hasFocus: _hasFocus) ??
                                widget.prefix,
                        labelStyle: Fonts.textLabelStyle.copyWith(
                          color:
                              _hasFocus.value ? focusedColor : unFocusedColor,
                        ),
                        focusColor: focusedColor,
                        suffixIcon: widget._type == _TextFieldType.other
                            ? (widget.suffixIcon?.build(hasFocus: _hasFocus) ??
                                widget.suffix)
                            : IconButton(
                                icon: Icon(
                                  widget._obscureText.value
                                      ? Icons.lock
                                      : Icons.lock_open,
                                ),
                                onPressed: () => widget._obscureText
                                    .call(!widget._obscureText.value),
                                color: _hasFocus.value ? focusedColor : null,
                              ),
                      ),
                      validator: widget.validator,
                      onSaved: widget.onSaveCallback,
                    ),
            ),
          ),
        ),
      );
}

/// Utilizzato per creare i [InputDecoration.suffixIcon] e
/// [InputDecoration.prefixIcon] di [CustomTextField]
/// in modo tale da avere gli stessi colori di focus e unfocus
class TextFieldIcon {
  // ignore: public_member_api_docs
  TextFieldIcon({required this.icon, this.onPressed});

  /// L'icona da utilizzare
  final IconData icon;

  /// Il callback da richiamare se viene tappata
  ///
  /// Se è `null` viene usata l'[icon] in sè, altrimenti
  /// viene creato un [IconButton]
  final VoidCallback? onPressed;

  /// Crea il [Widget] per il [TextFieldIcon]
  Widget build({RxBool? hasFocus}) {
    if (onPressed != null) {
      return IconButton(
        icon: Icon(
          icon,
          color: (hasFocus?.value ?? false) ? focusedColor : unFocusedColor,
        ),
        focusColor: focusedColor,
        onPressed: onPressed,
      );
    }

    return Icon(
      icon,
      color: (hasFocus?.value ?? false) ? focusedColor : unFocusedColor,
    );
  }
}
