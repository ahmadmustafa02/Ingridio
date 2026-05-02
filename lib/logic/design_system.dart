import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple-inspired design constants and utilities for UI consistency
class DesignSystem {
  // Color Palette
  static const Color primary = Color(0xFF9D4300);
  static const Color primaryContainer = Color(0xFFF97316);
  static const Color secondary = Color(0xFF924C00);
  static const Color background = Color(0xFFFFF8F5);
  static const Color onSurface = Color(0xFF2F1400);
  static const Color onSurfaceVariant = Color(0xFF584237);
  
  // Surface Colors
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFFFF1E9);
  static const Color surfaceHigh = Color(0xFFFFE3D1);
  static const Color surfaceHighest = Color(0xFFFFDCC4);
  
  // Other Colors
  static const Color tertiary = Color(0xFF7C5800);
  static const Color tertiaryContainer = Color(0xFFC99000);
  static const Color outlineVariant = Color(0xFFE0C0B1);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Typography
  static TextStyle headlineLarge({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      color: color ?? onSurface,
    );
  }

  static TextStyle headlineMedium({Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color ?? onSurface,
    );
  }

  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color ?? onSurface,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color ?? onSurface,
    );
  }

  static TextStyle labelSmall({Color? color}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color ?? onSurfaceVariant,
    );
  }
}

/// Apple-inspired card widget with consistent styling
class AppleCard extends StatelessWidget {
  const AppleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignSystem.spacingLg),
    this.borderRadius = DesignSystem.radiusMd,
    this.backgroundColor = DesignSystem.surfaceLowest,
    this.borderColor,
    this.elevation = 0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color? borderColor;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: elevation * 2,
                      offset: Offset(0, elevation / 2),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Apple-inspired button with consistent styling
class AppleButton extends StatelessWidget {
  const AppleButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    
    Color bgColor;
    Color fgColor;
    double padding;
    double fontSize;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = disabled ? DesignSystem.surfaceHigh : DesignSystem.primary;
        fgColor = Colors.white;
      case ButtonVariant.secondary:
        bgColor = DesignSystem.surfaceHigh;
        fgColor = DesignSystem.primary;
      case ButtonVariant.tertiary:
        bgColor = DesignSystem.surfaceLow;
        fgColor = DesignSystem.onSurface;
    }

    switch (size) {
      case ButtonSize.small:
        padding = DesignSystem.spacingSm;
        fontSize = 13;
      case ButtonSize.medium:
        padding = DesignSystem.spacingMd;
        fontSize = 15;
      case ButtonSize.large:
        padding = DesignSystem.spacingLg;
        fontSize = 17;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
          ),
          child: isLoading
              ? SizedBox(
                  height: fontSize + 4,
                  width: fontSize + 4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
        ),
      ),
    );
  }
}

enum ButtonVariant { primary, secondary, tertiary }
enum ButtonSize { small, medium, large }

/// Consistent divider with proper spacing
class AppleSpacer extends StatelessWidget {
  const AppleSpacer({
    super.key,
    this.height = DesignSystem.spacingLg,
    this.width = 0,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}

/// Section header with consistent styling
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: DesignSystem.headlineMedium(),
            ),
            if (action != null) action!,
          ],
        ),
        if (subtitle != null) ...[
          const AppleSpacer(height: DesignSystem.spacingSm),
          Text(
            subtitle!,
            style: DesignSystem.bodyMedium(color: DesignSystem.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
