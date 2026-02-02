import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart';

class ApplicationLimitsList extends StatelessWidget {
  final List<dynamic> data;

  const ApplicationLimitsList({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final filteredData = data
        .where((app) =>
            app['name'] != null && app['name'].toString().trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xffF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.timer,
                  size: 12,
                  color: Color(0xffF97316),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.applicationLimits,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? EmptyState(
                  icon: FluentIcons.timer,
                  message: l10n.noApplicationLimitsSet,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final app = filteredData[index];
                    final percentOfLimit =
                        (app['percentageOfLimit'] ?? 0).toDouble();

                    return _LimitItem(
                      name: app['name'] ?? l10n.unknownApp,
                      limit: app['dailyLimit'] ?? l10n.defaultTime,
                      usage: app['actualUsage'] ?? l10n.defaultTime,
                      percentOfLimit: percentOfLimit,
                      isOverLimit: percentOfLimit > 100,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LimitItem extends StatelessWidget {
  final String name;
  final String limit;
  final String usage;
  final double percentOfLimit;
  final bool isOverLimit;

  const _LimitItem({
    required this.name,
    required this.limit,
    required this.usage,
    required this.percentOfLimit,
    required this.isOverLimit,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isOverLimit ? const Color(0xffEF4444) : const Color(0xffF97316);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 5,
                percent: (percentOfLimit / 100).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.15),
                progressColor: color,
                padding: EdgeInsets.zero,
                barRadius: const Radius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '$usage / $limit',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isOverLimit ? color : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;

  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isHovered = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // Defer rendering until after the first frame to ensure correct layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isReady = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.micaBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.4)
                : theme.resources.cardStrokeColorDefault,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Safety check: skip rendering if constraints are invalid or not ready
            if (!_isReady ||
                !constraints.hasBoundedHeight ||
                !constraints.hasBoundedWidth ||
                constraints.maxHeight == 0 ||
                constraints.maxWidth == 0) {
              return const Center(
                child: SizedBox.shrink(),
              );
            }

            final availableSize = constraints.maxHeight < constraints.maxWidth
                ? constraints.maxHeight
                : constraints.maxWidth;
            final radius = (availableSize / 2) - 20;
            final lineWidth = radius * 0.18;

            // Calculate font sizes with proper bounds
            final percentFontSize = (radius * 0.35).clamp(14.0, 32.0);
            final titleFontSize = (radius * 0.16).clamp(9.0, 14.0);

            return Center(
              child: CircularPercentIndicator(
                radius: radius.clamp(30.0, 200.0),
                lineWidth: lineWidth.clamp(6.0, 24.0),
                animation: true,
                animationDuration: 1200,
                percent: widget.value.clamp(0.0, 1.0),
                center: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${(widget.value * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: percentFontSize,
                            color: widget.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            color: theme.inactiveColor,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: widget.color,
                backgroundColor: widget.color.withValues(alpha: 0.12),
              ),
            );
          },
        ),
      ),
    );
  }
}
