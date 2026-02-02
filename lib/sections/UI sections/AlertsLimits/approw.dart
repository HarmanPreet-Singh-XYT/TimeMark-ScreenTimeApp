import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';

class AppRow extends StatefulWidget {
  final AppUsageSummary app;
  final VoidCallback onEdit;
  final bool isLast;

  const AppRow({
    super.key,
    required this.app,
    required this.onEdit,
    this.isLast = false,
  });

  @override
  State<AppRow> createState() => AppRowState();
}

class AppRowState extends State<AppRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor();
    final progress = _calculateProgress();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.accentColor.withValues(alpha: 0.04)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // App name with icon - flex 3
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      // Container(
                      //   width: 32,
                      //   height: 32,
                      //   decoration: BoxDecoration(
                      //     color: statusColor.withValues(alpha:0.1),
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       widget.app.appName.isNotEmpty
                      //           ? widget.app.appName[0].toUpperCase()
                      //           : '?',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 13,
                      //         color: statusColor,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.app.appName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.app.limitStatus ? 'Active' : 'Off',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Category - flex 2
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      widget.app.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.typography.body?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Daily limit - flex 2
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _formatDuration(widget.app.dailyLimit, l10n),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            widget.app.limitStatus ? null : theme.inactiveColor,
                      ),
                    ),
                  ),
                ),

                // Current usage with progress bar - flex 3
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(widget.app.currentUsage, l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        if (widget.app.limitStatus &&
                            widget.app.dailyLimit != Duration.zero) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.inactiveBackgroundColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.typography.caption?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Edit button - fixed width
                SizedBox(
                  width: 50,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        FluentIcons.edit,
                        size: 14,
                        color: _isHovered
                            ? theme.accentColor
                            : theme.inactiveColor,
                      ),
                      onPressed: widget.onEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  double _calculateProgress() {
    if (!widget.app.limitStatus || widget.app.dailyLimit == Duration.zero) {
      return 0;
    }
    final progress =
        widget.app.currentUsage.inMinutes / widget.app.dailyLimit.inMinutes;
    return progress > 1 ? 1 : progress;
  }

  Color _getStatusColor() {
    if (!widget.app.limitStatus) return Colors.grey;
    if (widget.app.dailyLimit == Duration.zero) return Colors.grey;
    if (widget.app.currentUsage >= widget.app.dailyLimit) return Colors.red;
    if (widget.app.isAboutToReachLimit) return Colors.orange;
    if (widget.app.percentageOfLimitUsed > 0.75) {
      return const Color(0xFFEAB308);
    }
    return const Color(0xFF10B981);
  }

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration == Duration.zero) return l10n.durationNone;
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return l10n.durationHoursMinutes(h, m);
    if (h > 0) return '${h}h';
    return l10n.durationMinutesOnly(m);
  }
}
