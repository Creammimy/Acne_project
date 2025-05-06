import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_acne_scan/screens/result_screen.dart';
import 'package:project_acne_scan/services/result_model.dart';
import 'package:project_acne_scan/services/roboflow_service.dart';

class ScanScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ScanScreen({Key? key, required this.imagePaths}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<XFile> _images = [];
  bool _isAnalyzing = false;

  final List<String> labels = [
    'Pustula',
    'Acne Fulminans',
    'Blackhead',
    'Fungal Acne',
    'Nodules',
    'Papula',
    'Whitehead',
  ];

  Map<String, int> pimpleTypes = {
    'Pustula': 0,
    'Acne Fulminans': 0,
    'Blackhead': 0,
    'Fungal Acne': 0,
    'Nodules': 0,
    'Papula': 0,
    'Whitehead': 0,
  };

  List<ImageAnalysisResult> detectionResultsPerImage = [];

  @override
  void initState() {
    super.initState();
    _images = widget.imagePaths.map((path) => XFile(path)).toList();
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _addImage(ImageSource source) async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("สามารถเพิ่มได้สูงสุด 3 ภาพเท่านั้น"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _images.add(pickedImage);
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเลือกรูปภาพอย่างน้อย 1 รูป"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      detectionResultsPerImage.clear();
      pimpleTypes.updateAll((key, value) => 0);
    });

    for (int i = 0; i < _images.length; i++) {
  final image = _images[i];
  try {
    print('[📤] กำลังส่งภาพ ${i + 1}/${_images.length}: ${image.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("กำลังวิเคราะห์ภาพ ${i + 1}/${_images.length}..."),
        duration: const Duration(milliseconds: 800),
      ),
    );

    final analysis = await RoboflowService.analyzeImage(File(image.path));
    detectionResultsPerImage.add(analysis);

    // ✅ รวมจำนวนสิวจากภาพนี้เข้ากับ pimpleTypes
    analysis.pimpleCounts.forEach((type, count) {
      if (pimpleTypes.containsKey(type)) {
        pimpleTypes[type] = pimpleTypes[type]! + count;
      } else {
        pimpleTypes[type] = count;
      }
    });

    print('[✅] วิเคราะห์เสร็จ: ${image.name}');
  } catch (e) {
    print('[❌] วิเคราะห์ล้มเหลว: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("วิเคราะห์ภาพล้มเหลว: ${image.name}"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

    setState(() => _isAnalyzing = false);
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("วิเคราะห์เสร็จสิ้น"),
        content: const Text("คลิกเพื่อดูผลลัพธ์"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    imagePaths: _images.map((x) => x.path).toList(),
                    detectionResultsPerImage: detectionResultsPerImage,
                    pimpleTypes: pimpleTypes,
                    careInstructions:
                        'ล้างหน้าให้สะอาดและทายาลดสิววันละ 2 ครั้ง',
                  ),
                ),
              );
            },
            child: const Text("ดูผลลัพธ์"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: const Color(0xFFCDF8F7),
            radius: 30,
            child: Icon(icon, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตรวจสอบรูปภาพ"),
        backgroundColor: const Color(0xFF06D1D0),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Image.file(
                                File(_images[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: const Icon(Icons.cancel,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAddButton(Icons.camera_alt, 'กล้อง',
                        () => _addImage(ImageSource.camera)),
                    const SizedBox(width: 30),
                    _buildAddButton(Icons.photo, 'คลัง',
                        () => _addImage(ImageSource.gallery)),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isAnalyzing ? null : _startAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06D1D0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    "วิเคราะห์สิว",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "กำลังวิเคราะห์...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
