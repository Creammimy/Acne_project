import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RoboflowService {
  final String apiKey = 'YOUR_ROBOFLOW_API_KEY';
  final String modelEndpoint = 'https://detect.roboflow.com/YOUR_MODEL_NAME/1';

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse('$modelEndpoint?api_key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'image': base64Image},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze image: ${response.body}');
    }
  }
}
