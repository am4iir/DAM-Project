import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SolashScreen extends StatefulWidget {
  const SolashScreen({super.key});

  @override
  State<SolashScreen> createState() => _SolashScreenState();
}

class _SolashScreenState extends State<SolashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/singin');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom Icon with Petal Design
                  Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/log.png'), 
                    
                  ),
                   
                 
                  // App name
                  Text(
                    'canvus',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class PetalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

  
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    final petalPaint = Paint()
      ..color = const Color(0xFF00A8B5) 
      ..style = PaintingStyle.fill;

   
    final petalRadius = radius * 0.9;
    
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final angle = i * 90 * (3.14159 / 180);
      
      // Calculate petal edge points on circle
      Offset edgePoint1, edgePoint2;
      if (i == 0) { // Top
        edgePoint1 = Offset(center.dx - petalRadius * 0.6, center.dy - petalRadius * 0.9);
        edgePoint2 = Offset(center.dx + petalRadius * 0.6, center.dy - petalRadius * 0.9);
      } else if (i == 1) { // Right
        edgePoint1 = Offset(center.dx + petalRadius * 0.9, center.dy - petalRadius * 0.6);
        edgePoint2 = Offset(center.dx + petalRadius * 0.9, center.dy + petalRadius * 0.6);
      } else if (i == 2) { // Bottom
        edgePoint1 = Offset(center.dx + petalRadius * 0.6, center.dy + petalRadius * 0.9);
        edgePoint2 = Offset(center.dx - petalRadius * 0.6, center.dy + petalRadius * 0.9);
      } else { // Left
        edgePoint1 = Offset(center.dx - petalRadius * 0.9, center.dy + petalRadius * 0.6);
        edgePoint2 = Offset(center.dx - petalRadius * 0.9, center.dy - petalRadius * 0.6);
      }
      
      path.moveTo(edgePoint1.dx, edgePoint1.dy);
      
      
      final midPoint = Offset(
        center.dx + (edgePoint1.dx - center.dx) * 0.3,
        center.dy + (edgePoint1.dy - center.dy) * 0.3,
      );
      
      final nearCenter = Offset(
        center.dx + (edgePoint1.dx - center.dx) * 0.12,
        center.dy + (edgePoint1.dy - center.dy) * 0.12,
      );
      
      path.quadraticBezierTo(midPoint.dx, midPoint.dy, nearCenter.dx, nearCenter.dy);
      
      
      final midPoint2 = Offset(
        center.dx + (edgePoint2.dx - center.dx) * 0.3,
        center.dy + (edgePoint2.dy - center.dy) * 0.3,
      );
      
      path.quadraticBezierTo(midPoint2.dx, midPoint2.dy, edgePoint2.dx, edgePoint2.dy);
      
      // Arc along circle perimeter
      path.arcToPoint(
        edgePoint1,
        radius: Radius.circular(petalRadius),
        clockwise: i < 2,
        largeArc: false,
      );
      
      path.close();
      canvas.drawPath(path, petalPaint);
    }

    // Draw golden-brown four-pointed star in the center
    final starPaint = Paint()
      ..color = const Color(0xFFD4A574) // Golden-brown color
      ..style = PaintingStyle.fill;

    _drawFourPointedStar(canvas, center, radius * 0.25, starPaint);
  }

  void _drawFourPointedStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Draw four-pointed star (diamond shape)
    // Top point
    path.moveTo(center.dx, center.dy - size);
    // Right point
    path.lineTo(center.dx + size * 0.7, center.dy);
    // Bottom point
    path.lineTo(center.dx, center.dy + size);
    // Left point
    path.lineTo(center.dx - size * 0.7, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
