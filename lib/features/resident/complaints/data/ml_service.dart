import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/sorted_unsorted_model.tflite',
    );
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    final resizedImage = img.copyResize(rawImage!, width: 224, height: 224);

    // Create input tensor [1,224,224,3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) => List.filled(3, 0.0)),
      ),
    );

    // 🔥 IMPORTANT: MobileNetV2 preprocessing
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // Convert 0-255 → [-1,1]
        input[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        input[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        input[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }

    // 🔥 Output shape now [1,6]
    var output = List.generate(1, (_) => List.filled(6, 0.0));

    _interpreter.run(input, output);

    // Class names MUST match training order
    List<String> classNames = [
      "glass",
      "metal",
      "organic",
      "other",
      "paper",
      "plastic",
    ];

    // Find max prediction
    double maxScore = output[0][0];
    int maxIndex = 0;

    for (int i = 1; i < 6; i++) {
      if (output[0][i] > maxScore) {
        maxScore = output[0][i];
        maxIndex = i;
      }
    }

    return {
      "label": classNames[maxIndex],
      "confidence": maxScore,
      "allScores": output[0],
    };
  }
}
