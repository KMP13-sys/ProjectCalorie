import 'package:flutter/material.dart';
import 'dart:async';

/// SplashScreen Widget
/// หน้า Splash Screen แบบ Pixel Art พร้อม Animation
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
  /// Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _bounceController;

  /// Lifecycle: เริ่มต้น Animations และ Navigation Timer
  @override
  void initState() {
    super.initState();

    // Animation: Pulse effect (1 วินาที)
    _pulseController =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
          ..repeat(reverse: true);

    // Animation: Bounce effect (1.5 วินาที)
    _bounceController =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
          ..repeat(reverse: true);

    // Animation: Progress bar (2 วินาที)
    _progressController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _progressController.forward();

    // Navigation: ไปหน้าปลายทางหลังจาก 2 วินาที
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.destination),
        );
      }
    });
  }

  /// Lifecycle: ทำความสะอาด Animation Controllers
  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดตามหน้าจอ
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
            // Section: Pixel Grid Background
            CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

            // Decoration: Floating pixel clouds
            _buildPixelCloud(top: 40, left: 40, isSmall: isSmall),
            _buildPixelCloud(top: isSmall ? 120 : 130, right: isSmall ? 60 : 80, isSmall: isSmall),

            // Section: Main Content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMainContainer(size: size, isSmall: isSmall, isTablet: isTablet),
                    ],
                  ),
                ),
              ),
            ),

            // Decoration: Floating pixel stars
            _buildFloatingStar(top: null, bottom: null, left: size.width * 0.25, isSmall: isSmall, delay: 0),
            _buildFloatingStar(top: null, bottom: size.height * 0.3, right: size.width * 0.25, isSmall: isSmall, delay: 300),
          ],
        ),
      ),
    );
  }

  /// Widget: สร้าง Pixel Cloud สำหรับตกแต่ง
  Widget _buildPixelCloud({double? top, double? bottom, double? left, double? right, required bool isSmall}) {
    final cloudSize = isSmall ? 60.0 : 96.0;
    final pixelSize = isSmall ? 8.0 : 12.0;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: 0.2,
        child: SizedBox(
          width: cloudSize,
          height: cloudSize * 0.66,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 24,
            itemBuilder: (context, index) {
              final showPixel = [0, 1, 5, 6, 7, 11, 12, 13, 14, 15, 16, 17].contains(index);
              return Container(
                width: pixelSize,
                height: pixelSize,
                color: showPixel ? Colors.white : Colors.transparent,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Widget: สร้าง Floating Star พร้อม Bounce Animation
  Widget _buildFloatingStar({double? top, double? bottom, double? left, double? right, required bool isSmall, required int delay}) {
    final starSize = isSmall ? 12.0 : 16.0;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceController.value * 10),
            child: Container(
              width: starSize,
              height: starSize,
              color: const Color(0xFFfde047),
            ),
          );
        },
      ),
    );
  }

  /// Widget: สร้าง Main Container (Logo, Title, Loading)
  Widget _buildMainContainer({required Size size, required bool isSmall, required bool isTablet}) {
    // Responsive: ขนาดต่างๆ ตามหน้าจอ
    final logoSize = isSmall ? 100.0 : (isTablet ? 120.0 : 128.0);
    final titleSize = isSmall ? 32.0 : (isTablet ? 40.0 : 48.0);
    final dotSize = isSmall ? 6.0 : 8.0;
    final loadingTextSize = isSmall ? 14.0 : (isTablet ? 16.0 : 18.0);
    final loadingBarWidth = isSmall ? 200.0 : (isTablet ? 240.0 : 256.0);

    return Container(
      padding: EdgeInsets.all(isSmall ? 32 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(12, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decoration: Corner pixels
          Positioned(top: 0, left: 0, child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e))),
          Positioned(top: 0, right: 0, child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e))),
          Positioned(bottom: 0, left: 0, child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e))),
          Positioned(bottom: 0, right: 0, child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e))),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Section: Logo
              _buildPixelLogo(size: logoSize, isSmall: isSmall),
              SizedBox(height: isSmall ? 20 : 24),

              // Section: Title
              Text(
                'CAL-DEFICITS',
                style: TextStyle(
                  fontSize: titleSize,
                  fontFamily: 'TA8bit',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1f2937),
                  letterSpacing: 4,
                  shadows: const [
                    Shadow(offset: Offset(4, 4), color: Color(0x806fa85e)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Decoration: Pixel dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: dotSize, height: dotSize, color: const Color(0xFF6fa85e)),
                  const SizedBox(width: 4),
                  Container(width: dotSize, height: dotSize, color: const Color(0xFF8bc273)),
                  const SizedBox(width: 4),
                  Container(width: dotSize, height: dotSize, color: const Color(0xFFa8d48f)),
                  const SizedBox(width: 4),
                  Container(width: dotSize, height: dotSize, color: const Color(0xFF8bc273)),
                  const SizedBox(width: 4),
                  Container(width: dotSize, height: dotSize, color: const Color(0xFF6fa85e)),
                ],
              ),
              SizedBox(height: isSmall ? 20 : 24),

              // Section: Loading text with pulse animation
              Container(
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
                          fontSize: loadingTextSize,
                          fontFamily: 'TA8bit',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: isSmall ? 16 : 20),

              // Section: Loading progress bar
              Container(
                width: loadingBarWidth,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFF374151), width: 4),
                ),
                child: Container(
                  height: isSmall ? 24 : 32,
                  decoration: const BoxDecoration(color: Color(0xFF2d2d2d)),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF6fa85e), Color(0xFFa8d48f)],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(height: isSmall ? 6 : 8, color: Colors.white.withValues(alpha: 0.4)),
                                  const Spacer(),
                                  Container(height: isSmall ? 6 : 8, color: Colors.black.withValues(alpha: 0.2)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Decoration: Sparkle pixels on corners
          Positioned(
            top: -8,
            right: -8,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseController.value,
                  child: Container(
                    width: isSmall ? 12 : 16,
                    height: isSmall ? 12 : 16,
                    color: const Color(0xFFfde047),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -8,
            left: -8,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 1 - _pulseController.value,
                  child: Container(
                    width: isSmall ? 12 : 16,
                    height: isSmall ? 12 : 16,
                    color: const Color(0xFFfde047),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget: สร้าง Logo พร้อม Pulse Animation
  Widget _buildPixelLogo({required double size, required bool isSmall}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1 + (_pulseController.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
              ),
              border: Border.all(color: Colors.black, width: 6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D000000),
                  offset: Offset(6, 6),
                ),
              ],
            ),
            child: Image.asset(
              'assets/pic/logo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

/// PixelGridPainter Class
/// วาดตาราง Pixel เป็น Background
class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
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
