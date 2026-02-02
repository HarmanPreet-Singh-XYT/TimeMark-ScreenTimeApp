import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';

// ============== GENERAL SECTION ==============

class GeneralSection extends StatelessWidget {
  final Function(Locale) setLocale;

  const GeneralSection({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    // Add safety checks
    final themeValue = settings.themeOptions.contains(settings.theme)
        ? settings.theme
        : (settings.themeOptions.isNotEmpty
            ? settings.themeOptions.first.toString()
            : 'System');

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
          control: SizedBox(
            width: 200,
            child: ComboBox<String>(
              value: themeValue,
              items: settings.themeOptions.map((theme) {
                return ComboBoxItem<String>(
                  value: theme.toString(),
                  child: Text(theme.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('theme', value, context);
                }
              },
            ),
          ),
        ),
        SettingRow(
          title: l10n.languageTitle,
          description: l10n.languageDescription,
          control: SizedBox(
            width: 200,
            child: ComboBox<String>(
              value: languageValue,
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
