import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ingridio/models/food_vision_result.dart';
import 'package:ingridio/services/gemini_service.dart';

class FoodDetectionService {
  const FoodDetectionService();

  static final GeminiService _gemini = GeminiService();

  Future<List<String>> detectFoodItems(File imageFile) async {
    final FoodVisionResult vision = await _gemini.analyzeImageBytes(
      await imageFile.readAsBytes(),
      mimeType: 'image/jpeg',
    );
    return vision.detectedIngredientNames;
  }

  Future<FoodVisionResult> analyzeCapture(XFile image) =>
      _gemini.analyzeXFile(image);
}
