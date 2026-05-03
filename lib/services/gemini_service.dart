import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ingridio/models/food_vision_result.dart';
import 'package:ingridio/models/ingredient.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_cooking_step.dart';
import 'package:ingridio/models/recipe_ingredient_line.dart';

class GeminiService {
  GeminiService();

  static const String _modelName = 'gemini-3-flash-preview';

  static const String _visionPrompt =
      "Analyze this image and identify all visible food ingredients. Then suggest 3 recipes using these ingredients. Return ONLY valid JSON in this format:\n"
      "      {\n"
      "        'detected_ingredients': ['item1', 'item2'],\n"
      "        'recipes': [{\n"
      "          'name': '',\n"
      "          'match_percentage': 0,\n"
      "          'prep_time': '',\n"
      "          'calories': 0,\n"
      "          'ingredients': [{'name': '', 'amount': '', 'have_it': true}],\n"
      "          'steps': [{'step_number': 1, 'instruction': '', 'duration_seconds': 0}],\n"
      "          'tags': []\n"
      "        }]\n"
      "      }";

  static const String _placeholderRecipeImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB987vgoLrCvkIeqXUhwjqQovW76SroqevfrS5iSFtyAG4DOa9egIXVYaa1xam_8RfPeYvJNqYgBT3_F8C9fL5vRWwQa9SAwXZUNpzz0nLYlUNMNDkxUT-vUld-J-tDOMhnwEekLB8lM-nnK5ANaTuunhX6AhCK9Vg1tAKppGpUw2pI_kQmE7zqax_HWv5ILWVqSLCbXr4De2_jwlwtpdWvx5W2jyujnzdXcceE4g1fIQTSsVqhTavMKTL_k2T272DBk3V8ryAFuNc';

  String _requireApiKey() {
    // 1. Try to get the key from the build environment (dart-define)
    const String fromDefine =
        String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty && fromDefine != 'your_key_here') {
      return fromDefine.trim();
    }

    // 2. Try to get the key from .env file
    final String? key = dotenv.maybeGet('GEMINI_API_KEY')?.trim();
    if (key != null && key.isNotEmpty && key != 'your_key_here') {
      return key;
    }

    // Instead of throwing an error, we return an empty string
    // to handle it gracefully in analyzeImageBytes.
    return "";
  }

  Future<FoodVisionResult> analyzeXFile(XFile image) async {
    final Uint8List bytes = await image.readAsBytes();
    final String mime = _mimeTypeForPath(image.path);
    return analyzeImageBytes(bytes, mimeType: mime);
  }

  Future<FoodVisionResult> analyzeImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final String apiKey = _requireApiKey();

      // If key is empty, return a graceful error result instead of calling the model
      if (apiKey.isEmpty) {
        return FoodVisionResult(
          detectedIngredientNames: ["API Key Issue: Key not found"],
          recipes: [],
          detectedIngredients: [],
        );
      }

      final GenerativeModel model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          responseMimeType: 'application/json',
        ),
      );

      final GenerateContentResponse response = await model.generateContent(
        <Content>[
          Content.multi(<Part>[
            TextPart(_visionPrompt),
            DataPart(mimeType, bytes),
          ]),
        ],
      );

      final String? rawText = response.text;
      if (rawText == null || rawText.trim().isEmpty) {
        throw Exception('Gemini returned no text.');
      }

      final Object? decoded = jsonDecode(_isolateJsonObject(rawText));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Gemini JSON root is not an object.');
      }

      return _parseFoodVisionResult(decoded);
    } catch (e) {
      // Catch any error (including API issues) and return a peaceful fallback result
      return FoodVisionResult(
        detectedIngredientNames: ["API Error: ${e.toString()}"],
        recipes: [],
        detectedIngredients: [],
      );
    }
  }

  static String _mimeTypeForPath(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  static String _isolateJsonObject(String raw) {
    final String trimmed = raw.trim();
    String s = trimmed;
    if (s.startsWith('```')) {
      final int firstNl = s.indexOf('\n');
      if (firstNl != -1) {
        s = s.substring(firstNl + 1);
      }
      final int fence = s.lastIndexOf('```');
      if (fence != -1) {
        s = s.substring(0, fence).trim();
      }
    }
    final int start = s.indexOf('{');
    final int end = s.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const FormatException('No JSON object in model output.');
    }
    return s.substring(start, end + 1);
  }

  static FoodVisionResult _parseFoodVisionResult(Map<String, dynamic> root) {
    final List<String> detectedNames = _readStringList(
      root['detected_ingredients'] ?? root['detectedIngredients'],
    );

    final List<Ingredient> asIngredients = <Ingredient>[];
    for (int i = 0; i < detectedNames.length; i++) {
      final String name = detectedNames[i];
      asIngredients.add(
        Ingredient(
          id: _ingredientId(name, i),
          name: name,
          category: 'Detected',
          source: IngredientSource.camera,
        ),
      );
    }

    final Object? rawRecipes = root['recipes'];
    final List<Recipe> recipes = <Recipe>[];
    if (rawRecipes is List<dynamic>) {
      for (int i = 0; i < rawRecipes.length; i++) {
        final Object? el = rawRecipes[i];
        if (el is Map<String, dynamic>) {
          recipes.add(_recipeFromJson(el, i));
        }
      }
    }

    return FoodVisionResult(
      detectedIngredientNames: detectedNames,
      recipes: recipes,
      detectedIngredients: asIngredients,
    );
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List<dynamic>) {
      return <String>[];
    }
    final List<String> out = <String>[];
    for (final Object? el in value) {
      if (el is String) {
        final String t = el.trim();
        if (t.isNotEmpty) {
          out.add(t);
        }
      }
    }
    return out;
  }

  static String _ingredientId(String name, int index) {
    final String slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final String safe = slug.isEmpty ? 'item' : slug;
    return 'scan_${index}_$safe';
  }

  static Recipe _recipeFromJson(Map<String, dynamic> m, int index) {
    final String name = (m['name'] as String?)?.trim() ?? 'Recipe ${index + 1}';
    final int matchPct = _readInt(m['match_percentage'] ?? m['matchPercentage']);
    final String prepTime =
        (m['prep_time'] as String?)?.trim() ?? (m['prepTime'] as String?)?.trim() ?? '30 mins';
    final int calories = _readInt(m['calories']);

    final List<dynamic>? ingRaw =
        m['ingredients'] is List<dynamic> ? m['ingredients'] as List<dynamic> : null;
    final List<RecipeIngredientLine> lines = <RecipeIngredientLine>[];
    final List<String> ingredientNames = <String>[];
    if (ingRaw != null) {
      for (final Object? row in ingRaw) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        final String ingName = (row['name'] as String?)?.trim() ?? '';
        if (ingName.isEmpty) {
          continue;
        }
        ingredientNames.add(ingName);
        final Object? amountVal = row['amount'];
        final String amountStr = amountVal is String
            ? amountVal.trim()
            : (amountVal?.toString().trim() ?? '');
        final (double amt, String unit) = _parseAmount(amountStr);
        lines.add(
          RecipeIngredientLine(
            name: ingName,
            amountAtTwoServings: amt,
            unit: unit,
          ),
        );
      }
    }

    final List<dynamic>? stepsRaw =
        m['steps'] is List<dynamic> ? m['steps'] as List<dynamic> : null;
    final List<RecipeCookingStep> cookingSteps = <RecipeCookingStep>[];
    final List<String> stepStrings = <String>[];
    if (stepsRaw != null) {
      final List<Map<String, dynamic>> sorted = stepsRaw
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      sorted.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            _readInt(a['step_number'] ?? a['stepNumber'])
                .compareTo(_readInt(b['step_number'] ?? b['stepNumber'])),
      );
      for (final Map<String, dynamic> step in sorted) {
        final String instruction =
            (step['instruction'] as String?)?.trim() ?? '';
        if (instruction.isEmpty) {
          continue;
        }
        final int sn = _readInt(step['step_number'] ?? step['stepNumber']);
        final String title = sn > 0 ? 'Step $sn' : 'Step';
        cookingSteps.add(RecipeCookingStep(title: title, body: instruction));
        stepStrings.add(instruction);
      }
    }

    final List<String> tags = _readStringList(m['tags']);
    final String cuisine = tags.isNotEmpty ? tags.first : 'Suggested';
    final String description = matchPct > 0
        ? 'About $matchPct% match for ingredients you scanned.'
        : 'Suggested from your scan.';

    return Recipe(
      id: 'gemini_${index}_${name.hashCode}',
      name: name,
      cuisine: cuisine,
      cookTime: prepTime,
      difficulty: 'Easy',
      imageUrl: _placeholderRecipeImageUrl,
      cardSubtitle: matchPct > 0 ? '$matchPct% ingredient match' : null,
      showAiBadge: true,
      calories: calories > 0 ? calories : null,
      tag: tags.length > 1 ? tags[1] : null,
      description: description,
      searchKeywords: tags,
      ingredients: ingredientNames,
      steps: stepStrings,
      ingredientLines: lines.isEmpty ? null : lines,
      cookingSteps: cookingSteps.isEmpty ? null : cookingSteps,
    );
  }

  static int _readInt(Object? v) {
    if (v is int) {
      return v;
    }
    if (v is double) {
      return v.round();
    }
    if (v is String) {
      return int.tryParse(v.trim()) ?? 0;
    }
    return 0;
  }

  static (double, String) _parseAmount(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) {
      return (1, 'as needed');
    }
    final RegExpMatch? m = RegExp(
      r'^\s*([\d./]+)\s*(.*)$',
    ).firstMatch(t);
    if (m == null) {
      return (1, t);
    }
    final String numPart = m.group(1)!.trim();
    final String rest = m.group(2)?.trim() ?? '';
    double value = 1;
    if (numPart.contains('/')) {
      final List<String> frac = numPart.split('/');
      if (frac.length == 2) {
        final double? a = double.tryParse(frac[0]);
        final double? b = double.tryParse(frac[1]);
        if (a != null && b != null && b != 0) {
          value = a / b;
        }
      }
    } else {
      value = double.tryParse(numPart) ?? 1;
    }
    return (value, rest.isEmpty ? 'unit' : rest);
  }
}
