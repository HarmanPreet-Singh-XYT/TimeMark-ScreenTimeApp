import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../controller/data_controllers/reports_controller.dart';

class TopBoxes extends StatelessWidget {
  final AnalyticsSummary analyticsSummary;
  final bool isLoading;

  const TopBoxes({
    super.key,
    required this.analyticsSummary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _AnalyticsItem(
        title: l10n.totalScreenTime,
        value: _formatDuration(analyticsSummary.totalScreenTime),
        percentChange: analyticsSummary.screenTimeComparisonPercent,
        icon: FluentIcons.screen_time,
        accentColor: const Color(0xFF6366F1), // Indigo
      ),
      _AnalyticsItem(
        title: l10n.productiveTime,
        value: _formatDuration(analyticsSummary.productiveTime),
        percentChange: analyticsSummary.productiveTimeComparisonPercent,
        icon: FluentIcons.timer,
        accentColor: const Color(0xFF10B981), // Emerald
      ),
      _AnalyticsItem(
        title: l10n.mostUsedApp,
        value: analyticsSummary.mostUsedApp,
        subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
        icon: FluentIcons.account_browser,
        accentColor: const Color(0xFFF59E0B), // Amber
      ),
      _AnalyticsItem(
        title: l10n.focusSessions,
        value: analyticsSummary.focusSessionsCount.toString(),
        percentChange: analyticsSummary.focusSessionsComparisonPercent,
        icon: FluentIcons.red_eye,
        accentColor: const Color(0xFFEC4899), // Pink
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final crossAxisCount = isCompact ? 2 : 4;
        final aspectRatio = isCompact ? 1.6 : 1.8;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _AnalyticsCard(
              item: items[index],
              isLoading: isLoading,
              index: index,
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }
}

class _AnalyticsItem {
  final String title;
  final String value;
  final double? percentChange;
  final String? subValue;
  final IconData icon;
  final Color accentColor;

  const _AnalyticsItem({
    required this.title,
    required this.value,
    this.percentChange,
    this.subValue,
    required this.icon,
    required this.accentColor,
  });
}

class _AnalyticsCard extends StatefulWidget {
  final _AnalyticsItem item;
  final bool isLoading;
  final int index;

  const _AnalyticsCard({
    required this.item,
    required this.isLoading,
    required this.index,
  });

  @override
  State<_AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<_AnalyticsCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Staggered entrance animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showDetailsFlyout(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? widget.item.accentColor.withOpacity(0.08)
                      : widget.item.accentColor.withOpacity(0.04),
                  isDark ? theme.micaBackgroundColor : Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? widget.item.accentColor.withOpacity(0.5)
                    : theme.inactiveBackgroundColor.withOpacity(0.5),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.item.accentColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            transform: _isHovered
                ? (Matrix4.identity()..translate(0.0, -2.0))
                : Matrix4.identity(),
            child: widget.isLoading
                ? _buildShimmer(context)
                : _buildContent(context, l10n, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    FluentThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.caption?.color?.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            _buildIconBadge(theme),
          ],
        ),

        const Spacer(),

        // Value
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: _isHovered ? 26 : 24,
            fontWeight: FontWeight.w700,
            color: theme.typography.title?.color,
            letterSpacing: -0.5,
          ),
          child: Text(
            widget.item.value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        const SizedBox(height: 6),

        // Comparison or SubValue
        _buildFooter(l10n, theme),
      ],
    );
  }

  Widget _buildIconBadge(FluentThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.item.accentColor.withOpacity(_isHovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        widget.item.icon,
        size: 18,
        color: widget.item.accentColor,
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, FluentThemeData theme) {
    if (widget.item.percentChange != null) {
      final isPositive = widget.item.percentChange! >= 0;
      final color =
          isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? FluentIcons.trending12 : FluentIcons.stock_down,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${widget.item.percentChange!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.item.subValue != null) {
      return Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: widget.item.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.item.subValue!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.typography.caption?.color?.withOpacity(0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return const SizedBox(height: 16);
  }

  Widget _buildShimmer(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsFlyout(BuildContext context) {
    // Optional: Show a flyout/tooltip with more details
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(widget.item.title),
          content: Text('Value: ${widget.item.value}'),
          severity: InfoBarSeverity.info,
          isLong: false,
        );
      },
    );
  }
}

// Shimmer Loading Widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      Colors.grey[800],
                      Colors.grey[700],
                      Colors.grey[800],
                    ]
                  : [
                      Colors.grey[300],
                      Colors.grey[100],
                      Colors.grey[300],
                    ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
