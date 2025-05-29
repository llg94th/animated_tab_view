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
  })  : indices = List.generate(length, (index) => index),
        super(topIndex);

  int get topIndex => value;
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
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
  });

  /// The controller that manages the ordering and animations.
  final AnimatedReorderableController controller;

  /// How to align the non-positioned children in the stack.
  final AlignmentGeometry alignment;

  /// How to size the non-positioned children in the stack.
  final StackFit fit;

  /// The content will be clipped (or not) according to this option.
  final Clip clipBehavior;

  /// The list of children widgets.
  final List<Widget> children;

  @override
  State<AnimatedReorderableStack> createState() =>
      _AnimatedReorderableStackState();
}

class _AnimatedReorderableStackState extends State<AnimatedReorderableStack>
    with TickerProviderStateMixin {
  int? _draggingIndex;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedReorderableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildDraggableChild({
    required int index,
    required int positionInOrdering,
  }) {
    const childHeight = 300.0;
    const minTabWidth = 150.0;
    const overlapSpacing = 20.0;
    const kTabHeightSpacing = 4.0;
    const baseExtendedWidth = minTabWidth - overlapSpacing;

    const basePosition = Offset.zero;
    final zRatio =
        1 - min(1.0, max(_dragOffset.dx + minTabWidth, 0.0) / minTabWidth);
    final reducedWidth = zRatio * baseExtendedWidth;
    final increaseHeight = zRatio * kTabHeightSpacing;

    final isDragging = _draggingIndex == index;
    final tabWidth =
        minTabWidth + (positionInOrdering * baseExtendedWidth) - reducedWidth;
    final scaledHeight =
        childHeight - (positionInOrdering * kTabHeightSpacing) + increaseHeight;
    final scale = isDragging ? 1.0 : scaledHeight / childHeight;
    final finalPosition =
        isDragging ? basePosition + Offset(_dragOffset.dx, 0) : basePosition;
    final isTop = index == widget.controller.topIndex;
    final bottomAlignOffset = childHeight - scaledHeight;
    final opacity = isTop && isDragging
        ? (max(minTabWidth - _dragOffset.dx.abs(), 0.0) / minTabWidth).clamp(0.3, 1.0)
        : 1.0;
    return Positioned(
      left: finalPosition.dx,
      top: finalPosition.dy + bottomAlignOffset / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: isTop ? null : () => _handleTap(index),
            onPanStart: isTop
                ? (details) {
                    setState(() {
                      _draggingIndex = index;
                      _dragOffset = Offset.zero;
                    });
                  }
                : null,
            onPanUpdate: isTop
                ? (details) => setState(() => _dragOffset += details.delta)
                : null,
            onPanEnd:
                isTop ? (details) => _handleDragEnd(index, details) : null,
            child: TabContainer(
              gradient: [
                Colors.primaries[index % Colors.primaries.length],
                Colors.white
              ],
              width: 500,
              height: childHeight,
              titleWidth: tabWidth,
              titleHeight: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: tabWidth,
                    child: SizedBox(
                      width: minTabWidth,
                      height: 30,
                      child: Text(
                        'Tab Tab ${index + 1}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  widget.children[index],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int tappedIndex) {
    if (tappedIndex == widget.controller.topIndex) {
      // Tapped on current top card - cycle to next
      widget.controller.next();
      widget.controller.onReorder?.call(widget.controller.topIndex);
    } else {
      // Tapped on other card - make it the top card
      widget.controller.setTopIndex(tappedIndex);
      widget.controller.onReorder?.call(tappedIndex);
    }
  }

  void _handleDragEnd(int draggedIndex, DragEndDetails details) {
    final dragDistance = _dragOffset.dx.abs();
    final velocity = details.velocity.pixelsPerSecond;
    final isSwipe = dragDistance > 300 ||
        velocity.distance > 500; // Drag distance OR velocity threshold

    if (draggedIndex == widget.controller.topIndex) {
      // Current child swiped - move to next or previous based on swipe direction
      if (isSwipe) {
        log('isSwipe: $isSwipe');
        log('dragOffset: ${_dragOffset.dx}');
        if (_dragOffset.dx > 0) {
          // Swipe right - go to previous
          widget.controller.previous();
        } else {
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
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    log('building stack with indices: ${widget.controller.indices.toString()}');
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          return Stack(
            alignment: widget.alignment,
            fit: widget.fit,
            clipBehavior: widget.clipBehavior,
            children: [
              ...widget.controller.indices
                  .map((value) {
                    final positionInOrdering =
                        widget.controller.indices.indexOf(value);
                    return _buildDraggableChild(
                        index: value, positionInOrdering: positionInOrdering);
                  })
                  .toList()
                  .reversed,
              if (_draggingIndex != null)
                _buildDraggableChild(
                    index: _draggingIndex!,
                    positionInOrdering:
                        widget.controller.indices.indexOf(_draggingIndex ?? 0)),
            ],
          );
        });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('topIndex', widget.controller.topIndex));
    properties.add(
        DiagnosticsProperty<AlignmentGeometry>('alignment', widget.alignment));
    properties.add(EnumProperty<StackFit>('fit', widget.fit));
    properties.add(EnumProperty<Clip>('clipBehavior', widget.clipBehavior));
  }
}
