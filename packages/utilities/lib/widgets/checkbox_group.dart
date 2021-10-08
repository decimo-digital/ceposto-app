import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:utilities/widgets/checkbox.dart';

/// Viene usato in [AssociatedAccountDetails] per controllare
/// il gruppo di [TodubaCheckbox]
class CheckboxGroup extends StatefulWidget {
  // ignore: public_member_api_docs
  const CheckboxGroup({
    required this.controlLabel,
    required this.childrenLabels,
    this.onSave,
    this.childrenLeftPadding = 20,
    this.controlStyle,
    this.childrenStyle,
    this.otherChildren,
    this.readOnly = false,
    this.childrenValues,
    Key? key,
  })  : assert(
          !readOnly || childrenValues != null,
          'Se le checkbox sono in readonly, è necessario fornire il loro stato',
        ),
        assert(
          childrenValues == null ||
              childrenValues.length == childrenLabels.length,
          'Devono essere specificati i valori per tutte le labels',
        ),
        super(key: key);

  /// La [TodubaCheckbox] che funziona da controller
  ///
  /// Se viene modificata questa, modifica tutte le sottostanti
  final String controlLabel;

  /// Specifica se le checkbox devono essere in sola lettura o no
  ///
  /// Se impostato a `true`, [childrenLabels] è obbligatorio
  final bool readOnly;

  /// Specifica lo stato per le [childrenLabels]
  final List<bool>? childrenValues;

  /// Le [TodubaCheckbox] che funzioneranno da 'figlie'
  final List<String> childrenLabels;

  /// Speficia la rientranza delle [TodubaCheckbox] presenti in [childrenLabels]
  final double childrenLeftPadding;

  /// Viene chiamata ogni volta che un oggetto fra
  /// [controlLabel] e quelli presenti in [childrenLabels] cambia di stato
  ///
  /// Assieme al valore, ritona anche l'indice dell'elemento
  ///  in [childrenLabels] che è stato modificato
  ///
  /// Ritorna:
  /// - `true` -> tutti gli elementi in [childrenLabels] sono impostati a `true`
  /// - `false` -> tutti gli elementi in [childrenLabels]
  /// sono impostati a `false`
  /// - `null` -> gli elementi in [childrenLabels] sono un po' e un po'
  final void Function(int, bool?)? onSave;

  /// Sarà lo stile da applicare a [controlLabel]
  final TodubaCheckboxStyle? controlStyle;

  /// Sarà lo stile da applicare ad ogni elemento in [childrenLabels]
  final TodubaCheckboxStyle? childrenStyle;

  /// Altri elementi che vengono messi al di sotto di [childrenLabels]
  /// ma alla stessa indendatura di [controlLabel]
  final List<Widget>? otherChildren;

  @override
  CheckboxGroupState createState() => CheckboxGroupState();
}

// ignore: public_member_api_docs
class CheckboxGroupState extends State<CheckboxGroup> {
  /// Valuta tutti gli elementi in [items] per capire il loro stato
  ///
  /// Ritorna:
  /// - `true` -> sono tutti selezionati
  /// - `false` -> sono tutti non selezionati
  /// - `null` -> un po' e un po'
  bool? _selectionStatus(List<RxnBool> items) {
    final values = items.map((e) => e.value ?? false).toList();

    if (values.every((v) => v)) return true;

    if (values.every((v) => !v)) return false;

    return null;
  }

  /// Contiene i valori di tutti i [widget.childrenLabels]
  late final List<RxnBool> _childrenValues;

  /// Contiene il valore di [widget.controlLabel]
  final RxnBool _controlValue = RxnBool(false);

  /// Recupera lo stato del widget
  ///
  /// Ritorna:
  /// - `true` -> sono tutti selezionati
  /// - `false` -> sono tutti non selezionati
  /// - `null` -> un po' e un po'
  bool? getStatus() => _selectionStatus(_childrenValues);

  @override
  void initState() {
    super.initState();
    if (widget.childrenValues != null) {
      _childrenValues = widget.childrenValues!.map((e) => RxnBool(e)).toList();
      _selectionStatus(_childrenValues);
    } else {
      _childrenValues = List.generate(
        widget.childrenLabels.length,
        (index) => RxnBool(false),
      );
    }
    if (!widget.readOnly) {
      _childrenValues.asMap().entries.forEach((item) {
        item.value.listen((_) {
          final selectionStatus = _selectionStatus(_childrenValues);

          _controlValue.value = selectionStatus;
          _controlValue.refresh();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TodubaCheckbox(
          label: widget.controlLabel,
          style: widget.controlStyle,
          customValue: _controlValue,
          enabled: !widget.readOnly,
          onChange: (val) {
            _controlValue.value = val ?? false;
            _controlValue.refresh();
            // ignore: avoid_function_literals_in_foreach_calls
            _childrenValues.forEach((child) {
              child.call(val ?? false);
            });
          },
          tristate: true,
        ),

        /// I figli vengono fatti rientrare di [childrenLeftPadding] pixel
        Container(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: widget.childrenLabels
                .asMap()
                .entries
                .map(
                  (e) => TodubaCheckbox(
                    label: e.value,
                    style: widget.childrenStyle,
                    customValue: _childrenValues[e.key],
                    enabled: !widget.readOnly,
                    onChange: (val) => _childrenValues[e.key].call(val),
                  ),
                )
                .toList(),
          ),
        ),
        if (widget.otherChildren != null) ...widget.otherChildren!,
      ],
    );
  }
}
