import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/utils/fonts.dart';

/// Specifica un controller per gestire il widget [SegmentedControl]
class SegmentedControlController<T> {
  _SegmentedControlState<T>? _state;

  /// Imposta lo stato del widget [SegmentedControl]
  set widgetState(_SegmentedControlState<T> state) => _state = state;

  /// Cambia l'indice corrente
  void changeIndex(T newIndex) {
    assert(_state != null);
    _state!._currentIndex.call(newIndex);
  }
}

/// Permette di stilizzare il [SegmentedControl]
class SegmentedControlStyle {
  // ignore: public_member_api_docs
  SegmentedControlStyle({
    Color? selectedColor,
    Color? borderColor,
    Color? pressedColor,
    this.borderRadius = 5,
    this.borderWidth = 1,
  })  : selectedColor = selectedColor ?? Get.theme.primaryColor,
        borderColor = borderColor ?? Get.theme.primaryColor,
        pressedColor = pressedColor ?? Get.theme.primaryColor;

  /// Colore del figlio selezionato
  final Color? selectedColor;

  /// Colore del bordo attorno al componente
  final Color? borderColor;

  /// Colore del ripple
  final Color? pressedColor;

  /// Raggio degli angoli del componente
  final double borderRadius;

  /// Larghezza del bordo del componente
  final double borderWidth;
}

/// Oggetto da inserire nel [SegmentedControl]
class SegmentedControlItem<T> {
  // ignore: public_member_api_docs
  SegmentedControlItem({required this.value, required this.name});

  /// Il valore che viene restituito dalla [onChanged]
  final T value;

  /// La label da mostrare nel segmented
  final String name;
}

// ignore: public_member_api_docs
class SegmentedControl<T> extends StatefulWidget {
  // ignore: public_member_api_docs
  SegmentedControl({
    required this.children,
    required this.onChanged,
    SegmentedControlStyle? style,
    SegmentedControlController<T>? controller,
    this.maxHeight = 40,
    this.labelStyle,
    Key? key,
  })  : assert(children.isNotEmpty),
        style = style ?? SegmentedControlStyle(),
        controller = controller ?? SegmentedControlController<T>(),
        super(key: key);

  /// Specifica lo stile da applicare alle label
  /// all'interno delle scelte del [SegmentedControl]
  ///
  /// Se non è definito, viene usato [Fonts.segmentedLabelStyle]
  ///
  /// Nello stile, il parametro [color] viene ignorato
  final TextStyle? labelStyle;

  // ignore: public_member_api_docs
  late final SegmentedControlController<T> controller;

  /// I figli da inserire nel segmented
  ///
  /// Devono essere almeno 2
  final List<SegmentedControlItem> children;

  /// Funzione che viene richiamata ogni volta che viene selezionato
  /// un oggetto nel segmented
  final void Function(T) onChanged;

  // ignore: public_member_api_docs
  final SegmentedControlStyle style;

  // ignore: public_member_api_docs
  final double maxHeight;

  @override
  // ignore: no_logic_in_create_state
  _SegmentedControlState<T> createState() {
    final state = _SegmentedControlState<T>();
    controller.widgetState = state;
    return state;
  }
}

class _SegmentedControlState<T> extends State<SegmentedControl<T>> {
  /// Controlla quale child sia attivo
  late final Rx<T> _currentIndex;

  late final bool _isSelectedColorDark;

  @override
  void initState() {
    super.initState();
    _currentIndex = Rx<T>(widget.children.first.value as T);
    _currentIndex.listen((value) => widget.onChanged(value));
    _isSelectedColorDark =
        (widget.style.selectedColor?.computeLuminance() ?? 1) < 0.5;
  }

  BorderRadius _buildBorder(int currentIndex) => BorderRadius.zero;

  List<Widget> _buildChildren() {
    final entries = widget.children.toList();
    final List<Widget> children = [];
    for (int index = 0; index < entries.length; index++) {
      final e = entries[index];
      children.add(
        Expanded(
          child: Ink(
            child: InkWell(
              splashColor: widget.style.selectedColor,
              customBorder: RoundedRectangleBorder(
                borderRadius: _buildBorder(index),
              ),
              onTap: () => _currentIndex.call(e.value as T?),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve:
                    _currentIndex == e.value ? Curves.easeIn : Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: _buildBorder(index),
                  color: _currentIndex == e.value
                      ? widget.style.selectedColor
                      : null,
                ),
                child: SizedBox(
                  height: widget.maxHeight,
                  child: Center(
                    child: AutoSizeText(
                      e.name,
                      style: (widget.labelStyle ?? Fonts.segmentedLabelStyle)
                          .copyWith(
                        color: _isSelectedColorDark && _currentIndex == e.value
                            ? Colors.white
                            : widget.style.selectedColor,
                      ),
                      maxFontSize:
                          (widget.labelStyle ?? Fonts.segmentedLabelStyle)
                              .fontSize!,
                      minFontSize: 10,
                      stepGranularity: .1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        border: widget.style.borderColor != null
            ? Border.all(
                color: widget.style.borderColor!,
                width: widget.style.borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: Obx(() => Row(children: _buildChildren())),
      ),
    );
  }
}
