import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ============== FOOTER SECTION ==============

class FooterSection extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onReport;
  final VoidCallback onFeedback;
  final VoidCallback onGithub;

  const FooterSection({
    required this.onContact,
    required this.onReport,
    required this.onFeedback,
    required this.onGithub,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.inactiveBackgroundColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterButton(
            icon: FluentIcons.chat,
            label: l10n.contactButton,
            onPressed: onContact,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.bug,
            label: l10n.reportBugButton,
            onPressed: onReport,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.feedback,
            label: l10n.submitFeedbackButton,
            onPressed: onFeedback,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.open_source,
            label: l10n.githubButton,
            onPressed: onGithub,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered
                    ? theme.accentColor.withOpacity(0.15)
                    : theme.accentColor.withOpacity(0.08))
                : (_isHovered
                    ? theme.inactiveBackgroundColor.withOpacity(0.6)
                    : theme.inactiveBackgroundColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isPrimary
                  ? (_isHovered
                      ? theme.accentColor.withOpacity(0.5)
                      : theme.accentColor.withOpacity(0.2))
                  : (_isHovered
                      ? theme.inactiveBackgroundColor
                      : Colors.transparent),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isPrimary
                    ? theme.accentColor
                    : (_isHovered ? null : Colors.grey[100]),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.isPrimary
                      ? theme.accentColor
                      : (_isHovered ? null : Colors.grey[100]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
