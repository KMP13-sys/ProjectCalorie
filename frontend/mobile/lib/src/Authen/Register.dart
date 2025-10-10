import 'package:flutter/material.dart';
import 'editprofile.dart'; // import หน้า Login
import 'api_service.dart'; // import API service


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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false; // เพิ่มตัวแปรสำหรับแสดง loading

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
                  const SizedBox(height: 60),

                  Container(
                    width: 150,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 70,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            color: const Color(0xFFE0E0E0),
                            child: const Text(
                              'CAL-DEFICITS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildInputField(
                          controller: _usernameController,
                          hintText: 'Username',
                        ),

                        const SizedBox(height: 12),

                        _buildInputField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 12),

                        _buildInputField(
                          controller: _phoneController,
                          hintText: 'Phone No *',
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 12),

                        _buildInputField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                        ),

                        const SizedBox(height: 12),

                        _buildInputField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          isPassword: true,
                        ),

                        const SizedBox(height: 15),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _acceptTerms
                                    ? Colors.green
                                    : const Color(0xFFE0E0E0),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: Colors.transparent,
                                checkColor: Colors.white,
                                side: BorderSide.none,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'I accept term and condition and ',
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          _showPrivacyPolicyDialog();
                                        },
                                        child: const Text(
                                          'privacy policy',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.blue,
                                            decorationThickness: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Container(
                            width: 120,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
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
                                      'REGISTER',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Already have an account? Login here',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }

  Future<void> _handleRegister() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phone_number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (username.isEmpty) {
      _showError('กรุณากรอก Username');
      return;
    }

    if (email.isEmpty) {
      _showError('กรุณากรอก Email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('รูปแบบ Email ไม่ถูกต้อง');
      return;
    }

    if (phone_number.isEmpty) {
      _showError('กรุณากรอกหมายเลขโทรศัพท์');
      return;
    }

    if (password.isEmpty) {
      _showError('กรุณากรอก Password');
      return;
    }

    if (password.length < 6) {
      _showError('Password ต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    if (password != confirmPassword) {
      _showError('Password ไม่ตรงกัน');
      return;
    }

    if (!_acceptTerms) {
      _showError('กรุณายอมรับเงื่อนไขและความเป็นส่วนตัว');
      return;
    }

    // เรียก API
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.register(
        username: username,
        email: email,
        phone_number: phone_number,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // สมัครสมาชิกสำเร็จ
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
        // });

        // กลับไปหน้า Login
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        });
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  color: const Color(0xFFE0E0E0),
                  child: const Text(
                    'PRIVACY POLICY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                const Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. การเก็บรวบรวมข้อมูล',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'เราจะเก็บรวบรวมข้อมูลส่วนบุคคลที่จำเป็นสำหรับการให้บริการแอปพลิเคชัน Cal-Deficits เท่านั้น ข้อมูลที่เก็บรวบรวมประกอบด้วย ชื่อผู้ใช้ อีเมล หมายเลขโทรศัพท์ และข้อมูลการใช้งานแอปพลิเคชัน',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          '2. การใช้ข้อมูล',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ข้อมูลของท่านจะถูกใช้เพื่อ:\n• ให้บริการแอปพลิเคชันและปรับปรุงประสบการณ์การใช้งาน\n• ติดต่อสื่อสารเกี่ยวกับการบริการ\n• วิเคราะห์และปรับปรุงคุณภาพการบริการ\n• ส่งการแจ้งเตือนที่เกี่ยวข้องกับการใช้งาน',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          '3. การปกป้องข้อมูล',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อป้องกันการเข้าถึง การใช้ การเปลี่ยนแปลง หรือการเปิดเผยข้อมูลส่วนบุคคลของท่านโดยไม่ได้รับอนุญาต',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          '4. การแบ่งปันข้อมูล',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'เราจะไม่แบ่งปันข้อมูลส่วนบุคคลของท่านให้กับบุคคลที่สาม เว้นแต่ได้รับความยินยอมจากท่าน หรือเป็นการปฏิบัติตามกฎหมายที่เกี่ยวข้อง',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          '5. สิทธิของผู้ใช้',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ท่านมีสิทธิในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของท่าน รวมทั้งสิทธิในการคัดค้านการประมวลผลข้อมูล ท่านสามารถติดต่อเราเพื่อใช้สิทธิดังกล่าวได้ตลอดเวลา',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          '6. การติดต่อ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'หากท่านมีข้อสงสัยเกี่ยวกับนโยบายความเป็นส่วนตัวนี้ กรุณาติดต่อเราที่ support@cal-deficits.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20),

                        Text(
                          'นโยบายฉบับนี้มีผลบังคับใช้ตั้งแต่วันที่ 26 กันยายน 2025',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
