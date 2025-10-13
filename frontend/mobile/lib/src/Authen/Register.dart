import 'package:flutter/material.dart';
import 'login.dart';
import 'api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = '';
  String _selectedGoal = '';
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _showSuccessModal = false;

  late AnimationController _pixelController;
  final List<Offset> _pixels = [];

  @override
  void initState() {
    super.initState();
    _pixelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // สร้าง floating pixels
    for (int i = 0; i < 15; i++) {
      _pixels.add(Offset((i * 50.0) % 400, (i * 80.0) % 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
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

          // Pixel Grid Pattern
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          // Floating Pixels Animation
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

          // Floating Decorations (3 จุด)
          Positioned(
            top: 40,
            left: 40,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.yellow[300],
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 60,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.yellow[300],
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 80,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.yellow[300],
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Registration Form Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                      border: Border.all(color: Colors.black, width: 8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(12, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Bar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                            ),
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: const Text(
                            '◆ CREATE ACCOUNT ◆',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logo
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFa8d88e), Color(0xFF8bc273)],
                              ),
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/pic/logo.png',
                              width: 128,
                              height: 128,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'CAL-DEFICITS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'TA8bit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF204130),
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Decorative Dots
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
                              color: const Color(0xFFa8d88e),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ACCOUNT INFO SECTION
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '▶ ACCOUNT INFO',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _buildLabeledInput(
                                label: 'USERNAME *',
                                controller: _usernameController,
                                hint: 'Enter username...',
                                allowedChars: ['a-z', 'A-Z', '0-9', '_'],
                              ),
                              const SizedBox(height: 12),

                              _buildLabeledInput(
                                label: 'EMAIL *',
                                controller: _emailController,
                                hint: 'Enter email...',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),

                              _buildLabeledInput(
                                label: 'PHONE *',
                                controller: _phoneController,
                                hint: 'Enter phone...',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              _buildLabeledInput(
                                label: 'PASSWORD *',
                                controller: _passwordController,
                                hint: 'Min 6 characters...',
                                isPassword: true,
                              ),
                              const SizedBox(height: 12),

                              _buildLabeledInput(
                                label: 'CONFIRM PASSWORD *',
                                controller: _confirmPasswordController,
                                hint: 'Re-enter password...',
                                isPassword: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // PERSONAL INFO SECTION
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '▶ PERSONAL INFO',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildLabeledInput(
                                      label: 'AGE *',
                                      controller: _ageController,
                                      hint: 'Years',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildLabeledDropdown(
                                      label: 'GENDER *',
                                      value: _selectedGender,
                                      hint: 'Select...',
                                      items: const ['Male', 'Female'],
                                      onChanged: (value) {
                                        setState(
                                          () => _selectedGender = value ?? '',
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildLabeledInput(
                                      label: 'HEIGHT *',
                                      controller: _heightController,
                                      hint: '(CM)',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildLabeledInput(
                                      label: 'WEIGHT *',
                                      controller: _weightController,
                                      hint: '(KG)',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _buildLabeledDropdown(
                                label: 'GOAL *',
                                value: _selectedGoal,
                                hint: 'Select goal...',
                                items: const [
                                  'Lose Weight',
                                  'Maintain Weight',
                                  'Gain Weight',
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedGoal = value ?? '');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms Checkbox
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(
                                      () => _acceptTerms = value ?? false,
                                    );
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showPrivacyPolicyDialog,
                                  child: const Text(
                                    'I ACCEPT TERMS AND PRIVACY POLICY',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Register Button
                        GestureDetector(
                          onTap: _isLoading ? null : _handleRegister,
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
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    '▶ CREATE ACCOUNT',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Back to Login
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(3, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '← BACK TO LOGIN',
                                style: TextStyle(
                                  fontFamily: 'TA8bit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
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
                  ),

                  const SizedBox(height: 20),

                  // Hint Text (ปรับใหม่)
                  const Text(
                    '▼ FILL IN YOUR DATA ▼',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(2, 2), color: Colors.black38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),

          // Success Modal
          if (_showSuccessModal)
            Container(
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
                      // Corner Pixels
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          color: const Color(0xFF6fa85e),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          color: const Color(0xFF6fa85e),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          color: const Color(0xFF6fa85e),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          color: const Color(0xFF6fa85e),
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Bar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6fa85e),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: const Text(
                              '★ ACCOUNT CREATED! ★',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(3, 3),
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Pixel Star Icon (5x5 grid)
                          _buildPixelStar(),

                          const SizedBox(height: 24),

                          // Message Box
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            child: Column(
                              children: const [
                                Text(
                                  'ACCOUNT CREATED!',
                                  style: TextStyle(
                                    fontFamily: 'TA8bit',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Welcome to CAL-DEFICITS!',
                                  style: TextStyle(
                                    fontFamily: 'TA8bit',
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Continue Button (Auto redirect)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            child: const Text(
                              '▶ CONTINUE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
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
            ),
        ],
      ),
    );
  }

  // Pixel Star Icon (5x5 grid)
  Widget _buildPixelStar() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        children: [
          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.yellow[300]),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          // Row 3 (Center)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.yellow[300]),
              Container(width: 16, height: 16, color: Colors.yellow[200]),
              Container(width: 16, height: 16, color: Colors.yellow[300]),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
            ],
          ),
          // Row 4
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.yellow[300]),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          // Row 5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.yellow[400]),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
        ],
      ),
    );
  }

  // Labeled Input Field (ไม่มี emoji)
  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    List<String>? allowedChars,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
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
              // Filter allowed characters (for username)
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
            style: const TextStyle(
              fontFamily: 'TA8bit',
              fontSize: 13,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'TA8bit',
                fontSize: 12,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Labeled Dropdown (ไม่มี emoji)
  Widget _buildLabeledDropdown({
    required String label,
    required String value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'TA8bit',
                fontSize: 13,
                color: Colors.black87,
              ),
              dropdownColor: Colors.white,
              icon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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

  // Register Handler
  Future<void> _handleRegister() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String weight = _weightController.text.trim();
    String height = _heightController.text.trim();
    String age = _ageController.text.trim();

    // Username validation (เหมือน Web)
    if (username.isEmpty) {
      _showPixelError('⚠ Please enter username!');
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(username)) {
      _showPixelError(
        '⚠ Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว',
      );
      return;
    }

    if (username.length < 3) {
      _showPixelError('⚠ Username ต้องมีอย่างน้อย 3 ตัวอักษร');
      return;
    }

    // Email validation
    if (email.isEmpty || !email.contains('@')) {
      _showPixelError('⚠ Please enter valid email!');
      return;
    }

    // Phone validation (ต้องเป็นตัวเลข 0-9 และ 10 หลัก)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _showPixelError('⚠ กรุณากรอกหมายเลขโทรศัพท์ 10 หลัก');
      return;
    }

    // Password validation
    if (password.isEmpty) {
      _showPixelError('⚠ Please enter password!');
      return;
    }

    if (password.length < 6) {
      _showPixelError('⚠ Password ต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    if (password != confirmPassword) {
      _showPixelError('⚠ Passwords do not match!');
      return;
    }

    // Age validation
    final ageNum = int.tryParse(age);
    if (ageNum == null || ageNum < 10 || ageNum > 120) {
      _showPixelError('⚠ กรุณากรอกอายุที่ถูกต้อง');
      return;
    }

    // Height validation
    final heightNum = double.tryParse(height);
    if (heightNum == null || heightNum < 100 || heightNum > 250) {
      _showPixelError('⚠ กรุณากรอกส่วนสูงที่ถูกต้อง');
      return;
    }

    // Weight validation
    final weightNum = double.tryParse(weight);
    if (weightNum == null || weightNum < 30 || weightNum > 300) {
      _showPixelError('⚠ กรุณากรอกน้ำหนักที่ถูกต้อง');
      return;
    }

    // Gender validation
    if (_selectedGender.isEmpty) {
      _showPixelError('⚠ Please select gender!');
      return;
    }

    // Goal validation
    if (_selectedGoal.isEmpty) {
      _showPixelError('⚠ Please select goal!');
      return;
    }

    // Terms validation
    if (!_acceptTerms) {
      _showPixelError('⚠ Accept terms to continue!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // เรียก API พร้อมส่งข้อมูลครบทุกฟิลด์
      final response = await ApiService.register(
        username: username,
        email: email,
        phone_number: phone,
        password: password,
        age: ageNum,
        gender: _selectedGender
            .toLowerCase(), // แปลงเป็นตัวพิมพ์เล็ก (male/female)
        height: heightNum,
        weight: weightNum,
        goal: _selectedGoal.toLowerCase(), // แปลงเป็นตัวพิมพ์เล็ก
      );

      setState(() => _isLoading = false);

      if (response.success) {
        if (!mounted) return;

        setState(() => _showSuccessModal = true);

        // Auto redirect หลัง 2 วินาที
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } else {
        _showPixelError('✗ ${response.message}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showPixelError('✗ Error: ${e.toString()}');
    }
  }

  // Pixel Error Message
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

  // Pixel Success Message
  void _showPixelSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[700],
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

  // Privacy Policy Dialog
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                // Corner Pixels
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFF6fa85e),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFF6fa85e),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFF6fa85e),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFF6fa85e),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
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
                          const Text(
                            'PRIVACY POLICY',
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
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
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPrivacySection(
                              '1. ข้อมูลที่เราเก็บรวบรวม',
                              'CAL-DEFICITS เก็บรวบรวมข้อมูลส่วนบุคคลของคุณ เช่น ชื่อผู้ใช้ อีเมล หมายเลขโทรศัพท์ และข้อมูลสุขภาพที่เกี่ยวข้องกับการคำนวณแคลอรี่ เพื่อใช้ในการให้บริการและปรับปรุงประสบการณ์การใช้งาน',
                            ),
                            const SizedBox(height: 16),

                            _buildPrivacySection(
                              '2. การใช้ข้อมูล',
                              'เราใช้ข้อมูลของคุณเพื่อ:\n• ให้บริการคำนวณและติดตามแคลอรี่\n• สร้างและจัดการบัญชีผู้ใช้งาน\n• ปรับปรุงและพัฒนาบริการของเรา\n• ส่งการแจ้งเตือนและข้อมูลที่เกี่ยวข้อง',
                            ),
                            const SizedBox(height: 16),

                            _buildPrivacySection(
                              '3. การปกป้องข้อมูล',
                              'เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลส่วนบุคคลของคุณจากการเข้าถึง การใช้ หรือการเปิดเผยโดยไม่ได้รับอนุญาต ข้อมูลทั้งหมดจะถูกเข้ารหัสและจัดเก็บอย่างปลอดภัย',
                            ),
                            const SizedBox(height: 16),

                            _buildPrivacySection(
                              '4. การแบ่งปันข้อมูล',
                              'เราจะไม่ขาย เช่า หรือแบ่งปันข้อมูลส่วนบุคคลของคุณให้กับบุคคลที่สาม ยกเว้นในกรณีที่จำเป็นตามกฎหมายหรือได้รับความยินยอมจากคุณ',
                            ),
                            const SizedBox(height: 16),

                            _buildPrivacySection(
                              '5. สิทธิของผู้ใช้งาน',
                              'คุณมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณได้ตลอดเวลา สามารถติดต่อเราได้ผ่านทางอีเมล หรือในส่วนการตั้งค่าบัญชี',
                            ),
                            const SizedBox(height: 16),

                            _buildPrivacySection(
                              '6. การเปลี่ยนแปลงนโยบาย',
                              'เราอาจปรับปรุงนโยบายความเป็นส่วนตัวนี้เป็นครั้งคราว การเปลี่ยนแปลงจะมีผลทันทีเมื่อเผยแพร่บนเว็บไซต์',
                            ),
                            const SizedBox(height: 20),

                            // Contact Section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'ติดต่อเรา',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'หากคุณมีคำถามเกี่ยวกับนโยบายความเป็นส่วนตัว กรุณาติดต่อเราที่:',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Email: support@cal-deficits.com\nวันที่มีผลบังคับใช้: 12 ตุลาคม 2025',
                                    style: TextStyle(
                                      fontFamily: 'TA8bit',
                                      fontSize: 11,
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

                    // Footer Button
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
                            ),
                          ),
                          child: const Text(
                            '◀ CLOSE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
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

  // Privacy Section Builder
  Widget _buildPrivacySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

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

// Floating Pixels Painter
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
