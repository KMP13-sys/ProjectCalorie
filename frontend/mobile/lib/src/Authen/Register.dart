import 'package:flutter/material.dart';
import 'login.dart';
import '../../service/auth_service.dart';

// Register Screen
// หน้าลงทะเบียนสำหรับผู้ใช้งานใหม่ พร้อม Responsive Design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Form Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Form State Variables
  String _selectedGender = '';
  String _selectedGoal = '';
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _showSuccessModal = false;

  // Animation: Floating pixels background
  late AnimationController _pixelController;
  final List<Offset> _pixels = [];

  // Lifecycle: เริ่มต้น Animation Controllers
  @override
  void initState() {
    super.initState();

    // Animation สำหรับ floating pixels background
    _pixelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // สร้าง pixel positions แบบกระจาย
    for (int i = 0; i < 15; i++) {
      _pixels.add(Offset((i * 50.0) % 400, (i * 80.0) % 600));
    }
  }

  // UI: สร้างหน้า Register
  @override
  Widget build(BuildContext context) {
    // คำนวณขนาดหน้าจอสำหรับ Responsive Design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final isMediumScreen = screenSize.width >= 400 && screenSize.width < 600;

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
                  Color(0xFFa8d88e),
                ],
              ),
            ),
          ),

          // Background: Pixel Grid Pattern
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          // Background: Floating Pixels Animation
          AnimatedBuilder(
            animation: _pixelController,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingPixelsPainter(
                  pixels: _pixels,
                  animation: _pixelController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Decoration: Floating Decorations
          _buildFloatingDecoration(40, 40, 24, null),
          _buildFloatingDecoration(80, null, 16, 60),
          _buildFloatingDecoration(null, 80, 20, 80),

          // Main Content: Registration Form
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Form Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: isSmallScreen ? 6 : 8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(isSmallScreen ? 8 : 12, isSmallScreen ? 8 : 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header: "CREATE ACCOUNT"
                        _buildHeader(isSmallScreen, isMediumScreen),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          child: Column(
                            children: [
                              // Logo
                              _buildLogo(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 12 : 16),

                              // App Name
                              Text(
                                'CAL-DEFICITS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: isSmallScreen ? 22 : isMediumScreen ? 26 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF204130),
                                  letterSpacing: 2,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Decoration: Pixel Dots
                              _buildDecorativeDots(),

                              SizedBox(height: isSmallScreen ? 20 : 24),

                              // Section: Account Info (Username, Email, Phone, Password)
                              _buildAccountInfoSection(isSmallScreen, isMediumScreen),

                              SizedBox(height: isSmallScreen ? 12 : 16),

                              // Section: Personal Info (Age, Gender, Height, Weight, Goal)
                              _buildPersonalInfoSection(isSmallScreen, isMediumScreen),

                              SizedBox(height: isSmallScreen ? 20 : 24),

                              // Checkbox: Terms and Privacy Policy
                              _buildTermsCheckbox(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Button: Register
                              _buildRegisterButton(isSmallScreen, isMediumScreen),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Link: Back to Login
                              _buildBackToLoginButton(isSmallScreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Hint Text
                  Text(
                    '▼ FILL IN YOUR DATA ▼',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(offset: Offset(2, 2), color: Colors.black38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Overlay: Loading
          if (_isLoading) _buildLoadingOverlay(),

          // Modal: Success
          if (_showSuccessModal) _buildSuccessModal(isSmallScreen),
        ],
      ),
    );
  }

  // Widget: สร้าง Floating Decoration (จุดตกแต่งลอย)
  Widget _buildFloatingDecoration(double? top, double? bottom, double size, double? right) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: top != null ? 40 : (bottom != null ? 80 : null),
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.yellow[300],
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  // Widget: สร้าง Header Bar "CREATE ACCOUNT"
  Widget _buildHeader(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 5),
        ),
      ),
      child: Text(
        '◆ CREATE ACCOUNT ◆',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'TA8bit',
          fontSize: isSmallScreen ? 20 : isMediumScreen ? 24 : 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Widget: สร้างกล่องโลโก้แอพ
  Widget _buildLogo(bool isSmallScreen) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFa8d88e),
              Color(0xFF8bc273),
            ],
          ),
          border: Border.all(
            color: Colors.black,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(4, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Image.asset(
          'assets/pic/logo.png',
          width: isSmallScreen ? 100 : 128,
          height: isSmallScreen ? 100 : 128,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Widget: สร้าง Pixel Dots ประดับ (3 สี)
  Widget _buildDecorativeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 8, height: 8, color: const Color(0xFF6fa85e)),
        const SizedBox(width: 4),
        Container(width: 8, height: 8, color: const Color(0xFF8bc273)),
        const SizedBox(width: 4),
        Container(width: 8, height: 8, color: const Color(0xFFa8d88e)),
      ],
    );
  }

  // Widget: สร้างส่วน Account Info
  // ประกอบด้วย Username, Email, Phone, Password, Confirm Password
  Widget _buildAccountInfoSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader('ACCOUNT INFO', isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),

          _buildLabeledInput(
            label: 'USERNAME *',
            controller: _usernameController,
            hint: 'Enter username...',
            allowedChars: ['a-z', 'A-Z', '0-9', '_'],
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          _buildLabeledInput(
            label: 'EMAIL *',
            controller: _emailController,
            hint: 'Enter email...',
            keyboardType: TextInputType.emailAddress,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          _buildLabeledInput(
            label: 'PHONE *',
            controller: _phoneController,
            hint: 'Enter phone...',
            keyboardType: TextInputType.phone,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          _buildLabeledInput(
            label: 'PASSWORD *',
            controller: _passwordController,
            hint: 'Min 8 characters...',
            isPassword: true,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          _buildLabeledInput(
            label: 'CONFIRM PASSWORD *',
            controller: _confirmPasswordController,
            hint: 'Re-enter password...',
            isPassword: true,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  // Widget: สร้างส่วน Personal Info
  // ประกอบด้วย Age, Gender, Height, Weight, Goal
  Widget _buildPersonalInfoSection(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader('PERSONAL INFO', isSmallScreen, isMediumScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Row 1: Age & Gender
          Row(
            children: [
              Expanded(
                child: _buildLabeledInput(
                  label: 'AGE *',
                  controller: _ageController,
                  hint: 'Years',
                  keyboardType: TextInputType.number,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: _buildLabeledDropdown(
                  label: 'GENDER *',
                  value: _selectedGender,
                  hint: 'Select...',
                  items: const ['MALE', 'FEMALE'],
                  onChanged: (value) {
                    setState(() => _selectedGender = value ?? '');
                  },
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          // Row 2: Height & Weight
          Row(
            children: [
              Expanded(
                child: _buildLabeledInput(
                  label: 'HEIGHT *',
                  controller: _heightController,
                  hint: '(CM)',
                  keyboardType: TextInputType.number,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: _buildLabeledInput(
                  label: 'WEIGHT *',
                  controller: _weightController,
                  hint: '(KG)',
                  keyboardType: TextInputType.number,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          // Dropdown: Goal Selection
          _buildLabeledDropdown(
            label: 'GOAL *',
            value: _selectedGoal,
            hint: 'Select goal...',
            items: const [
              'LOSE WEIGHT',
              'MAINTAIN WEIGHT',
              'GAIN WEIGHT',
            ],
            onChanged: (value) {
              setState(() => _selectedGoal = value ?? '');
            },
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  // Widget: สร้าง Section Header พร้อมไอคอน Play
  Widget _buildSectionHeader(String title, bool isSmallScreen, bool isMediumScreen) {
    final iconSize = isSmallScreen ? 20.0 : isMediumScreen ? 24.0 : 28.0;
    final fontSize = isSmallScreen ? 16.0 : isMediumScreen ? 18.0 : 20.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/pic/play.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          color: Colors.black87,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget: สร้าง Checkbox ยอมรับเงื่อนไขและความเป็นส่วนตัว
  Widget _buildTermsCheckbox(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(
          color: Colors.grey[800]!,
          width: 4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isSmallScreen ? 18 : 20,
            height: isSmallScreen ? 18 : 20,
            child: Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() => _acceptTerms = value ?? false);
              },
              activeColor: Colors.black87,
              checkColor: Colors.white,
              side: BorderSide(
                color: Colors.grey[800]!,
                width: 2,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: GestureDetector(
              onTap: _showPrivacyPolicyDialog,
              child: Text(
                'I ACCEPT TERMS AND PRIVACY POLICY',
                style: TextStyle(
                  fontFamily: 'TA8bit',
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: สร้างปุ่ม Register/Create Account
  // แสดง loading indicator เมื่อกำลังลงทะเบียน
  Widget _buildRegisterButton(bool isSmallScreen, bool isMediumScreen) {
    final iconSize = isSmallScreen ? 20.0 : isMediumScreen ? 24.0 : 28.0;
    final fontSize = isSmallScreen ? 16.0 : isMediumScreen ? 18.0 : 20.0;

    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
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
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pic/play.png',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'CREATE ACCOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: isSmallScreen ? 1.5 : 2,
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 2),
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Widget: สร้างปุ่มกลับไปหน้า Login
  Widget _buildBackToLoginButton(bool isSmallScreen) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : 24,
            vertical: isSmallScreen ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Text(
            '← BACK TO LOGIN',
            style: TextStyle(
              fontFamily: 'TA8bit',
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(2, 2),
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget: สร้าง Loading Overlay (เต็มหน้าจอ)
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 4,
        ),
      ),
    );
  }

  // Widget: สร้าง Success Modal เมื่อลงทะเบียนสำเร็จ
  // แสดง 2 วินาทีแล้วนำทางไปหน้า Login
  Widget _buildSuccessModal(bool isSmallScreen) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFa8d88e), Color(0xFF8bc273)],
            ),
            border: Border.all(color: Colors.black, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decoration: Corner Pixels
              _buildCornerPixel(0, 0, null, null),
              _buildCornerPixel(0, null, null, 0),
              _buildCornerPixel(null, 0, 0, null),
              _buildCornerPixel(null, null, 0, 0),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6fa85e),
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                    child: Text(
                      '★ ACCOUNT CREATED! ★',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(3, 3),
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon: Pixel Star
                  _buildPixelStar(),

                  const SizedBox(height: 24),

                  // Message
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 24),
                    padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ACCOUNT CREATED!',
                          style: TextStyle(
                            fontFamily: 'TA8bit',
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to CAL-DEFICITS!',
                          style: TextStyle(
                            fontFamily: 'TA8bit',
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button: Continue
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 24),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                      ),
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '▶ CONTINUE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(2, 2),
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper: สร้าง Pixel มุมกล่อง (Corner Pixel)
  Widget _buildCornerPixel(double? top, double? bottom, double? left, double? right) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 16,
        height: 16,
        color: const Color(0xFF6fa85e),
      ),
    );
  }

  // Widget: สร้างไอคอนดาว Pixel Art (5x5 grid)
  Widget _buildPixelStar() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        children: [
          _buildPixelStarRow([false, false, true, false, false]),
          _buildPixelStarRow([false, true, true, true, false], isMiddle: true),
          _buildPixelStarRow([true, true, true, true, true], isCenter: true),
          _buildPixelStarRow([false, true, true, true, false], isMiddle: true),
          _buildPixelStarRow([false, false, true, false, false]),
        ],
      ),
    );
  }

  // Widget Helper: สร้างแถวของดาว Pixel พร้อมการไล่สี
  Widget _buildPixelStarRow(List<bool> pattern, {bool isCenter = false, bool isMiddle = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((filled) {
        Color? color;
        if (filled) {
          if (isCenter) {
            color = Colors.yellow[200];
          } else if (isMiddle) {
            color = Colors.yellow[300];
          } else {
            color = Colors.yellow[400];
          }
        } else {
          color = Colors.transparent;
        }
        return Container(width: 16, height: 16, color: color);
      }).toList(),
    );
  }

  // Widget: สร้าง Input Field พร้อม Label
  // รองรับ password mode และ input validation
  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    List<String>? allowedChars,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[800]!, width: 3),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            onChanged: (value) {
              // Filter input ตาม allowedChars
              if (allowedChars != null) {
                final filtered = value.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
                if (filtered != value) {
                  controller.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length),
                  );
                }
              }
              if (onChanged != null) {
                onChanged(controller.text);
              }
            },
            style: TextStyle(
              fontFamily: 'TA8bit',
              fontSize: isSmallScreen ? 13 : 15,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: isSmallScreen ? 13 : 15,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 8 : 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget: สร้าง Dropdown พร้อม Label
  Widget _buildLabeledDropdown({
    required String label,
    required String value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[800]!, width: 3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              isExpanded: true,
              style: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: isSmallScreen ? 13 : 15,
                color: Colors.black87,
              ),
              dropdownColor: Colors.white,
              icon: Padding(
                padding: EdgeInsets.only(right: isSmallScreen ? 10 : 12),
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
                    child: Text(item),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Business Logic: จัดการการลงทะเบียน
  // ตรวจสอบความถูกต้องของข้อมูลและเรียก AuthService
  Future<void> _handleRegister() async {
    // ดึงค่าจาก Form Controllers
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String weight = _weightController.text.trim();
    String height = _heightController.text.trim();
    String age = _ageController.text.trim();

    // Validation: Username
    if (username.isEmpty) {
      _showPixelError('⚠ Please enter username!');
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(username)) {
      _showPixelError('⚠ Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว');
      return;
    }

    if (username.length < 3) {
      _showPixelError('⚠ Username ต้องมีอย่างน้อย 3 ตัวอักษร');
      return;
    }

    // Validation: Email
    if (email.isEmpty || !email.contains('@')) {
      _showPixelError('⚠ Please enter email!');
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showPixelError('⚠ Please enter valid email format!');
      return;
    }

    // Validation: Phone (ต้องเป็นตัวเลข 10 หลัก)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _showPixelError('⚠ กรุณากรอกหมายเลขโทรศัพท์ 10 หลัก');
      return;
    }

    // Validation: Password
    if (password.isEmpty) {
      _showPixelError('⚠ Please enter password!');
      return;
    }

    if (password.length < 8) {
      _showPixelError('⚠ Password ต้องมีอย่างน้อย 8 ตัวอักษร');
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      _showPixelError('⚠ Password ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว');
      return;
    }

    if (password != confirmPassword) {
      _showPixelError('⚠ Passwords do not match!');
      return;
    }

    // Validation: Age (13-120 ปี)
    final ageNum = int.tryParse(age);
    if (ageNum == null || ageNum < 13 || ageNum > 120) {
      _showPixelError('⚠ ต้องมีอายุอย่างน้อย 13 ปีขึ้นไป');
      return;
    }

    // Validation: Height (100-250 cm)
    final heightNum = double.tryParse(height);
    if (heightNum == null || heightNum < 100 || heightNum > 250) {
      _showPixelError('⚠ กรุณากรอกส่วนสูงที่ถูกต้อง');
      return;
    }

    // Validation: Weight (30-300 kg)
    final weightNum = double.tryParse(weight);
    if (weightNum == null || weightNum < 30 || weightNum > 300) {
      _showPixelError('⚠ กรุณากรอกน้ำหนักที่ถูกต้อง');
      return;
    }

    // Validation: Gender
    if (_selectedGender.isEmpty) {
      _showPixelError('⚠ Please select gender!');
      return;
    }

    // Validation: Goal
    if (_selectedGoal.isEmpty) {
      _showPixelError('⚠ Please select goal!');
      return;
    }

    // Validation: Terms Acceptance
    if (!_acceptTerms) {
      _showPixelError('⚠ Accept terms to continue!');
      return;
    }

    // Start Loading
    setState(() => _isLoading = true);

    try {
      // API Call: Register
      await AuthService.register(
        username: username,
        email: email,
        phoneNumber: phone,
        password: password,
        age: ageNum,
        gender: _selectedGender.toLowerCase(),
        height: heightNum,
        weight: weightNum,
        goal: _selectedGoal.toLowerCase(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Show Success Modal
      setState(() => _showSuccessModal = true);

      // Navigate to Login after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showPixelError('✗ $errorMessage');
    }
  }

  // Helper: แสดง Error Message แบบ Pixel Style (SnackBar)
  void _showPixelError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[700],
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'TA8bit',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog: แสดง Privacy Policy
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 400;

        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 8),
            ),
            child: Stack(
              children: [
                // Decoration: Corner Pixels
                _buildCornerPixel(0, null, 0, null),
                _buildCornerPixel(0, null, null, 0),
                _buildCornerPixel(null, 0, 0, null),
                _buildCornerPixel(null, 0, null, 0),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PRIVACY POLICY',
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  offset: Offset(3, 3),
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              '×',
                              style: TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 32,
                                color: Colors.white,
                                height: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPrivacySection(
                              '1. ข้อมูลที่เราเก็บรวบรวม',
                              'CAL-DEFICITS เก็บรวบรวมข้อมูลส่วนบุคคลของคุณ เช่น ชื่อผู้ใช้ อีเมล หมายเลขโทรศัพท์ และข้อมูลสุขภาพที่เกี่ยวข้องกับการคำนวณแคลอรี่ เพื่อใช้ในการให้บริการและปรับปรุงประสบการณ์การใช้งาน',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildPrivacySection(
                              '2. การใช้ข้อมูล',
                              'เราใช้ข้อมูลของคุณเพื่อ:\n• ให้บริการคำนวณและติดตามแคลอรี่\n• สร้างและจัดการบัญชีผู้ใช้งาน\n• ปรับปรุงและพัฒนาบริการของเรา\n• ส่งการแจ้งเตือนและข้อมูลที่เกี่ยวข้อง',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildPrivacySection(
                              '3. การปกป้องข้อมูล',
                              'เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลส่วนบุคคลของคุณจากการเข้าถึง การใช้ หรือการเปิดเผยโดยไม่ได้รับอนุญาต ข้อมูลทั้งหมดจะถูกเข้ารหัสและจัดเก็บอย่างปลอดภัย',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildPrivacySection(
                              '4. การแบ่งปันข้อมูล',
                              'เราจะไม่ขาย เช่า หรือแบ่งปันข้อมูลส่วนบุคคลของคุณให้กับบุคคลที่สาม ยกเว้นในกรณีที่จำเป็นตามกฎหมายหรือได้รับความยินยอมจากคุณ',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildPrivacySection(
                              '5. สิทธิของผู้ใช้งาน',
                              'คุณมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณได้ตลอดเวลา สามารถติดต่อเราได้ผ่านทางอีเมล หรือในส่วนการตั้งค่าบัญชี',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildPrivacySection(
                              '6. การเปลี่ยนแปลงนโยบาย',
                              'เราอาจปรับปรุงนโยบายความเป็นส่วนตัวนี้เป็นครั้งคราว การเปลี่ยนแปลงจะมีผลทันทีเมื่อเผยแพร่บนเว็บไซต์',
                              isSmallScreen,
                            ),
                            const SizedBox(height: 20),

                            // Contact Information
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ติดต่อเรา',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: isSmallScreen ? 13 : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'หากคุณมีคำถามเกี่ยวกับนโยบายความเป็นส่วนตัว กรุณาติดต่อเราที่:',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: isSmallScreen ? 11 : 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Email: support@cal-deficits.com\nวันที่มีผลบังคับใช้: 12 ตุลาคม 2025',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: isSmallScreen ? 11 : 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer: Close Button
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 4),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                            ),
                          ),
                          child: Text(
                            '◀ CLOSE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: isSmallScreen ? 14 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Helper: สร้างส่วนแสดงข้อความ Privacy Policy
  Widget _buildPrivacySection(String title, String content, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: isSmallScreen ? 13 : 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: isSmallScreen ? 11 : 13,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Lifecycle: ทำความสะอาด resources เมื่อออกจากหน้า
  @override
  void dispose() {
    _pixelController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
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

// Custom Painter: วาด Floating Pixels Animation
// Pixels จะเคลื่อนที่แนวตั้งและวนกลับมาด้านบนเมื่อถึงด้านล่าง
class FloatingPixelsPainter extends CustomPainter {
  final List<Offset> pixels;
  final double animation;

  FloatingPixelsPainter({required this.pixels, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);

    for (int i = 0; i < pixels.length; i++) {
      final offset = Offset(
        pixels[i].dx,
        (pixels[i].dy + (animation * 600)) % size.height,
      );

      canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, 8, 8), paint);
    }
  }

  @override
  bool shouldRepaint(FloatingPixelsPainter oldDelegate) => true;
}
