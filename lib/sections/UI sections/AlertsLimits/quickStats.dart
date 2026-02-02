import 'package:fluent_ui/fluent_ui.dart';

// Quick Stats Row
class QuickStatsRow extends StatelessWidget {
  final Duration totalScreenTime;
  final int appsWithLimits;
  final int appsNearLimit;
  final bool isMedium;

  const QuickStatsRow({
    super.key,
    required this.totalScreenTime,
    required this.appsWithLimits,
    required this.appsNearLimit,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatChip(
        icon: FluentIcons.clock,
        label: 'Today\'s Screen Time',
        value: _formatDuration(totalScreenTime),
        color: const Color(0xFF3B82F6),
        lightBg: const Color(0xFFEFF6FF),
      ),
      _StatChip(
        icon: FluentIcons.shield,
        label: 'Active Limits',
        value: appsWithLimits.toString(),
        color: const Color(0xFF10B981),
        lightBg: const Color(0xFFECFDF5),
      ),
      _StatChip(
        icon: FluentIcons.warning,
        label: 'Near Limit',
        value: appsNearLimit.toString(),
        color: appsNearLimit > 0
            ? const Color(0xFFF59E0B)
            : const Color(0xFF6B7280),
        lightBg: appsNearLimit > 0
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF9FAFB),
      ),
    ];

    if (isMedium) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
        ],
      );
    } else {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 8),
          cards[1],
          const SizedBox(height: 8),
          cards[2],
        ],
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color lightBg;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.lightBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
