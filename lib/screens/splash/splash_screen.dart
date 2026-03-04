import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../theme/colors.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Timeline
  static const Duration totalDuration = Duration(milliseconds: 5000);
  static const Duration navigationStart = Duration(milliseconds: 4900);
  static const Duration transitionDuration = Duration(milliseconds: 320);

  // Scene positioning
  static const Alignment _oceanShimmerAlignment = Alignment(0, 0.66);
  static const Alignment _mistOriginAlignment = Alignment(0.08, 0.72);

  late final AnimationController _controller;
  late final AnimationController _ambientController;

  late final Animation<double> _fadeIn;
  late final Animation<double> _pushIn;
  late final Animation<double> _waterShift;
  late final Animation<double> _sunOpacity;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoRise;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _goldSweep;

  // Mist drifts ~10 px to the right over 3 seconds and loops subtly.
  late final Animation<double> _mistDrift;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..forward();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 0.0s -> 0.5s fade from black.
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
    );

    // 0.0s -> 5.0s tiny cinematic push-in.
    _pushIn = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Begin subtle overlays after ~1.0s.
    _waterShift = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.linear),
      ),
    );

    _sunOpacity = Tween<double>(begin: 0.11, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Logo appears near 2.5s (0.5 x 5s).
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.74, curve: Curves.easeOut),
      ),
    );

    _logoRise = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.74, curve: Curves.easeOutCubic),
      ),
    );

    _haloOpacity = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeOut),
      ),
    );

    // Single shimmer sweep over .ai
    _goldSweep = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.82, curve: Curves.easeInOut),
      ),
    );

    _mistDrift = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );

    _navigationTimer = Timer(navigationStart, _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: TripMeApp.homeRoute),
        transitionDuration: transitionDuration,
        reverseTransitionDuration: transitionDuration,
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _ambientController]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(scale: _pushIn.value, child: _buildHeroImage()),
              _buildSunRayFlicker(),
              _buildOceanShimmer(),
              _buildWaterfallMist(),
              _buildBranding(),
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withOpacity((1 - _fadeIn.value)
                        .clamp(0.0, 1.0)
                        .toDouble()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroImage() {
    return Image.asset(
      'assets/splash/island.png',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) {
        // Local fallback to avoid blank screen if asset is temporarily missing.
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C4D9A), Color(0xFF0B77C8), Color(0xFF3BC2D2)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOceanShimmer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: _oceanShimmerAlignment,
          child: SizedBox(
            width: double.infinity,
            height: 260,
            child: ShaderMask(
              blendMode: BlendMode.screen,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1 + _waterShift.value, 0),
                  end: Alignment(1 + _waterShift.value, 0),
                  colors: const [
                    Colors.transparent,
                    Color(0x12C7F6FF),
                    Color(0x1FE9FDFF),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.6, 1.0],
                ).createShader(bounds);
              },
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x1A27B7C7)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterfallMist() {
    return Align(
      alignment: _mistOriginAlignment,
      child: Transform.translate(
        offset: Offset(_mistDrift.value, 0),
        child: IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              width: 110,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.mistWhite.withOpacity(0.65),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSunRayFlicker() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.86, -0.86),
              radius: 0.68,
              colors: [
                Colors.white.withOpacity(_sunOpacity.value),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0, 0.04),
            child: Opacity(
              opacity: _logoOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _logoRise.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _haloOpacity.value,
                      child: Container(
                        width: 280,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x66F6C982),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 6),
                              blurRadius: 12,
                              color: Color(0x6636485E),
                            ),
                          ],
                        ),
                        children: [
                          const TextSpan(
                            text: 'TripMe',
                            style: TextStyle(color: Color(0xFFF4F7FD)),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: _AiShimmer(shimmerProgress: _goldSweep.value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Opacity(
                opacity: _taglineOpacity.value,
                child: const Text(
                  'Discover Sri Lanka, Your Way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.6,
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

class _AiShimmer extends StatelessWidget {
  const _AiShimmer({required this.shimmerProgress});

  final double shimmerProgress;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(-1.2 + shimmerProgress, 0),
          end: Alignment(0.2 + shimmerProgress, 0),
          colors: const [
            AppColors.sigiriyaOchre,
            Color(0xFFEDB24D),
            Color(0xFFFFE2A0),
            Color(0xFFB97924),
          ],
          stops: const [0.0, 0.4, 0.55, 1.0],
        ).createShader(bounds);
      },
      child: const Text(
        '.ai',
        style: TextStyle(
          fontSize: 58,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              offset: Offset(0, 6),
              blurRadius: 12,
              color: Color(0x6648351A),
            ),
          ],
        ),
      ),
    );
  }
}
