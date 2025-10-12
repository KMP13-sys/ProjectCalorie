import 'package:flutter/material.dart';
import 'navbaruser.dart';
import 'LogIn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ข้อมูลผู้ใช้ (ควรดึงจาก database จริง)
  final String username = 'MyPeach';
  final String weight = '65 kg';
  final String age = '25 years';
  final String height = '170 cm';
  final String gender = 'Male';
  final String goal = 'Lose Weight';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // Navbar
          NavBarUser(username: username),

          // เนื้อหาหน้า Profile
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // หัวข้อ PROFILE
                    const Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF204130),
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // รูปโปรไฟล์
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(90),
                        child: Image.asset(
                          'assets/default_profile.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // ถ้าไม่มีรูป แสดงไอคอน
                            return Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.person,
                                size: 100,
                                color: Color(0xFF204130),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ฟิลด์ข้อมูล
                    _buildInfoField('weight', weight),
                    const SizedBox(height: 15),

                    _buildInfoField('age', age),
                    const SizedBox(height: 15),

                    _buildInfoField('height', height),
                    const SizedBox(height: 15),

                    _buildInfoField('gender', gender),
                    const SizedBox(height: 15),

                    _buildInfoField('goal', goal),

                    const SizedBox(height: 40),

                    // ปุ่ม LOG OUT
                    Container(
                      width: 150,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9E09A),
                        border: Border.all(
                          color: const Color(0xFF204130),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: TextButton(
                        onPressed: _handleLogout,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          'LOG OUT',
                          style: TextStyle(
                            color: Color(0xFF204130),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับแสดงฟิลด์ข้อมูล
  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border.all(
          color: const Color(0xFF204130),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF204130),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF204130),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชัน Logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(
              color: Color(0xFF204130),
              width: 3,
            ),
          ),
          backgroundColor: const Color(0xFFDBFFC8),
          title: const Text(
            'ออกจากระบบ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF204130),
            ),
          ),
          content: const Text(
            'คุณต้องการออกจากระบบหรือไม่?',
            style: TextStyle(color: Color(0xFF204130)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                  color: Color(0xFF204130),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: ลบข้อมูล token, user data
                // await SharedPreferences.getInstance().then((prefs) {
                //   prefs.clear();
                // });

                Navigator.of(context).pop(); // ปิด dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // ลบ stack ทั้งหมด
                );
              },
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}