import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/models/scanned_ingredient.dart';
import 'package:ingridio/screens/recipe_match_screen.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({
    super.key,
    required this.initialIngredients,
  });

  final List<ScannedIngredient> initialIngredients;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);

  late List<ScannedIngredient> _items;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List<ScannedIngredient>.from(widget.initialIngredients);
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _removeAt(int index) {
    setState(() => _items.removeAt(index));
  }

  void _addFromField() {
    final String name = _addController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() {
      _items.add(
        ScannedIngredient(
          name: name,
          confidence: IngredientConfidence.high,
        ),
      );
      _addController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int count = _items.length;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        foregroundColor: _onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'We found $count ingredients!',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                final ScannedIngredient item = _items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _IngredientResultCard(
                    ingredient: item,
                    onRemove: () => _removeAt(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Material(
              color: _surfaceContainerLowest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _outlineVariant.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addFromField(),
                        style: GoogleFonts.beVietnamPro(
                          color: _onSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add more ingredients…',
                          hintStyle: GoogleFonts.beVietnamPro(
                            color: _onSurfaceVariant,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _addFromField,
                      style: IconButton.styleFrom(
                        backgroundColor: _surfaceContainerLow,
                        foregroundColor: _primary,
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final List<String> names =
                        _items.map((ScannedIngredient e) => e.name).toList();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecipeMatchScreen(
                          detectedIngredients: names,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Find Recipes with $count ingredients →',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientResultCard extends StatelessWidget {
  const _IngredientResultCard({
    required this.ingredient,
    required this.onRemove,
  });

  final ScannedIngredient ingredient;
  final VoidCallback onRemove;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final bool high = ingredient.confidence == IngredientConfidence.high;

    return Material(
      color: _surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                ingredient.name,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: high
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                high ? '✓ Detected' : '? Not sure',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: high ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF584237),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFF1E9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
