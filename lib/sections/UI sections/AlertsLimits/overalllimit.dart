import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;

// Overall Limit Card
class OverallLimitCard extends StatelessWidget {
  final bool enabled;
  final double hours;
  final double minutes;
  final Duration totalScreenTime;
  final Function(bool) onEnabledChanged;
  final Function(double) onHoursChanged;
  final Function(double) onMinutesChanged;

  const OverallLimitCard({
    required this.enabled,
    required this.hours,
    required this.minutes,
    required this.totalScreenTime,
    required this.onEnabledChanged,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final limitDuration = Duration(
      hours: hours.round(),
      minutes: (minutes.round() ~/ 5 * 5),
    );
    final progress = _calculateProgress(limitDuration);
    final statusColor = _getStatusColor(limitDuration);

    return rub.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(FluentIcons.stopwatch, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.overallScreenTimeLimit,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ToggleSwitch(
                checked: enabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 20),

            // Time display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      rub.TimeDisplay(
                        value: hours.round(),
                        label: l10n.hours,
                        color: statusColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: statusColor,
                          ),
                        ),
                      ),
                      rub.TimeDisplay(
                        value: minutes.round() ~/ 5 * 5,
                        label: l10n.minutes,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 6,
                      width: double.infinity,
                      child: ProgressBar(
                        value: progress * 100,
                        backgroundColor: theme.inactiveBackgroundColor,
                        activeColor: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDuration(totalScreenTime)} / ${_formatDuration(limitDuration)} used',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sliders
            rub.SliderRow(
              label: l10n.hours,
              value: hours,
              max: 12,
              divisions: 12,
              onChanged: onHoursChanged,
            ),
            const SizedBox(height: 8),
            rub.SliderRow(
              label: l10n.minutes,
              value: minutes,
              max: 55,
              divisions: 11,
              step: 5,
              onChanged: onMinutesChanged,
            ),
          ],
        ],
      ),
    );
  }

  double _calculateProgress(Duration limit) {
    if (!enabled || limit.inMinutes == 0) return 0;
    final progress = totalScreenTime.inMinutes / limit.inMinutes;
    return progress > 1 ? 1 : progress;
  }

  Color _getStatusColor(Duration limit) {
    if (!enabled) return Colors.grey;
    if (limit == Duration.zero) return Colors.grey;

    final percentage = totalScreenTime.inMinutes / limit.inMinutes;

    if (percentage >= 1) return Colors.red;
    if (percentage > 0.9) return Colors.orange;
    if (percentage > 0.75) return const Color(0xFFEAB308);
    return const Color(0xFF10B981);
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
