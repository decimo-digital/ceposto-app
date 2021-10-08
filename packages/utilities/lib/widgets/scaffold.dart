import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:utilities/widgets/alert_dialog.dart';

/// Scaffold custom che aggiunge alcune funzionalità di base
class CustomScaffold extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomScaffold({
    Key? key,
    this.appBar,
    this.bottomNavigationBar,
    this.body,
    this.resizeToAvoidBottomInset = false,
    this.onPop,
    this.floatingActionButton,
    this.onPopExit = false,
    this.enableBackGesture = true,
    this.withWillPopScope = true,
    this.forceKeyboardClose = true,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final PreferredSizeWidget? appBar;
  // ignore: public_member_api_docs
  final Widget? bottomNavigationBar;
  // ignore: public_member_api_docs
  final Widget? body;
  // ignore: public_member_api_docs
  final bool resizeToAvoidBottomInset;

  /// Se vale `true` forza la chiusura della tastiera
  /// quando la pagina viene pushata
  final bool forceKeyboardClose;

  // ignore: public_member_api_docs
  final WillPopCallback? onPop;
  // ignore: public_member_api_docs
  final Widget? floatingActionButton;

  /// Se impostato a `true`, verrà mostrato un dialog che chiude l'app
  final bool onPopExit;

  /// Funziona solo su iphone. Se impostato a `false`
  /// blocca la gesture per andare indietro
  final bool enableBackGesture;

  /// Se `false` rimuove il widget [WillPopScope]
  /// (usato principalmente per l'[Hero] in home_tab)
  final bool withWillPopScope;

  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

// ignore: public_member_api_docs
class CustomScaffoldState extends State<CustomScaffold> {
  Widget? _floatingActionButton;

  /// La chiave dello [Scaffold] originale
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Permette di notificare il prossimo cambio di stato del
  /// [FloatingActionButton]
  final _fabController = StreamController<bool>.broadcast();

  /// Imposta un fab sullo [Scaffold]
  ///
  /// Se [updatestate] è `true` aggiorna l'interfaccia con un `setState()`
  ///
  /// Se [keepCurrentFab] vale `true` il [FloatingActionButton] corrente
  /// (se è settato) viene messo in una [Column] con il nuovo [fab]
  ///
  /// [reversed] viene valutato solo se [keepCurrentFab] è `true` e
  /// ci si trova nel caso in cui si debba
  /// aggiungere due [FloatingActionButton] assieme
  ///
  /// Se il [fab] passato è `null`, il [FloatingActionButton] dello [Scaffold]
  /// viene rimosso totalmente. Se viene valorizzato anche il [toRemoveKey],
  /// viene cercato fra i [Widget] in [_floatingActionButton] se ne esiste uno
  /// con la chiave corrispondente
  void setFloatingActionButton(
    Widget? fab, {
    bool updatestate = false,
    bool keepCurrentFab = false,
    ValueKey? toRemoveKey,
    bool reversed = false,
  }) {
    assert(
      fab == null || fab.key == null || fab.key is ValueKey,
      'Il fab deve avere per forza una ValueKey',
    );

    if (fab != null && keepCurrentFab && _floatingActionButton != null) {
      final children = [
        _floatingActionButton!,
        fab,
      ];

      _floatingActionButton = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: reversed ? children.reversed.toList() : children,
      );
    } else {
      if (fab == null && toRemoveKey != null) {
        if (_floatingActionButton is Column) {
          // Rimuove il children che ha come chiave la stessa
          // [toRemoveKey]
          final newChildren = (_floatingActionButton! as Column)
              .children
              .where((c) => (c.key as ValueKey?)?.value != toRemoveKey.value)
              .toList();

          if (newChildren.isEmpty) {
            _floatingActionButton = null;
          } else if (newChildren.length == 1) {
            _floatingActionButton = newChildren.first;
          } else if (newChildren.length > 1) {
            _floatingActionButton = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: reversed ? newChildren.reversed.toList() : newChildren,
            );
          }
        } else if (_floatingActionButton?.key == toRemoveKey) {
          _floatingActionButton = null;
        }
      } else {
        _floatingActionButton = fab;
      }
    }

    _fabController.sink.add(fab == null);
    if (updatestate && mounted) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Ritorna `true` se in [_floatingActionButton] è contenuto un [Widget] che
  /// abbia una chiave con lo stesso valore di [key]
  bool containsFab(ValueKey key) {
    if (_floatingActionButton == null) return false;
    if (_floatingActionButton is! Column) {
      final fKey = _floatingActionButton!.key;
      if (fKey == null) return false;
      if (fKey is! ValueKey || fKey.value != key.value) return false;
      return true;
    }

    final children = (_floatingActionButton! as Column).children;

    return children.any((element) {
      final eKey = element.key;
      if (eKey == null) return false;
      if (eKey is! ValueKey || eKey.value != key.value) return false;
      return true;
    });
  }

  /// Ritorna `true` se c'è un [FloatingActionButton] impostato
  bool get hasAFabSet => _floatingActionButton != null;

  /// Ritorna un singolo cambio di stato del fab
  ///
  /// Ritorna `true` se il fab è stato dismesso
  /// `false` altrimenti
  Future<bool> get nextFabStateChange => _fabController.stream.take(1).first;

  @override
  void initState() {
    if (widget.forceKeyboardClose) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    super.initState();
    _floatingActionButton = widget.floatingActionButton;
  }

  @override
  void dispose() {
    _fabController.close();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (ModalRoute.of(context)!.isFirst || widget.onPopExit) {
      try {
        final pop = await showDialog<bool>(
              context: context,
              builder: (context) => _ExitDialog(),
            ) ??
            false;
        if (widget.onPopExit && pop) exit(1);
        return pop;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }
    return true;
  }

  // ignore: public_member_api_docs
  PersistentBottomSheetController<T> showBottomSheet<T>(
    WidgetBuilder builder, {
    double? elevation,
  }) =>
      _scaffoldKey.currentState!.showBottomSheet(builder, elevation: elevation);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: widget.body,
      floatingActionButton: _floatingActionButton,
    );

    if (!widget.withWillPopScope) return scaffold;

    if (Platform.isAndroid) {
      return WillPopScope(
        onWillPop: widget.onPop ?? _onWillPop,
        child: scaffold,
      );
    }

    return WillPopScope(
      onWillPop: widget.enableBackGesture ? null : _onWillPop,
      child: scaffold,
    );
  }
}

class _ExitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveAlertDialog(
      title: const Text('Sicuro di voler uscire?'),
      content: const Text("Premendo sì, uscirai dall'app"),
      actions: [
        AdaptiveAlertDialogAction(
          onPressed: () => Get.back(result: false),
          label: 'No',
        ),
        AdaptiveAlertDialogAction(
          onPressed: () => Get.back(result: true),
          label: 'Si',
        ),
      ],
    );
  }
}
