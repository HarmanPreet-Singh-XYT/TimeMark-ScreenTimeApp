import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
// ============================================================================
// STATS CARDS
// ============================================================================

class StatsCards extends StatelessWidget {
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;

  const StatsCards({
    super.key,
    required this.totalScreenTime,
    required this.totalProductiveTime,
    required this.mostUsedApp,
    required this.focusSessions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        // Dynamic height based on screen size, with min/max bounds
        final screenHeight = MediaQuery.of(context).size.height;
        final cardHeight = (screenHeight * 0.12).clamp(90.0, 120.0);

        final cards = [
          _StatCard(
            icon: FluentIcons.timer,
            title: l10n.totalScreenTime,
            value: totalScreenTime,
            gradient: const LinearGradient(
              colors: [Color(0xff1E3A8A), Color(0xff3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
          _StatCard(
            icon: FluentIcons.check_mark,
            title: l10n.productiveTime,
            value: totalProductiveTime,
            gradient: const LinearGradient(
              colors: [Color(0xff14532D), Color(0xff22C55E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
          _StatCard(
            icon: FluentIcons.app_icon_default_list,
            title: l10n.mostUsedApp,
            value: mostUsedApp,
            gradient: const LinearGradient(
              colors: [Color(0xff581C87), Color(0xffA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
            isText: true,
          ),
          _StatCard(
            icon: FluentIcons.focus,
            title: l10n.focusSessions,
            value: focusSessions,
            gradient: const LinearGradient(
              colors: [Color(0xff7C2D12), Color(0xffF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
        ];

        if (isCompact) {
          return Column(
            children: [
              Row(children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final LinearGradient gradient;
  final double height;
  final bool isText;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
    required this.height,
    this.isText = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setTranslationRaw(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first
                  .withValues(alpha: _isHovered ? 0.4 : 0.2),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                widget.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      widget.isText ? (widget.value.length > 12 ? 16 : 20) : 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: widget.isText ? 0 : -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: widget.isText ? 2 : 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
