// general_section.dart
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

// ============== GENERAL SECTION ==============

class GeneralSection extends StatelessWidget {
  final Function(Locale) setLocale;

  const GeneralSection({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeCustomizationProvider>();

    final languageValue = settings.languageOptions
            .any((lang) => lang['code'] == settings.language)
        ? settings.language
        : 'en';

    return SettingsCard(
      title: l10n.generalSection,
      icon: FluentIcons.settings,
      children: [
        SettingRow(
          title: l10n.themeTitle,
          description: l10n.themeDescription,
          control: _CompactThemeSelector(
            currentMode: themeProvider.themeMode,
            onModeChanged: (mode) => themeProvider.setThemeMode(mode),
            l10n: l10n,
          ),
        ),
        SettingRow(
          title: l10n.languageTitle,
          description: l10n.languageDescription,
          control: SizedBox(
            width: 160,
            child: ComboBox<String>(
              value: languageValue,
              isExpanded: true,
              items: settings.languageOptions.map((lang) {
                return ComboBoxItem<String>(
                  value: lang['code']!,
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('language', value);
                  setLocale(Locale(value));
                }
              },
            ),
          ),
        ),
        SettingRow(
          title: l10n.voiceGenderTitle,
          description: l10n.voiceGenderDescription,
          control: SizedBox(
            width: 160,
            child: ComboBox<String>(
              value: settings.voiceGender,
              isExpanded: true,
              items: settings.voiceGenderOptions.map((gender) {
                return ComboBoxItem<String>(
                  value: gender['value']!,
                  child: Text(
                    gender['labelKey'] == 'voiceGenderMale'
                        ? l10n.voiceGenderMale
                        : l10n.voiceGenderFemale,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('voiceGender', value);
                }
              },
            ),
          ),
        ),
        // NEW: Tracking Mode Selection
        SettingRow(
          title: l10n.trackingModeTitle, // Add localization
          description: l10n.trackingModeDescription, // Add localization
          control: _TrackingModeSelector(l10n: l10n),
        ),
        if (Platform.isMacOS)
          SettingRow(
            title: l10n.launchAtStartupTitle,
            description: l10n.launchAtStartupDescription,
            showDivider: Platform.isWindows ? true : false,
            control: ToggleSwitch(
              checked: settings.launchAtStartupVar,
              onChanged: (value) =>
                  settings.updateSetting('launchAtStartup', value),
            ),
          ),
        if (Platform.isWindows)
          SettingRow(
            title: l10n.launchMinimizedTitle,
            description: l10n.launchMinimizedDescription,
            showDivider: false,
            control: ToggleSwitch(
              checked: settings.launchAsMinimized,
              onChanged: (value) =>
                  settings.updateSetting('launchAsMinimized', value),
            ),
          ),
      ],
    );
  }
}

// ============== TRACKING MODE SELECTOR ==============

class _TrackingModeSelector extends StatelessWidget {
  final AppLocalizations l10n;

  const _TrackingModeSelector({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isPrecise = settings.trackingMode == TrackingModeOptions.precise;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompactTrackingModeToggle(
          isPrecise: isPrecise,
          onChanged: (value) {
            settings.updateSetting(
              'trackingMode',
              value ? TrackingModeOptions.precise : TrackingModeOptions.polling,
            );
          },
          l10n: l10n,
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: isPrecise
              ? l10n.trackingModePreciseHint
              : l10n.trackingModePollingHint,
          child: Icon(
            isPrecise ? FluentIcons.warning : FluentIcons.info,
            size: 14,
            color: isPrecise ? Colors.orange : Colors.grey[80],
          ),
        ),
      ],
    );
  }
}

// ============== COMPACT TRACKING MODE TOGGLE ==============

class _CompactTrackingModeToggle extends StatelessWidget {
  final bool isPrecise;
  final Function(bool) onChanged;
  final AppLocalizations l10n;

  const _CompactTrackingModeToggle({
    required this.isPrecise,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrackingModeButton(
            icon: FluentIcons.clock,
            tooltip: l10n.trackingModePolling,
            isSelected: !isPrecise,
            onTap: () => onChanged(false),
            isFirst: true,
          ),
          _TrackingModeButton(
            icon: FluentIcons.bullseye,
            tooltip: l10n.trackingModePrecise,
            isSelected: isPrecise,
            onTap: () => onChanged(true),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TrackingModeButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _TrackingModeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_TrackingModeButton> createState() => _TrackingModeButtonState();
}

class _TrackingModeButtonState extends State<_TrackingModeButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    Color bgColor;
    Color iconColor;

    if (widget.isSelected) {
      bgColor = theme.accentColor;
      iconColor = Colors.white;
    } else if (_isHovering) {
      bgColor = theme.inactiveBackgroundColor.withValues(alpha: 0.5);
      iconColor = theme.typography.body?.color ?? Colors.white;
    } else {
      bgColor = Colors.transparent;
      iconColor = theme.typography.body?.color?.withValues(alpha: 0.7) ??
          Colors.grey[100];
    }

    BorderRadius borderRadius = BorderRadius.zero;
    if (widget.isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(5),
        bottomLeft: Radius.circular(5),
      );
    } else if (widget.isLast) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
      );
    }

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ============== COMPACT THEME SELECTOR ==============

class _CompactThemeSelector extends StatelessWidget {
  final String currentMode;
  final Function(String) onModeChanged;
  final AppLocalizations l10n;

  const _CompactThemeSelector({
    required this.currentMode,
    required this.onModeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactThemeButton(
            icon: FluentIcons.sunny,
            tooltip: l10n.themeLight,
            isSelected: currentMode == ThemeOptions.light,
            onTap: () => onModeChanged(ThemeOptions.light),
            isFirst: true,
          ),
          _CompactThemeButton(
            icon: FluentIcons.clear_night,
            tooltip: l10n.themeDark,
            isSelected: currentMode == ThemeOptions.dark,
            onTap: () => onModeChanged(ThemeOptions.dark),
          ),
          _CompactThemeButton(
            icon: FluentIcons.devices2,
            tooltip: l10n.themeSystem,
            isSelected: currentMode == ThemeOptions.system,
            onTap: () => onModeChanged(ThemeOptions.system),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _CompactThemeButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _CompactThemeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_CompactThemeButton> createState() => _CompactThemeButtonState();
}

class _CompactThemeButtonState extends State<_CompactThemeButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    Color bgColor;
    Color iconColor;

    if (widget.isSelected) {
      bgColor = theme.accentColor;
      iconColor = Colors.white;
    } else if (_isHovering) {
      bgColor = theme.inactiveBackgroundColor.withValues(alpha: 0.5);
      iconColor = theme.typography.body?.color ?? Colors.white;
    } else {
      bgColor = Colors.transparent;
      iconColor = theme.typography.body?.color?.withValues(alpha: 0.7) ??
          Colors.grey[100];
    }

    // Border radius for first/last items
    BorderRadius borderRadius = BorderRadius.zero;
    if (widget.isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(5),
        bottomLeft: Radius.circular(5),
      );
    } else if (widget.isLast) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
      );
    }

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
