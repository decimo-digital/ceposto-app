import 'package:flutter/material.dart';

/// [ScrollPhysics] che non accetta lo scroll da parte dell'utente
/// ma solo 
class ImplicitScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that does not let the user
  /// scroll but accepts implicit scrolling.
  const ImplicitScrollPhysics({
    ScrollPhysics? parent,
    this.context,
    this.onlyImplicitScrolling = false,
  }) : super(parent: parent);

  /// Se è definito, lo scroll sarà abilitato solo se
  /// la tastiera è aperta
  final BuildContext? context;

  /// Se vale `true` abilita lo scroll solamente implicito
  final bool onlyImplicitScrolling;

  @override
  ImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      ImplicitScrollPhysics(parent: buildParent(ancestor));

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (onlyImplicitScrolling) return false;

    /// Se il [context] non è nullo, abilito lo
    /// scroll solo se la tastiera è stata
    /// tirata su
    if (context != null) {
      final bottomInset = MediaQuery.of(context!).viewInsets.bottom;
      return bottomInset > 0;
    } else {
      if (parent != null) {
        return parent!.shouldAcceptUserOffset(position);
      } else {
        return position.pixels != 0.0 &&
            (position.extentAfter > 0 || position.extentBefore > 0);
      }
    }
  }

  @override
  bool get allowImplicitScrolling => true;
}
