import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'Register.dart';
import '../home/home.dart';
import '../../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showSuccessModal = false;

  late AnimationController _bounceController1;
  late AnimationController _bounceController2;
  late AnimationController _bounceController3;
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

    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Delay สำหรับ bounce animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceController2.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bounceController3.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _bounceController1.dispose();
    _bounceController2.dispose();
    _bounceController3.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Validate username
  bool _validateUsername(String username) {
    // ต้องมีตัวอักษรอย่างน้อย 1 ตัว
    if (!RegExp(r'[a-zA-Z]').hasMatch(username)) {
      setState(() {
        _errorMessage =
            'Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว';
      });
      return false;
    }

    // ต้องมีความยาวอย่างน้อย 3 ตัวอักษร
    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username ต้องมีอย่างน้อย 3 ตัวอักษร';
      });
      return false;
    }

    return true;
  }

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    // Validation
    if (username.isEmpty) {
      setState(() {
        _errorMessage = '⚠ Please enter username!';
      });
      return;
    }

    // Validate username format
    if (!_validateUsername(username)) {
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = '⚠ Please enter password!';
      });
      return;
    }

    // เรียก API
    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ เรียก AuthService.login (จะบันทึก tokens + userId อัตโนมัติ)
      await AuthService.login(username: username, password: password);

      // ✅ Login สำเร็จ (ถ้าไม่สำเร็จจะ throw exception)
      setState(() {
        _isLoading = false;
        _showSuccessModal = true;
      });

      // เริ่ม animation
      _progressController.forward();

      // รอ 2 วินาทีแล้ว redirect
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6fa85e),
                  Color(0xFF8bc273),
                  Color(0xFFa8d48f),
                ],
              ),
            ),
          ),

          // Pixel Grid Background
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          // Floating Pixels
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLoginBox(),
                    const SizedBox(height: 32),
                    _buildHintText(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Success Modal
          if (_showSuccessModal) _buildSuccessModal(),
        ],
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

  Widget _buildLoginBox() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(12, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner Pixels
          ..._buildCornerPixels(),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 6),
                  ),
                ),
                child: const Text(
                  '◆ LOGIN ◆',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(offset: Offset(3, 3), color: Color(0x80000000)),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'CAL-DEFICITS',
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937),
                        letterSpacing: 2,
                      ),
                    ),

                    // Pixel Dots
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: const Color(0xFF6fa85e),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          color: const Color(0xFF8bc273),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          color: const Color(0xFFa8d48f),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage.isNotEmpty) _buildErrorMessage(),

                    // Username Field
                    _buildInputField(
                      label: '> USERNAME',
                      controller: _usernameController,
                      hint: 'Enter username...',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildInputField(
                      label: '> PASSWORD',
                      controller: _passwordController,
                      hint: 'Enter password...',
                      isPassword: true,
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    _buildLoginButton(),

                    const SizedBox(height: 24),

                    // Footer Links
                    _buildFooterLinks(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerPixels() {
    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
    ];
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
        ),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/pic/logo.png',
        width: 128,
        height: 128,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFfecaca),
        border: Border.all(color: const Color(0xFFdc2626), width: 4),
      ),
      child: Row(
        children: [
          const Text('⚠', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                fontFamily: 'TA8bit',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF991b1b),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFf3f4f6),
            border: Border.all(color: const Color(0xFF1f2937), width: 4),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            inputFormatters: inputFormatters,
            onChanged: (value) {
              if (_errorMessage.isNotEmpty) {
                setState(() {
                  _errorMessage = '';
                });
              }
            },
            style: const TextStyle(
              fontFamily: 'TA8bit',
              color: Color(0xFF1f2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'TA8bit',
                color: Color(0xFF9ca3af),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
          ),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : const Text(
                '▶ LOGIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'TA8bit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(offset: Offset(2, 2), color: Color(0x80000000)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFd1d5db),
            width: 4,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Forgot password
              showDialog(
                context: context,
                builder: (context) => _buildPixelDialog(
                  title: 'FORGOT PASSWORD',
                  content: 'กรุณาติดต่อผู้ดูแลระบบ\nเพื่อรีเซ็ตรหัสผ่าน',
                ),
              );
            },
            child: const Text(
              '? Forgot Password',
              style: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4b5563),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1f2937),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: const Text(
                '↗ SIGN UP',
                style: TextStyle(
                  fontFamily: 'TA8bit',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintText() {
    return const Center(
      child: Text(
        '▼ ENTER YOUR CREDENTIALS ▼',
        style: TextStyle(
          fontFamily: 'TA8bit',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 1,
          shadows: [Shadow(offset: Offset(2, 2), color: Color(0x80000000))],
        ),
      ),
    );
  }

  Widget _buildSuccessModal() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
            ),
            border: Border.all(color: Colors.black, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Corner Pixels
              ..._buildCornerPixels().map((w) => w),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6fa85e),
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                    child: const Text(
                      '★ SUCCESS! ★',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(3, 3),
                            color: Color(0x80000000),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // Pixel Heart Icon
                        _buildPixelHeart(),

                        const SizedBox(height: 16),

                        // Message Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'LOGIN COMPLETE!',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1f2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Welcome back, User!',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: 14,
                                  color: Color(0xFF6b7280),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Loading Bar
                        _buildLoadingBar(),

                        const SizedBox(height: 12),

                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontFamily: 'TA8bit',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Color(0x80000000),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelHeart() {
    return SizedBox(
      width: 64,
      height: 64,
      child: GridView.count(
        crossAxisCount: 5,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _pixel(Colors.transparent),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(Colors.transparent),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(Colors.transparent),

          _pixel(const Color(0xFFff6b6b)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff6b6b)),

          _pixel(const Color(0xFFff6b6b)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff6b6b)),

          _pixel(Colors.transparent),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(const Color(0xFFff8787)),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(Colors.transparent),

          _pixel(Colors.transparent),
          _pixel(Colors.transparent),
          _pixel(const Color(0xFFff6b6b)),
          _pixel(Colors.transparent),
          _pixel(Colors.transparent),
        ],
      ),
    );
  }

  Widget _pixel(Color color) {
    return Container(width: 12, height: 12, color: color);
  }

  // ✅ แก้ไข Loading Bar - ให้เลื่อนแค่ส่วนใน
  Widget _buildLoadingBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF6fa85e), width: 4),
      ),
      child: Container(
        height: 24,
        width: double.infinity, // ✅ กำหนดความกว้างเต็ม
        decoration: const BoxDecoration(color: Color(0xFF2d2d2d)),
        child: Stack(
          children: [
            // ✅ Animated Inner Bar
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width *
                        _progressController.value *
                        0.85, // ✅ คำนวณความกว้างแทน
                    height: 24,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4ecdc4), Color(0xFF44a3c4)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const Spacer(),
                        Container(
                          height: 8,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixelDialog({required String title, required String content}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 4),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'TA8bit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'TA8bit',
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                    ),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: const Text(
                    '◀ CLOSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'TA8bit',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pixel Grid Painter
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
