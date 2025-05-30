
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const kCardRadius = 12.0;

class TabContainer extends StatelessWidget {
  const TabContainer({
    super.key,
    required this.child,
    this.gradient = const [Colors.white, Colors.red],
    this.width = 150,
    this.height = 120,
    this.titleWidth = 80,
    this.titleHeight = 30,
  });

  final Widget child;
  final List<Color> gradient;
  final double width;
  final double height;
  final double titleWidth;
  final double titleHeight;

  @override
  Widget build(BuildContext context) {
    return _TabHitTestWidget(
      titleWidth: titleWidth,
      titleHeight: titleHeight,
      child: CustomPaint(
        painter: CardPainter(
          titleHeight: titleHeight,
          titleWidth: titleWidth,
          gradient: gradient,
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}

class _TabHitTestWidget extends SingleChildRenderObjectWidget {
  const _TabHitTestWidget({
    required this.titleWidth,
    required this.titleHeight,
    required Widget child,
  }) : super(child: child);

  final double titleWidth;
  final double titleHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTabHitTest(
      titleWidth: titleWidth,
      titleHeight: titleHeight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTabHitTest renderObject) {
    renderObject
      ..titleWidth = titleWidth
      ..titleHeight = titleHeight;
  }
}

class _RenderTabHitTest extends RenderProxyBox {
  _RenderTabHitTest({
    required double titleWidth,
    required double titleHeight,
  }) : _titleWidth = titleWidth,
       _titleHeight = titleHeight;

  double _titleWidth;
  double get titleWidth => _titleWidth;
  set titleWidth(double value) {
    if (_titleWidth != value) {
      _titleWidth = value;
      markNeedsPaint();
    }
  }

  double _titleHeight;
  double get titleHeight => _titleHeight;
  set titleHeight(double value) {
    if (_titleHeight != value) {
      _titleHeight = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;

    // Create the same path as CardPainter to test if the hit is within the shape
    const leftShift = kCardRadius;
    const quadraticPoint = 1.5 / 5 * kCardRadius;
    const endPoint = 2 / 5 * kCardRadius;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double titlePadding = 0;
    final titleRect = Rect.fromLTWH(
      titlePadding,
      0,
      rect.width - titlePadding,
      titleHeight,
    );

    final path = Path()
      ..addRRect(RRect.fromRectXY(rect, kCardRadius, kCardRadius));
    final clipRRect = Rect.fromLTRB(
      titleWidth + titleRect.left,
      titleRect.top,
      rect.width,
      titleHeight,
    );
    final clipPath = Path()
      ..moveTo(clipRRect.left - kCardRadius, clipRRect.top)
      ..lineTo(clipRRect.right, clipRRect.top)
      ..lineTo(clipRRect.right, clipRRect.bottom + kCardRadius)
      ..conicTo(
        clipRRect.right,
        clipRRect.bottom,
        clipRRect.right - kCardRadius,
        clipRRect.bottom,
        1,
      )
      ..lineTo(clipRRect.left + leftShift + kCardRadius, clipRRect.bottom)
      ..quadraticBezierTo(
        clipRRect.left + leftShift + quadraticPoint,
        clipRRect.bottom,
        clipRRect.left + leftShift,
        clipRRect.bottom - endPoint,
      )
      ..lineTo(clipRRect.left, clipRRect.top + endPoint)
      ..quadraticBezierTo(
        clipRRect.left - quadraticPoint,
        clipRRect.top,
        clipRRect.left - kCardRadius,
        clipRRect.top,
      )
      ..close();

    final finalPath = Path.combine(PathOperation.difference, path, clipPath);

    // Test if the position is within the path
    if (finalPath.contains(position)) {
      return super.hitTest(result, position: position);
    }
    
    return false;
  }
}

class CardPainter extends CustomPainter {
  CardPainter({
    super.repaint,
    required this.titleHeight,
    required this.titleWidth,
    required this.gradient,
  });

  final double titleHeight;
  final double titleWidth;
  final List<Color> gradient;

  @override
  void paint(Canvas canvas, Size size) {
    const leftShift = kCardRadius; // công thức chuẩn quadraticBezierTo
    const quadraticPoint = 1.5 / 5 * kCardRadius;
    const endPoint = 2 / 5 * kCardRadius;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: gradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    double titlePadding = 0;
    final titleRect = Rect.fromLTWH(
      titlePadding,
      0,
      rect.width - titlePadding,
      titleHeight,
    );

    final path = Path()
      ..addRRect(RRect.fromRectXY(rect, kCardRadius, kCardRadius));
    final clipRRect = Rect.fromLTRB(
      titleWidth + titleRect.left,
      titleRect.top,
      rect.width,
      titleHeight,
    );
    final clipPath = Path()
      ..moveTo(clipRRect.left - kCardRadius, clipRRect.top)
      ..lineTo(clipRRect.right, clipRRect.top)
      ..lineTo(clipRRect.right, clipRRect.bottom + kCardRadius)
      ..conicTo(
        clipRRect.right,
        clipRRect.bottom,
        clipRRect.right - kCardRadius,
        clipRRect.bottom,
        1,
      )
      ..lineTo(clipRRect.left + leftShift + kCardRadius, clipRRect.bottom)
      ..quadraticBezierTo(
        clipRRect.left + leftShift + quadraticPoint,
        clipRRect.bottom,
        clipRRect.left + leftShift,
        clipRRect.bottom - endPoint,
      )
      ..lineTo(clipRRect.left, clipRRect.top + endPoint)
      ..quadraticBezierTo(
        clipRRect.left - quadraticPoint,
        clipRRect.top,
        clipRRect.left - kCardRadius,
        clipRRect.top,
      )
      ..close();

    final finalPath = Path.combine(PathOperation.difference, path, clipPath);

    canvas.drawShadow(
      finalPath.transform(Matrix4.translationValues(4, -1, 0).storage),
      Colors.black45,
      2,
      true,
    );
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CardPainter oldDelegate) =>
      gradient != oldDelegate.gradient;
}
