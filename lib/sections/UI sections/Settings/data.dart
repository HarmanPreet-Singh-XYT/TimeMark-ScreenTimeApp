import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
// ============== DATA SECTION ==============

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return SettingsCard(
      title: l10n.dataSection,
      icon: FluentIcons.database,
      iconColor: Colors.red,
      children: [
        SettingRow(
          title: l10n.clearDataTitle,
          description: l10n.clearDataDescription,
          control: _DangerButton(
            label: l10n.clearDataButtonLabel,
            icon: FluentIcons.delete,
            onPressed: () => _showDataDialog(context, settings),
          ),
        ),
        SettingRow(
          title: l10n.resetSettingsTitle2,
          description: l10n.resetSettingsDescription,
          showDivider: false,
          control: _DangerButton(
            label: l10n.resetButtonLabel,
            icon: FluentIcons.refresh,
            isWarning: true,
            onPressed: () => _showSettingsDialog(context, settings),
          ),
        ),
      ],
    );
  }

  Future<void> _showDataDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Text(l10n.clearDataDialogTitle),
          ],
        ),
        content: Text(l10n.clearDataDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
            ),
            child: Text(l10n.clearDataButtonLabel),
            onPressed: () {
              settings.clearData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.resetSettingsDialogTitle),
          ],
        ),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            child: Text(l10n.resetButtonLabel),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isWarning;
  final VoidCallback onPressed;

  const _DangerButton({
    required this.label,
    required this.icon,
    this.isWarning = false,
    required this.onPressed,
  });

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isWarning ? Colors.orange : Colors.red;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered ? color : color.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
