import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/logic/user_preferences_store.dart';
import 'package:ingridio/models/user_preferences.dart';
import 'package:ingridio/screens/login_screen.dart';
import 'package:ingridio/screens/personalize_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _secondaryContainer = Color(0xFFFC9436);
  static const Color _tertiary = Color(0xFF7C5800);
  static const Color _tertiaryFixed = Color(0xFFFFDEA8);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);
  static const Color _outline = Color(0xFF8C7164);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _sectionHeader = Color(0xFFC56902);

  late final AnimationController _avatarTiltController;
  late final Animation<double> _avatarTilt;

  static const String _defaultName = 'Ahmad Mustafa';

  @override
  void initState() {
    super.initState();
    _avatarTiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _avatarTilt = Tween<double>(begin: 3 * math.pi / 180, end: 0).animate(
      CurvedAnimation(
        parent: _avatarTiltController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _avatarTiltController.dispose();
    super.dispose();
  }

  String get _displayName =>
      UserPreferencesStore.current?.displayName?.trim().isNotEmpty == true
          ? UserPreferencesStore.current!.displayName!.trim()
          : _defaultName;

  String _preferenceLine(List<String> values) {
    if (values.isEmpty) {
      return 'Not set';
    }
    return values.join(', ');
  }

  Future<void> _openPersonalize() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const PersonalizeScreen(navigateHomeOnSave: false),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleNotifications() {
    setState(() {
      UserPreferencesStore.notificationsEnabled =
          !UserPreferencesStore.notificationsEnabled;
    });
  }

  void _showLanguageDialog() {
    final String current = UserPreferencesStore.selectedLanguage;
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Language',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LanguageOptionTile(
                label: 'English (US)',
                selected: current == 'English (US)',
                onTap: () {
                  UserPreferencesStore.selectedLanguage = 'English (US)';
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
              ),
              _LanguageOptionTile(
                label: 'Urdu',
                selected: current == 'Urdu',
                onTap: () {
                  UserPreferencesStore.selectedLanguage = 'Urdu';
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
              ),
              _LanguageOptionTile(
                label: 'Arabic',
                selected: current == 'Arabic',
                onTap: () {
                  UserPreferencesStore.selectedLanguage = 'Arabic';
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Ingridio Terms of Service\n\n'
            'By using this app you agree to cook delicious meals responsibly. '
            'All recipes are for personal use only.',
            style: GoogleFonts.beVietnamPro(height: 1.45),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.beVietnamPro(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.beVietnamPro(color: _onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Logout',
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
    if (ok == true && mounted) {
      UserPreferencesStore.reset();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = MediaQuery.sizeOf(context).width < 380 ? 20 : 24;
    final double bottomPad = MediaQuery.paddingOf(context).bottom + 100;
    final UserPreferences? prefs = UserPreferencesStore.current;
    final List<String> cuisines = prefs?.selectedCuisines ?? <String>[];
    final List<String> diets = prefs?.selectedDiets ?? <String>[];

    return ColoredBox(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ColoredBox(
            color: _background,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _primaryContainer,
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              MockData.profileHeaderAvatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: _surfaceContainerHigh,
                                child: Icon(Icons.person, color: _secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ingridio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: _onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: _primary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, bottomPad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildProfileHero(),
                      const SizedBox(height: 40),
                      _buildSectionHeader('Culinary Profile'),
                      const SizedBox(height: 14),
                      _PreferenceRow(
                        icon: Icons.ramen_dining_rounded,
                        iconBackground: _secondaryFixed,
                        iconColor: _secondary,
                        title: 'Cuisine Preferences',
                        subtitle: _preferenceLine(cuisines),
                        onTap: _openPersonalize,
                      ),
                      const SizedBox(height: 10),
                      _PreferenceRow(
                        icon: Icons.eco_rounded,
                        iconBackground: _tertiaryFixed,
                        iconColor: _tertiary,
                        title: 'Dietary Preferences',
                        subtitle: _preferenceLine(diets),
                        onTap: _openPersonalize,
                      ),
                      const SizedBox(height: 36),
                      _buildSectionHeader('App Settings'),
                      const SizedBox(height: 14),
                      _buildSettingsCard(),
                      const SizedBox(height: 36),
                      _LogoutButton(onTap: _confirmLogout),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: _sectionHeader,
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Center(
          child: MouseRegion(
            onEnter: (_) => _avatarTiltController.forward(),
            onExit: (_) => _avatarTiltController.reverse(),
            child: Listener(
              onPointerDown: (_) => _avatarTiltController.forward(),
              onPointerUp: (_) => _avatarTiltController.reverse(),
              onPointerCancel: (_) => _avatarTiltController.reverse(),
              child: SizedBox(
                width: 148,
                height: 148,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _avatarTilt,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.rotate(
                          angle: _avatarTilt.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          MockData.profileHeroAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: _surfaceContainerHigh,
                            child: Icon(Icons.person, size: 48, color: _outline),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _tertiaryContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _background, width: 2),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          'Level 12',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Master Saucier',
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: _secondary,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: _tertiaryContainer,
                label: 'Streak',
                value: '14 Days',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.restaurant_rounded,
                iconColor: _primaryContainer,
                label: 'Cooked',
                value: '42 Recipes',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    final bool on = UserPreferencesStore.notificationsEnabled;
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: <Widget>[
                const Icon(Icons.notifications_rounded, color: _secondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: _onSurface,
                    ),
                  ),
                ),
                _OrangeToggle(
                  value: on,
                  onChanged: (_) => _toggleNotifications(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: _outlineVariant.withValues(alpha: 0.25)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLanguageDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.language_rounded, color: _secondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Language',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    Text(
                      UserPreferencesStore.selectedLanguage,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _secondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: _outlineVariant.withValues(alpha: 0.25)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showTermsDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.gavel_rounded, color: _secondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Terms of Service',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, color: _outline, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: GoogleFonts.beVietnamPro()),
      trailing: selected ? const Icon(Icons.check_rounded, color: Color(0xFF9D4300)) : null,
      onTap: onTap,
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const Color _surfaceLowest = Color(0xFFFFFFFF);
  static const Color _surfaceHigh = Color(0xFFFFE3D1);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _outline = Color(0xFF8C7164);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surfaceLowest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: _surfaceHigh.withValues(alpha: 0.5),
        highlightColor: _surfaceHigh.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  static const Color _surfaceLow = Color(0xFFFFF1E9);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _secondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrangeToggle extends StatelessWidget {
  const _OrangeToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? _primaryContainer : const Color(0xFFD0D0D0),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  static const Color _error = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: _errorContainer,
        borderRadius: 12,
      ),
      child: Material(
        color: _errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.logout_rounded, color: _error),
                const SizedBox(width: 10),
                Text(
                  'Logout',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _error,
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

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(borderRadius - 1),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Path path = Path()..addRRect(rrect);
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      const double dash = 6;
      const double gap = 4;
      while (distance < metric.length) {
        final double len = math.min(dash, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}
