import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedGoal;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Build Muscle'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // TODO: โหลดข้อมูลจาก database/API
    setState(() {
      _weightController.text = '65';
      _heightController.text = '170';
      _ageController.text = '25';
      _selectedGender = 'Male';
      _selectedGoal = 'Lose Weight';
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // TODO: บันทึกข้อมูลไปยัง database/API
      final profileData = {
        'weight': _weightController.text,
        'height': _heightController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'goal': _selectedGoal,
      };
      
      print('Saving profile: $profileData');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // กลับไปหน้าก่อนหน้า
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // หัวข้อ
                  const Text(
                    'EDIT PROFILE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // รูปโปรไฟล์
                  Stack(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          image: DecorationImage(
                            image: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D5016),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Weight Field
                  _buildTextField(
                    controller: _weightController,
                    label: 'weight',
                    keyboardType: TextInputType.number,
                    suffix: 'kg',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Height Field
                  _buildTextField(
                    controller: _heightController,
                    label: 'height',
                    keyboardType: TextInputType.number,
                    suffix: 'cm',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Age Field
                  _buildTextField(
                    controller: _ageController,
                    label: 'age',
                    keyboardType: TextInputType.number,
                    suffix: 'yrs',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gender Dropdown
                  _buildDropdown(
                    label: 'gender',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Goal Dropdown
                  _buildDropdown(
                    label: 'goal',
                    value: _selectedGoal,
                    items: _goals,
                    onChanged: (value) {
                      setState(() {
                        _selectedGoal = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCE5B3),
                      foregroundColor: const Color(0xFF2D5016),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF2D5016), width: 2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFF2D5016),
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFF2D5016),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF2D5016), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFF2D5016),
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          color: Color(0xFF2D5016),
        ),
        dropdownColor: const Color(0xFFE8F5E9),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2D5016)),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}