import 'package:flutter/material.dart';

class NavBarUser extends StatelessWidget {
  final String username;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoTap;

  const NavBarUser({
    Key? key,
    this.username = 'Admin****แก้***',
    this.onProfileTap,
    this.onLogoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70, // ← เพิ่มความสูงขึ้นนิดหน่อย
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // ← เพิ่ม padding
      decoration: const BoxDecoration(
        color: Color(0xFFffffff),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, // ← อยู่กลางแนวตั้ง
        children: [
          // Logo ทางซ้าย (สูงเท่าช่องขาว)
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              width: 60,// ← ขนาดโลโก้
              height:60, // ← สูงเต็มที่
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
              fontFamily: 'TA8bit'
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

          // ไอคอนโปรไฟล์
          GestureDetector(
            onTap: onProfileTap,
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