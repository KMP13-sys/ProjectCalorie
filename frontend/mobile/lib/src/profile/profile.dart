// lib/src/profile/profile.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../componants/navbaruser.dart';
import '../authen/login.dart';
//import '../../service/storage_helper.dart';
import '../../service/profile_service.dart';
import '../../models/profile_models.dart';
import '../../service/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ข้อมูลผู้ใช้
  UserProfile? userProfile;
  bool isLoadingProfile = true;

  // Controllers สำหรับแก้ไขข้อมูล
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  String _selectedGender = 'male';
  String _selectedGoal = 'lose weight';

  // State สำหรับ toggle edit mode
  bool _isEditing = false;
  bool _isLoading = false;

  // สำหรับอัปโหลดรูป
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();

    _loadUserProfile();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // โหลดข้อมูล User จาก API
  Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileService.getMyProfile();

      if (mounted) {
        setState(() {
          userProfile = profile;
          _weightController.text = profile.weight?.toString() ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _ageController.text = profile.age?.toString() ?? '';
          _selectedGender = profile.gender ?? 'male';
          _selectedGoal = profile.goal ?? 'lose weight';
          isLoadingProfile = false;
        });

        // Debug: แสดง URL ของรูป
        // ignore: avoid_print
        print(
          '🖼️ Profile loaded. Image URL: ${profile.imageProfileUrl}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error loading profile: $e');
      if (mounted) {
        setState(() => isLoadingProfile = false);
      }
    }
  }

  // เลือกรูปจาก Gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // อัปโหลดรูปทันที
        await _uploadProfileImage();
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการเลือกรูป: ${e.toString()}');
    }
  }

  // อัปโหลดรูปโปรไฟล์
  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      await ProfileService.updateMyProfileImage(imageFile: _selectedImage!);

      // อัปโหลดสำเร็จ - โหลดข้อมูลใหม่
      await _loadUserProfile();

      setState(() {
        _isLoading = false;
        _selectedImage = null; // Clear cache image after successful upload
      });

      if (mounted) {
        _showSuccessDialog('✓ อัปเดทรูปโปรไฟล์เรียบร้อย!');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedImage = null; // Clear cache image on error
      });
      _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProfile) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6fa85e), Color(0xFF8bc273), Color(0xFFa8d88e)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6fa85e),
                  Color(0xFF8bc273),
                  Color(0xFFa8d88e),
                ],
              ),
            ),
          ),

          // Pixel Grid Background
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          Column(
            children: [
              // Navbar
              const NavBarUser(),

              // เนื้อหาหน้า Profile
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Profile Card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(12, 12),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Corner Pixels
                              ..._buildCornerPixels(),

                              Column(
                                children: [
                                  // Header Bar
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6fa85e),
                                          Color(0xFF8bc273),
                                        ],
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 6,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '◆ PROFILE ◆',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'TA8bit',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(3, 3),
                                            color: Color(0x80000000),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        // Avatar Section - เปลี่ยน layout ตาม Edit Mode
                                        _isEditing
                                            ? _buildEditModeAvatar()
                                            : _buildNormalModeAvatar(),

                                        const SizedBox(height: 32),

                                        // Info Section
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                              color: Colors.grey[800]!,
                                              width: 4,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '▶ PERSONAL INFO',
                                                style: TextStyle(
                                                  fontFamily: 'TA8bit',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              _buildInfoField(
                                                'WEIGHT',
                                                _weightController,
                                                'kg',
                                              ),
                                              const SizedBox(height: 12),

                                              _buildInfoField(
                                                'HEIGHT',
                                                _heightController,
                                                'cm',
                                              ),
                                              const SizedBox(height: 12),

                                              _buildInfoField(
                                                'AGE',
                                                _ageController,
                                                'years',
                                              ),
                                              const SizedBox(height: 12),

                                              _buildGenderField(),
                                              const SizedBox(height: 12),

                                              _buildGoalField(),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 32),

                                        // Buttons (เปลี่ยนตาม state)
                                        _isEditing
                                            ? _buildEditModeButtons()
                                            : _buildNormalModeButtons(),

                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Normal Mode Avatar - แสดงกลางหน้าจอ
  Widget _buildNormalModeAvatar() {
    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFa8d88e), Color(0xFF8bc273)],
            ),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: _buildProfileAvatar(),
        ),

        const SizedBox(height: 24),

        // Username
        Text(
          (userProfile?.username ?? 'USER').toUpperCase(),
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1f2937),
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        // Pixel Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, color: const Color(0xFF6fa85e)),
            const SizedBox(width: 4),
            Container(width: 8, height: 8, color: const Color(0xFF8bc273)),
            const SizedBox(width: 4),
            Container(width: 8, height: 8, color: const Color(0xFFa8d88e)),
          ],
        ),
      ],
    );
  }

  // Edit Mode Avatar - มีปุ่มลบบัญชีทางขวา
  Widget _buildEditModeAvatar() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacer ซ้าย
            const SizedBox(width: 48),

            // Avatar + Username (ตรงกลาง)
            Expanded(
              child: Column(
                children: [
                  // Avatar พร้อมปุ่มกล้อง
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFa8d88e), Color(0xFF8bc273)],
                          ),
                          border: Border.all(color: Colors.black, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: _buildProfileAvatar(),
                      ),
                      // ปุ่มกล้อง
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _pickImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6fa85e),
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/pic/camera.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Username
                  Text(
                    (userProfile?.username ?? 'USER').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1f2937),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Pixel Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: const Color(0xFF6fa85e),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        color: const Color(0xFF8bc273),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        color: const Color(0xFFa8d88e),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ปุ่มลบบัญชีทางขวา
            GestureDetector(
              onTap: _handleDeleteAccount,
              child: Container(
                width: 70,
                height: 45,
                // padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 249, 135, 135),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'DELETE ACCOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget แสดงรูปโปรไฟล์
  Widget _buildProfileAvatar() {
    // ถ้ามีรูปที่เลือกจาก gallery
    if (_selectedImage != null) {
      return ClipRect(
        child: Image.file(
          _selectedImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    // ถ้ามีรูปจาก backend
    if (userProfile?.imageProfileUrl != null &&
        userProfile!.imageProfileUrl!.isNotEmpty) {
      return ClipRect(
        child: Image.network(
          userProfile!.imageProfileUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/pic/person.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      );
    }

    // ไม่มีรูป - ใช้ person.png
    return Container(
      width: 100,
      height: 100,
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/pic/person.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  List<Widget> _buildCornerPixels() {
    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(width: 24, height: 24, color: const Color(0xFF6fa85e)),
      ),
    ];
  }

  // Widget Info Field (รองรับทั้ง read-only และ editable)
  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: _isEditing ? 0 : 10,
          ),
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : Colors.grey[100],
            border: Border.all(
              color: _isEditing ? const Color(0xFF6fa85e) : Colors.grey[800]!,
              width: 3,
            ),
          ),
          child: _isEditing
              ? TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixText: unit,
                    suffixStyle: TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.text.isEmpty
                          ? '-'
                          : '${controller.text} $unit',
                      style: const TextStyle(
                        fontFamily: 'TA8bit',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // Widget Gender Field
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER *',
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: _isEditing ? 0 : 10,
          ),
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : Colors.grey[100],
            border: Border.all(
              color: _isEditing ? const Color(0xFF6fa85e) : Colors.grey[800]!,
              width: 3,
            ),
          ),
          child: _isEditing
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    style: const TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                    items: ['male', 'female'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                  ),
                )
              : Text(
                  _selectedGender.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }

  // Widget Goal Field
  Widget _buildGoalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOAL *',
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: _isEditing ? 0 : 10,
          ),
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : Colors.grey[100],
            border: Border.all(
              color: _isEditing ? const Color(0xFF6fa85e) : Colors.grey[800]!,
              width: 3,
            ),
          ),
          child: _isEditing
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGoal,
                    isExpanded: true,
                    style: const TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                    items: ['lose weight', 'maintain weight', 'gain weight']
                        .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGoal = value!);
                    },
                  ),
                )
              : Text(
                  _selectedGoal.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'TA8bit',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }

  // Normal Mode Buttons
  Widget _buildNormalModeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildPixelButton(
            '◀ BACK',
            Colors.grey[800]!,
            Colors.white,
            () {
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPixelButton(
            '✎ EDIT',
            const Color(0xFF6fa85e),
            Colors.white,
            () {
              setState(() => _isEditing = true);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPixelButton(
            'LOGOUT ▶',
            const Color(0xFFfb7185),
            Colors.white,
            _handleLogout,
          ),
        ),
      ],
    );
  }

  // Edit Mode Buttons
  Widget _buildEditModeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildPixelButton(
            '✗ CANCEL',
            Colors.grey[800]!,
            Colors.white,
            _handleCancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isLoading
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6fa85e),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : _buildPixelButton(
                  '✓ SAVE',
                  const Color(0xFF6fa85e),
                  Colors.white,
                  _handleSave,
                ),
        ),
      ],
    );
  }

  // Handle Cancel
  void _handleCancel() {
    setState(() {
      if (userProfile != null) {
        _weightController.text = userProfile!.weight?.toString() ?? '';
        _heightController.text = userProfile!.height?.toString() ?? '';
        _ageController.text = userProfile!.age?.toString() ?? '';
        _selectedGender = userProfile!.gender ?? 'male';
        _selectedGoal = userProfile!.goal ?? 'lose weight';
      }
      _selectedImage = null; // Clear any cached image
      _isEditing = false;
    });
  }

  // Handle Save
  Future<void> _handleSave() async {
    if (userProfile == null) return;

    // Validation
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight == null || weight < 20 || weight > 300) {
      _showErrorDialog('⚠ กรุณากรอกน้ำหนักที่ถูกต้อง');
      return;
    }

    if (height == null || height < 50 || height > 300) {
      _showErrorDialog('⚠ กรุณากรอกส่วนสูงที่ถูกต้อง');
      return;
    }

    if (age == null || age < 1 || age > 120) {
      _showErrorDialog('⚠ กรุณากรอกอายุที่ถูกต้อง');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ProfileService.updateMyProfile(
        weight: weight,
        height: height,
        age: age,
        gender: _selectedGender,
        goal: _selectedGoal,
      );

      setState(() => _isLoading = false);

      // บันทึกสำเร็จ - โหลดข้อมูลใหม่
      await _loadUserProfile();

      setState(() => _isEditing = false);

      if (mounted) {
        _showSuccessDialog('✓ บันทึกข้อมูลเรียบร้อย!');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('✗ เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // Handle Delete Account
  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Corner Pixels
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFff6b6b),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFff6b6b),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFff6b6b),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFff6b6b),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFff6b6b),
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 4),
                        ),
                      ),
                      child: const Text(
                        '⚠ WARNING ⚠',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'TA8bit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              color: Color(0x80000000),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          // Danger Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFff6b6b),
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '!',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Message
                          const Text(
                            'DELETE YOUR ACCOUNT?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1f2937),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'This action cannot be undone!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 11,
                              color: Color(0xFF6b7280),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Pixel decoration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6b6b),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6b6b),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6b6b),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildPixelButton(
                                  'CANCEL',
                                  Colors.grey[800]!,
                                  Colors.white,
                                  () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPixelButton(
                                  'DELETE',
                                  const Color(0xFFff6b6b),
                                  Colors.white,
                                  () async {
                                    Navigator.of(context).pop();

                                    // แสดง loading
                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF6fa85e),
                                          ),
                                        ),
                                      );
                                    }

                                    try {
                                      // เรียก API ลบบัญชี
                                      await AuthService.deleteAccount();

                                      // ปิด loading dialog
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }

                                      // ลบสำเร็จ - กลับไปหน้า Login
                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );

                                        // แสดง snackbar แจ้งเตือน
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Account deleted successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      // ปิด loading dialog
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }

                                      // แสดง error dialog
                                      if (mounted) {
                                        _showErrorDialog(
                                          'Failed to delete account: ${e.toString().replaceAll('Exception: ', '')}',
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => _buildMessageDialog(
        title: 'ERROR',
        message: message,
        color: const Color(0xFFff6b6b),
        icon: '⚠',
      ),
    );
  }

  // Show Success Dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => _buildMessageDialog(
        title: 'SUCCESS',
        message: message,
        color: const Color(0xFF10b981),
        icon: '✓',
      ),
    );
  }

  // Message Dialog
  Widget _buildMessageDialog({
    required String title,
    required String message,
    required Color color,
    required String icon,
  }) {
    final isSuccess = title == 'SUCCESS';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSuccess
                ? [const Color(0xFFa8d88e), const Color(0xFF8bc273)]
                : [const Color(0xFFfecaca), const Color(0xFFfca5a5)],
          ),
          border: Border.all(color: Colors.black, width: 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Corner Pixels
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 16, height: 16, color: color),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(width: 16, height: 16, color: color),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(width: 16, height: 16, color: color),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(width: 16, height: 16, color: color),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color,
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 4),
                    ),
                  ),
                  child: Text(
                    isSuccess ? '★ SUCCESS! ★' : '◆ $title ◆',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'TA8bit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(offset: Offset(2, 2), color: Color(0x80000000)),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Pixel Icon
                      isSuccess ? _buildPixelHeart() : _buildPixelWarning(),

                      const SizedBox(height: 24),

                      // Message Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isSuccess ? 'PROFILE UPDATED!' : 'ERROR!',
                              style: const TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1f2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSuccess
                                  ? 'Changes saved successfully!'
                                  : message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSuccess
                                    ? [
                                        const Color(0xFF6fa85e),
                                        const Color(0xFF8bc273),
                                      ]
                                    : [
                                        const Color(0xFFdc2626),
                                        const Color(0xFFef4444),
                                      ],
                              ),
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              '▶ CONTINUE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'TA8bit',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    color: Color(0x80000000),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Pixel Heart Icon
  Widget _buildPixelHeart() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: const Color(0xFFff8787)),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFff6b6b)),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
        ],
      ),
    );
  }

  // Pixel Warning Icon
  Widget _buildPixelWarning() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: const Color(0xFFfde047)),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: const Color(0xFFfde047)),
              Container(width: 16, height: 16, color: const Color(0xFFfef08a)),
              Container(width: 16, height: 16, color: const Color(0xFFfde047)),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: const Color(0xFFfde047)),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: const Color(0xFFfbbf24)),
              Container(width: 16, height: 16, color: Colors.transparent),
              Container(width: 16, height: 16, color: Colors.transparent),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Button แบบ Pixel Art
  Widget _buildPixelButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1,
            shadows: textColor == Colors.white
                ? [const Shadow(offset: Offset(2, 2), color: Color(0x80000000))]
                : [],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชัน Logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Corner Pixels
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFf9a8d4),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFf9a8d4),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFf9a8d4),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    color: const Color(0xFFf9a8d4),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFfb7185),
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 4),
                        ),
                      ),
                      child: const Text(
                        '◆ WARNING ◆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'TA8bit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              color: Color(0x80000000),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          // Warning Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFfb7185),
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            child: const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Message
                          const Text(
                            'DO YOU WANT TO\nLOG OUT?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TA8bit',
                              fontSize: 14,
                              color: Color(0xFF1f2937),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Pixel decoration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf472b6),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf472b6),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf472b6),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildPixelButton(
                                  'CANCEL',
                                  Colors.grey[800]!,
                                  Colors.white,
                                  () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPixelButton(
                                  'LOGOUT',
                                  const Color(0xFFfb7185),
                                  Colors.white,
                                  () async {
                                    // เรียก API logout และลบข้อมูล
                                    try {
                                      await AuthService.logout();
                                    } catch (e) {
                                      // ถ้า API logout ล้มเหลว ก็ยังคงล้างข้อมูล local
                                      // ignore: avoid_print
                                      print('Logout API error: $e');
                                    }

                                    if (mounted) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Pixel Grid Painter
class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
