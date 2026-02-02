import 'package:fluent_ui/fluent_ui.dart';

// Reusable Card Widget
class Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveBackgroundColor,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final int divisions;
  final int step;
  final Function(double) onChanged;

  const SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.divisions,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final displayValue =
        step > 1 ? (value.round() ~/ step * step) : value.round();

    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: max,
            divisions: divisions,
            onChanged: (v) =>
                onChanged(step > 1 ? (v ~/ step * step).toDouble() : v),
          ),
        ),
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displayValue.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const TimeDisplay({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SettingTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool showDivider;

  const SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.accentColor.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.icon,
                    size: 16, color: theme.accentColor.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.subtitle,
                        style: theme.typography.caption?.copyWith(
                          fontSize: 11,
                          color:
                              theme.typography.caption?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                ToggleSwitch(
                  checked: widget.value,
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 1,
              color: theme.inactiveBackgroundColor.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
