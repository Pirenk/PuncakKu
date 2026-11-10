import 'package:flutter/material.dart';

class MountainLogo extends StatelessWidget {
  final double size;
  final Color color;

  const MountainLogo({
    super.key,
    this.size = 32,
    this.color = const Color(0xFF1B4D3E),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.9),
      painter: MountainLogoPainter(color: color),
    );
  }
}

class MountainLogoPainter extends CustomPainter {
  final Color color;

  MountainLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Outer mountain contours with two peaks
    path.moveTo(size.width * 0.08, size.height * 0.88);
    path.lineTo(size.width * 0.32, size.height * 0.18); // Left peak
    path.lineTo(size.width * 0.52, size.height * 0.52); // Valley
    path.lineTo(size.width * 0.72, size.height * 0.28); // Right peak
    path.lineTo(size.width * 0.92, size.height * 0.88); // Right base
    path.close();

    // Internal curved wave line
    final wavePath = Path();
    wavePath.moveTo(size.width * 0.08, size.height * 0.68);
    wavePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.58,
      size.width * 0.55,
      size.height * 0.68,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.78,
      size.width * 0.92,
      size.height * 0.68,
    );

    canvas.drawPath(path, paint);
    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

