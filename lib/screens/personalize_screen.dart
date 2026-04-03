import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/logic/user_preferences_store.dart';
import 'package:ingridio/models/user_preferences.dart';
import 'package:ingridio/screens/home_screen.dart';

class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key, this.navigateHomeOnSave = true});

  final bool navigateHomeOnSave;

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _CuisineItem {
  const _CuisineItem({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.featuredHeight,
    required this.compactHeight,
    required this.titleSize,
  });

  final String id;
  final String label;
  final String imageUrl;
  final double featuredHeight;
  final double compactHeight;
  final double titleSize;
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _onSecondaryFixedVariant = Color(0xFF6F3800);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  static const String _pakistaniId = 'Pakistani & Desi';

  static const List<_CuisineItem> _cuisines = <_CuisineItem>[
    _CuisineItem(
      id: _pakistaniId,
      label: 'Pakistani & Desi',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCb_qrJpuKTwQJzmtb3rfH8WlXvVRAr8zP3zdPietpou6qDQnNbom_fbYgnJbSU1lOiUdHm4AABR9wJwslQEI-wHcoAh6eVKz6ljwgwNE_97rfkxUv_KxLBbFNOTSdvisGAIaEh5lK9yb557OAhfSsaUL0pNDRSwB0RMgbFnX3IcyRqklrhsy_NBP96NAWRIvZ7QqsyERR4JvpsESDHomE6bz2d-4f9RuzlJzFhtKaxUBUSZxnFtkAb_TzQdkhNd_6BCKbYNgCWH8w',
      featuredHeight: 192,
      compactHeight: 192,
      titleSize: 20,
    ),
    _CuisineItem(
      id: 'Italian',
      label: 'Italian',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBqUoFTn0Fmc4F3ntVpWrj8tWyJbtL_G5kK_DdoKK7TYq-e7ghe97UXa3lpfPldVbcBtNov1u6oZ3JY0LcZfaa_Oy0kzOM3KborWzStaOc0Gozcf-NVitoPzqhxcV2FYk5z9IXpPsT_AriUK4aA6dBGp5-ihR6SMH2WRfup_qc2iB9SRL_ZKmtLfVL1h6fMlcwTkwCdJNfm07BVmxpOdhDJ9exCn62YI_G-8qfBSXqTDzxArmM8z04VOWJiZSZnGsOyxQfQOzxN7B0',
      featuredHeight: 192,
      compactHeight: 160,
      titleSize: 18,
    ),
    _CuisineItem(
      id: 'Chinese',
      label: 'Chinese',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCGCMtIaWYpN8DRh19t3SmYlb9SqdFQ7fIXA6tOhjJ00JCcjtbyEbdki79Bygq6Dp-91JWHdLlact69-QfgSYwX9AN6yKFY6aIFg1h0AoO9IM1btLKJKoZLB4nrzjqnNg0DFcsm_11rm8dsVodXhiUwsDp3_JMejUKIKnDK_ZJcBhPx7rtieSO6sWfmNlwuqaPqRFOWu5cvL5RqLs3Qwubm_7K--_DwqcgdzrwcFwA87pAzugyHi533ii4pClUtM--jbQO4WXCAvk4',
      featuredHeight: 192,
      compactHeight: 160,
      titleSize: 18,
    ),
    _CuisineItem(
      id: 'Mediterranean',
      label: 'Mediterranean',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAky8jJu_so2KlJUGUyZ-ZAf2XZH0ZFmYcHQTejc6c--nGR30GILdx5gSGa3ShLN3pah0Zion1ikMm9H62awp3FzZSde7cWZ6N_ktA-4rvvLvE0rbDF2XJGcyzbmv4g3_JJmcFm8Usqkm3BOLTJcwcP5OO0rh7hiXPetiHnDu4PaFGRn2zFdb9q7dsuT1_158E6VKfAFZ4MP7qDgUWlkA9Iil-BZ08f-RUVlW0pT5U0dFM_hegIihGLROf_Qjr5UDkBpdmqHhe_H24',
      featuredHeight: 192,
      compactHeight: 160,
      titleSize: 18,
    ),
    _CuisineItem(
      id: 'Mexican',
      label: 'Mexican',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBs-73Gfo5gYzdTqs-XSLkESJPmaxLRO3NpWBRLbUZm4Qai8CKmnYY593mpuHimtYz_4ULEap4i2RcbL1PZiNFAC2nRxWjkFxnCQITPkJTAp44YPl3SPC9FZfWfzSldtLV8B4jRbVgfFfLJ7adF-6Ix_7nCIid5kJBEFY72prK0tV-9igh-G2_rb1HEGLkjCW9ns9lRLd7ZXvz1wCRuMDDbxgjoqtuDSyToopytYml13lacwie60hxVR_7eylhxWWCkXmBKF85IreE',
      featuredHeight: 192,
      compactHeight: 160,
      titleSize: 18,
    ),
  ];

  static const List<String> _dietLabels = <String>[
    'Halal',
    'Gluten-Free',
    'Vegan',
    'High Protein',
    'Low Carb',
    'Others',
  ];

  final List<String> selectedCuisines = <String>[];
  final List<String> selectedDiets = <String>[];

  bool get _canSave => selectedCuisines.length >= 2;

  @override
  void initState() {
    super.initState();
    final UserPreferences? existing = UserPreferencesStore.current;
    if (existing != null) {
      selectedCuisines.addAll(existing.selectedCuisines);
      selectedDiets.addAll(existing.selectedDiets);
    }
  }

  static const String _pairingEmptyMessage =
      'Select your favorite cuisines to get personalized meal plans.';

  String get _pairingHighlight {
    if (selectedCuisines.isEmpty) {
      return '';
    }
    if (selectedCuisines.contains(_pakistaniId)) {
      return 'Pakistani & Desi';
    }
    if (selectedCuisines.contains('Italian')) {
      return 'Italian';
    }
    return selectedCuisines.first;
  }

  void _toggleCuisine(String id) {
    setState(() {
      if (selectedCuisines.contains(id)) {
        selectedCuisines.remove(id);
      } else {
        selectedCuisines.add(id);
      }
    });
  }

  void _toggleDiet(String label) {
    setState(() {
      if (selectedDiets.contains(label)) {
        selectedDiets.remove(label);
      } else {
        selectedDiets.add(label);
      }
    });
  }

  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onSave() {
    if (!_canSave) {
      return;
    }
    UserPreferencesStore.save(
      UserPreferences(
        displayName: UserPreferencesStore.current?.displayName,
        selectedCuisines: List<String>.from(selectedCuisines),
        selectedDiets: List<String>.from(selectedDiets),
      ),
    );
    if (widget.navigateHomeOnSave) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = MediaQuery.sizeOf(context).width < 380 ? 20 : 24;
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: _background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: _background,
            padding: EdgeInsets.fromLTRB(horizontal, safe.top + 8, horizontal, 12),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: _onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: const Icon(Icons.arrow_back_rounded, color: _primary),
                ),
                Expanded(
                  child: Text(
                    'Personalize Your Table',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Savor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tell us what you love, and we\'ll handle the rest.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _secondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Favorite Cuisines',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                        ),
                      ),
                      Text(
                        'Select 2 or more',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildCuisineGrid(),
                  const SizedBox(height: 44),
                  Text(
                    'Dietary Requirements',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _dietLabels.map((String label) {
                      final bool selected = selectedDiets.contains(label);
                      return _DietChip(
                        label: label,
                        selected: selected,
                        onTap: () => _toggleDiet(label),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _surfaceContainerLowest.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _outlineVariant.withOpacity(0.15),
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _tertiaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: _onTertiaryContainer,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Smart Pairing',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: _onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  selectedCuisines.isEmpty
                                      ? Text(
                                          _pairingEmptyMessage,
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: _onSurfaceVariant,
                                          ),
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 14,
                                              height: 1.5,
                                              color: _onSurfaceVariant,
                                            ),
                                            children: <InlineSpan>[
                                              const TextSpan(
                                                text: 'Based on your love for ',
                                              ),
                                              TextSpan(
                                                text: _pairingHighlight,
                                                style: GoogleFonts.beVietnamPro(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _primary,
                                                ),
                                              ),
                                              TextSpan(
                                                text: _pairingSuffix,
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomSaveBar(
            enabled: _canSave,
            onSave: _onSave,
            bottomInset: safe.bottom,
            horizontal: horizontal,
          ),
        ],
      ),
    );
  }

  String get _pairingSuffix {
    if (selectedCuisines.contains(_pakistaniId)) {
      return ', we\'ll prioritize aromatic spices and layered flavors in your meal plans.';
    }
    if (selectedCuisines.contains('Italian')) {
      return ', we\'ll prioritize fresh herbs and artisanal oils in your meal plans.';
    }
    if (selectedCuisines.length == 1) {
      return ', we\'ll tailor suggestions to match your tastes.';
    }
    return ', we\'ll blend those flavors into your meal plans.';
  }

  Widget _buildCuisineGrid() {
    final _CuisineItem featured = _cuisines[0];
    final List<_CuisineItem> rest = _cuisines.sublist(1);

    return Column(
      children: <Widget>[
        _CuisineCard(
          item: featured,
          fullWidth: true,
          selected: selectedCuisines.contains(featured.id),
          onTap: () => _toggleCuisine(featured.id),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < rest.length; i += 2) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _CuisineCard(
                  item: rest[i],
                  fullWidth: false,
                  selected: selectedCuisines.contains(rest[i].id),
                  onTap: () => _toggleCuisine(rest[i].id),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < rest.length
                    ? _CuisineCard(
                        item: rest[i + 1],
                        fullWidth: false,
                        selected:
                            selectedCuisines.contains(rest[i + 1].id),
                        onTap: () => _toggleCuisine(rest[i + 1].id),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (i + 2 < rest.length) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CuisineCard extends StatelessWidget {
  const _CuisineCard({
    required this.item,
    required this.fullWidth,
    required this.selected,
    required this.onTap,
  });

  final _CuisineItem item;
  final bool fullWidth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double h =
        fullWidth ? item.featuredHeight : item.compactHeight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _PersonalizeScreenState._primaryContainer : Colors.transparent,
              width: selected ? 3 : 0,
            ),
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33F97316),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: _PersonalizeScreenState._surfaceContainerLow,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: fullWidth
                        ? <Color>[
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.82),
                          ]
                        : <Color>[
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.12),
                            Colors.black.withOpacity(0.72),
                          ],
                    stops: fullWidth
                        ? const <double>[0.0, 0.35, 1.0]
                        : const <double>[0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: fullWidth ? 20 : 16,
                bottom: fullWidth ? 16 : 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: item.titleSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (selected) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _PersonalizeScreenState._primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DietChip extends StatelessWidget {
  const _DietChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool showRestaurant = selected && label == 'Halal';
    final bool showAdd = label == 'Others';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? _PersonalizeScreenState._secondaryFixed
                : _PersonalizeScreenState._surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? _PersonalizeScreenState._primaryContainer
                  : Colors.transparent,
              width: selected ? 2 : 0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showRestaurant) ...<Widget>[
                Icon(
                  Icons.restaurant_rounded,
                  size: 20,
                  color: _PersonalizeScreenState._onSecondaryFixedVariant,
                ),
                const SizedBox(width: 6),
              ],
              if (showAdd && !selected) ...<Widget>[
                Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: _PersonalizeScreenState._secondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? _PersonalizeScreenState._onSecondaryFixedVariant
                      : _PersonalizeScreenState._secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSaveBar extends StatelessWidget {
  const _BottomSaveBar({
    required this.enabled,
    required this.onSave,
    required this.bottomInset,
    required this.horizontal,
  });

  final bool enabled;
  final VoidCallback onSave;
  final double bottomInset;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            _PersonalizeScreenState._background,
            _PersonalizeScreenState._background.withOpacity(0.95),
            _PersonalizeScreenState._background.withOpacity(0),
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, bottomInset + 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: enabled
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: <Color>[
                        _PersonalizeScreenState._primaryContainer,
                        _PersonalizeScreenState._primary,
                      ],
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x264C2706),
                        blurRadius: 40,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save & Continue',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFE8DDD6),
                    disabledForegroundColor: const Color(0xFF8C7164),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save & Continue',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
