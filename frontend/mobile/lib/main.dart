// lib/main.dart
import 'package:flutter/material.dart';
import 'src/open.dart';
import 'src/authen/login.dart';
import 'src/home/home.dart';
import 'service/auth_service.dart';

void main() {
  runApp(const CalDeficitsApp());
}

class CalDeficitsApp extends StatelessWidget {
  const CalDeficitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cal-Deficits',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'TA8bit'),
      home: const AuthWrapper(), // เช็ค session ก่อน
    );
  }
}

// Widget สำหรับเช็ค session
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // เช็คว่ามี session หรือไม่ (ทำงานใน background ขณะแสดง splash)
  Future<void> _checkSession() async {
    try {
      final hasSession = await AuthService.hasValidSession();

      if (mounted) {
        setState(() {
          // เลือก destination ตาม session
          _destination = hasSession ? const HomeScreen() : const LoginScreen();
        });
      }
    } catch (e) {
      print('Error checking session: $e');
      if (mounted) {
        setState(() {
          _destination = const LoginScreen();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  ถ้ายังไม่รู้ว่าจะไปไหน ให้ส่ง LoginScreen ไปก่อน (fallback)
    // แต่จริงๆ แล้ว _checkSession จะเสร็จก่อน animation หมด (2 วินาที)
    return SplashScreen(destination: _destination ?? const LoginScreen());
  }
}
