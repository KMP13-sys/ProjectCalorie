import 'package:flutter/material.dart';
import 'LogIn.dart'; // import หน้า login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // เพิ่ม delay 3 วินาที แล้วไปหน้า login อัตโนมัติ
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pic/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 30),
            const Text(
              'CAL-DEFICITS',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'TA8bit', // ใช้ฟอนต์ 8-bit
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'TA8bit', // ใช้ฟอนต์ 8-bit
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}