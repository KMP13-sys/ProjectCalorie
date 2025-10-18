// components/navbaruser.dart
import 'package:flutter/material.dart';
import 'package:mobile/src/profile/profile.dart';
import '../home/home.dart';
import '../../service/storage_helper.dart';
import '../../service/profile_service.dart';
import '../../service/user_models.dart';

class NavBarUser extends StatefulWidget {
  const NavBarUser({Key? key}) : super(key: key);

  @override
  State<NavBarUser> createState() => _NavBarUserState();
}

class _NavBarUserState extends State<NavBarUser> {
  String username = 'USER'; // ค่าเริ่มต้น
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ฟังก์ชันดึงข้อมูล User จาก API
  Future<void> _loadUserProfile() async {
    try {
      final userId = await StorageHelper.getUserId();

      if (userId != null) {
        final userProfile = await ProfileService.getUserProfile(userId);

        if (userProfile != null && mounted) {
          setState(() {
            username = userProfile.username;
            profileImageUrl = userProfile.imageProfileUrl;
            isLoading = false;
          });
        } else {
          // ถ้าดึงข้อมูลไม่สำเร็จ ใช้ username จาก storage แทน
          final storedUsername = await StorageHelper.getUsername();
          if (mounted) {
            setState(() {
              username = storedUsername ?? 'USER';
              isLoading = false;
            });
          }
        }
      } else {
        // ไม่มี userId ใน storage
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6fa85e), Color(0xFF8bc273)],
        ),
        border: const Border(bottom: BorderSide(color: Colors.black, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ฝั่งซ้าย: Logo + ชื่อแอพ
              Row(
                children: [
                  // Logo (คลิกไปหน้า Home)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFa8d88e), Color(0xFF8bc273)],
                        ),
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
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

                  const SizedBox(width: 12),

                  // ชื่อแอพ (คลิกไปหน้า Home)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pixel decorations (3 จุด)
                        Row(
                          children: [
                            _buildPixelDot(Colors.white.withOpacity(0.8)),
                            const SizedBox(width: 3),
                            _buildPixelDot(Colors.white.withOpacity(0.6)),
                            const SizedBox(width: 3),
                            _buildPixelDot(Colors.white.withOpacity(0.4)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CAL-DEFICITS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            fontFamily: 'TA8bit',
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ฝั่งขวา: Username + Profile Icon
              isLoading
                  ? _buildLoadingState()
                  : Row(
                      children: [
                        // Username with pixel decoration
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Pixel star
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6fa85e),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                username.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1f2937),
                                  letterSpacing: 1,
                                  fontFamily: 'TA8bit',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Profile Icon (คลิกไปหน้า Profile)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: _buildProfileImage(),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับแสดงรูปโปรไฟล์
  Widget _buildProfileImage() {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return ClipRect(
        child: Image.network(
          profileImageUrl!,
          fit: BoxFit.cover,
          width: 44,
          height: 44,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6fa85e),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.person, color: Color(0xFF6fa85e), size: 24),
            );
          },
        ),
      );
    } else {
      // ไม่มีรูป ใช้ icon
      return const Center(
        child: Icon(Icons.person, color: Color(0xFF6fa85e), size: 24),
      );
    }
  }

  // Widget แสดงขณะกำลังโหลด
  Widget _buildLoadingState() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const SizedBox(
            width: 60,
            height: 16,
            child: Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6fa85e),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6fa85e),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget สร้าง Pixel Dot
  Widget _buildPixelDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }
}
