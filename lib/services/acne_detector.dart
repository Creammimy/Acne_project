// ... imports ...
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'labels.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final DetectionRect boundingBox;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  DetectionRect get rect => boundingBox;
}

class DetectionRect {
  final double left, top, right, bottom;

  DetectionRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;
}

class AcneDetector {
  late Interpreter _interpreter;
  final int inputSize = 640;
  final double scoreThreshold = 0.3;

  AcneDetector._create();

  static Future<AcneDetector> create() async {
    final detector = AcneDetector._create();
    final modelData = await rootBundle.load('assets/acne_model_32.tflite');
    detector._interpreter = await Interpreter.fromBuffer(modelData.buffer.asUint8List());
    return detector;
  }

  Future<List<DetectionResult>> detect(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final oriImage = img.decodeImage(imageBytes)!;
    final resizedImage = img.copyResize(oriImage, width: inputSize, height: inputSize);

    var input = imageToByteList(resizedImage);
    var output = List.filled(1 * 11 * 8400, 0.0).reshape([1, 11, 8400]);

    _interpreter.run(input, output);
    print("✅ Model ran successfully");
    print("🔍 Sample output: ${output[0][0].sublist(0, 5)}");

    return parseResults(output, oriImage.width, oriImage.height);
  }

  List<List<List<List<double>>>> imageToByteList(img.Image image) {
    return [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final pixel = image.getPixel(x, y);
          return [
            (img.getRed(pixel) / 127.5) - 1.0,
            (img.getGreen(pixel) / 127.5) - 1.0,
            (img.getBlue(pixel) / 127.5) - 1.0,
          ];
        });
      })
    ];
  }

  List<DetectionResult> parseResults(List output, int oriW, int oriH) {
    final results = <DetectionResult>[];
    final predictions = output[0];

    for (int i = 0; i < 8400; i++) {
      double x = (predictions[0][i] as num).toDouble();
      double y = (predictions[1][i] as num).toDouble();
      double w = (predictions[2][i] as num).toDouble();
      double h = (predictions[3][i] as num).toDouble();
      double confidence = (predictions[4][i] as num).toDouble();

      if (confidence < scoreThreshold) continue;

      List<double> classScores = [];
      for (int c = 5; c < 11; c++) {
        classScores.add((predictions[c][i] as num).toDouble());
      }

      double maxClassScore = classScores.reduce(max);
      if (maxClassScore < scoreThreshold) continue;

      int classIndex = classScores.indexOf(maxClassScore);
      if (classIndex < 0 || classIndex >= labels.length) continue;

      final left = (x - w / 2) * oriW / inputSize;
      final top = (y - h / 2) * oriH / inputSize;
      final right = (x + w / 2) * oriW / inputSize;
      final bottom = (y + h / 2) * oriH / inputSize;

      results.add(DetectionResult(
        label: labels[classIndex],
        confidence: maxClassScore,
        boundingBox: DetectionRect(left: left, top: top, right: right, bottom: bottom),
      ));
    }

    return results;
  }
}
