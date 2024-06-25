import 'package:flutter/material.dart';

class RectanglePainter extends CustomPainter {
  final Offset start;
  final Color color;
  final double height;
  final double width;
  final bool showMeasurements;
  final double measurementScale;

  RectanglePainter({
    required this.start,
    required this.width,
    required this.color,
    this.showMeasurements = true,
    this.height = 100,
    this.measurementScale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(start.dx + width, start.dy);
    path.lineTo(start.dx + width, start.dy + height);
    path.lineTo(start.dx, start.dy + height);
    path.lineTo(start.dx, start.dy);
    path.close();

    canvas.drawPath(path, paint);

    if (showMeasurements) {
      // Draw measurements
      _drawMeasurements(canvas, start, width, height);
    }
  }

  void _drawMeasurements(
      Canvas canvas, Offset start, double width, double height) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      backgroundColor: Colors.white,
    );
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal measurement
    final horizontalText = (width * measurementScale).toStringAsFixed(1);
    textPainter.text = TextSpan(text: horizontalText, style: textStyle);
    textPainter.layout();
    final horizontalOffset = Offset(
      start.dx + width / 2 - textPainter.width / 2,
      start.dy - textPainter.height - 10,
    );
    textPainter.paint(canvas, horizontalOffset);

    // Draw vertical measurement
    final verticalText = (height * measurementScale).toStringAsFixed(1);
    textPainter.text = TextSpan(text: verticalText, style: textStyle);
    textPainter.layout();
    final verticalOffset = Offset(
      start.dx - textPainter.height - 10,
      start.dy + height / 2 + textPainter.width / 2,
    );
    canvas.save();
    canvas.translate(verticalOffset.dx, verticalOffset.dy);
    canvas.rotate(-3.14 / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RectanglePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.width != width ||
        oldDelegate.color != color ||
        oldDelegate.height != height;
  }
}
