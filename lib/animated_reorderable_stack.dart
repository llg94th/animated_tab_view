import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:widget_demo/rabbit_ear_container.dart';

class AnimatedReorderableController extends ValueNotifier<int> {
  AnimatedReorderableController({
    required this.length,
    int topIndex = 0,
    this.onReorder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  })  : indices = List.generate(length, (index) => index),
        super(topIndex);

  int get topIndex => value;

  /// Duration for all animations in the stack
  final Duration animationDuration;

  /// Curve for all animations in the stack
  final Curve animationCurve;

  void setTopIndex(int index) {
    // Reorder indices so target index is first, then continue in circular order
    indices.clear();
    for (int i = 0; i < length; i++) {
      indices.add((index + i) % length);
    }
    value = index;
    log('indices reordered to: ${indices.toString()}');
  }

  void next() {
    // Move to next index in the current circular order
    log('next');
    final nextIndex = indices[1];
    setTopIndex(nextIndex);
  }

  void previous() {
    // Move to previous index in the current circular order
    log('previous');
    final prevIndex = indices[length - 1];
    setTopIndex(prevIndex);
  }

  final int length;
  final ValueChanged<int>? onReorder;
  final List<int> indices;
}

/// An animated Stack widget that reorders children with smooth position animations.
/// The current child moves to (0,0) and others move to staggered positions.
/// Children can be dragged to reorder them.
class AnimatedReorderableStack extends StatefulWidget {
  /// Creates an AnimatedReorderableStack.
  const AnimatedReorderableStack({
    super.key,
    required this.controller,
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
    this.childHeight = 300.0,
    this.childWidth = 500.0,
    this.minTabWidth = 150.0,
    this.tabOverlapWidth = 10.0,
    this.tabHeightSpacing = 4.0,
    this.tabHeight = 30.0,
  });

  /// The controller that manages the ordering and animations.
  final AnimatedReorderableController controller;

  /// The content will be clipped (or not) according to this option.
  final Clip clipBehavior;

  /// The list of children widgets.
  final List<Widget> children;

  /// Height of each child container
  final double childHeight;

  /// Width of each child container
  final double childWidth;

  /// Minimum width of tabs
  final double minTabWidth;

  /// Overlap width between tabs
  final double tabOverlapWidth;

  /// Height spacing between tabs
  final double tabHeightSpacing;

  /// Height of tab headers
  final double tabHeight;

  /// Calculated exposed width of tabs
  double get tabExposedWidth => minTabWidth - tabOverlapWidth;

  @override
  State<AnimatedReorderableStack> createState() =>
      _AnimatedReorderableStackState();
}

class _AnimatedReorderableStackState extends State<AnimatedReorderableStack>
    with TickerProviderStateMixin {
  int? _draggingIndex;
  bool _isJustSwiped = false;
  late ValueNotifier<Offset> _dragOffset;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Store previous and current tab widths for animation
  Map<int, double> _previousTabWidths = {};
  final Map<int, double> _currentTabWidths = {};

  @override
  void initState() {
    super.initState();
    _dragOffset = ValueNotifier(Offset.zero);
    _animationController = AnimationController(
      duration: widget.controller.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.controller.animationCurve,
    );

    widget.controller.addListener(_onControllerChanged);

    // Initialize tab widths
    _initializeTabWidths();
  }

  void _initializeTabWidths() {
    for (int i = 0; i < widget.controller.length; i++) {
      final positionInOrdering = widget.controller.indices.indexOf(i);
      final tabWidth =
          widget.minTabWidth + (positionInOrdering * widget.tabExposedWidth);

      _currentTabWidths[i] = tabWidth;
      _previousTabWidths[i] = tabWidth;
    }
  }

  void _onControllerChanged() {
    // Store previous values for animation
    if (!_isJustSwiped) _previousTabWidths = Map.from(_currentTabWidths);
    _isJustSwiped = false;
    // Calculate new values
    _updateAnimatedProperties();

    // Start animation
    _animationController.reset();
    _animationController.forward();
  }

  void _updateAnimatedProperties() {
    for (int i = 0; i < widget.controller.length; i++) {
      final positionInOrdering = widget.controller.indices.indexOf(i);

      // Calculate tab width (without drag reduction - that's applied in build)
      final tabWidth =
          widget.minTabWidth + (positionInOrdering * widget.tabExposedWidth);
      _currentTabWidths[i] = tabWidth;
    }
  }

  @override
  void didUpdateWidget(AnimatedReorderableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);

      _animationController.duration = widget.controller.animationDuration;
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.controller.animationCurve,
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  Widget _buildDraggableChild({
    required int index,
    required int positionInOrdering,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ValueListenableBuilder<Offset>(
          valueListenable: _dragOffset,
          builder: (context, dragOffset, child) {
            final isDraggingLayer = _draggingIndex == index;
            final isDragging = _draggingIndex != null;
            final isTop = index == widget.controller.topIndex;
            final reducedTabWidth =
                max(min(dragOffset.dx, 0.0), -widget.minTabWidth);
            final zRatio = (-reducedTabWidth / widget.minTabWidth);

            // Calculate animated tab width
            final previousWidth =
                _previousTabWidths[index] ?? widget.minTabWidth;
            final currentWidth = _currentTabWidths[index] ?? widget.minTabWidth;

            final baseAnimatedWidth = isDraggingLayer
                ? currentWidth // Use current width during drag
                : Tween<double>(
                    begin: previousWidth,
                    end: currentWidth,
                  ).animate(_animation).value;

            // Apply drag reduction only when actually dragging
            final animatedTabWidth = isDragging
                ? max(baseAnimatedWidth + reducedTabWidth, widget.minTabWidth)
                : baseAnimatedWidth;

            final position = isDraggingLayer
                ? Offset(min(0.0, dragOffset.dx), 0.0)
                : Offset.zero;
            final opacity = isTop && isDraggingLayer ? 1 - zRatio : 1.0;

            final reducedTitleHeight = isDragging
                ? widget.tabHeightSpacing * positionInOrdering -
                    zRatio * widget.tabHeightSpacing
                : widget.tabHeightSpacing * positionInOrdering;
            final newTitleHeight = widget.tabHeight - reducedTitleHeight;

            return Positioned(
              left: position.dx,
              top: reducedTitleHeight,
              child: Opacity(
                opacity: opacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTap: isTop || isDragging ? null : () => _handleTap(index),
                  onPanStart: isTop
                      ? (details) {
                          _draggingIndex = index;
                          _dragOffset.value = Offset.zero;
                        }
                      : null,
                  onPanUpdate: isTop
                      ? (details) => _dragOffset.value += details.delta
                      : null,
                  onPanEnd: isTop
                      ? (details) => _handleDragEnd(index, details)
                      : null,
                  child: TabContainer(
                    gradient: [
                      Colors.primaries[index % Colors.primaries.length],
                      Colors.white
                    ],
                    width: widget.childWidth,
                    height: widget.childHeight - reducedTitleHeight,
                    titleWidth: animatedTabWidth,
                    titleHeight: newTitleHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          width: animatedTabWidth,
                          child: SizedBox(
                            width: widget.minTabWidth,
                            height: newTitleHeight,
                            child: Transform.scale(
                              scale: newTitleHeight / widget.tabHeight,
                              child: Text(
                                'Tab Tab ${index + 1}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        widget.children[index],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(int tappedIndex) {
    if (tappedIndex == widget.controller.topIndex) {
      // Tapped on current top card - cycle to next
    } else {
      // Tapped on other card - make it the top card
      widget.controller.setTopIndex(tappedIndex);
      widget.controller.onReorder?.call(tappedIndex);
    }
  }

  void _handleDragEnd(int draggedIndex, DragEndDetails details) {
    final dragDistance = _dragOffset.value.dx.abs();
    final velocity = details.velocity.pixelsPerSecond;
    final isSwipe = dragDistance > 30 || velocity.distance > 500;

    if (draggedIndex == widget.controller.topIndex) {
      // Current child swiped - move to next or previous based on swipe direction
      if (isSwipe) {
        if (_dragOffset.value.dx > 0) {
          // Swipe right - go to previous
          // widget.controller.previous();
        } else {
          _previousTabWidths = Map.from(_currentTabWidths);
          for (int i = 0; i < widget.controller.length; i++) {
            _previousTabWidths[i] = max(
                _previousTabWidths[i]! - widget.minTabWidth,
                widget.minTabWidth);
          }
          _isJustSwiped = true;
          // Swipe left - go to next
          widget.controller.next();
        }
        widget.controller.onReorder?.call(widget.controller.topIndex);
      }
    } else {
      // Other child dragged - make it the top child
      widget.controller.setTopIndex(draggedIndex);
      widget.controller.onReorder?.call(draggedIndex);
    }
    setState(() {
      _draggingIndex = null;
      _dragOffset.value = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
                alignment: AlignmentDirectional.topEnd,
                fit: StackFit.loose,
                clipBehavior: widget.clipBehavior,
                children: widget.controller.indices.reversed.map((value) {
                  final positionInOrdering =
                      widget.controller.indices.indexOf(value);
                  return _buildDraggableChild(
                      index: value, positionInOrdering: positionInOrdering);
                }).toList());
          },
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('topIndex', widget.controller.topIndex));
    properties.add(EnumProperty<Clip>('clipBehavior', widget.clipBehavior));
  }
}
