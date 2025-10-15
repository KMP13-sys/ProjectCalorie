import 'package:flutter/material.dart';
import 'dart:async';
import 'authen/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController1;
  late AnimationController _bounceController2;
  late AnimationController _bounceController3;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers สำหรับ floating pixels
    _bounceController1 = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController2 = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController3 = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // เริ่ม loading animation
    _progressController.forward();

    // Delay 300ms สำหรับ bounce 2 และ 3
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceController2.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bounceController3.forward();
    });

    // Navigate ไปหน้า login หลัง 2 วินาที
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6fa85e), // from-[#6fa85e]
              Color(0xFF8bc273), // via-[#8bc273]
              Color(0xFFa8d48f), // to-[#a8d48f]
            ],
          ),
        ),
        child: Stack(
          children: [
            // Pixel Grid Background Pattern
            CustomPaint(
              painter: PixelGridPainter(),
              size: Size.infinite,
            ),

            // Floating Pixel Decorations
            _buildFloatingPixel(
              controller: _bounceController1,
              top: 40,
              left: 40,
              size: 24,
            ),
            _buildFloatingPixel(
              controller: _bounceController2,
              top: 80,
              right: 64,
              size: 16,
            ),
            _buildFloatingPixel(
              controller: _bounceController3,
              bottom: 80,
              left: 80,
              size: 20,
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Pixel Border
                  _buildPixelLogo(),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  _buildTitle(),
                  
                  const SizedBox(height: 8),
                  
                  // Pixel Dots
                  _buildPixelDots(),
                  
                  const SizedBox(height: 32),
                  
                  // Loading Text
                  _buildLoadingText(),
                  
                  const SizedBox(height: 24),
                  
                  // Pixel Loading Bar
                  _buildLoadingBar(),
                  
                  const SizedBox(height: 16),
                  
                  // // Press to Start Button (optional)
                  // _buildPressToStart(),
                ],
              ),
            ),

            // Bottom hint text
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildHintText(),
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
                color: const Color(0xFFfde047), // yellow-300
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

  Widget _buildPixelLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFa8d48f),
            Color(0xFF8bc273),
          ],
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
            width: 128,
            height: 128,
            fit: BoxFit.contain,
          ),
          // Sparkle pixels
          Positioned(
            top: -8,
            right: -8,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseController.value,
                  child: Container(
                    width: 16,
                    height: 16,
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
                    width: 16,
                    height: 16,
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

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: const Text(
        'CAL-DEFICITS',
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: Color(0xFF1f2937), // gray-800
          letterSpacing: 4,
          shadows: [
            Shadow(
              offset: Offset(4, 4),
              color: Color(0x806fa85e),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixelDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 8, height: 8, color: const Color(0xFF6fa85e)),
        const SizedBox(width: 4),
        Container(width: 8, height: 8, color: const Color(0xFF8bc273)),
        const SizedBox(width: 4),
        Container(width: 8, height: 8, color: const Color(0xFFa8d48f)),
      ],
    );
  }

  Widget _buildLoadingText() {
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
            child: const Text(
              '> LOADING...',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'monospace',
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

  Widget _buildLoadingBar() {
    return Container(
      width: 256,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF374151), width: 4),
      ),
      child: Container(
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF2d2d2d),
        ),
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
                        colors: [
                          Color(0xFF4ecdc4),
                          Color(0xFF44a3c4),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const Spacer(),
                        Container(
                          height: 8,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget _buildPressToStart() {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const LoginScreen()),
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(top: 16),
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [
  //             Color(0xFF6fa85e),
  //             Color(0xFF8bc273),
  //           ],
  //         ),
  //         border: Border.all(color: Colors.black, width: 4),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.3),
  //             offset: const Offset(4, 4),
  //           ),
  //         ],
  //       ),
  //       child: const Text(
  //         '▶ PRESS TO START',
  //         style: TextStyle(
  //           fontFamily: 'monospace',
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //           fontSize: 16,
  //           letterSpacing: 1,
  //           shadows: [
  //             Shadow(
  //               offset: Offset(2, 2),
  //               color: Color(0x80000000),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHintText() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_pulseController.value * 0.5),
          child: const Center(
            child: Text(
              '▼ LOADING YOUR APP ▼',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    color: Color(0x80000000),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter สำหรับ Pixel Grid Background
class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // วาดเส้นแนวนอน
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // วาดเส้นแนวตั้ง
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}