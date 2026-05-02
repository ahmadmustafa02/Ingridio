import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/logic/pantry_manager.dart';
import 'package:ingridio/models/ingredient.dart';
import 'package:ingridio/screens/profile_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _secondaryContainer = Color(0xFFFC9436);
  static const Color _outline = Color(0xFF8C7164);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiaryFixed = Color(0xFFFFDEA8);
  static const Color _tertiary = Color(0xFF7C5800);
  static const Color _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ingredient> _filtered(List<Ingredient> all) {
    final String q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      return List<Ingredient>.from(all);
    }
    return all
        .where((Ingredient e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirmRemove(Ingredient ingredient) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove ingredient?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Remove ${ingredient.name} from pantry?',
            style: GoogleFonts.beVietnamPro(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.beVietnamPro(color: _outline),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w700,
                  color: _error,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      PantryManager.instance.removeById(ingredient.id);
    }
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _AddIngredientSheet(
          onAdded: () {
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ingredient added!',
                  style: GoogleFonts.beVietnamPro(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _produceIcon(String name) {
    switch (name.toLowerCase()) {
      case 'tomatoes':
        return Icons.restaurant_rounded;
      case 'spinach':
        return Icons.spa_rounded;
      case 'avocado':
        return Icons.grid_view_rounded;
      case 'carrots':
        return Icons.agriculture_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  Widget _freshStatus(Ingredient i) {
    final int? d = i.daysLeft;
    if (d == null) {
      return const SizedBox.shrink();
    }
    if (d <= 1) {
      return Text(
        'Expiring soon',
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _error,
        ),
      );
    }
    if (d <= 3) {
      return Text(
        '$d days left',
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _primaryContainer,
        ),
      );
    }
    return Text(
      d == 7 ? '1 week' : '$d days',
      style: GoogleFonts.beVietnamPro(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _outline,
        letterSpacing: 0.4,
      ),
    );
  }

  String _dairyQtyLine(Ingredient i) {
    if (i.unit == 'pack') {
      return '${i.quantity ?? 0} pack';
    }
    return '${i.quantity ?? 0} left';
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = MediaQuery.sizeOf(context).width < 380 ? 20 : 24;
    final double bottomPad = MediaQuery.paddingOf(context).bottom + 100;

    return ColoredBox(
      color: _background,
      child: ListenableBuilder(
        listenable: PantryManager.instance,
        builder: (BuildContext context, Widget? child) {
          final List<Ingredient> all = PantryManager.instance.items;
          final List<Ingredient> filtered = _filtered(all);
          final List<Ingredient> produce = filtered
              .where((Ingredient e) => e.category == 'Fresh Produce')
              .toList();
          final List<Ingredient> spices =
              filtered.where((Ingredient e) => e.category == 'Spices').toList();
          final List<Ingredient> grains =
              filtered.where((Ingredient e) => e.category == 'Grains').toList();
          final List<Ingredient> dairy = filtered
              .where((Ingredient e) => e.category == 'Dairy & Proteins')
              .toList();
          final List<Ingredient> other = filtered
              .where((Ingredient e) => e.category == 'Other')
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ColoredBox(
                color: _background,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Ingridio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: _onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.settings_rounded,
                            color: _primaryContainer,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No ingredients found',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          8,
                          horizontal,
                          bottomPad,
                        ),
                        child: LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints c) {
                            final bool wide = c.maxWidth >= 840;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  'My Pantry',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    letterSpacing: -0.8,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${all.length} ingredients available for cooking',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _secondary,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints rowC) {
                                    final bool rowWide = rowC.maxWidth > 560;
                                    if (rowWide) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: _SearchField(
                                              controller: _searchController,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          _AddButton(onPressed: _showAddSheet),
                                        ],
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        _SearchField(
                                          controller: _searchController,
                                        ),
                                        const SizedBox(height: 12),
                                        _AddButton(onPressed: _showAddSheet),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 36),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: _FreshProduceSection(
                                          items: produce,
                                          produceIcon: _produceIcon,
                                          freshStatus: _freshStatus,
                                          onLongPressRemove: _confirmRemove,
                                        ),
                                      ),
                                      const SizedBox(width: 22),
                                      Expanded(
                                        flex: 4,
                                        child: _SpicesSection(
                                          items: spices,
                                          errorColor: _error,
                                          surfaceLowest: _surfaceContainerLowest,
                                          outlineVariant: _outlineVariant,
                                          tertiary: _tertiary,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...<Widget>[
                                  _FreshProduceSection(
                                    items: produce,
                                    produceIcon: _produceIcon,
                                    freshStatus: _freshStatus,
                                    onLongPressRemove: _confirmRemove,
                                  ),
                                  const SizedBox(height: 22),
                                  _SpicesSection(
                                    items: spices,
                                    errorColor: _error,
                                    surfaceLowest: _surfaceContainerLowest,
                                    outlineVariant: _outlineVariant,
                                    tertiary: _tertiary,
                                  ),
                                ],
                                const SizedBox(height: 22),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: _GrainsSection(
                                          items: grains,
                                          onLongPressRemove: _confirmRemove,
                                        ),
                                      ),
                                      const SizedBox(width: 22),
                                      Expanded(
                                        child: _DairySection(
                                          items: dairy,
                                          dairyQtyLine: _dairyQtyLine,
                                          onLongPressRemove: _confirmRemove,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...<Widget>[
                                  _GrainsSection(
                                    items: grains,
                                    onLongPressRemove: _confirmRemove,
                                  ),
                                  const SizedBox(height: 22),
                                  _DairySection(
                                    items: dairy,
                                    dairyQtyLine: _dairyQtyLine,
                                    onLongPressRemove: _confirmRemove,
                                  ),
                                ],
                                if (other.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 22),
                                  _OtherSection(
                                    items: other,
                                    onLongPressRemove: _confirmRemove,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _outline = Color(0xFF8C7164);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.beVietnamPro(
        color: _onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search your pantry...',
        hintStyle: GoogleFonts.beVietnamPro(color: _outline.withValues(alpha: 0.85)),
        prefixIcon: const Icon(Icons.search_rounded, color: _outline),
        filled: true,
        fillColor: _surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryContainer, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _primaryContainer,
        borderRadius: BorderRadius.circular(14),
        elevation: 4,
        shadowColor: const Color(0x33F97316),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Add Ingredient',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FreshProduceSection extends StatelessWidget {
  const _FreshProduceSection({
    required this.items,
    required this.produceIcon,
    required this.freshStatus,
    required this.onLongPressRemove,
  });

  final List<Ingredient> items;
  final IconData Function(String name) produceIcon;
  final Widget Function(Ingredient) freshStatus;
  final Future<void> Function(Ingredient) onLongPressRemove;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _primary = Color(0xFF9D4300);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: _surfaceContainerLow,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.eco_rounded, color: _primary),
                          const SizedBox(width: 8),
                          Text(
                            'Fresh Produce',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${items.length} Items',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints bc) {
                      final int cols = bc.maxWidth > 360 ? 4 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Ingredient i = items[index];
                          return GestureDetector(
                            onLongPress: () => onLongPressRemove(i),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      color: _surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      produceIcon(i.name),
                                      color: _primary,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    i.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  freshStatus(i),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: -28,
              bottom: -28,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.1,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Image.network(
                      MockData.pantryProduceDecorationUrl,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpicesSection extends StatelessWidget {
  const _SpicesSection({
    required this.items,
    required this.errorColor,
    required this.surfaceLowest,
    required this.outlineVariant,
    required this.tertiary,
  });

  final List<Ingredient> items;
  final Color errorColor;
  final Color surfaceLowest;
  final Color outlineVariant;
  final Color tertiary;

  static const Color _tertiaryFixed = Color(0xFFFFDEA8);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _tertiaryFixed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.flare_rounded, color: tertiary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Spices',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...items.map((Ingredient i) {
            final bool isLow = i.stockLevel == 'Low';
            final bool isLast = i == items.last;
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        i.name,
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLow ? errorColor : surfaceLowest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        i.stockLevel ?? '',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLow ? Colors.white : _onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Divider(
                    height: 20,
                    color: outlineVariant.withValues(alpha: 0.12),
                  ),
              ],
            );
          }),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surfaceLowest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI SUGGESTION: "You have enough to make a Madras Curry."',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tertiary,
                    height: 1.35,
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

class _GrainsSection extends StatelessWidget {
  const _GrainsSection({
    required this.items,
    required this.onLongPressRemove,
  });

  final List<Ingredient> items;
  final Future<void> Function(Ingredient) onLongPressRemove;

  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _secondary = Color(0xFF924C00);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.grain_rounded, color: _secondary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Grains & Staples',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((Ingredient i) {
                  return GestureDetector(
                    onLongPress: () => onLongPressRemove(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        i.name,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          width: 96,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: <Color>[
                  _secondary.withValues(alpha: 0.05),
                  _secondary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DairySection extends StatelessWidget {
  const _DairySection({
    required this.items,
    required this.dairyQtyLine,
    required this.onLongPressRemove,
  });

  final List<Ingredient> items;
  final String Function(Ingredient) dairyQtyLine;
  final Future<void> Function(Ingredient) onLongPressRemove;

  static const Color _secondaryContainer = Color(0xFFFC9436);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ColoredBox(
            color: _secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.egg_alt_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Dairy & Proteins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...items.map((Ingredient i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onLongPress: () => onLongPressRemove(i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    i.name.toLowerCase().contains('egg')
                                        ? Icons.egg_rounded
                                        : Icons.opacity_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      i.name,
                                      style: GoogleFonts.beVietnamPro(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    dairyQtyLine(i),
                                    style: GoogleFonts.beVietnamPro(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.3,
                child: Transform.rotate(
                  angle: -0.1,
                  child: Image.network(
                    MockData.pantryDairyDecorationUrl,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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

class _OtherSection extends StatelessWidget {
  const _OtherSection({
    required this.items,
    required this.onLongPressRemove,
  });

  final List<Ingredient> items;
  final Future<void> Function(Ingredient) onLongPressRemove;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Other',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((Ingredient i) {
              return GestureDetector(
                onLongPress: () => onLongPressRemove(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    i.name,
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      color: _onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AddIngredientSheet extends StatefulWidget {
  const _AddIngredientSheet({required this.onAdded});

  final VoidCallback onAdded;

  @override
  State<_AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<_AddIngredientSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  static const List<String> _units = <String>[
    'pcs',
    'g',
    'kg',
    'ml',
    'l',
    'cup',
    'bunch',
    'pack',
    'jar',
  ];

  static const List<String> _categories = <String>[
    'Fresh Produce',
    'Spices',
    'Grains',
    'Dairy & Proteins',
    'Other',
  ];

  String _unit = 'pcs';
  String _category = 'Other';

  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _primary = Color(0xFF9D4300);

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final int? qty = int.tryParse(_quantity.text.trim());
    PantryManager.instance.add(
      Ingredient(
        id: PantryManager.newId(),
        name: _name.text.trim(),
        category: _category,
        quantity: qty,
        unit: _unit,
        daysLeft: _category == 'Fresh Produce' ? 7 : null,
        stockLevel: _category == 'Spices' ? 'Med' : null,
        source: IngredientSource.manual,
      ),
    );
    widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        decoration: const BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  'Add Ingredient',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _name,
                  decoration: _fieldDecoration('Ingredient name'),
                  style: GoogleFonts.beVietnamPro(color: _onSurface),
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('Quantity (optional)'),
                  style: GoogleFonts.beVietnamPro(color: _onSurface),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: _fieldDecoration('Unit'),
                  items: _units
                      .map(
                        (String u) => DropdownMenuItem<String>(
                          value: u,
                          child: Text(u, style: GoogleFonts.beVietnamPro()),
                        ),
                      )
                      .toList(),
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() => _unit = v);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _fieldDecoration('Category'),
                  items: _categories
                      .map(
                        (String c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c, style: GoogleFonts.beVietnamPro()),
                        ),
                      )
                      .toList(),
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() => _category = v);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: _primary,
                          side: const BorderSide(color: _primary),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _primaryContainer,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Add to Pantry',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.beVietnamPro(color: _onSurface.withValues(alpha: 0.7)),
      filled: true,
      fillColor: _surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
