import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RebrandingModal extends StatefulWidget {
  const RebrandingModal({super.key});

  static const String _dismissedKey = 'rebranding_modal_dismissed';
  static final DateTime _expiryDate = DateTime(2026, 2, 25);

  static Future<void> showIfNeeded(BuildContext context) async {
    final now = DateTime.now();

    if (now.isAfter(_expiryDate) || now.isAtSameMomentAs(_expiryDate)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_dismissedKey) ?? false;

    if (dismissed) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RebrandingModal(),
      );
    }
  }

  @override
  State<RebrandingModal> createState() => _RebrandingModalState();
}

class _RebrandingModalState extends State<RebrandingModal>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconBounceAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _iconBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Subtle pulse for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _entranceController.forward().then((_) {
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _dismiss(BuildContext context) async {
    // Reverse animation before closing
    await _entranceController.reverse();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(RebrandingModal._dismissedKey, true);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primaryPurple = Color(0xFFA855F7);
    const deepPurple = Color(0xFF7C3AED);
    const lightPurple = Color(0xFFC084FC);
    const pinkAccent = Color(0xFFEC4899);

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: ContentDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background gradient decoration
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryPurple.withValues(alpha: isDark ? 0.15 : 0.08),
                        primaryPurple.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        pinkAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                        pinkAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon with glow
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_iconBounceAnimation, _pulseAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconBounceAnimation.value *
                              _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x30A855F7),
                              Color(0x18EC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: primaryPurple.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "NEW NAME" badge
                    _buildStaggeredFade(
                      delay: 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepPurple, pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: deepPurple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '✨ NEW NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main heading with shimmer on "Scolect"
                    _buildStaggeredFade(
                      delay: 0.45,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: theme.typography.body?.color,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: 'TimeMark is now\n'),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      final shimmerValue =
                                          _shimmerController.value;
                                      return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: const [
                                          deepPurple,
                                          lightPurple,
                                          pinkAccent,
                                          lightPurple,
                                          deepPurple,
                                        ],
                                        stops: [
                                          0.0,
                                          (shimmerValue - 0.2).clamp(0.0, 1.0),
                                          shimmerValue,
                                          (shimmerValue + 0.2).clamp(0.0, 1.0),
                                          1.0,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'Scolect',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decorative divider
                    _buildStaggeredFade(
                      delay: 0.5,
                      child: Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepPurple, pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    _buildStaggeredFade(
                      delay: 0.55,
                      child: Text(
                        'Same powerful productivity tracking.\nA fresh new identity and experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.inactiveColor,
                          height: 1.6,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Feature highlights
                    _buildStaggeredFade(
                      delay: 0.65,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem('🚀', 'Faster'),
                            _buildDividerDot(isDark),
                            _buildFeatureItem('🎨', 'Fresher'),
                            _buildDividerDot(isDark),
                            _buildFeatureItem('💪', 'Better'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue button with gradient
                    _buildStaggeredFade(
                      delay: 0.75,
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => _dismiss(context),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    deepPurple,
                                    primaryPurple,
                                    pinkAccent
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        primaryPurple.withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Get Started →',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredFade({
    required double delay,
    required Widget child,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(delay, (delay + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ),
    );

    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: SlideTransition(
            position: slideAnim,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String emoji, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FluentTheme.of(context).inactiveColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerDot(bool isDark) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.12),
      ),
    );
  }
}
