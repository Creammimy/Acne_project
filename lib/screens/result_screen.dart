import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_acne_scan/services/result_model.dart';

class ResultScreen extends StatelessWidget {
  final List<String> imagePaths;
  final List<ImageAnalysisResult> detectionResultsPerImage;
  final Map<String, int> pimpleTypes;
  final String careInstructions;

  const ResultScreen({
    Key? key,
    required this.imagePaths,
    required this.detectionResultsPerImage,
    required this.pimpleTypes,
    required this.careInstructions,
  }) : super(key: key);

  void _saveResult(BuildContext context) {
    print("บันทึกผลลัพธ์");
    print("Acne Types: $pimpleTypes");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกผลลัพธ์เรียบร้อย")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ผลลัพธ์การวิเคราะห์"),
        backgroundColor: const Color(0xFFCDF8F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้ายทั้งหมด
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: detectionResultsPerImage.length,
                itemBuilder: (context, index) {
                  final renderedPath =
                      detectionResultsPerImage[index].renderedImagePath;

                  if (renderedPath == null || renderedPath.isEmpty) {
                    return const Center(
                      child: Text("ไม่สามารถแสดงผลภาพได้"),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.file(
                      File(renderedPath),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),

            // หัวข้อ + Dropdown กรองประเภทสิว
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ผลการวิเคราะห์ใบหน้าของคุณ:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  hint: const Text("สิวทั้งหมด"),
                  items: pimpleTypes.keys.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // ยังไม่ใช้งานจริง
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // แสดงจำนวนสิว
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pimpleTypes.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) => Text("${entry.key}: ${entry.value} จุด"))
                  .toList(),
            ),

            const SizedBox(height: 16),
            const Text(
              "คำแนะนำการดูแล:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            Text(
              careInstructions,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),

            // ปุ่มบันทึก และกลับหน้าแรก
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _saveResult(context),
                  icon: const Icon(Icons.save),
                  label: const Text("บันทึกผลลัพธ์"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("กลับไปหน้าแรก"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
