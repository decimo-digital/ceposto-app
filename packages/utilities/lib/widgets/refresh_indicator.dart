// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The over-scroll distance that moves the indicator
/// to its maximum displacement, as a percentage of the
/// scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

/// How much the scroll's drag gesture can overshoot the
/// RefreshIndicator's displacement; max
/// displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

/// When the scroll ends, the duration of the refresh
/// indicator's animation to the RefreshIndicator's displacement.
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

/// The duration of the ScaleTransition that starts when
/// the refresh action has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// The signature for a function that's called when the user has
/// dragged a [ReactiveRefreshIndicator] far enough to demonstrate
/// that they want to instigate a refresh.
typedef RefreshCallback = void Function();

/// The state machine moves through these modes only when
/// the scrollable identified by scrollableKey has been
/// scrolled to its min or max limit.
enum _RefreshIndicatorMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}

/// This is a customization of the [RefreshIndicator] widget that is reactive
/// in design. This makes it much easier to integrate into code
/// that has multiple avenues of refresh instigation. That is, refreshing
/// in response to the user pulling down a [ListView], but also in
/// response to some other stimuli, like swiping a header left or right.
///
/// Instead of [onRefresh] being asynchronous as it is in [RefreshIndicator],
/// it is synchronous. Consequently, instead of determining the
/// visibility of the refresh indicator on your behalf, you must tell the
/// control yourself via [isRefreshing]. The [onRefresh] callback is
/// only executed if the user instigates a refresh via a
/// pull-to-refresh gesture.
class ReactiveRefreshIndicator extends StatefulWidget {
  const ReactiveRefreshIndicator({
    required this.child,
    required this.isRefreshing,
    required this.onRefresh,
    this.displacement = 40.0,
    this.indicatorAtTop = true,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    Key? key,
  }) : super(key: key);

  final Widget child;

  final double displacement;
  final bool indicatorAtTop;

  final bool isRefreshing;

  final RefreshCallback onRefresh;

  final Color? color;

  final Color? backgroundColor;

  final ScrollNotificationPredicate notificationPredicate;

  @override
  ReactiveRefreshIndicatorState createState() =>
      ReactiveRefreshIndicatorState();
}

class ReactiveRefreshIndicatorState extends State<ReactiveRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late Animation<double> _positionFactor;
  late Animation<double> _scaleFactor;
  late Animation<double> _value;
  Animation<Color?>? _valueColor;

  _RefreshIndicatorMode? _mode;
  bool? _isIndicatorAtTop;
  double? _dragOffset;

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(vsync: this);
    _positionFactor = Tween<double>(
      begin: 0.0,
      end: _kDragSizeFactorLimit,
    ).animate(_positionController);
    _value = Tween<double>(
      // The "value" of the circular progress indicator during a drag.
      begin: 0.0,
      end: 0.75,
    ).animate(_positionController);

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_scaleController);

    _isIndicatorAtTop = widget.indicatorAtTop;

    _showOrDismissAccordingToIsRefreshing();
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = ColorTween(
      begin: (widget.color ?? theme.colorScheme.secondary).withOpacity(0.0),
      end: (widget.color ?? theme.colorScheme.secondary).withOpacity(1.0),
    ).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit),
      ),
    );

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ReactiveRefreshIndicator oldWidget) {
    _showOrDismissAccordingToIsRefreshing();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showOrDismissAccordingToIsRefreshing() {
    if (widget.isRefreshing) {
      if (_mode != _RefreshIndicatorMode.refresh) {
        Future(() {
          _start(AxisDirection.down);
          _show();
        });
      }
    } else {
      if (_mode != null && _mode != _RefreshIndicatorMode.done) {
        _dismiss(_RefreshIndicatorMode.done);
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }

    if (notification is ScrollStartNotification &&
        notification.metrics.extentBefore == 0.0 &&
        _mode == null &&
        _start(notification.metrics.axisDirection)) {
      setState(() {
        _mode = _RefreshIndicatorMode.drag;
      });
      return false;
    }

    bool? indicatorAtTopNow;

    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }

    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed) {
        _dismiss(_RefreshIndicatorMode.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_RefreshIndicatorMode.canceled);
        } else {
          _dragOffset = _dragOffset! + notification.scrollDelta!;
          _checkDragOffset(notification.metrics.viewportDimension);
        }
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed) {
        _dragOffset = _dragOffset! - notification.overscroll / 2.0;
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _RefreshIndicatorMode.armed:
          _show(userInstigated: true);
          break;
        case _RefreshIndicatorMode.drag:
          _dismiss(_RefreshIndicatorMode.canceled);
          break;
        default:
          // do nothing
          break;
      }
    }

    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) {
      return false;
    }

    if (_mode == _RefreshIndicatorMode.drag) {
      notification.disallowGlow();
      return true;
    }

    return false;
  }

  bool _start(AxisDirection direction) {
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;

    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(
      _mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed,
    );

    double newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);

    if (_mode == _RefreshIndicatorMode.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }

    _positionController.value =
        newValue.clamp(0.0, 1.0); // this triggers various rebuilds

    if (_mode == _RefreshIndicatorMode.drag &&
        _valueColor!.value!.alpha == 0xFF) {
      _mode = _RefreshIndicatorMode.armed;
    }
  }

  Future<void> _dismiss(_RefreshIndicatorMode newMode) async {
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(
      newMode == _RefreshIndicatorMode.canceled ||
          newMode == _RefreshIndicatorMode.done,
    );

    setState(() {
      _mode = newMode;
    });

    switch (_mode) {
      case _RefreshIndicatorMode.done:
        await _scaleController.animateTo(
          1.0,
          duration: _kIndicatorScaleDuration,
        );
        break;
      case _RefreshIndicatorMode.canceled:
        await _positionController.animateTo(
          0.0,
          duration: _kIndicatorScaleDuration,
        );
        break;
      default:
        assert(false);
    }

    if (mounted && _mode == newMode) {
      _dragOffset = null;
      //_isIndicatorAtTop = null;

      setState(() => _mode = null);
    }
  }

  void _show({bool userInstigated = false}) {
    assert(_mode != _RefreshIndicatorMode.refresh);
    assert(_mode != _RefreshIndicatorMode.snap);

    _mode = _RefreshIndicatorMode.snap;
    _positionController
        .animateTo(
      1.0 / _kDragSizeFactorLimit,
      duration: _kIndicatorSnapDuration,
    )
        .then<void>((value) {
      if (mounted && _mode == _RefreshIndicatorMode.snap) {
        setState(() => _mode = _RefreshIndicatorMode.refresh);

        if (userInstigated) {
          widget.onRefresh();
        }
      }
    });
  }

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _isIndicatorAtTop = widget.indicatorAtTop;

    final Widget child = NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );

    if (_mode == null) {
      assert(_dragOffset == null);

      return child;
    }

    assert(_dragOffset != null);
    assert(_isIndicatorAtTop != null);

    final bool showIndeterminateIndicator =
        _mode == _RefreshIndicatorMode.refresh ||
            _mode == _RefreshIndicatorMode.done;

    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: _isIndicatorAtTop! ? 0.0 : null,
          bottom: !_isIndicatorAtTop! ? 0.0 : null,
          left: 0.0,
          right: 0.0,
          child: SizeTransition(
            axisAlignment: _isIndicatorAtTop! ? 1.0 : -1.0,
            sizeFactor: _positionFactor, // this is what brings it down
            child: Container(
              padding: _isIndicatorAtTop!
                  ? EdgeInsets.only(top: widget.displacement)
                  : EdgeInsets.only(bottom: widget.displacement),
              alignment: _isIndicatorAtTop!
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (BuildContext context, Widget? child) {
                    return RefreshProgressIndicator(
                      value: showIndeterminateIndicator ? null : _value.value,
                      valueColor: _valueColor,
                      backgroundColor: widget.backgroundColor,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
