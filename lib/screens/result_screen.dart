import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_acne_scan/services/result_model.dart';
import 'package:project_acne_scan/services/acne_detector.dart'; // <== เพิ่ม import นี้

class ResultScreen extends StatelessWidget {
  final List<String> imagePaths;
  final List<List<Result>> detectionResultsPerImage;
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
    print("บันทึกผลลัพธ์ทั้งหมด");
    print("จำนวนรูป: ${imagePaths.length}");
    print("Acne Types: $pimpleTypes");
    print("Care Instructions: $careInstructions");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกผลลัพธ์เรียบร้อย")),
    );
  }

  double _getWidth(Result result) => result.rect.right - result.rect.left;
  double _getHeight(Result result) => result.rect.bottom - result.rect.top;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ผลลัพธ์การวิเคราะห์"),
        backgroundColor: const Color(0xFFCDF8F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(imagePaths[index]),
                        fit: BoxFit.contain,
                      ),
                      ...detectionResultsPerImage[index].map((result) {
                        return Positioned(
                          left: result.rect.left,
                          top: result.rect.top,
                          width: _getWidth(result),
                          height: _getHeight(result),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                color: Colors.red.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  "${result.label} (${(result.confidence * 100).toStringAsFixed(1)}%)",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "สรุปจำนวนสิวแต่ละประเภท:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...pimpleTypes.entries.map((e) => Text("${e.key}: ${e.value} จุด")),
            const SizedBox(height: 16),
            const Text(
              "คำแนะนำการดูแล:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(careInstructions),
            const SizedBox(height: 16),
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