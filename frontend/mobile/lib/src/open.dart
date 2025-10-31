// lib/src/open.dart
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget destination;

  const SplashScreen({
    super.key,
    required this.destination,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController1;
  late AnimationController _bounceController2;
  late AnimationController _bounceController3;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _bounceController1 =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
          ..repeat(reverse: true);
    _bounceController2 =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
          ..repeat(reverse: true);
    _bounceController3 =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
          ..repeat(reverse: true);

    _pulseController =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
          ..repeat(reverse: true);
    _progressController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _progressController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceController2.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bounceController3.forward();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.destination),
        );
      }
    });
  }

  @override
  void dispose() {
    _bounceController1.dispose();
    _bounceController2.dispose();
    _bounceController3.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6fa85e), Color(0xFF8bc273), Color(0xFFa8d48f)],
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

            _buildFloatingPixel(controller: _bounceController1, top: 40, left: 40, size: isSmall ? 16 : 24),
            _buildFloatingPixel(controller: _bounceController2, top: 80, right: 64, size: isSmall ? 12 : 16),
            _buildFloatingPixel(controller: _bounceController3, bottom: 80, left: 80, size: isSmall ? 14 : 20),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPixelLogo(size: isSmall ? 80 : (isTablet ? 100 : 128)),
                      SizedBox(height: isSmall ? 16 : 24),
                      _buildTitle(fontSize: isSmall ? 28 : (isTablet ? 34 : 40)),
                      const SizedBox(height: 8),
                      _buildPixelDots(dotSize: isSmall ? 6 : 8),
                      SizedBox(height: isSmall ? 20 : 32),
                      _buildLoadingText(fontSize: isSmall ? 14 : 18),
                      SizedBox(height: isSmall ? 16 : 24),
                      _buildLoadingBar(width: isSmall ? 180 : (isTablet ? 220 : 256)),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: isSmall ? 20 : 40,
              left: 0,
              right: 0,
              child: _buildHintText(fontSize: isSmall ? 12 : 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPixel({
    required AnimationController controller,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, controller.value * 10),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFfde047),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPixelLogo({required double size}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1 + (_pulseController.value * 0.05); // ✅ tablet มี pulse เบาๆ
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
              ),
              border: Border.all(color: Colors.black, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(8, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Image.asset(
                  'assets/pic/logo.png',
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Opacity(
                    opacity: _pulseController.value,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFFfde047),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: -8,
                  child: Opacity(
                    opacity: 1 - _pulseController.value,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFFfde047),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle({required double fontSize}) {
    return Text(
      'CAL-DEFICITS',
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: 'TA8bit',
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1f2937),
        letterSpacing: 4,
        shadows: const [Shadow(offset: Offset(4, 4), color: Color(0x806fa85e))],
      ),
    );
  }

  Widget _buildPixelDots({required double dotSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: dotSize, height: dotSize, color: const Color(0xFF6fa85e)),
        const SizedBox(width: 4),
        Container(width: dotSize, height: dotSize, color: const Color(0xFF8bc273)),
        const SizedBox(width: 4),
        Container(width: dotSize, height: dotSize, color: const Color(0xFFa8d48f)),
      ],
    );
  }

  Widget _buildLoadingText({required double fontSize}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF6fa85e), width: 4),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + (_pulseController.value * 0.5),
            child: Text(
              '> LOADING...',
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'TA8bit',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingBar({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF374151), width: 4),
      ),
      child: Container(
        height: 32,
        decoration: const BoxDecoration(color: Color(0xFF2d2d2d)),
        child: AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return FractionallySizedBox(
              widthFactor: _progressController.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4ecdc4), Color(0xFF44a3c4)],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHintText({required double fontSize}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_pulseController.value * 0.5),
          child: Center(
            child: Text(
              '▼ LOADING YOUR APP ▼',
              style: TextStyle(
                fontFamily: 'TA8bit',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: fontSize,
                letterSpacing: 1,
                shadows: const [Shadow(offset: Offset(2, 2), color: Color(0x80000000))],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
