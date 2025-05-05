import 'dart:ui';

// result_model.dart
import '../services/acne_detector.dart'; // เพื่อให้ใช้ DetectionRect ได้

class Result {
  final String label;
  final double confidence;
  final DetectionRect rect;

  Result({
    required this.label,
    required this.confidence,
    required this.rect,
  });
}
