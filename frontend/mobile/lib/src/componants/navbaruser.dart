import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/profile.dart';
import '../home/home.dart';
import '../../config/api_config.dart';
import '../../service/storage_helper.dart';
import '../../service/profile_service.dart';

// NavBarUser Widget
// Navigation Bar สำหรับผู้ใช้ทั่วไป แสดงโลโก, ชื่อแอป, username และรูปโปรไฟล์
class NavBarUser extends StatefulWidget {
  const NavBarUser({Key? key}) : super(key: key);

  @override
  State<NavBarUser> createState() => _NavBarUserState();
}

class _NavBarUserState extends State<NavBarUser> {
  // State Variables
  String username = 'USER';
  String? profileImageUrl;
  bool isLoading = true;

  // Lifecycle: โหลดข้อมูลโปรไฟล์เมื่อเริ่มต้น
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Helper: ทดสอบว่า URL รูปภาพใช้ได้หรือไม่
  Future<bool> _testImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Business Logic: โหลดข้อมูลโปรไฟล์จาก API
  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await ProfileService.getMyProfile();
      if (mounted) {
        setState(() {
          username = userProfile.username;
          if (userProfile.imageProfileUrl != null) {
            profileImageUrl =
                ApiConfig.getImageUrl(userProfile.imageProfileUrl!);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      try {
        final storedUsername = await StorageHelper.getUsername();
        if (mounted) {
          setState(() {
            username = storedUsername ?? 'USER';
            isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            username = 'USER';
            isLoading = false;
          });
        }
      }
    }
  }

  // Widget: สร้างรูปโปรไฟล์เริ่มต้น (default)
  Widget _buildDefaultProfileImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/pic/person.png',
          width: size * 0.6,
          height: size * 0.6,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: const Color(0xFF6fa85e),
            );
          },
        ),
      ),
    );
  }

  // UI: สร้าง Navigation Bar แบบ Pixel Art Style
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive: Enhanced responsive breakpoints
      final isUltraSmall = constraints.maxWidth < 320;
      final isSmallScreen = constraints.maxWidth < 360;
      final isMediumScreen = constraints.maxWidth < 400;

      final logoSize = isUltraSmall ? 35.0 : isSmallScreen ? 40.0 : isMediumScreen ? 50.0 : 60.0;
      final profileSize = isUltraSmall ? 35.0 : isSmallScreen ? 40.0 : 50.0;
      final spacing = isUltraSmall ? 4.0 : isSmallScreen ? 6.0 : isMediumScreen ? 10.0 : 12.0;
      final usernameFont = isUltraSmall ? 9.0 : isSmallScreen ? 10.0 : 12.0;
      final appNameFont = isUltraSmall ? 14.0 : isSmallScreen ? 16.0 : 18.0;
      final borderWidth = isSmallScreen ? 1.5 : 2.0;
      final shadowOffset = isSmallScreen ? 2.0 : 3.0;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
          ),
          border: const Border(bottom: BorderSide(color: Colors.black, width: 6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Section: Left Side - Logo + App Name
                Flexible(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          child: Image.asset(
                            'assets/pic/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF8bc273),
                                child: const Center(
                                  child: Text('🥗', style: TextStyle(fontSize: 24)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      if (!isSmallScreen)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  _buildPixelDot(Colors.white.withValues(alpha: 0.8)),
                                  SizedBox(width: isSmallScreen ? 2 : 3),
                                  _buildPixelDot(Colors.white.withValues(alpha: 0.6)),
                                  SizedBox(width: isSmallScreen ? 2 : 3),
                                  _buildPixelDot(Colors.white.withValues(alpha: 0.4)),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 3 : 4),
                              Text(
                                'CAL-DEFICITS',
                                style: TextStyle(
                                  fontSize: appNameFont,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: isSmallScreen ? 1 : 2,
                                  fontFamily: 'TA8bit',
                                  shadows: const [
                                    Shadow(offset: Offset(2, 2), color: Colors.black38),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Section: Right Side - Username + Profile Image
                isLoading
                    ? _buildLoadingState(isSmallScreen, profileSize)
                    : Row(
                        children: [
                          if (!isSmallScreen)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing,
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: borderWidth),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: Offset(shadowOffset, shadowOffset),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: isSmallScreen ? 4 : 5,
                                    height: isSmallScreen ? 4 : 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6fa85e),
                                      border: Border.all(color: Colors.black, width: 1),
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? 4 : 6),
                                  Text(
                                    username.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: usernameFont,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1f2937),
                                      letterSpacing: 1,
                                      fontFamily: 'TA8bit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: spacing),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                              );
                            },
                            child: Container(
                              width: profileSize,
                              height: profileSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: borderWidth),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: Offset(shadowOffset, shadowOffset),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: _buildProfileImage(profileSize),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Widget: สร้างรูปโปรไฟล์ (ดึงจาก network หรือแสดง default)
  Widget _buildProfileImage(double size) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return FutureBuilder<bool>(
        future: _testImageUrl(profileImageUrl!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6fa85e),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data == true) {
            return ClipRect(
              child: Image.network(
                profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProfileImage(size);
                },
              ),
            );
          } else {
            return _buildDefaultProfileImage(size);
          }
        },
      );
    } else {
      return _buildDefaultProfileImage(size);
    }
  }

  // Widget: สร้าง Loading State สำหรับ username และ profile
  Widget _buildLoadingState(bool isSmallScreen, double profileSize) {
    final borderWidth = isSmallScreen ? 1.5 : 2.0;
    final shadowOffset = isSmallScreen ? 2.0 : 3.0;
    final spacing = isSmallScreen ? 6.0 : 12.0;

    return Row(
      children: [
        if (!isSmallScreen)
          Container(
            padding: EdgeInsets.symmetric(horizontal: spacing, vertical: isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: SizedBox(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 14 : 16,
              child: Center(
                child: SizedBox(
                  width: isSmallScreen ? 10 : 12,
                  height: isSmallScreen ? 10 : 12,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6fa85e),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Container(
          width: profileSize,
          height: profileSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: Offset(shadowOffset, shadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: isSmallScreen ? 16 : 20,
              height: isSmallScreen ? 16 : 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6fa85e),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget: สร้างจุด Pixel สำหรับตกแต่ง
  Widget _buildPixelDot(Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      width: isSmallScreen ? 5 : 6,
      height: isSmallScreen ? 5 : 6,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }
}
