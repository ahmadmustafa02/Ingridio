import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ingridio/screens/personalize_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _validEmail = 'ahmad@ingridio.com';
  static const String _validPassword = '1234';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  static const Color _primary = Color(0xFF9D4300);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _signIn() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    if (email == _validEmail && password == _validPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PersonalizeScreen(),
        ),
      );
      return;
    }
    _showSnack('Invalid credentials');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDbVpAHMCaZ7VzFD6YDnU8xTpHKpBikZ5Zd1SGNGPkdPtxkgOQdGYmdN7PZRTFO5f2uMMTmoVXD89FMCEXgj1FnpFm8W_-Mg7d_p7h1NSVIonXAk69eB2e0zHyNVp9UOEtFQ9VIpCNJRQjgyWh5PNcRMNElZMzuRABde2dk9vVpurIofI_2fOYg92psmeYTSrtXTB5ycAYYkZnacHWRli-mhBu69WgzUmk-gIlOzKAk8pkVTOjcvI1p5K3Q78V_8avJo7wB2Hn52No',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    _background,
                    _background.withOpacity(0.4),
                  ],
                  stops: const <double>[0.4, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const _Branding(),
                      const SizedBox(height: 26),
                      _AuthCard(
                        primary: _primary,
                        primaryContainer: _primaryContainer,
                        surfaceContainerLow: _surfaceContainerLow,
                        onSurface: _onSurface,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        isPasswordHidden: _isPasswordHidden,
                        onPasswordToggle: () {
                          setState(() => _isPasswordHidden = !_isPasswordHidden);
                        },
                        onSignIn: _signIn,
                        onSocialTap: () => _showSnack('Coming soon'),
                      ),
                      const SizedBox(height: 24),
                      _Footer(primary: _primary, onSurface: _onSurface),
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
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x331A0A00),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ingridio',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 40,
            height: 1.1,
            color: Color(0xFF2F1400),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Savor every ingredient.',
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: Color(0xFF924C00),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.primary,
    required this.primaryContainer,
    required this.surfaceContainerLow,
    required this.onSurface,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordHidden,
    required this.onPasswordToggle,
    required this.onSignIn,
    required this.onSocialTap,
  });

  final Color primary;
  final Color primaryContainer;
  final Color surfaceContainerLow;
  final Color onSurface;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordHidden;
  final VoidCallback onPasswordToggle;
  final VoidCallback onSignIn;
  final VoidCallback onSocialTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0C0B1).withOpacity(0.15),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x104C2706),
                blurRadius: 60,
                offset: Offset(0, 40),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xFF2F1400),
                ),
              ),
              const SizedBox(height: 20),
              _LabeledInput(
                label: 'Email Address',
                prefixIcon: Icons.mail_outline_rounded,
                hintText: 'chef@ingridio.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
                surfaceContainerLow: surfaceContainerLow,
                onSurface: onSurface,
              ),
              const SizedBox(height: 16),
              _LabeledInput(
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                hintText: '••••••••',
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: isPasswordHidden,
                surfaceContainerLow: surfaceContainerLow,
                onSurface: onSurface,
                suffix: IconButton(
                  onPressed: onPasswordToggle,
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF8C7164),
                  ),
                ),
                trailingLabel: GestureDetector(
                  onTap: onSocialTap,
                  child: Text(
                    'Forgot?',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: <Color>[
                        Color(0xFFF97316),
                        Color(0xFF9D4300),
                      ],
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x339D4300),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onSignIn,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0C0B1).withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: const Color(0xFF8C7164).withOpacity(0.6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0C0B1).withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      icon: const _GoogleLogo(),
                      onTap: onSocialTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      icon: const Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 20,
                      ),
                      onTap: onSocialTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.prefixIcon,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.obscureText,
    required this.surfaceContainerLow,
    required this.onSurface,
    this.suffix,
    this.trailingLabel,
  });

  final String label;
  final IconData prefixIcon;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color surfaceContainerLow;
  final Color onSurface;
  final Widget? suffix;
  final Widget? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Color(0xFF924C00),
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            if (trailingLabel != null) trailingLabel!,
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w500,
            color: onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              color: Color(0x998C7164),
            ),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF8C7164)),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF9D4300), width: 1.8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF1E9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2F1400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GooglePainter(),
      ),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Rect rect = Offset.zero & size;
    final double stroke = size.width * 0.23;
    final Rect arcRect = rect.deflate(stroke / 2);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -0.25, 1.45, false, paint..strokeWidth = stroke..style = PaintingStyle.stroke);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 1.2, 1.35, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 2.6, 1.05, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 3.6, 1.3, false, paint);
    paint
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.42,
        size.width * 0.42,
        size.height * 0.16,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.primary,
    required this.onSurface,
  });

  final Color primary;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.w500,
              color: Color(0xFF584237),
            ),
            children: <InlineSpan>[
              const TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Create Account',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF8C7164),
              ),
            ),
            SizedBox(width: 22),
            Text(
              'Terms of Service',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF8C7164),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
