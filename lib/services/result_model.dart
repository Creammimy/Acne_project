import 'dart:ui';

class Result {
  final String label;
  final double confidence;
  final Rect rect;

  Result({
    required this.label,
    required this.confidence,
    required this.rect,
  });

  @override
  String toString() {
    return 'Result(label: $label, confidence: $confidence, rect: $rect)';
  }
}
class ImageAnalysisResult {
  final List<Result> results;
  
  final String? renderedImagePath;
  final Map<String, int> pimpleCounts;

  ImageAnalysisResult({
    required this.results,
   
    this.renderedImagePath,
    required this.pimpleCounts,
  });
}
