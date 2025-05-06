import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:project_acne_scan/services/result_model.dart';
import 'package:http/http.dart' as http;

class RoboflowService {
  static const String apiKey = '4YKZlXYHqznB0NVOQQfw';
  static const String workflowUrl =
      'https://serverless.roboflow.com/infer/workflows/creamiko/detect-count-and-visualize';

  static Future<ImageAnalysisResult> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = "data:image/jpeg;base64,$base64Image";

      final body = jsonEncode({
        "api_key": apiKey,
        "inputs": {
          "image": {"type": "base64", "value": dataUri}
        }
      });

      final response = await http.post(
        Uri.parse(workflowUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📦 Raw Response Body:");
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final outputs = jsonResponse['outputs'];

        if (outputs == null || outputs.isEmpty) {
          throw Exception("outputs is null or empty");
        }

        final outputImageBase64 = outputs[0]['output_image']['value'];
        final decodedImage = base64Decode(outputImageBase64);
        final tempFile = await _saveImageToTempFile(decodedImage);

        // ✅ ปลอดภัยขึ้น: ตรวจสอบชนิดก่อน cast
        final dynamic rawPredictions = outputs[0]['predictions'];
        final List<dynamic> predictions = (rawPredictions is List) ? rawPredictions : [];

        final Map<String, int> pimpleCounts = {};
        for (var pred in predictions) {
          final label = pred['class'];
          pimpleCounts[label] = (pimpleCounts[label] ?? 0) + 1;
        }

        return ImageAnalysisResult(
          results: [],
          renderedImagePath: tempFile.path,
          pimpleCounts: pimpleCounts,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("[❌] วิเคราะห์ล้มเหลว: $e");
      throw Exception("วิเคราะห์ล้มเหลว: $e");
    }
  }

  static Future<File> _saveImageToTempFile(Uint8List bytes) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File(
        '${tempDir.path}/roboflow_result_${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await tempFile.writeAsBytes(bytes, flush: true);
  }
}
