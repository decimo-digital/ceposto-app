// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:utilities/utils/implicit_scroll_physics.dart';

@Deprecated("Usare 'IntrinsicMovingWidget' al posto")
class AutoMovingTab extends StatelessWidget {
  /// Particolarmente utile nel caso della registrazione
  /// quando la tastiera compare, la schermata viene alzata in modo tale
  /// da rendere visibile il componente che ha il focus
  @Deprecated("Usare 'IntrinsicMovingWidget' al posto")
  const AutoMovingTab({
    required this.child,
    this.formKey,
    this.canScroll = false,
    Key? key,
  }) : super(key: key);

  final CustomStack child;
  final Key? formKey;
  final bool canScroll;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Form(
      key: formKey,
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          physics: canScroll ? null : const ImplicitScrollPhysics(),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SizedBox(
                height: size.height - kToolbarHeight - (size.height * .2),
                width: size.width,
              ),
              if (child.title != null)
                Positioned(top: child.titleOffset, child: child.title!),
              Container(
                constraints: BoxConstraints(maxHeight: child.bodySize.height),
                width: child.bodySize.width,
                child: child.children != null
                    ? Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          SizedBox(
                            height: child.bodySize.height,
                            width: child.bodySize.width,
                          ),
                          ...child.children!,
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: child.columnChildren!,
                      ),
              ),
              if (child.footer != null)
                Positioned(bottom: child.footerOffset, child: child.footer!),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomStack {
  CustomStack({
    required this.bodySize,
    // ignore: deprecated_consistency
    this.children,
    this.footer,
    this.columnChildren,
    this.title,
    this.titleOffset,
    this.footerOffset,
  })  : assert(
          (footer == null && footerOffset == null) ||
              (footer != null && footerOffset != null),
        ),
        assert(
          (title == null && titleOffset == null) ||
              (title != null && titleOffset != null),
        ),
        assert(
          (children != null && columnChildren == null) ||
              (columnChildren != null && children == null),
        );

  /// Specifica la dimensione massima dello stack (porzione di centro schermo)
  final Size bodySize;

  /// Lista di componenti che verrà renderizzata a centro schermo
  @Deprecated('Usare columnChildren al posto')
  final List<Widget>? children;

  final List<Widget>? columnChildren;

  final Widget? footer;

  final Widget? title;

  final double? titleOffset;
  final double? footerOffset;
}
