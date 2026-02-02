import 'package:fluent_ui/fluent_ui.dart';

// Control button widget
class ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            transform: Matrix4.identity()
              ..scaleByDouble(
                _isPressed ? 0.92 : 1.0, // x
                _isPressed ? 0.92 : 1.0, // y
                1.0, // z
                1.0, // w
              ),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isHovered
                  ? FluentTheme.of(context).accentColor.withValues(alpha: 0.1)
                  : FluentTheme.of(context).micaBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovered
                    ? FluentTheme.of(context).accentColor.withValues(alpha: 0.3)
                    : FluentTheme.of(context).inactiveBackgroundColor,
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? FluentTheme.of(context).accentColor : null,
            ),
          ),
        ),
      ),
    );
  }
}

// Play/Pause button widget
class PlayPauseButton extends StatefulWidget {
  final bool isRunning;
  final Color color;
  final VoidCallback onPressed;

  const PlayPauseButton({
    super.key,
    required this.isRunning,
    required this.color,
    required this.onPressed,
  });

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 6),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.isRunning ? FluentIcons.pause : FluentIcons.play_solid,
              key: ValueKey(widget.isRunning),
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Session type chip widget with tap functionality
class SessionChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback? onTap;

  const SessionChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.color,
    this.onTap,
  });

  @override
  State<SessionChip> createState() => _SessionChipState();
}

class _SessionChipState extends State<SessionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.color.withValues(alpha: 0.15)
                : _isHovered
                    ? widget.color.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? widget.color
                  : _isHovered
                      ? widget.color.withValues(alpha: 0.5)
                      : FluentTheme.of(context).inactiveBackgroundColor,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isActive
                  ? widget.color
                  : _isHovered
                      ? widget.color.withValues(alpha: 0.8)
                      : FluentTheme.of(context)
                          .typography
                          .body
                          ?.color
                          ?.withValues(alpha: 0.6),
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
