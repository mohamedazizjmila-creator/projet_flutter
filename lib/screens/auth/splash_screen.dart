// lib/screens/auth/splash_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // ✅ Animation rebond (plus légère)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // ✅ Barre de progression
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressController.forward();

    // ✅ Navigation après 1.8s
    Timer(const Duration(milliseconds: 1800), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primaryMain,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ✅ Cercles décoratifs (statiques, pas d'animation)
            ..._buildDecorativeCircles(size),
            // ✅ Œufs flottants (animation simplifiée)
            ..._buildFloatingEggs(size),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Logo avec effet rebond
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    ),
                    child: _buildLogo(),
                  ),
                  const SizedBox(height: 24),
                  // ✅ Texte (pas d'animation fade pour éviter lag)
                  Column(
                    children: [
                      Text(
                        'SOTAVI',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestion avicole intelligente',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ Barre de progression circulaire
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) => SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 2.5,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF86efac),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐔', style: TextStyle(fontSize: 60)),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles(Size size) {
    return [
      Positioned(
        top: -60,
        right: -60,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
          ),
        ),
      ),
      Positioned(
        bottom: 80,
        left: -80,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.03),
          ),
        ),
      ),
      Positioned(
        top: size.height * 0.5,
        right: -50,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.02),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildFloatingEggs(Size size) {
    final eggs = ['🥚', '🥚', '🐣', '🥚', '🐔'];
    final positions = [
      Offset(size.width * 0.05, size.height * 0.10),
      Offset(size.width * 0.88, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.70),
      Offset(size.width * 0.12, size.height * 0.78),
      Offset(size.width * 0.48, size.height * 0.85),
    ];
    final delays = [0.0, 0.7, 1.2, 0.3, 1.8];

    return List.generate(eggs.length, (i) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 2000 + (i * 200)),
        builder: (context, value, child) {
          final offset = sin(value * pi * 2) * 12;
          return Positioned(
            left: positions[i].dx,
            top: positions[i].dy + offset,
            child: Opacity(
              opacity: 0.2,
              child: Text(
                eggs[i],
                style: TextStyle(fontSize: 26 + i * 3.0),
              ),
            ),
          );
        },
      );
    });
  }
}
