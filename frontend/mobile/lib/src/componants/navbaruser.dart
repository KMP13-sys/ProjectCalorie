import 'package:flutter/material.dart';
import 'package:mobile/src/profile/profile.dart';
import '../home/home.dart';
import '../profile/profile.dart';


class NavBarUser extends StatelessWidget {
  final String username;

  const NavBarUser({
    Key? key,
    this.username = 'User',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFffffff),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo ทางซ้าย (คลิกไปหน้า Home)
          GestureDetector(
            onTap: () {
              // ไปหน้า Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/pic/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ชื่อแอพ
          const Text(
            'CAL-DEFICITS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF204130),
              letterSpacing: 2,
              fontFamily: 'Courier',
            ),
          ),

          const Spacer(),

          // ชื่อผู้ใช้
          Text(
            username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF204130),
            ),
          ),

          const SizedBox(width: 12),

          // ไอคอนโปรไฟล์ (คลิกไปหน้า Profile)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF204130),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF204130),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

