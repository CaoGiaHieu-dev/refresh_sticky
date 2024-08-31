library refresh_sticky;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that provides a sticky refresh indicator that can be used to refresh the content of a scrollable widget.
///
/// The refresh indicator is sticky, meaning that it remains visible even when the user scrolls past it. This allows for a more seamless user experience, as the user can always see the refresh indicator and know that they can refresh the content.
///
/// The refresh indicator is also customizable, so you can change the size, color, and loading animation of the indicator.
class RefreshSticky extends StatefulWidget {
  /// Creates a refresh sticky widget.
  ///
  /// [builder] is the builder function that will be used to create the content of the scrollable widget.
  ///
  /// [onRefresh] is the callback function that will be called when the user refreshes the content.
  ///
  /// [size] is the size of the refresh indicator.
  ///
  /// [loadingBuilder] is the builder function that will be used to create the loading animation of the refresh indicator.
  ///
  /// [preLoadingBuilder] is the builder function that will be used to create the pre-loading animation of the refresh indicator.
  ///
  /// [controller] is the scroll controller that will be used to manage the scroll position of the scrollable widget.
  ///
  /// [moveToFirstAfterComplete] is a boolean value that determines whether the scroll position will be moved to the top after the refresh is complete.
  ///
  /// [reverse] is a boolean value that determines whether the refresh indicator should be placed at the bottom of the scrollable widget.
  ///
  /// [scaleLoadingIcon] is a double value that determines the scale of the loading icon.
  ///
  /// [axis] is the axis of the scrollable widget.
  const RefreshSticky({
    Key? key,
    required this.builder,
    required this.onRefresh,
    this.size = 50,
    this.loadingBuilder,
    this.preLoadingBuilder,
    this.controller,
    this.moveToFirstAfterComplete = false,
    this.reverse = false,
    this.scaleLoadingIcon = 1.2,
    this.axis = Axis.vertical,
  })  : assert(axis == Axis.vertical || reverse == false),
        super(key: key);

  /// The builder function that will be used to create the content of the scrollable widget.
  final Widget Function(
    BuildContext context,
    ScrollController controller,
  ) builder;

  /// The callback function that will be called when the user refreshes the content.
  final Future<void> Function() onRefresh;

  /// The size of the refresh indicator.
  final double size;

  /// The builder function that will be used to create the loading animation of the refresh indicator.
  final WidgetBuilder? loadingBuilder;

  /// The builder function that will be used to create the pre-loading animation of the refresh indicator.
  final WidgetBuilder? preLoadingBuilder;

  /// The scroll controller that will be used to manage the scroll position of the scrollable widget.
  final ScrollController? controller;

  /// A boolean value that determines whether the scroll position will be moved to the top after the refresh is complete.
  final bool moveToFirstAfterComplete;

  /// A boolean value that determines whether the refresh indicator should be placed at the bottom of the scrollable widget.
  final bool reverse;

  /// A double value that determines the scale of the loading icon.
  final double scaleLoadingIcon;

  /// The axis of the scrollable widget.
  final Axis axis;

  @override
  State<RefreshSticky> createState() => _RefreshStickyState();
}

class _RefreshStickyState extends State<RefreshSticky> {
  /// The dimension of the loading animation.
  final _loadingDimension = ValueNotifier<double>(0.0);

  /// The scale of the loading animation.
  final _loadingScale = ValueNotifier<double>(0.0);

  /// A boolean value that determines whether the loading animation is in progress.
  final _isStartLoading = ValueNotifier<bool>(false);

  /// The scroll controller that will be used to manage the scroll position of the scrollable widget.
  late final ScrollController _scrollController;

  @override
  void initState() {
    /// Initialize the scroll controller.
    _scrollController = widget.controller ?? ScrollController();

    /// Add a listener to the scroll controller to update the loading animation when the scroll position changes.
    WidgetsBinding.instance.endOfFrame.whenComplete(() {
      _listenOnOffset();
    });

    super.initState();
  }

  @override
  void dispose() {
    /// Remove the listener from the scroll controller.
    _scrollController.removeListener(_updateLoading);

    /// Dispose the scroll controller if it was created by this widget.
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// Adds a listener to the scroll controller to update the loading animation when the scroll position changes.
  void _listenOnOffset() {
    /// Remove the listener from the scroll controller.
    _scrollController.removeListener(_updateLoading);

    /// Add the listener to the scroll controller.
    _scrollController.addListener(_updateLoading);
  }

  /// Updates the loading animation when the scroll position changes.
  void _updateLoading() async {
    /// If the loading animation is in progress, then do nothing.
    if (_isStartLoading.value) return;

    /// If the scroll position is less than 0, then update the loading animation.
    if (_scrollController.offset < 0) {
      /// The loading dimension is the maximum of the scroll offset and the negative size of the refresh indicator.
      _loadingDimension.value = max(
        _scrollController.offset,
        -widget.size,
      );

      /// The loading scale is the maximum of the scroll offset divided by the size of the refresh indicator and the negative scale loading icon.
      _loadingScale.value = max(
        _scrollController.offset / widget.size,
        -widget.scaleLoadingIcon,
      );
    } else {
      /// If the scroll position is greater than or equal to 0, then reset the loading animation.
      _loadingDimension.value = 0;
      _loadingScale.value = 0;
    }
  }

  /// Starts the refresh animation.
  Future<void> _startRefresh() async {
    /// If the scroll position is greater than the negative size of the refresh indicator, then do nothing.
    if (_scrollController.offset > -widget.size) return;

    /// Update the scroll offset to the negative size of the refresh indicator.
    await _updateScrollUpdateOffset(-widget.size);

    /// If the loading animation is in progress, then do nothing.
    if (_isStartLoading.value) return;

    /// Set the loading animation in progress to true if the scroll offset is equal to the negative size of the refresh indicator.
    _isStartLoading.value = _scrollController.offset == -widget.size;

    /// Wait for the end of the frame.
    await WidgetsBinding.instance.endOfFrame;

    /// Call the onRefresh callback function.
    await widget.onRefresh();

    /// Wait for the end of the frame.
    await WidgetsBinding.instance.endOfFrame;

    /// Set the loading animation in progress to false.
    _isStartLoading.value = false;

    /// If the move to first after complete flag is set to true, then move the scroll position to the top.
    if (widget.moveToFirstAfterComplete) {
      _updateScrollUpdateOffset(0);
    } else {
      /// Reset the loading animation.
      _loadingDimension.value = 0;
      _loadingScale.value = 0;
    }
  }

  /// Updates the scroll offset.
  Future<void> _updateScrollUpdateOffset(double offset) async {
    /// Animate the scroll offset to the specified value.
    await _scrollController.animateTo(
      offset,
      duration: kThemeAnimationDuration,
      curve: Curves.linear,
    );

    /// Update the loading animation.
    _updateLoading();
  }

  /// Builds the loading animation.
  Widget _loading() {
    /// Build the loading animation based on the loading dimension.
    return ValueListenableBuilder<double>(
      valueListenable: _loadingDimension,
      builder: (context, dimension, _) {
        /// If the loading dimension is greater than 0, then return an empty SizedBox.
        if (dimension > 0) return const SizedBox();

        /// Build the loading animation with the specified dimension and scale.
        return AnimatedContainer(
          duration: Duration.zero,
          height: dimension * -widget.scaleLoadingIcon,
          width: dimension * -widget.scaleLoadingIcon,
          alignment: Alignment.center,
          child: ValueListenableBuilder<double>(
            valueListenable: _loadingScale,
            builder: (context, scale, child) {
              /// Rotate the loading icon by 180 degrees.
              return Transform.rotate(
                angle: pi,
                child: AnimatedScale(
                  /// Scale the loading icon based on the scale value.
                  scale: scale * (widget.axis == Axis.horizontal ? -1 : 1),
                  duration: Duration.zero,
                  child: child,
                ),
              );
            },

            /// Build the loading icon based on the loading state.
            child: ValueListenableBuilder<bool>(
              valueListenable: _isStartLoading,
              builder: (context, isLoading, child) {
                /// Return the loading builder if the loading animation is in progress, otherwise return the pre-loading builder.
                return isLoading
                    ? widget.loadingBuilder?.call(context) ?? child!
                    : widget.preLoadingBuilder?.call(context) ?? child!;
              },

              /// The default loading icon is a circular progress indicator.
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Build the scrollable widget with the refresh indicator.
    var child = <Widget>[
      /// The loading animation.
      _loading(),

      /// The content of the scrollable widget.
      Expanded(
        child: Listener(
          /// Trigger the refresh animation when the user lifts their finger from the screen.
          onPointerUp: (_) {
            _startRefresh();
          },
          child: widget.builder.call(
            context,
            _scrollController,
          ),
        ),
      ),
    ];

    /// Reverse the order of the children if the reverse flag is set to true.
    if (widget.reverse) {
      child = child.reversed.toList();
    }

    /// Build the scrollable widget.
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          /// Set the constraints of the scrollable widget.
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          child: widget.axis == Axis.horizontal
              ?

              /// Build the scrollable widget horizontally.
              Row(children: child)

              /// Build the scrollable widget vertically.
              : IntrinsicHeight(
                  child: Column(children: child),
                ),
        );
      },
    );
  }
}
