import 'package:flutter/material.dart';
import 'Register.dart';
import '../home/home.dart';
import 'api_service.dart'; // import API service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // เพิ่มตัวแปร loading

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

                  // const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4), // สีขาว --% โปร่งใส
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            'CAL-DEFICITS',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF204130),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Username Field
                        Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0x606D6D6D),
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 24,
                              ),
                            ),
                            style: const TextStyle(
                              color: const Color(0xFF515151),
                              fontSize: 24,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Password Field
                        Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0x606D6D6D),
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 24,
                              ),
                            ),
                            style: const TextStyle(
                              color: const Color(0xFF515151),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        Center(
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9E09A),
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: TextButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'LOG IN',
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

                        // Footer Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showForgotPasswordDialog();
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showRegisterDialog();
                              },
                              child: const Text(
                                "I Don't have account",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Validation
    if (username.isEmpty) {
      _showError('กรุณากรอก Username');
      return;
    }

    if (password.isEmpty) {
      _showError('กรุณากรอก Password');
      return;
    }

    // เรียก API
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        username: username,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // Login สำเร็จ
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        );


      // บันทึก token ถ้าต้องการ (ใช้ shared_preferences)
      // await SharedPreferences.getInstance().then((prefs) {
      //   prefs.setString('token', response.token ?? '');
      //   prefs.setInt('userId', response.user?.id ?? 0);
      //   prefs.setString('userEmail', response.user?.email ?? '');
      // });

      // ไปหน้า Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      } else {
        // มี error
        _showError(response.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Forgot Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}