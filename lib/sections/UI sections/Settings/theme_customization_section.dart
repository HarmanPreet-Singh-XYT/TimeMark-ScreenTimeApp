import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:screentime/adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:screentime/main.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import './theme_helpers.dart';
// ============== THEME CUSTOMIZATION SECTION ==============

class ThemeCustomizationSection extends StatefulWidget {
  const ThemeCustomizationSection({super.key});

  @override
  State<ThemeCustomizationSection> createState() =>
      _ThemeCustomizationSectionState();
}

class _ThemeCustomizationSectionState extends State<ThemeCustomizationSection> {
  void _refreshTheme(BuildContext context, CustomThemeData newTheme) {
    final adaptiveTheme = FluentAdaptiveTheme.of(context);
    adaptiveTheme.setTheme(
      light: buildLightTheme(newTheme),
      dark: buildDarkTheme(newTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final fluentTheme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.themeCustomization,
      icon: FluentIcons.color,
      iconColor: Colors.magenta,
      trailing: Text(
        themeProvider.currentTheme.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fluentTheme.accentColor,
        ),
      ),
      children: [
        // Theme Preset Selector
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chooseThemePreset,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fluentTheme.typography.body?.color,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemePresets.allPresets.map((preset) {
                  final isSelected = themeProvider.currentTheme.id == preset.id;
                  return ThemePresetCard(
                    theme: preset,
                    isSelected: isSelected,
                    onTap: () async {
                      await themeProvider.setTheme(preset);
                      if (mounted) {
                        _refreshTheme(context, preset);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Custom Themes List
        if (themeProvider.customThemes.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.yourCustomThemes,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fluentTheme.typography.body?.color,
                      ),
                    ),
                    Row(
                      children: [
                        // Import Button
                        IconButton(
                          icon: const Icon(FluentIcons.download, size: 14),
                          onPressed: () => _importTheme(context, themeProvider),
                        ),
                        // Create Button
                        IconButton(
                          icon: const Icon(FluentIcons.add, size: 14),
                          onPressed: () =>
                              _createNewCustomTheme(context, themeProvider),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...themeProvider.customThemes.map((customTheme) {
                  final isSelected =
                      themeProvider.currentTheme.id == customTheme.id;
                  return _CustomThemeListItem(
                    theme: customTheme,
                    isSelected: isSelected,
                    onTap: () async {
                      await themeProvider.setTheme(customTheme);
                      if (mounted) {
                        _refreshTheme(context, customTheme);
                      }
                    },
                    onEdit: () =>
                        _editCustomTheme(context, themeProvider, customTheme),
                    onDelete: () =>
                        _deleteCustomTheme(context, themeProvider, customTheme),
                    onExport: () =>
                        _exportTheme(context, themeProvider, customTheme),
                  );
                }),
              ],
            ),
          ),
        ],

        const Divider(),

        // Theme Actions Row
        Column(
          children: [
            SettingRow(
              title: l10n.createCustomTheme,
              description: l10n.designOwnColorScheme,
              control: FilledButton(
                onPressed: () => _createNewCustomTheme(context, themeProvider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.newTheme, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            SettingRow(
              title: l10n.importTheme,
              description: l10n.importFromFile,
              control: Button(
                onPressed: () => _importTheme(context, themeProvider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.download, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.import, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Edit Current Theme (if custom)
        if (themeProvider.currentTheme.isCustom) ...[
          SettingRow(
            title: l10n.editCurrentTheme,
            description:
                l10n.customizeColorsFor(themeProvider.currentTheme.name),
            showDivider: false,
            control: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  onPressed: () => _exportTheme(
                      context, themeProvider, themeProvider.currentTheme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.share, size: 12),
                      const SizedBox(width: 6),
                      Text(l10n.export, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _editCustomTheme(
                      context, themeProvider, themeProvider.currentTheme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.edit, size: 12),
                      const SizedBox(width: 6),
                      Text(l10n.edit, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ============== THEME MANAGEMENT METHODS ==============

  void _createNewCustomTheme(
      BuildContext context, ThemeCustomizationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => ThemeEditorDialog(
        initialTheme: ThemePresets.defaultTheme.copyWith(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: l10n.customThemeNumber(provider.customThemes.length + 1),
          isCustom: true,
        ),
        onSave: (theme) async {
          await provider.addCustomTheme(theme);
          await provider.setTheme(theme);
          if (mounted) {
            _refreshTheme(context, theme);
            _showSuccessMessage(context, l10n.themeCreatedSuccessfully);
          }
        },
      ),
    );
  }

  void _editCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => ThemeEditorDialog(
        initialTheme: theme,
        onSave: (updatedTheme) async {
          await provider.updateCustomTheme(updatedTheme);
          if (provider.currentTheme.id == theme.id) {
            await provider.setTheme(updatedTheme);
            if (mounted) {
              _refreshTheme(context, updatedTheme);
            }
          }
          if (mounted) {
            _showSuccessMessage(context, l10n.themeUpdatedSuccessfully);
          }
        },
      ),
    );
  }

  void _deleteCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.deleteCustomTheme),
        content: Text(l10n.confirmDeleteTheme(theme.name)),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xffff0000)),
            ),
            child: Text(l10n.delete),
            onPressed: () async {
              await provider.deleteCustomTheme(theme.id);
              if (mounted) {
                _refreshTheme(context, provider.currentTheme);
                Navigator.pop(context);
                _showSuccessMessage(context, l10n.themeDeletedSuccessfully);
              }
            },
          ),
        ],
      ),
    );
  }

  // ============== IMPORT/EXPORT METHODS ==============

  Future<void> _exportTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Show export options dialog
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _ExportOptionsDialog(theme: theme),
      );

      if (result == null || !mounted) return;

      final themeJson = provider.exportTheme(theme);
      final fileName = '${theme.name.replaceAll(' ', '_')}_theme.json';

      if (result == 'file') {
        // Export as file
        await _saveThemeToFile(themeJson, fileName);
        if (mounted) {
          _showSuccessMessage(context, l10n.themeExportedSuccessfully);
        }
      } else if (result == 'clipboard') {
        // Copy to clipboard
        await Clipboard.setData(ClipboardData(text: themeJson));
        if (mounted) {
          _showSuccessMessage(context, l10n.themeCopiedToClipboard);
        }
      } else if (result == 'share') {
        // Share via system share sheet
        await _shareTheme(themeJson, fileName);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, '${l10n.exportFailed}: $e');
      }
    }
  }

  Future<void> _importTheme(
      BuildContext context, ThemeCustomizationProvider provider) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Show import options dialog
      final result = await showDialog<String>(
        context: context,
        builder: (context) => _ImportOptionsDialog(),
      );

      if (result == null || !mounted) return;

      String? themeJson;

      if (result == 'file') {
        // Import from file
        themeJson = await _loadThemeFromFile();
      } else if (result == 'clipboard') {
        // Import from clipboard
        final clipboardData = await Clipboard.getData('text/plain');
        themeJson = clipboardData?.text;
      }

      if (themeJson == null || themeJson.isEmpty) {
        if (mounted) {
          _showErrorMessage(context, l10n.noThemeDataFound);
        }
        return;
      }

      // Validate and import theme
      final importedTheme = await provider.importTheme(themeJson);

      if (importedTheme != null) {
        await provider.setTheme(importedTheme);
        if (mounted) {
          _refreshTheme(context, importedTheme);
          _showSuccessMessage(
              context, l10n.themeImportedSuccessfully(importedTheme.name));
        }
      } else {
        if (mounted) {
          _showErrorMessage(context, l10n.invalidThemeFormat);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, '${l10n.importFailed}: $e');
      }
    }
  }

  // ============== FILE OPERATIONS ==============

  Future<void> _saveThemeToFile(String jsonData, String fileName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use share or save to downloads
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonData);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Theme Export',
      );
    } else {
      // Desktop: Use file picker
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save JSON file',
        fileName: fileName, // e.g. data.json
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath == null) {
        throw Exception('Save cancelled');
      }
    }
  }

  Future<String?> _loadThemeFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        return utf8.decode(file.bytes!);
      } else if (file.path != null) {
        return await File(file.path!).readAsString();
      }
    }

    return null;
  }

  Future<void> _shareTheme(String jsonData, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonData);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Custom Theme',
      text: 'Check out my custom theme!',
    );
  }

  // ============== UI FEEDBACK ==============

  void _showSuccessMessage(BuildContext context, String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(message),
        severity: InfoBarSeverity.success,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('Error'),
        content: Text(message),
        severity: InfoBarSeverity.error,
      ),
    );
  }
}

// ============== EXPORT OPTIONS DIALOG ==============

class _ExportOptionsDialog extends StatelessWidget {
  final CustomThemeData theme;

  const _ExportOptionsDialog({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Row(
        children: [
          const Icon(FluentIcons.share, size: 20),
          const SizedBox(width: 12),
          Text(l10n.exportTheme),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chooseExportMethod,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _OptionButton(
            icon: FluentIcons.save,
            label: l10n.saveAsFile,
            description: l10n.saveThemeAsJSONFile,
            onPressed: () => Navigator.pop(context, 'file'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.copy,
            label: l10n.copyToClipboard,
            description: l10n.copyThemeJSONToClipboard,
            onPressed: () => Navigator.pop(context, 'clipboard'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.share,
            label: l10n.share,
            description: l10n.shareThemeViaSystemSheet,
            onPressed: () => Navigator.pop(context, 'share'),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ============== IMPORT OPTIONS DIALOG ==============

class _ImportOptionsDialog extends StatelessWidget {
  const _ImportOptionsDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Row(
        children: [
          const Icon(FluentIcons.download, size: 20),
          const SizedBox(width: 12),
          Text(l10n.importTheme),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chooseImportMethod,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _OptionButton(
            icon: FluentIcons.open_file,
            label: l10n.loadFromFile,
            description: l10n.selectJSONFileFromDevice,
            onPressed: () => Navigator.pop(context, 'file'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.paste,
            label: l10n.pasteFromClipboard,
            description: l10n.importFromClipboardJSON,
            onPressed: () => Navigator.pop(context, 'clipboard'),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ============== OPTION BUTTON ==============

class _OptionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.accentColor.withValues(alpha: 0.1)
                : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? theme.accentColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.typography.caption?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.chevron_right,
                size: 16,
                color: theme.typography.caption?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== CUSTOM THEME LIST ITEM (ENHANCED) ==============

class _CustomThemeListItem extends StatefulWidget {
  final CustomThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _CustomThemeListItem({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
  });

  @override
  State<_CustomThemeListItem> createState() => _CustomThemeListItemState();
}

class _CustomThemeListItemState extends State<_CustomThemeListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.accentColor.withValues(alpha: 0.1)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
                    : theme.inactiveBackgroundColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? theme.accentColor : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              ColorDot(color: widget.theme.primaryAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.theme.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(FluentIcons.share, size: 12),
                onPressed: widget.onExport,
              ),
              IconButton(
                icon: const Icon(FluentIcons.edit, size: 12),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: const Icon(FluentIcons.delete, size: 12),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Note: Include all other classes from the original file
// (ThemePresetCard, ColorDot, ThemeEditorDialog, etc.)
