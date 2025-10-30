import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/profile.dart';
import '../home/home.dart';
import '../../config/api_config.dart';
import '../../service/storage_helper.dart';
import '../../service/profile_service.dart';

class NavBarUser extends StatefulWidget {
  const NavBarUser({Key? key}) : super(key: key);

  @override
  State<NavBarUser> createState() => _NavBarUserState();
}

class _NavBarUserState extends State<NavBarUser> {
  String username = 'USER';
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<bool> _testImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 360;
      final logoSize = isSmallScreen ? 40.0 : 60.0;
      final profileSize = isSmallScreen ? 40.0 : 50.0;
      final spacing = isSmallScreen ? 6.0 : 12.0;
      final usernameFont = isSmallScreen ? 10.0 : 12.0;

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
            padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ฝั่งซ้าย: Logo + App Name
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
                                  _buildPixelDot(Colors.white.withOpacity(0.8)),
                                  SizedBox(width: 3),
                                  _buildPixelDot(Colors.white.withOpacity(0.6)),
                                  SizedBox(width: 3),
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

                // ฝั่งขวา: Username + Profile Image
                isLoading
                    ? _buildLoadingState(isSmallScreen, profileSize)
                    : Row(
                        children: [
                          if (!isSmallScreen)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 2),
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
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6fa85e),
                                      border: Border.all(color: Colors.black, width: 1),
                                    ),
                                  ),
                                  SizedBox(width: 6),
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
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(3, 3),
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

  Widget _buildLoadingState(bool isSmallScreen, double profileSize) {
    return Row(
      children: [
        if (!isSmallScreen)
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
        SizedBox(width: 8),
        Container(
          width: profileSize,
          height: profileSize,
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
