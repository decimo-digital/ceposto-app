// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

/// Permette di definire delle icone svg "Stateful"
/// Per la definizione di un'icona di questo tipo
/// bisogna usare un file json con i campi
/// ```json
/// {
///   "selected": "svg-path",
///   "unselected": "svg-path"
/// }
/// ```
class StatefulSvgImage extends StatefulWidget {
  const StatefulSvgImage({
    required this.statefulPath,
    required this.size,
    this.isSelected = false,
    this.semanticsLabel,
    this.label,
    this.autoSizeGroup,
    this.labelMaxLines = 2,
    this.labelMinFont = 12,
    Key? key,
  }) : super(key: key);

  final String statefulPath;
  final bool isSelected;
  final Size size;

  /// Solo per debug
  final String? semanticsLabel;
  final String? label;

  /// Normalizza la dimensione del label fra tutte le icone che
  /// condividono lo stesso gruppo
  final AutoSizeGroup? autoSizeGroup;
  final int labelMaxLines;
  final double labelMinFont;

  @override
  _StatefulSvgImageState createState() => _StatefulSvgImageState();
}

class _StatefulSvgImageState extends State<StatefulSvgImage> {
  String? _selectedPath;
  String? _unselectedPath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final map = jsonDecode(await rootBundle.loadString(widget.statefulPath));
    _selectedPath = (map['selected'] as String).replaceAll('\\', '');
    _unselectedPath = (map['unselected'] as String).replaceAll('\\', '');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPath != null && _unselectedPath != null) {
      try {
        if (widget.label != null) {
          return SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: SvgPicture.memory(
                    utf8.encode(
                      widget.isSelected ? _selectedPath! : _unselectedPath!,
                    ) as Uint8List,
                    semanticsLabel: widget.semanticsLabel,
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    widget.label!,
                    textAlign: TextAlign.center,
                    maxLines: widget.labelMaxLines,
                    group: widget.autoSizeGroup,
                    minFontSize: widget.labelMinFont,
                  ),
                ),
              ],
            ),
          );
        }

        return SvgPicture.memory(
          utf8.encode(widget.isSelected ? _selectedPath! : _unselectedPath!)
              as Uint8List,
          width: widget.size.width,
          height: widget.size.height,
          semanticsLabel: widget.semanticsLabel,
        );
      } catch (e) {
        debugPrint('Error $e');
        return SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: const CircularProgressIndicator(),
        );
      }
    }

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: const CircularProgressIndicator(),
    );
  }
}
