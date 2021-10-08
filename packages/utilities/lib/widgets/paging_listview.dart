import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:utilities/interfaces/serializable.dart';
import 'package:utilities/utils/caching.dart';

/// Funzione che richiama la chiamata da paginare
///
/// Come parametro contiene il numero di pagina da caricare
typedef PagingCallback<T> = Future<List<T>> Function(int page);

/// Funzione che crea il widget per mostrare l'oggetto [T]
typedef ItemBuilder<T> = Widget Function(T item);

/// Funzione custom per ordinare degli elementi
typedef Sorting<T> = int Function(T item1, T item2);

/// Funzione che viene utilizzata per il fallback
/// della ricerca
typedef SearchFallback<T> = Future<List<T>> Function(String query);

/// Crea una [ListView] con la paginazione integrata
class PagingListview<T extends ForPaging> extends StatefulWidget {
  // ignore: public_member_api_docs
  const PagingListview({
    required this.pagingCallback,
    required this.itemBuilder,
    required this.scrollController,
    this.enableRefresh = true,
    this.newRequestOffset = 600,
    this.loadingPlaceholder,
    this.emptyPlaceholder,
    this.emptyPayloadMessage,
    this.sorting,
    this.endingItem,
    this.caching,
    this.query,
    this.onRefresh,
    this.withScrollbar = true,
    this.asSliverList = false,
    this.searchFallback,
    this.firstPage = 1,
    this.queryDebouncing = const Duration(milliseconds: 500),
    Key? key,
  }) : super(key: key);

  /// Se `true`, restituisce una [SliverList]
  final bool asSliverList;

  /// Se specificata, viene richiamata quando la [query] non
  /// restituisce risultati
  final SearchFallback<T>? searchFallback;

  /// Se vale `true` abilita la scrollbar per
  /// muovere la lista più velocemente
  final bool withScrollbar;

  /// La prima pagina con cui chiamare [pagingCallback]
  final int firstPage;

  /// Indica il tempo di debounce per eseguire le query
  /// richieste da [query]
  final Duration queryDebouncing;

  /// Permette di effettuare delle ricerche all'interno della lista
  ///
  /// Per effettuare le ricerche il tipo di elemento che
  /// dev'essere mostrato deve estendere il mixin `Searchable`
  final RxString? query;

  /// Callback che viene richiamato quando si fa un refresh
  final VoidCallback? onRefresh;

  /// Viene richiamata ogni volta che viene caricata una nuova pagina
  final Caching<T>? caching;

  /// Viene richiamata quando [newRequestOffset] viene raggiunto
  final PagingCallback<T> pagingCallback;

  /// Crea gli oggetti per mostrare l'oggetto [T]
  final ItemBuilder<T> itemBuilder;

  /// Se impostato a `true` abilita il refresh facendo lo scroll dall'alto
  ///
  /// Nel caso in cui [asSliverList] vale `true`, questo parametro viene
  /// ignorato e il [RefreshIndicator] sarà da aggiungere in modo che wrappi
  /// la [ScrollView] che comprende tutto
  final bool enableRefresh;

  /// Indica a quanto pixel dalla fine della lista bisogna inviare
  /// la nuova chiamata
  final double newRequestOffset;

  /// Lo scrollController che gestisce la lista
  final ScrollController scrollController;

  /// [Widget] che viene mostrato mentre che si caricano gli elementi
  final Widget? loadingPlaceholder;

  /// Viene mostrato quando non ci sono oggetti che compongono
  /// il [PagingListview]
  final Widget? emptyPlaceholder;

  /// Messaggio che verrà messo nel [FlutterToast]
  /// quando si trova la prima chiamata senza dati nel body
  final String? emptyPayloadMessage;

  /// Il widget da mostrare a fondo della lista
  ///
  /// Sarà visibile solo se si scrolla verso l'alto
  final Widget? endingItem;

  /// Viene applicata per ordinare i risultati
  final Sorting<T>? sorting;

  @override
  _PagingListviewState<T> createState() => _PagingListviewState<T>();
}

class _PagingListviewState<T extends ForPaging>
    extends State<PagingListview<T>> {
  /// Specifica la pagina attuale
  final _page = 0.obs;

  /// I dati caricati fin'ora
  final _data = <T>{}.obs;

  /// I dati che sono da mostrare effettivamente
  final _filteringData = <T>{}.obs;

  /// Verrà impostato a `false` quando si riceverà
  /// la prima chiamata che ritorna 0 elementi
  bool _canDoOtherCalls = true;

  /// Specifica se mostrare il [Widget.loadingPlaceholder] (se è disponibile)
  final _isLoading = false.obs;

  /// Permette di effettuare il debounce della [widget.query]
  Timer? _queryDebouncing;

  /// Contiene l'operazione che sta andando in questo momento
  CancelableOperation<List<T>>? _cancelableOperation;

  /// Registra il [_queryDebouncing] per richiamare il callback di
  /// query [queryCallback] dopo
  void _registerQuery(String query, VoidCallback queryCallback) {
    _queryDebouncing?.cancel();
    _queryDebouncing = Timer(widget.queryDebouncing, () {
      queryCallback.call();
      _queryDebouncing = null;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.caching?.onLoad().then((value) {
      _data
        ..addAll(value)
        ..refresh();
      if (value.isNotEmpty) _isLoading.call(false);
    });

    _data.listen((value) {
      _filteringData
        ..clear()
        ..addAll(
          _data.where(
            (element) {
              if (widget.query?.value != null) {
                return element.match(widget.query!.value);
              }
              return true;
            },
          ),
        );
    });

    widget.query?.listen(
      (value) => _registerQuery(value, () async {
        final filtered =
            _data.where((element) => element.match(value)).toList();

        if (filtered.isEmpty && widget.searchFallback != null) {
          final fallback = await widget.searchFallback!.call(value);
          filtered.addAll(fallback);

          widget.caching?.onSave(_page.value, fallback);
        }

        _filteringData.call(filtered.toSet());
      }),
    );

    widget.scrollController.addListener(() async {
      final shouldMakeCall = widget.scrollController.position.extentAfter <
              widget.newRequestOffset &&
          !_isLoading.value &&
          _canDoOtherCalls;

      if (shouldMakeCall) {
        _page.call(_page.value + 1);
      }
    });

    _page.listen((page) async {
      if (!_canDoOtherCalls) return;
      _isLoading.call(true);

      debugPrint('[PagingListview] Getting page $page');
      _cancelableOperation = CancelableOperation.fromFuture(
        widget.pagingCallback.call(page),
        onCancel: () {
          debugPrint('PagingListview fetch canceled');
        },
      );

      final newData = await _cancelableOperation!.value;
      debugPrint('[PagingListview] Got response for page $page');

      if (newData.isEmpty || _data.containsAll(newData)) {
        _canDoOtherCalls = false;
        if (widget.emptyPayloadMessage != null) {
          Fluttertoast.showToast(msg: widget.emptyPayloadMessage!);
        }
      }

      _data.addAll(newData);

      if (widget.sorting != null) {
        final temp = _data.toList()..sort(widget.sorting);
        _data
          ..clear()
          ..addAll(temp);
      }

      widget.caching?.onSave(page, _data.toList());

      _isLoading.call(false);
    });

    _page.call(widget.firstPage);
  }

  @override
  void dispose() {
    _cancelableOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_filteringData.isEmpty) {
        if (_isLoading.value && widget.loadingPlaceholder != null) {
          if (widget.asSliverList) {
            return SliverFillRemaining(
              child: Center(child: widget.loadingPlaceholder),
            );
          } else {
            return widget.loadingPlaceholder!;
          }
        }

        if (!_isLoading.value && widget.emptyPlaceholder != null) {
          if (widget.asSliverList) {
            return SliverFillRemaining(
              child: Center(child: widget.emptyPlaceholder),
            );
          } else {
            return widget.emptyPlaceholder!;
          }
        }
      }

      if (widget.asSliverList) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                widget.itemBuilder.call(_filteringData.toList()[index]),
            childCount: _filteringData.length,
          ),
        );
      } else {
        Widget list = ListView.builder(
          itemCount: _filteringData.length,
          itemBuilder: (context, index) =>
              widget.itemBuilder.call(_filteringData.toList()[index]),
          controller: widget.scrollController,
        );

        if (widget.withScrollbar) {
          list = Scrollbar(
            controller: widget.scrollController,
            child: list,
          );
        }

        if (!widget.enableRefresh) return list;
        return RefreshIndicator(
          onRefresh: () async {
            if (_isLoading.value) return;
            widget.onRefresh?.call();
            _canDoOtherCalls = true;
            _data.clear();
            _page
              ..value = 1
              ..refresh();
          },
          child: list,
        );
      }
    });
  }
}
