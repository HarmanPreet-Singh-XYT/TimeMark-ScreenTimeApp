import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart';

class ApplicationLimitsList extends StatelessWidget {
  final List<dynamic> data;

  const ApplicationLimitsList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final filteredData = data
        .where((app) =>
            app['name'] != null && app['name'].toString().trim().isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;
        final headerPadding = isCompact ? 12.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(headerPadding, headerPadding - 2,
                  headerPadding, headerPadding - 6),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? 4 : 5),
                    decoration: BoxDecoration(
                      color: const Color(0xffF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      FluentIcons.timer,
                      size: isCompact ? 10 : 12,
                      color: const Color(0xffF97316),
                    ),
                  ),
                  SizedBox(width: isCompact ? 6 : 8),
                  Expanded(
                    child: Text(
                      l10n.applicationLimits,
                      style: TextStyle(
                        fontSize: isCompact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                      padding: EdgeInsets.fromLTRB(
                          headerPadding, 0, headerPadding, headerPadding - 4),
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
                          isCompact: isCompact,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _LimitItem extends StatelessWidget {
  final String name;
  final String limit;
  final String usage;
  final double percentOfLimit;
  final bool isOverLimit;
  final bool isCompact;

  const _LimitItem({
    required this.name,
    required this.limit,
    required this.usage,
    required this.percentOfLimit,
    required this.isOverLimit,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isOverLimit ? const Color(0xffEF4444) : const Color(0xffF97316);

    if (isCompact) {
      // Stacked layout for very narrow widths
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$usage / $limit',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isOverLimit ? color : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 4,
                percent: (percentOfLimit / 100).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.15),
                progressColor: color,
                padding: EdgeInsets.zero,
                barRadius: const Radius.circular(3),
              ),
            ),
          ],
        ),
      );
    }

    // Row layout for normal widths
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
            width: 70,
            child: Text(
              '$usage / $limit',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isOverLimit ? color : null,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
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
            if (!_isReady ||
                !constraints.hasBoundedHeight ||
                !constraints.hasBoundedWidth ||
                constraints.maxHeight < 50 ||
                constraints.maxWidth < 50) {
              return const Center(child: SizedBox.shrink());
            }

            // Determine if we should use horizontal or vertical layout
            final aspectRatio = constraints.maxWidth / constraints.maxHeight;
            final useHorizontalLayout =
                aspectRatio > 1.8 && constraints.maxHeight < 120;

            if (useHorizontalLayout) {
              return _buildHorizontalLayout(constraints, theme);
            }
            return _buildVerticalLayout(constraints, theme);
          },
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(
      BoxConstraints constraints, FluentThemeData theme) {
    final availableSize = constraints.maxHeight < constraints.maxWidth
        ? constraints.maxHeight
        : constraints.maxWidth;
    final radius = (availableSize / 2) - 20;
    final lineWidth = radius * 0.18;
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
  }

  Widget _buildHorizontalLayout(
      BoxConstraints constraints, FluentThemeData theme) {
    final height = constraints.maxHeight;
    final radius = (height / 2) - 12;
    final lineWidth = (radius * 0.2).clamp(4.0, 10.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: radius.clamp(25.0, 50.0),
            lineWidth: lineWidth,
            animation: true,
            animationDuration: 1200,
            percent: widget.value.clamp(0.0, 1.0),
            center: Text(
              '${(widget.value * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: (radius * 0.4).clamp(10.0, 16.0),
                color: widget.color,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: widget.color,
            backgroundColor: widget.color.withValues(alpha: 0.12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title.replaceAll('\n', ' '),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.inactiveColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
