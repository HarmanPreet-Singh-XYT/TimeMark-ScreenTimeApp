import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cp;
import 'package:flutter/material.dart' as mt;
import 'package:screentime/adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:screentime/main.dart'; // For buildLightTheme and buildDarkTheme

// ============== THEME CUSTOMIZATION SECTION ==============

class ThemeCustomizationSection extends StatefulWidget {
  const ThemeCustomizationSection({super.key});

  @override
  State<ThemeCustomizationSection> createState() =>
      _ThemeCustomizationSectionState();
}

class _ThemeCustomizationSectionState extends State<ThemeCustomizationSection> {
  bool _showAdvanced = false;

  // Method to manually refresh FluentAdaptiveTheme with new colors
  void _refreshTheme(BuildContext context, CustomThemeData newTheme) {
    final adaptiveTheme = FluentAdaptiveTheme.of(context);

    // Update the theme in the adaptive theme manager
    adaptiveTheme.setTheme(
      light: buildLightTheme(newTheme),
      dark: buildDarkTheme(newTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final fluentTheme = FluentTheme.of(context);

    return SettingsCard(
      title: 'Theme Customization',
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
                'Choose a Theme Preset',
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
                  return _ThemePresetCard(
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
                      'Your Custom Themes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fluentTheme.typography.body?.color,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.add, size: 14),
                      onPressed: () =>
                          _createNewCustomTheme(context, themeProvider),
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
                  );
                }),
              ],
            ),
          ),
        ],

        const Divider(),

        // Create Custom Theme Button
        SettingRow(
          title: 'Create Custom Theme',
          description: 'Design your own color scheme',
          control: FilledButton(
            onPressed: () => _createNewCustomTheme(context, themeProvider),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.add, size: 12),
                SizedBox(width: 6),
                Text('New Theme', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),

        // Advanced Customization Toggle
        if (themeProvider.currentTheme.isCustom) ...[
          const Divider(),
          SettingRow(
            title: 'Edit Current Theme',
            description:
                'Customize colors for ${themeProvider.currentTheme.name}',
            showDivider: false,
            control: FilledButton(
              onPressed: () => _editCustomTheme(
                  context, themeProvider, themeProvider.currentTheme),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.edit, size: 12),
                  SizedBox(width: 6),
                  Text('Edit', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _createNewCustomTheme(
      BuildContext context, ThemeCustomizationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _ThemeEditorDialog(
        initialTheme: ThemePresets.defaultTheme.copyWith(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Custom Theme ${provider.customThemes.length + 1}',
          isCustom: true,
        ),
        onSave: (theme) async {
          await provider.addCustomTheme(theme);
          await provider.setTheme(theme);
          if (mounted) {
            _refreshTheme(context, theme);
          }
        },
      ),
    );
  }

  void _editCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => _ThemeEditorDialog(
        initialTheme: theme,
        onSave: (updatedTheme) async {
          await provider.updateCustomTheme(updatedTheme);
          if (provider.currentTheme.id == theme.id) {
            await provider.setTheme(updatedTheme);
            if (mounted) {
              _refreshTheme(context, updatedTheme);
            }
          }
        },
      ),
    );
  }

  void _deleteCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Custom Theme'),
        content: Text('Are you sure you want to delete "${theme.name}"?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xffff0000)),
            ),
            child: const Text('Delete'),
            onPressed: () async {
              await provider.deleteCustomTheme(theme.id);
              if (mounted) {
                _refreshTheme(context, provider.currentTheme);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============== THEME PRESET CARD ==============

class _ThemePresetCard extends StatefulWidget {
  final CustomThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePresetCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ThemePresetCard> createState() => _ThemePresetCardState();
}

class _ThemePresetCardState extends State<_ThemePresetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.accentColor.withValues(alpha: 0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? theme.accentColor
                  : _isHovered
                      ? theme.inactiveBackgroundColor
                      : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color Preview
              Row(
                children: [
                  _ColorDot(color: widget.theme.primaryAccent),
                  const SizedBox(width: 4),
                  _ColorDot(color: widget.theme.secondaryAccent),
                  const SizedBox(width: 4),
                  _ColorDot(color: widget.theme.successColor),
                ],
              ),
              const SizedBox(height: 8),
              // Theme Name
              Text(
                widget.theme.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? theme.accentColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }
}

// ============== CUSTOM THEME LIST ITEM ==============

class _CustomThemeListItem extends StatefulWidget {
  final CustomThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomThemeListItem({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
              // Color Preview
              _ColorDot(color: widget.theme.primaryAccent),
              const SizedBox(width: 8),
              // Theme Name
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
              // Edit Button
              IconButton(
                icon: const Icon(FluentIcons.edit, size: 12),
                onPressed: widget.onEdit,
              ),
              // Delete Button
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

// ============== THEME EDITOR DIALOG ==============

class _ThemeEditorDialog extends StatefulWidget {
  final CustomThemeData initialTheme;
  final Function(CustomThemeData) onSave;

  const _ThemeEditorDialog({
    required this.initialTheme,
    required this.onSave,
  });

  @override
  State<_ThemeEditorDialog> createState() => _ThemeEditorDialogState();
}

class _ThemeEditorDialogState extends State<_ThemeEditorDialog> {
  late CustomThemeData _currentTheme;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
    _nameController = TextEditingController(text: widget.initialTheme.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateColor(String colorKey, Color color) {
    setState(() {
      switch (colorKey) {
        case 'primaryAccent':
          _currentTheme = _currentTheme.copyWith(primaryAccent: color);
          break;
        case 'secondaryAccent':
          _currentTheme = _currentTheme.copyWith(secondaryAccent: color);
          break;
        case 'successColor':
          _currentTheme = _currentTheme.copyWith(successColor: color);
          break;
        case 'warningColor':
          _currentTheme = _currentTheme.copyWith(warningColor: color);
          break;
        case 'errorColor':
          _currentTheme = _currentTheme.copyWith(errorColor: color);
          break;
        case 'lightBackground':
          _currentTheme = _currentTheme.copyWith(lightBackground: color);
          break;
        case 'darkBackground':
          _currentTheme = _currentTheme.copyWith(darkBackground: color);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
      title: const Text('Customize Theme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Name
            TextBox(
              controller: _nameController,
              placeholder: 'Theme Name',
            ),
            const SizedBox(height: 20),

            // Brand Colors
            _ColorSection(
              title: 'Brand Colors',
              colors: [
                _ColorPickerItem(
                    'Primary', _currentTheme.primaryAccent, 'primaryAccent'),
                _ColorPickerItem('Secondary', _currentTheme.secondaryAccent,
                    'secondaryAccent'),
                _ColorPickerItem(
                    'Success', _currentTheme.successColor, 'successColor'),
                _ColorPickerItem(
                    'Warning', _currentTheme.warningColor, 'warningColor'),
                _ColorPickerItem(
                    'Error', _currentTheme.errorColor, 'errorColor'),
              ],
              onColorChange: _updateColor,
            ),

            const SizedBox(height: 16),

            // Background Colors
            _ColorSection(
              title: 'Background Colors',
              colors: [
                _ColorPickerItem('Light Background',
                    _currentTheme.lightBackground, 'lightBackground'),
                _ColorPickerItem('Dark Background',
                    _currentTheme.darkBackground, 'darkBackground'),
              ],
              onColorChange: _updateColor,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            final updatedTheme =
                _currentTheme.copyWith(name: _nameController.text);
            widget.onSave(updatedTheme);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _ColorPickerItem {
  final String label;
  final Color color;
  final String key;

  _ColorPickerItem(this.label, this.color, this.key);
}

class _ColorSection extends StatelessWidget {
  final String title;
  final List<_ColorPickerItem> colors;
  final Function(String, Color) onColorChange;

  const _ColorSection({
    required this.title,
    required this.colors,
    required this.onColorChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...colors.map((item) => _ColorPickerRow(
              label: item.label,
              color: item.color,
              onColorChanged: (color) => onColorChange(item.key, color),
            )),
      ],
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final Color color;
  final Function(Color) onColorChanged;

  const _ColorPickerRow({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey[100]!,
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = color;

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('Pick Color for $label'),
        content: SingleChildScrollView(
          child: mt.Material(
            color: Colors.transparent,
            child: cp.BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Select'),
            onPressed: () {
              onColorChanged(pickerColor);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
