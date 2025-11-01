import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../componants/navbaruser.dart';
import '../authen/login.dart';
import '../../service/profile_service.dart';
import '../../models/profile_models.dart';
import '../../service/auth_service.dart';

/// ProfileScreen Widget
/// หน้าโปรไฟล์ผู้ใช้ - แสดงและแก้ไขข้อมูลส่วนตัว
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// State Variables: User Profile Data
  UserProfile? userProfile;
  bool isLoadingProfile = true;

  /// State Variables: Form Controllers
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  String _selectedGender = 'male';
  String _selectedGoal = 'lose weight';

  /// State Variables: UI State
  bool _isEditing = false;
  bool _isLoading = false;

  /// State Variables: Image Upload
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  /// Lifecycle: เริ่มต้น Controllers และโหลดข้อมูล
  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();

    _loadUserProfile();
  }

  /// Lifecycle: ทำความสะอาด Controllers
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Business Logic: โหลดข้อมูลโปรไฟล์จาก API
  Future<void> _loadUserProfile() async {
    try {
      // API Call: ดึงข้อมูลโปรไฟล์
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingProfile = false);
      }
    }
  }

  /// Business Logic: เลือกรูปจาก Gallery
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

        await _uploadProfileImage();
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการเลือกรูป: ${e.toString()}');
    }
  }

  /// Business Logic: อัปโหลดรูปโปรไฟล์ไปยัง Server
  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      // API Call: อัปโหลดรูปโปรไฟล์
      await ProfileService.updateMyProfileImage(imageFile: _selectedImage!);

      await _loadUserProfile();

      setState(() {
        _isLoading = false;
        _selectedImage = null;
      });

      if (mounted) {
        _showSuccessDialog('✓ อัปเดทรูปโปรไฟล์เรียบร้อย!');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedImage = null;
      });
      _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI: Loading State
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
          // Section: Background with gradient
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

          // Section: Pixel Grid Background
          CustomPaint(painter: PixelGridPainter(), size: Size.infinite),

          Column(
            children: [
              // Section: Navbar
              const NavBarUser(),

              // Section: Profile Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Section: Profile Card
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
                              // Decoration: Corner Pixels
                              ..._buildCornerPixels(),

                              Column(
                                children: [
                                  // Section: Header Bar
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

                                  // Section: Content
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        // Section: Avatar (เปลี่ยน layout ตาม Edit Mode)
                                        _isEditing
                                            ? _buildEditModeAvatar()
                                            : _buildNormalModeAvatar(),

                                        const SizedBox(height: 32),

                                        // Section: Info Fields
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(right: 6),
                                                  decoration: BoxDecoration(
                                                  ),
                                                  child: Image.asset(
                                                    'assets/pic/play.png', // แทน ▶
                                                    width: 16,
                                                    height: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const Text(
                                                  'PERSONAL INFO',
                                                  style: TextStyle(
                                                    fontFamily: 'TA8bit',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
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

                                        // Section: Action Buttons (เปลี่ยนตาม state)
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

  /// Widget: Avatar สำหรับ Normal Mode (แสดงกลางหน้าจอ)
  Widget _buildNormalModeAvatar() {
    return Column(
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

        const SizedBox(height: 24),

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

  /// Widget: Avatar สำหรับ Edit Mode (มีปุ่มกล้องและปุ่มลบบัญชี)
  Widget _buildEditModeAvatar() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 48),

            // Section: Avatar + Username (กลาง)
            Expanded(
              child: Column(
                children: [
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
                      // UI: ปุ่มกล้อง
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

            // Section: ปุ่มลบบัญชี (ขวา)
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

  /// Widget: แสดงรูปโปรไฟล์ (จาก Gallery, Backend, หรือ Default)
  Widget _buildProfileAvatar() {
    // Data: รูปจาก Gallery (ชั่วคราว)
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

    // Data: รูปจาก Backend
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

    // Data: Default Image
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

  /// Widget: สร้าง Corner Pixels สำหรับตกแต่ง
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

  /// Widget: ช่องข้อมูล (รองรับทั้ง read-only และ editable)
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

  /// Widget: ช่องเลือกเพศ
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

  /// Widget: ช่องเลือกเป้าหมาย
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

  /// Widget: ปุ่มสำหรับ Normal Mode (Back, Edit, Logout)
  Widget _buildNormalModeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildPixelButton(
            'BACK',
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
            'EDIT',
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
            'LOGOUT',
            const Color(0xFFfb7185),
            Colors.white,
            _handleLogout,
          ),
        ),
      ],
    );
  }

  /// Widget: ปุ่มสำหรับ Edit Mode (Cancel, Save)
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

  /// Business Logic: ยกเลิกการแก้ไข (คืนค่าเดิม)
  void _handleCancel() {
    setState(() {
      if (userProfile != null) {
        _weightController.text = userProfile!.weight?.toString() ?? '';
        _heightController.text = userProfile!.height?.toString() ?? '';
        _ageController.text = userProfile!.age?.toString() ?? '';
        _selectedGender = userProfile!.gender ?? 'male';
        _selectedGoal = userProfile!.goal ?? 'lose weight';
      }
      _selectedImage = null;
      _isEditing = false;
    });
  }

  /// Business Logic: บันทึกข้อมูลโปรไฟล์
  Future<void> _handleSave() async {
    if (userProfile == null) return;

    // Validation: ตรวจสอบข้อมูล
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
      // API Call: บันทึกข้อมูลโปรไฟล์
      await ProfileService.updateMyProfile(
        weight: weight,
        height: height,
        age: age,
        gender: _selectedGender,
        goal: _selectedGoal,
      );

      setState(() => _isLoading = false);

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

  /// Business Logic: ลบบัญชีผู้ใช้
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
                          // Section: Danger Icon
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

                                    // UI: แสดง loading
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
                                      // API Call: ลบบัญชี
                                      await AuthService.deleteAccount();

                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }

                                      // Navigation: กลับไปหน้า Login
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
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }

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

  /// UI: แสดง Error Dialog
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

  /// UI: แสดง Success Dialog
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

  /// Widget: Message Dialog (Success/Error)
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
            // Decoration: Corner Pixels
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
                // Section: Header
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
                      // Section: Pixel Icon
                      isSuccess ? _buildPixelHeart() : _buildPixelWarning(),

                      const SizedBox(height: 24),

                      // Section: Message Box
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

                      // Section: Continue Button
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

  /// Widget: Pixel Heart Icon (สำหรับ Success)
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

  /// Widget: Pixel Warning Icon (สำหรับ Error)
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

  /// Widget: ปุ่มแบบ Pixel Art
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

  /// Business Logic: ออกจากระบบ
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
                          // Section: Warning Icon
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
                                    // API Call: ออกจากระบบ
                                    try {
                                      await AuthService.logout();
                                    } catch (e) {
                                      // Note: ถ้า API ล้มเหลว ก็ยังคงล้างข้อมูล local
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

/// PixelGridPainter Class
/// วาดตาราง Pixel เป็น Background
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
