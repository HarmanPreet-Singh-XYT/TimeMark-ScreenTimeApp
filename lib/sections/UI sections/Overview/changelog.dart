import 'dart:convert';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

class ChangelogModal {
  static const String _lastShownVersionKey = 'last_shown_changelog_version';

  /// Check if changelog should be shown and display it if needed
  static Future<void> showIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';
      final lastShownVersion = prefs.getString(_lastShownVersionKey);

      if (lastShownVersion == null || lastShownVersion != currentVersion) {
        debugPrint(
            '📱 Changelog: New version detected - $currentVersion (last shown: $lastShownVersion)');

        final releaseData = await _fetchReleaseData(currentVersion);

        if (releaseData != null && context.mounted) {
          debugPrint(
              '✅ Changelog: Found for version $currentVersion, displaying');
          await _showChangelogDialog(context, releaseData);
          await prefs.setString(_lastShownVersionKey, currentVersion);
          debugPrint('💾 Changelog: Saved version $currentVersion as shown');
        } else {
          debugPrint(
              '⚠️ Changelog: No release found for version $currentVersion');
        }
      } else {
        debugPrint(
            '✓ Changelog: Version $currentVersion already shown, skipping');
      }
    } catch (e) {
      debugPrint('❌ Changelog Error: $e');
    }
  }

  /// Manually show changelog (for settings menu)
  static Future<void> showManually(BuildContext context) async {
    try {
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';

      // Show loading indicator while fetching
      if (context.mounted) {
        _showLoadingDialog(context);
      }

      final releaseData = await _fetchReleaseData(currentVersion);

      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading
      }

      if (releaseData != null && context.mounted) {
        await _showChangelogDialog(context, releaseData);
      } else if (context.mounted) {
        await _showErrorDialog(context);
      }
    } catch (e) {
      debugPrint('Error showing changelog manually: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading if still showing
        await _showErrorDialog(context);
      }
    }
  }

  static Future<Map<String, dynamic>?> _fetchReleaseData(String version) async {
    try {
      final tagName = version.startsWith('v') ? version : 'v$version';

      final response = await http
          .get(Uri.parse('https://api.github.com/repos/HarmanPreet-Singh-XYT/'
              'Scolect-ScreenTimeApp/releases/tags/$tagName'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        return {
          'tag_name': release['tag_name'],
          'name': release['name'],
          'body': release['body'],
          'published_at': release['published_at'],
          'html_url': release['html_url'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching release data: $e');
      return null;
    }
  }

  /// Show a loading dialog while fetching
  static void _showLoadingDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 300),
        content: Row(
          children: [
            const ProgressRing(),
            const SizedBox(width: 16),
            Text(l10n.changelogUnableToLoad), // Reuse or add a "Loading..." key
          ],
        ),
      ),
    );
  }

  /// Show the changelog dialog with animations
  static Future<void> _showChangelogDialog(
    BuildContext context,
    Map<String, dynamic> releaseData,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AnimatedChangelogDialog(releaseData: releaseData),
    );
  }

  /// Show error dialog
  static Future<void> _showErrorDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(
              FluentIcons.error_badge,
              color: Colors.warningPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(l10n.changelogUnableToLoad),
          ],
        ),
        content: Text(l10n.changelogErrorDescription),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(l10n.ok),
            ),
          ),
        ],
      ),
    );
  }

  /// Reset the shown version (for testing)
  static Future<void> resetShownVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastShownVersionKey);
  }

  /// Get the last shown version
  static Future<String?> getLastShownVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastShownVersionKey);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Changelog Dialog (StatefulWidget for animation controllers)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedChangelogDialog extends StatefulWidget {
  final Map<String, dynamic> releaseData;

  const _AnimatedChangelogDialog({required this.releaseData});

  @override
  State<_AnimatedChangelogDialog> createState() =>
      _AnimatedChangelogDialogState();
}

class _AnimatedChangelogDialogState extends State<_AnimatedChangelogDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _contentController;
  late final AnimationController _shimmerController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _contentFadeAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollTopButton = false;

  @override
  void initState() {
    super.initState();

    // Entrance animation (dialog scale + fade)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Content stagger animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // Shimmer for header icon
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Start animation sequence
    _entranceController.forward().then((_) {
      _contentController.forward();
      _shimmerController.repeat();
    });

    // Scroll listener for "scroll to top" button
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 150;
    if (shouldShow != _showScrollTopButton) {
      setState(() => _showScrollTopButton = shouldShow);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _dismissWithAnimation() async {
    await _entranceController.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        title: _AnimatedHeader(
          releaseData: widget.releaseData,
          shimmerController: _shimmerController,
        ),
        content: Stack(
          children: [
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedReleaseDate(
                      publishedAt: widget.releaseData['published_at'],
                      contentController: _contentController,
                    ),
                    const SizedBox(height: 16),
                    _AnimatedChangelogContent(
                      body: widget.releaseData['body'],
                      contentController: _contentController,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Scroll-to-top floating button
            Positioned(
              bottom: 8,
              right: 8,
              child: AnimatedScale(
                scale: _showScrollTopButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showScrollTopButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        FluentIcons.chevron_up,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _AnimatedButton(
            contentController: _contentController,
            onPressed: _dismissWithAnimation,
            label: l10n.continueButton,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Header with shimmer effect on icon
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedHeader extends StatelessWidget {
  final Map<String, dynamic> releaseData;
  final AnimationController shimmerController;

  const _AnimatedHeader({
    required this.releaseData,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        AnimatedBuilder(
          animation: shimmerController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: 0,
                  endAngle: 2 * pi,
                  transform: GradientRotation(shimmerController.value * 2 * pi),
                  colors: [
                    theme.accentColor.withValues(alpha: 0.08),
                    theme.accentColor.withValues(alpha: 0.2),
                    theme.accentColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                FluentIcons.rocket,
                color: theme.accentColor,
                size: 24,
              ),
            );
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changelogWhatsNew,
                style: theme.typography.subtitle?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      releaseData['tag_name'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      releaseData['name'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.inactiveColor,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Release Date with stagger
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedReleaseDate extends StatelessWidget {
  final String? publishedAt;
  final AnimationController contentController;

  const _AnimatedReleaseDate({
    required this.publishedAt,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    if (publishedAt == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final date = DateTime.parse(publishedAt!);
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: contentController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.calendar, size: 14, color: theme.accentColor),
              const SizedBox(width: 8),
              Text(
                l10n.changelogReleasedOn(formattedDate),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Changelog Content with staggered item reveals
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedChangelogContent extends StatelessWidget {
  final String? body;
  final AnimationController contentController;

  const _AnimatedChangelogContent({
    required this.body,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    if (body == null || body!.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Text(l10n.changelogNoContent);
    }

    final theme = FluentTheme.of(context);
    final lines = body!.split('\n');
    final List<_ParsedLine> parsed = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('-') ||
          line.startsWith('•') ||
          line.startsWith('*')) {
        parsed.add(_ParsedLine(
          type: _LineType.bullet,
          text: line.substring(1).trim(),
        ));
      } else if (line.startsWith('##')) {
        parsed.add(_ParsedLine(
          type: _LineType.subheader,
          text: line.replaceAll('#', '').trim(),
        ));
      } else if (line.startsWith('#')) {
        parsed.add(_ParsedLine(
          type: _LineType.header,
          text: line.replaceAll('#', '').trim(),
        ));
      } else {
        parsed.add(_ParsedLine(type: _LineType.text, text: line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(parsed.length, (index) {
        // Stagger each item within the content animation window
        final itemCount = parsed.length;
        final start = (0.15 + (index / itemCount) * 0.7).clamp(0.0, 1.0);
        final end = (start + 0.3).clamp(0.0, 1.0);

        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: contentController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );

        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: contentController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: _buildLineWidget(context, theme, parsed[index]),
          ),
        );
      }),
    );
  }

  Widget _buildLineWidget(
    BuildContext context,
    FluentThemeData theme,
    _ParsedLine line,
  ) {
    switch (line.type) {
      case _LineType.header:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.accentColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );

      case _LineType.subheader:
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.typography.body?.color?.withValues(alpha: 0.85),
            ),
          ),
        );

      case _LineType.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 10),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accentColor,
                      theme.accentColor.withValues(alpha: 0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  _stripMarkdownBold(line.text),
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],
          ),
        );

      case _LineType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _stripMarkdownBold(line.text),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        );
    }
  }

  /// Strip basic markdown bold (**text**) for plain display
  String _stripMarkdownBold(String text) {
    return text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\$1');
  }
}

enum _LineType { header, subheader, bullet, text }

class _ParsedLine {
  final _LineType type;
  final String text;

  const _ParsedLine({required this.type, required this.text});
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Continue Button with scale-in effect
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedButton extends StatefulWidget {
  final AnimationController contentController;
  final VoidCallback onPressed;
  final String label;

  const _AnimatedButton({
    required this.contentController,
    required this.onPressed,
    required this.label,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.contentController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.contentController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _buttonFade.value,
          child: Transform.scale(
            scale: _buttonScale.value,
            child: child,
          ),
        );
      },
      child: FilledButton(
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
