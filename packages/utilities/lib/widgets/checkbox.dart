import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/utils/fonts.dart';
import 'package:utilities/utils/theme_utility.dart';

// ignore: public_member_api_docs
typedef TodubaCheckboxValidator = String? Function(bool?);

// ignore: public_member_api_docs
mixin TodubaCheckboxStyle {
  // ignore: public_member_api_docs
  TextStyle? get textStyle;
}

/// Permette di stilizzare il Toggle
class TodubaCheckboxStyleToggle with TodubaCheckboxStyle {
  // ignore: public_member_api_docs
  TodubaCheckboxStyleToggle({
    this.textStyle,
    this.activeTrackColor,
  });

  @override
  final TextStyle? textStyle;

  /// Il colore del track se il tasto è attivo
  final Color? activeTrackColor;
}

/// Permette di stilizzare la checkbox classica
class TodubaCheckboxStyleCheck with TodubaCheckboxStyle {
  // ignore: public_member_api_docs
  TodubaCheckboxStyleCheck({
    this.checkboxCheckColor,
    TextStyle? textStyle,
    Color? checkboxIdleColor,
    Color? checkboxDisabledColor,
    Color? checkboxSelectedColor,
    Color? borderColor,
    double? borderWidth,
  })  : textStyle = textStyle ?? Fonts.checkboxStyle,
        borderColor = borderColor ?? Colors.grey,
        borderWidth = borderWidth ?? 2,
        checkBoxFillColor = ThemeUtility.getFor(
          checkboxIdleColor,
          values: {
            MaterialState.disabled: checkboxDisabledColor,
            MaterialState.selected: checkboxSelectedColor,
          },
        );

  @override
  final TextStyle textStyle;

  /// Il colore che la checkbox assume quando viene checkata a true
  final MaterialStateProperty<Color?>? checkBoxFillColor;

  /// Specifica il colore dell'icona di check interna al checkbox
  final Color? checkboxCheckColor;

  /// Il colore del bordo della checkbox
  final Color borderColor;

  /// Lo spessore del bordo
  final double borderWidth;
}

class _TodubaCheckboxState extends StatelessWidget {
  _TodubaCheckboxState({
    required this.label,
    required this.value,
    required this.type,
    required this.enabled,
    this.error,
    Key? key,
    this.onChange,
    TodubaCheckboxStyle? style,
    this.trailing,
    this.tristate = false,
  }) : super(key: key) {
    if (style == null) {
      switch (type) {
        case TodubaCheckboxType.check:
          _style = TodubaCheckboxStyleCheck();
          break;
        case TodubaCheckboxType.toggle:
          _style = TodubaCheckboxStyleToggle();
          break;
      }
    } else {
      _style = style;
    }
  }

  final bool enabled;

  final String label;

  final String? error;

  final void Function(bool?)? onChange;

  late final TodubaCheckboxStyle _style;

  final Widget? trailing;

  /// Se `true` [onChange] può avere come valori `true`, `false` e `null`
  ///
  /// Se `false` [onChange] sarà sicuramente valorizzato
  final bool tristate;

  final bool? value;

  final TodubaCheckboxType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (type == TodubaCheckboxType.check)
          Checkbox(
            value: value,
            onChanged: enabled ? (value) => onChange?.call(value) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fillColor: (_style as TodubaCheckboxStyleCheck).checkBoxFillColor,
            checkColor: (_style as TodubaCheckboxStyleCheck).checkboxCheckColor,
            tristate: tristate,
            side: BorderSide(
              color: (_style as TodubaCheckboxStyleCheck).borderColor,
              width: (_style as TodubaCheckboxStyleCheck).borderWidth,
            ),
          ),
        if (type == TodubaCheckboxType.toggle)
          Switch.adaptive(
            onChanged: enabled ? (value) => onChange?.call(value) : null,
            value: value!,
            activeColor: (_style as TodubaCheckboxStyleToggle).activeTrackColor,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _style.textStyle),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        trailing ?? Container(),
      ],
    );
  }
}

/// Permette di modificare la checkbox da normale a Toggle
enum TodubaCheckboxType {
  // ignore: public_member_api_docs
  check,
  // ignore: public_member_api_docs
  toggle,
}

// ignore: public_member_api_docs
class TodubaCheckbox extends FormField<bool> {
  // ignore: public_member_api_docs
  TodubaCheckbox({
    required String label,
    bool autovalidate = false,
    Key? key,
    void Function(bool?)? onChange,
    TodubaCheckboxStyle? style,
    bool tristate = false,
    Widget? trailing,
    TodubaCheckboxType type = TodubaCheckboxType.check,
    RxnBool? customValue,
    bool enabled = true,
  })  : assert(
          style == null ||
              (type == TodubaCheckboxType.check &&
                  style is TodubaCheckboxStyleCheck) ||
              (type == TodubaCheckboxType.toggle &&
                  style is TodubaCheckboxStyleToggle),
        ),
        super(
          key: key,
          onSaved: (_) {},
          validator: (_) => null,
          autovalidateMode: autovalidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          builder: (state) {
            if (customValue != null) {
              return Obx(() {
                return _TodubaCheckboxState(
                  //tristate ? state.value : (state.value ?? false),
                  value:
                      tristate ? customValue.value : customValue.value ?? false,
                  label: label,
                  style: style,
                  enabled: enabled,
                  tristate: tristate,
                  key: key,
                  type: type,
                  trailing: trailing,
                  onChange: (val) {
                    onChange?.call(val);
                    state.didChange(val);
                  },
                );
              });
            }

            return _TodubaCheckboxState(
              value: tristate ? state.value : (state.value ?? false),
              label: label,
              style: style,
              tristate: tristate,
              key: key,
              enabled: enabled,
              type: type,
              trailing: trailing,
              onChange: (val) {
                onChange?.call(val);
                state.didChange(val);
              },
            );
          },
        );

  // ignore: public_member_api_docs
  TodubaCheckbox.formField({
    required String label,
    FormFieldSetter<bool>? onSaved,
    FormFieldValidator<bool>? validator,
    bool autovalidate = false,
    Key? key,
    void Function(bool?)? onChange,
    TodubaCheckboxStyle? style,
    bool tristate = false,
    bool enabled = true,
    RxnBool? customValue,
    Widget? trailing,
    TodubaCheckboxType type = TodubaCheckboxType.check,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          builder: (state) {
            if (customValue != null) {
              return Obx(() {
                return _TodubaCheckboxState(
                  value:
                      tristate ? customValue.value : customValue.value ?? false,
                  label: label,
                  style: style,
                  enabled: enabled,
                  tristate: tristate,
                  key: key,
                  type: type,
                  trailing: trailing,
                  error: state.errorText,
                  onChange: (val) {
                    onChange?.call(val);
                    state.didChange(val);
                  },
                );
              });
            }
            return _TodubaCheckboxState(
              value: tristate ? state.value : (state.value ?? false),
              label: label,
              style: style,
              enabled: enabled,
              tristate: tristate,
              key: key,
              type: type,
              trailing: trailing,
              error: state.errorText,
              onChange: (val) {
                onChange?.call(val);
                state.didChange(val);
              },
            );
          },
        );
}
