import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';

class SessionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SessionHistory({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 350,
        minHeight: 100,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.dateHeader,
                      overflow: TextOverflow.ellipsis,
                      style:
                          FluentTheme.of(context).typography.caption?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.durationHeader,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style:
                          FluentTheme.of(context).typography.caption?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.statusHeader,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style:
                          FluentTheme.of(context).typography.caption?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Session list
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.history,
                            size: 32,
                            color:
                                FluentTheme.of(context).inactiveBackgroundColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noSessionsYet,
                            overflow: TextOverflow.ellipsis,
                            style: FluentTheme.of(context)
                                .typography
                                .caption
                                ?.copyWith(
                                  color: FluentTheme.of(context)
                                      .typography
                                      .caption
                                      ?.color
                                      ?.withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final session = data[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: _GroupedSessionRow(session: session),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedSessionRow extends StatefulWidget {
  final Map<String, dynamic> session;

  const _GroupedSessionRow({required this.session});

  @override
  State<_GroupedSessionRow> createState() => _GroupedSessionRowState();
}

class _GroupedSessionRowState extends State<_GroupedSessionRow> {
  bool _isHovered = false;
  bool _isExpanded = false;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, HH:mm').format(dateTime);
  }

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return l10n.hourMinuteFormat(hours.toString(), minutes.toString());
    } else if (hours > 0) {
      return l10n.hourOnlyFormat(hours.toString());
    } else {
      return l10n.minuteFormat(minutes.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = widget.session;
    final bool isComplete = session['isComplete'] ?? false;
    final bool isPomodoro = session['type'] == 'pomodoro';
    final DateTime startTime = session['startTime'] as DateTime;
    final String formattedDate = _formatDateTime(startTime);

    // Get duration info
    final String totalDuration = session['formattedTotalDuration'] ??
        _formatDuration(
            session['totalDuration'] as Duration? ?? Duration.zero, l10n);
    final String workDuration = session['formattedWorkDuration'] ??
        _formatDuration(
            session['workDuration'] as Duration? ?? Duration.zero, l10n);
    final int workPhases = session['workPhases'] ?? 0;

    // Determine status color and icon
    final Color statusColor = isComplete
        ? const Color(0xFF4CAF50) // Green for complete
        : const Color(0xFFFF9800); // Orange for in-progress

    final IconData statusIcon =
        isComplete ? FluentIcons.check_mark : FluentIcons.clock;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? FluentTheme.of(context).accentColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: _isExpanded
                ? Border.all(
                    color: FluentTheme.of(context)
                        .accentColor
                        .withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main row
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Date
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedDate,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:
                              FluentTheme.of(context).typography.body?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        if (isPomodoro)
                          Text(
                            l10n.workSessions(workPhases),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: FluentTheme.of(context)
                                .typography
                                .caption
                                ?.copyWith(
                                  color: FluentTheme.of(context)
                                      .typography
                                      .caption
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                          ),
                      ],
                    ),
                  ),

                  // Duration
                  Expanded(
                    child: Text(
                      totalDuration,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: FluentTheme.of(context).typography.body?.copyWith(
                            color: FluentTheme.of(context)
                                .typography
                                .body
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                  ),

                  // Status
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isComplete ? l10n.complete : l10n.inProgress,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: FluentTheme.of(context)
                                .typography
                                .caption
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand indicator
                  if (isPomodoro) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? FluentIcons.chevron_up
                          : FluentIcons.chevron_down,
                      size: 12,
                      color: FluentTheme.of(context)
                          .typography
                          .caption
                          ?.color
                          ?.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),

              // Expanded details
              if (_isExpanded && isPomodoro) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context)
                        .inactiveBackgroundColor
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailRow(
                        context,
                        l10n.workTime,
                        workDuration,
                        const Color(0xFFFF5C50),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        l10n.breakTime,
                        session['formattedBreakDuration'] ??
                            l10n.minuteFormat('0'),
                        const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        l10n.phasesCompleted,
                        '${session['phases'] ?? 0} / 8',
                        FluentTheme.of(context).accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: FluentTheme.of(context).typography.caption,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
