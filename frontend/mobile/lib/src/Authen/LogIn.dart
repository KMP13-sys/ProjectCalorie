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

  // Responsive Design Helpers
  // คำนวณขนาดหน้าจอสำหรับการปรับแต่ง UI
  double getResponsiveWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double getResponsiveHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // คำนวณขนาดฟอนต์ตามขนาดหน้าจอ
  // baseSize จะถูกเพิ่มขึ้น 30% และปรับตามความกว้างของหน้าจอ
  double getFontSize(BuildContext context, double baseSize) {
    double width = getResponsiveWidth(context);
    double scaledBase = baseSize * 1.3;

    if (width > 600) return scaledBase * 1.2;
    if (width > 400) return scaledBase * 1.1;
    return scaledBase;
  }

  // คำนวณระยะห่างระหว่าง elements ตามขนาดหน้าจอ
  double getSpacing(BuildContext context, double baseSpacing) {
    double width = getResponsiveWidth(context);
    if (width > 600) return baseSpacing * 1.2;
    if (width > 400) return baseSpacing;
    return baseSpacing * 0.9;
  }

  // Lifecycle: เริ่มต้น Animation Controllers
  // สร้าง animation controllers สำหรับ floating pixels และ progress bar
  @override
  void initState() {
    super.initState();

    // Animation สำหรับ floating pixels (3 ตัว)
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

    // Animation สำหรับ loading bar ใน success modal
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // เริ่ม animation แบบ stagger (ทีละตัว)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bounceController2.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bounceController3.forward();
    });
  }

  // Lifecycle: ทำความสะอาด resources เมื่อออกจากหน้า
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

  // Validation: ตรวจสอบ username
  // - ต้องมีตัวอักษร a-z หรือ A-Z อย่างน้อย 1 ตัว
  // - ต้องมีความยาวอย่างน้อย 3 ตัวอักษร
  bool _validateUsername(String username) {
    if (!RegExp(r'[a-zA-Z]').hasMatch(username)) {
      setState(() {
        _errorMessage = 'Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว';
      });
      return false;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username ต้องมีอย่างน้อย 3 ตัวอักษร';
      });
      return false;
    }

    return true;
  }

  // Business Logic: จัดการการ Login
  // เรียก AuthService และนำทางไปหน้า Home เมื่อสำเร็จ
  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    if (username.isEmpty) {
      setState(() {
        _errorMessage = '⚠ Please enter username!';
      });
      return;
    }

    if (!_validateUsername(username)) {
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = '⚠ Please enter password!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(username: username, password: password);

      setState(() {
        _isLoading = false;
        _showSuccessModal = true;
      });

      _progressController.forward();

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

  // UI: สร้างหน้า Login
  @override
  Widget build(BuildContext context) {
    final screenWidth = getResponsiveWidth(context);
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: Stack(
        children: [
          // Background: Gradient สีเขียว
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

          // Background: Pixel Grid Pattern
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          // Decoration: Floating Pixels (ซ่อนในหน้าจอเล็ก)
          if (!isSmallScreen) ...[
            _buildFloatingPixel(
              controller: _bounceController1,
              top: 40,
              left: 40,
              size: screenWidth > 600 ? 24 : 16,
            ),
            _buildFloatingPixel(
              controller: _bounceController2,
              top: 80,
              right: 64,
              size: screenWidth > 600 ? 16 : 12,
            ),
            _buildFloatingPixel(
              controller: _bounceController3,
              bottom: 80,
              left: 80,
              size: screenWidth > 600 ? 20 : 14,
            ),
          ],

          // Main Content: Login Box
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(getSpacing(context, 16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLoginBox(),
                    SizedBox(height: getSpacing(context, 32)),
                    _buildHintText(),
                    SizedBox(height: getSpacing(context, 40)),
                  ],
                ),
              ),
            ),
          ),

          // Modal: แสดงเมื่อ Login สำเร็จ
          if (_showSuccessModal) _buildSuccessModal(),
        ],
      ),
    );
  }

  // Widget: สร้าง Floating Pixel ที่เคลื่อนไหวขึ้นลง
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

  // Widget: สร้างกล่อง Login Box หลักพร้อม decoration
  Widget _buildLoginBox() {
    final screenWidth = getResponsiveWidth(context);
    final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.92;
    final borderWidth = screenWidth > 600 ? 8.0 : screenWidth > 400 ? 6.0 : 5.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(
              screenWidth > 600 ? 12 : screenWidth > 400 ? 8 : 6,
              screenWidth > 600 ? 12 : screenWidth > 400 ? 8 : 6,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoration: Pixel มุมกล่อง
          ..._buildCornerPixels(),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: แถบหัวข้อ "LOGIN"
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: getSpacing(context, 12),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: screenWidth > 600 ? 6 : screenWidth > 400 ? 4 : 3,
                    ),
                  ),
                ),
                child: Text(
                  '◆ LOGIN ◆',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: getFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: screenWidth > 400 ? 2 : 1,
                    shadows: const [
                      Shadow(offset: Offset(3, 3), color: Color(0x80000000)),
                    ],
                  ),
                ),
              ),

              // Content: เนื้อหาในกล่อง Login
              Padding(
                padding: EdgeInsets.all(getSpacing(context, 28)),
                child: Column(
                  children: [
                    // Logo
                    _buildLogo(),

                    SizedBox(height: getSpacing(context, 24)),

                    // App Name
                    Text(
                      'CAL-DEFICITS',
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: getFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1f2937),
                        letterSpacing: screenWidth > 400 ? 2 : 1,
                      ),
                    ),

                    // Decoration: Pixel ประดับ
                    SizedBox(height: getSpacing(context, 10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth > 400 ? 10 : 8,
                          height: screenWidth > 400 ? 10 : 8,
                          color: const Color(0xFF6fa85e),
                        ),
                        SizedBox(width: screenWidth > 400 ? 5 : 4),
                        Container(
                          width: screenWidth > 400 ? 10 : 8,
                          height: screenWidth > 400 ? 10 : 8,
                          color: const Color(0xFF8bc273),
                        ),
                        SizedBox(width: screenWidth > 400 ? 5 : 4),
                        Container(
                          width: screenWidth > 400 ? 10 : 8,
                          height: screenWidth > 400 ? 10 : 8,
                          color: const Color(0xFFa8d48f),
                        ),
                      ],
                    ),

                    SizedBox(height: getSpacing(context, 24)),

                    // Error Message
                    if (_errorMessage.isNotEmpty) _buildErrorMessage(),

                    // Input: Username Field
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

                    SizedBox(height: getSpacing(context, 20)),

                    // Input: Password Field
                    _buildInputField(
                      label: '> PASSWORD',
                      controller: _passwordController,
                      hint: 'Enter password...',
                      isPassword: true,
                    ),

                    SizedBox(height: getSpacing(context, 28)),

                    // Button: Login
                    _buildLoginButton(),

                    SizedBox(height: getSpacing(context, 24)),

                    // Link: Sign Up
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

  // Widget: สร้าง Pixel ประดับมุมกล่อง (4 มุม)
  List<Widget> _buildCornerPixels() {
    final screenWidth = getResponsiveWidth(context);
    final pixelSize = screenWidth > 600 ? 28.0 : screenWidth > 400 ? 24.0 : 20.0;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(width: pixelSize, height: pixelSize, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(width: pixelSize, height: pixelSize, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(width: pixelSize, height: pixelSize, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(width: pixelSize, height: pixelSize, color: const Color(0xFF6fa85e)),
      ),
    ];
  }

  // Widget: สร้างกล่องโลโก้แอพ
  Widget _buildLogo() {
    final screenWidth = getResponsiveWidth(context);
    final logoSize = screenWidth > 600 ? 140.0 : screenWidth > 400 ? 110.0 : 90.0;
    final borderWidth = screenWidth > 600 ? 5.0 : screenWidth > 400 ? 4.0 : 3.0;

    return Container(
      padding: EdgeInsets.all(getSpacing(context, 12)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
        ),
        border: Border.all(color: Colors.black, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/pic/logo.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }

  // Widget: สร้างกล่องแสดงข้อความ Error
  Widget _buildErrorMessage() {
    final screenWidth = getResponsiveWidth(context);
    final borderWidth = screenWidth > 600 ? 5.0 : screenWidth > 400 ? 4.0 : 3.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getSpacing(context, 12)),
      margin: EdgeInsets.only(bottom: getSpacing(context, 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFfecaca),
        border: Border.all(color: const Color(0xFFdc2626), width: borderWidth),
      ),
      child: Row(
        children: [
          Text('⚠', style: TextStyle(fontSize: getFontSize(context, 20))),
          SizedBox(width: getSpacing(context, 8)),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: getFontSize(context, 12),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF991b1b),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: สร้างช่องกรอกข้อมูล (Input Field)
  // รองรับทั้ง TextField ธรรมดาและ Password Field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final screenWidth = getResponsiveWidth(context);
    final borderWidth = screenWidth > 600 ? 5.0 : screenWidth > 400 ? 4.0 : 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: getFontSize(context, 15),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: getSpacing(context, 8)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFf3f4f6),
            border: Border.all(color: const Color(0xFF1f2937), width: borderWidth),
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
            style: TextStyle(
              fontFamily: 'TA8bit',
              fontSize: getFontSize(context, 14),
              color: const Color(0xFF1f2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: getFontSize(context, 14),
                color: const Color(0xFF9ca3af),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: getSpacing(context, 16),
                vertical: getSpacing(context, 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget: สร้างปุ่ม Login
  // แสดง loading indicator เมื่อกำลัง login
  Widget _buildLoginButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderWidth = screenWidth > 600 ? 6.0 : screenWidth > 400 ? 5.0 : 4.0;
    final paddingY = screenWidth > 600 ? 26.0 : screenWidth > 400 ? 22.0 : 18.0;
    final iconSize = screenWidth > 600 ? 38.0 : screenWidth > 400 ? 32.0 : 28.0;
    final fontSize = getFontSize(context, 18.0);
    final spacing = screenWidth > 600 ? 14.0 : screenWidth > 400 ? 12.0 : 10.0;

    return GestureDetector(
    onTap: _isLoading ? null : _handleLogin,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: paddingY),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
        ),
        border: Border.all(color: Colors.black, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(
              screenWidth > 600 ? 6 : screenWidth > 400 ? 4 : 3,
              screenWidth > 600 ? 6 : screenWidth > 400 ? 4 : 3,
            ),
          ),
        ],
      ),
      child: _isLoading
          ? Center(
              child: SizedBox(
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Image.asset(
                        'assets/pic/play.png',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Image.asset(
                      'assets/pic/play.png',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ],
                ),

                SizedBox(width: spacing),
                Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: screenWidth > 400 ? 1 : 0.5,
                    shadows: const [
                      Shadow(offset: Offset(2, 2), color: Color(0x80000000)),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // Widget: สร้างลิงก์ไปหน้า Sign Up
  Widget _buildFooterLinks() {
    final screenWidth = getResponsiveWidth(context);
    final borderWidth = screenWidth > 600 ? 5.0 : screenWidth > 400 ? 4.0 : 3.0;

    return Container(
      padding: EdgeInsets.only(top: getSpacing(context, 24)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFFd1d5db),
            width: borderWidth,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getSpacing(context, 16),
              vertical: getSpacing(context, 8),
            ),
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
            child: Text(
              '↗ SIGN UP',
              style: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: getFontSize(context, 12),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget: สร้างข้อความแนะนำด้านล่างกล่อง Login
  Widget _buildHintText() {
    return Center(
      child: Text(
        '▼ ENTER YOUR CREDENTIALS ▼',
        style: TextStyle(
          fontFamily: 'TA8bit',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: getFontSize(context, 14),
          letterSpacing: getResponsiveWidth(context) > 400 ? 1 : 0.5,
          shadows: const [Shadow(offset: Offset(2, 2), color: Color(0x80000000))],
        ),
      ),
    );
  }

  // Widget: สร้าง Success Modal เมื่อ Login สำเร็จ
  // แสดง loading bar และนำทางไปหน้า Home หลังจาก 2 วินาที
  Widget _buildSuccessModal() {
    final screenWidth = getResponsiveWidth(context);
    final maxWidth = screenWidth > 600 ? 450.0 : screenWidth * 0.88;
    final borderWidth = screenWidth > 600 ? 8.0 : screenWidth > 400 ? 6.0 : 5.0;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.all(getSpacing(context, 16)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
            ),
            border: Border.all(color: Colors.black, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(
                  screenWidth > 600 ? 8 : screenWidth > 400 ? 6 : 4,
                  screenWidth > 600 ? 8 : screenWidth > 400 ? 6 : 4,
                ),
              ),
            ],
          ),
          child: Stack(
            children: [
              ..._buildCornerPixels(),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: getSpacing(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6fa85e),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: screenWidth > 600 ? 4 : screenWidth > 400 ? 3 : 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '★ SUCCESS! ★',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: getFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: screenWidth > 400 ? 2 : 1,
                        shadows: const [
                          Shadow(
                            offset: Offset(3, 3),
                            color: Color(0x80000000),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Column(
                      children: [
                        _buildPixelHeart(),

                        SizedBox(height: screenWidth * 0.04),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: screenWidth > 600 ? 4 : screenWidth > 400 ? 3 : 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'LOGIN COMPLETE!',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: getFontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1f2937),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              Text(
                                'Welcome back, User!',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: getFontSize(context, 14),
                                  color: const Color(0xFF6b7280),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth * 0.04),

                        _buildLoadingBar(),

                        SizedBox(height: screenWidth * 0.03),

                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontFamily: 'TA8bit',
                            fontSize: getFontSize(context, 12),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Color(0x80000000),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: สร้างไอคอนหัวใจแบบ Pixel Art
  Widget _buildPixelHeart() {
    final screenWidth = getResponsiveWidth(context);
    final heartSize = screenWidth > 600 ? 72.0 : screenWidth > 400 ? 64.0 : 56.0;
    final pixelSize = heartSize / 5;

    return SizedBox(
      width: heartSize,
      height: heartSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(const Color(0xFFff8787), pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(const Color(0xFFff6b6b), pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
              _pixelWithSize(Colors.transparent, pixelSize),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Helper: สร้าง Pixel เดี่ยวตามขนาดที่กำหนด
  Widget _pixelWithSize(Color color, double size) {
    return Container(
      width: size,
      height: size,
      color: color,
    );
  }

  // Widget: สร้าง Loading Bar พร้อม Animation
  Widget _buildLoadingBar() {
    final screenWidth = getResponsiveWidth(context);
    final borderWidth = screenWidth > 600 ? 5.0 : screenWidth > 400 ? 4.0 : 3.0;

    return Container(
      padding: EdgeInsets.all(getSpacing(context, 8)),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF6fa85e), width: borderWidth),
      ),
      child: Container(
        height: screenWidth > 600 ? 24 : screenWidth > 400 ? 20 : 16,
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF2d2d2d)),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        _progressController.value *
                        0.85,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4ecdc4), Color(0xFF44a3c4)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: screenWidth > 600 ? 8 : screenWidth > 400 ? 6 : 5,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const Spacer(),
                        Container(
                          height: screenWidth > 600 ? 8 : screenWidth > 400 ? 6 : 5,
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

}

// Custom Painter: วาด Pixel Grid Pattern บนพื้นหลัง
// สร้างเส้นตารางแนวนอนและแนวตั้งทั้งหน้าจอ
class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // วาดเส้นแนวนอน
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // วาดเส้นแนวตั้ง
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}