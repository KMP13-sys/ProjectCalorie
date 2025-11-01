import 'package:flutter/material.dart';
import 'src/open.dart';
import 'src/authen/login.dart';
import 'src/home/home.dart';
import 'service/auth_service.dart';

void main() {
  runApp(const CalDeficitsApp());
}

/// CalDeficitsApp
/// Root Widget ของแอปพลิเคชัน
class CalDeficitsApp extends StatelessWidget {
  const CalDeficitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cal-Deficits',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'TA8bit'),
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper Widget
/// ตรวจสอบ Session และเลือก Destination (Home หรือ Login)
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  /// State Variables
  Widget? _destination;

  /// Lifecycle: เริ่มต้นตรวจสอบ Session
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Business Logic: ตรวจสอบ Session และกำหนด Destination
  Future<void> _checkSession() async {
    try {
      final hasSession = await AuthService.hasValidSession();

      if (mounted) {
        setState(() {
          _destination = hasSession ? const HomeScreen() : const LoginScreen();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _destination = const LoginScreen();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: ถ้ายังไม่รู้ว่าจะไปไหน ให้ส่ง LoginScreen ไปก่อน (fallback)
    // แต่ _checkSession จะเสร็จก่อน splash animation หมด (2 วินาที)
    return SplashScreen(destination: _destination ?? const LoginScreen());
  }
}
