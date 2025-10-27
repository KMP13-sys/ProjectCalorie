import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../FoodDetailScreen/FoodDetailScreen.dart';

class SelectImageScreen extends StatefulWidget {
  const SelectImageScreen({super.key});

  @override
  State<SelectImageScreen> createState() => _SelectImageScreenState();
}

class _SelectImageScreenState extends State<SelectImageScreen> {
  final ImagePicker _picker = ImagePicker();

  // ตำแหน่งเริ่มต้นของปุ่ม
  double _x = 0;
  double _y = 0;
  bool _initialized = false;

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 4),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFBDBDBD),
                    child: const Text(
                      'SELECT IMAGE SOURCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: _optionBox(
                      icon: Icons.camera_alt,
                      text: 'ถ่ายรูปใหม่ (Camera)',
                      color: const Color(0xFFD4F2C1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: _optionBox(
                      icon: Icons.photo_library,
                      text: 'เลือกรูปจากอัลบั้ม (Gallery)',
                      color: const Color(0xFFFFF3A3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Text(
                        'CANCEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        const String foodName = "คาโบนาร่า";
        const int carbs = 53;
        const int fat = 80;
        const int protein = 23;
        const int calories = 954;

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                  imageFile: imageFile,
                  foodName: foodName,
                  carbs: carbs,
                  fat: fat,
                  protein: protein,
                  calories: calories,
                ),
              ),
            );
          });
        }
      }
    }
  }

  Widget _optionBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // initialize ตำแหน่งเริ่มต้นให้ตรงกลาง/ติดล่าง
    if (!_initialized) {
      _x = MediaQuery.of(context).size.width / 2 - 50;
      _y = MediaQuery.of(context).size.height - 150;
      _initialized = true;
    }

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลัง
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFB0E6A9),
          ),

          // ปุ่มกล้อง draggable
          Positioned(
            left: _x,
            top: _y,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _x += details.delta.dx;
                  _y += details.delta.dy;

                  // ลบ clamp เพื่อให้ลากออกนอกหน้าจอได้
                  // _x = _x.clamp(0.0, MediaQuery.of(context).size.width - 100);
                  // _y = _y.clamp(0.0, MediaQuery.of(context).size.height - 100);
                });
              },
              onTap: _pickImage,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
