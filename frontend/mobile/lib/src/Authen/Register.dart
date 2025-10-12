import 'package:flutter/material.dart';
import 'LogIn.dart';
import 'api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Image.asset(
                    'assets/pic/logo.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'CAL-DEFICITS',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF204130),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Username
                        _buildInputField(
                          controller: _usernameController,
                          hintText: 'Username',
                        ),
                        const SizedBox(height: 12),

                        // Email
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        // Phone No
                        _buildInputField(
                          controller: _phoneController,
                          hintText: 'Phone No',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        // Password
                        _buildInputField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),

                        // Confirm Password
                        _buildInputField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),

                        // Weight
                        _buildInputField(
                          controller: _weightController,
                          hintText: 'Weight',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Height
                        _buildInputField(
                          controller: _heightController,
                          hintText: 'Height',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Age
                        _buildInputField(
                          controller: _ageController,
                          hintText: 'Age',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Gender
                        _buildInputField(
                          controller: _genderController,
                          hintText: 'Gender',
                        ),
                        const SizedBox(height: 12),

                        // Goal
                        _buildInputField(
                          controller: _goalController,
                          hintText: 'Goal',
                        ),

                        const SizedBox(height: 20),

                        // Checkbox ยอมรับเงื่อนไข
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // ✅ ให้ชิดกันแนวเดียว
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (bool? value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF204130),
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.black, width: 2),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // ✅ ลดช่องว่างรอบกล่อง
                              visualDensity: VisualDensity.compact, // ✅ ขยับกล่องให้ชิดข้อความ
                            ),
                            const SizedBox(width: 6), // ✅ ระยะห่างระหว่างกล่องกับข้อความ
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft, // ✅ ให้ข้อความชิดแนวเดียวกับกล่อง
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'TA8bit',
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I accept terms and conditions'),
                                      TextSpan(
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle, // ✅ ให้อยู่ระดับเดียวกับข้อความ
                                        child: GestureDetector(
                                          onTap: _showPrivacyPolicyDialog,
                                          child: const Text(
                                            'privacy policy',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ปุ่ม REGISTER
                        Center(
                          child: Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9E09A),
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: TextButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : const Text(
                                      'REGISTER',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ลิงก์กลับไปหน้า Login
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
                            child: const Text(
                              'Already have an account? Login here',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- สร้าง Input Field แบบเดียวกับหน้า Login ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0x606D6D6D),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(0),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF515151),
          fontSize: 20,
        ),
      ),
    );
  }

  // --- ฟังก์ชันสมัคร ---
  Future<void> _handleRegister() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    if (password != confirmPassword) {
      _showError('Password ไม่ตรงกัน');
      return;
    }

    if (!_acceptTerms) {
      _showError('กรุณายอมรับเงื่อนไขและนโยบายความเป็นส่วนตัว');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        username: username,
        email: email,
        phone_number: phone,
        password: password,
      );

      setState(() => _isLoading = false);

      if (response.success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showError(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // --- ฟังก์ชันแสดง Error ---
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Dialog นโยบายความเป็นส่วนตัว ---
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'นโยบายความเป็นส่วนตัว\n\n'
              'เราจะเก็บรักษาข้อมูลส่วนบุคคลของคุณอย่างปลอดภัย...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _goalController.dispose();
    super.dispose();
  }
}
