import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/UI%20sections/Settings/colorpicker.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
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
                      l10n.yourCustomThemes,
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

        // Advanced Customization Toggle
        if (themeProvider.currentTheme.isCustom) ...[
          const Divider(),
          SettingRow(
            title: l10n.editCurrentTheme,
            description:
                l10n.customizeColorsFor(themeProvider.currentTheme.name),
            showDivider: false,
            control: FilledButton(
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
          ),
        ],
      ],
    );
  }

  void _createNewCustomTheme(
      BuildContext context, ThemeCustomizationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => _ThemeEditorDialog(
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

// ============== ENHANCED THEME EDITOR DIALOG ==============

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
  int _selectedTabIndex = 0;

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
      _currentTheme = _currentTheme.updateColor(colorKey, color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
      title: Row(
        children: [
          const Icon(FluentIcons.color, size: 20),
          const SizedBox(width: 12),
          Text(l10n.customizeTheme),
          const Spacer(),
          // Live Preview Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _currentTheme.primaryAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentTheme.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.preview,
                  style: TextStyle(
                    fontSize: 11,
                    color: _currentTheme.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme Name Input
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextBox(
              controller: _nameController,
              placeholder: l10n.themeName,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(FluentIcons.tag, size: 14),
              ),
            ),
          ),

          // Tab Navigation
          SizedBox(
            height: 36,
            child: Row(
              children: [
                _TabButton(
                  label: l10n.brandColors,
                  icon: FluentIcons.color,
                  isSelected: _selectedTabIndex == 0,
                  onTap: () => setState(() => _selectedTabIndex = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: l10n.lightTheme,
                  icon: FluentIcons.sunny,
                  isSelected: _selectedTabIndex == 1,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: l10n.darkTheme,
                  icon: FluentIcons.clear_night,
                  isSelected: _selectedTabIndex == 2,
                  onTap: () => setState(() => _selectedTabIndex = 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildTabContent(),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        Button(
          child: Text(l10n.reset),
          onPressed: () {
            setState(() {
              _currentTheme = widget.initialTheme;
              _nameController.text = widget.initialTheme.name;
            });
          },
        ),
        FilledButton(
          child: Text(l10n.saveTheme),
          onPressed: () {
            final updatedTheme = _currentTheme.copyWith(
              name: _nameController.text.trim().isEmpty
                  ? l10n.customTheme
                  : _nameController.text.trim(),
            );
            widget.onSave(updatedTheme);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _BrandColorsTab(
          key: const ValueKey('brand'),
          theme: _currentTheme,
          onColorChange: _updateColor,
        );
      case 1:
        return _LightThemeTab(
          key: const ValueKey('light'),
          theme: _currentTheme,
          onColorChange: _updateColor,
        );
      case 2:
        return _DarkThemeTab(
          key: const ValueKey('dark'),
          theme: _currentTheme,
          onColorChange: _updateColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ============== TAB BUTTON ==============

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.accentColor.withValues(alpha: 0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? theme.accentColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isSelected ? theme.accentColor : null,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
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

// ============== BRAND COLORS TAB ==============

class _BrandColorsTab extends StatelessWidget {
  final CustomThemeData theme;
  final Function(String, Color) onColorChange;

  const _BrandColorsTab({
    super.key,
    required this.theme,
    required this.onColorChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
          title: l10n.primaryColors,
          description: l10n.primaryColorsDesc,
        ),
        _ColorPickerRow(
          label: l10n.primaryAccent,
          description: l10n.primaryAccentDesc,
          color: theme.primaryAccent,
          onColorChanged: (c) => onColorChange('primaryAccent', c),
        ),
        _ColorPickerRow(
          label: l10n.secondaryAccent,
          description: l10n.secondaryAccentDesc,
          color: theme.secondaryAccent,
          onColorChanged: (c) => onColorChange('secondaryAccent', c),
        ),

        const SizedBox(height: 20),
        _ColorSectionHeader(
          title: l10n.semanticColors,
          description: l10n.semanticColorsDesc,
        ),
        _ColorPickerRow(
          label: l10n.successColor,
          description: l10n.successColorDesc,
          color: theme.successColor,
          onColorChanged: (c) => onColorChange('successColor', c),
        ),
        _ColorPickerRow(
          label: l10n.warningColor,
          description: l10n.warningColorDesc,
          color: theme.warningColor,
          onColorChanged: (c) => onColorChange('warningColor', c),
        ),
        _ColorPickerRow(
          label: l10n.errorColor,
          description: l10n.errorColorDesc,
          color: theme.errorColor,
          onColorChanged: (c) => onColorChange('errorColor', c),
        ),

        const SizedBox(height: 20),
        // Preview Card
        _ThemePreviewCard(theme: theme, isDark: false),
      ],
    );
  }
}

// ============== LIGHT THEME TAB ==============

class _LightThemeTab extends StatelessWidget {
  final CustomThemeData theme;
  final Function(String, Color) onColorChange;

  const _LightThemeTab({
    super.key,
    required this.theme,
    required this.onColorChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
          title: l10n.backgroundColors,
          description: l10n.backgroundColorsLightDesc,
        ),
        _ColorPickerRow(
          label: l10n.background,
          description: l10n.backgroundDesc,
          color: theme.lightBackground,
          onColorChanged: (c) => onColorChange('lightBackground', c),
        ),
        _ColorPickerRow(
          label: l10n.surface,
          description: l10n.surfaceDesc,
          color: theme.lightSurface,
          onColorChanged: (c) => onColorChange('lightSurface', c),
        ),
        _ColorPickerRow(
          label: l10n.surfaceSecondary,
          description: l10n.surfaceSecondaryDesc,
          color: theme.lightSurfaceSecondary,
          onColorChanged: (c) => onColorChange('lightSurfaceSecondary', c),
        ),
        _ColorPickerRow(
          label: l10n.border,
          description: l10n.borderDesc,
          color: theme.lightBorder,
          onColorChanged: (c) => onColorChange('lightBorder', c),
        ),

        const SizedBox(height: 20),
        _ColorSectionHeader(
          title: l10n.textColors,
          description: l10n.textColorsLightDesc,
        ),
        _ColorPickerRow(
          label: l10n.textPrimary,
          description: l10n.textPrimaryDesc,
          color: theme.lightTextPrimary,
          onColorChanged: (c) => onColorChange('lightTextPrimary', c),
        ),
        _ColorPickerRow(
          label: l10n.textSecondary,
          description: l10n.textSecondaryDesc,
          color: theme.lightTextSecondary,
          onColorChanged: (c) => onColorChange('lightTextSecondary', c),
        ),

        const SizedBox(height: 20),
        // Preview Card
        _ThemePreviewCard(theme: theme, isDark: false),
      ],
    );
  }
}

// ============== DARK THEME TAB ==============

class _DarkThemeTab extends StatelessWidget {
  final CustomThemeData theme;
  final Function(String, Color) onColorChange;

  const _DarkThemeTab({
    super.key,
    required this.theme,
    required this.onColorChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
          title: l10n.backgroundColors,
          description: l10n.backgroundColorsDarkDesc,
        ),
        _ColorPickerRow(
          label: l10n.background,
          description: l10n.backgroundDesc,
          color: theme.darkBackground,
          onColorChanged: (c) => onColorChange('darkBackground', c),
        ),
        _ColorPickerRow(
          label: l10n.surface,
          description: l10n.surfaceDesc,
          color: theme.darkSurface,
          onColorChanged: (c) => onColorChange('darkSurface', c),
        ),
        _ColorPickerRow(
          label: l10n.surfaceSecondary,
          description: l10n.surfaceSecondaryDesc,
          color: theme.darkSurfaceSecondary,
          onColorChanged: (c) => onColorChange('darkSurfaceSecondary', c),
        ),
        _ColorPickerRow(
          label: l10n.border,
          description: l10n.borderDesc,
          color: theme.darkBorder,
          onColorChanged: (c) => onColorChange('darkBorder', c),
        ),

        const SizedBox(height: 20),
        _ColorSectionHeader(
          title: l10n.textColors,
          description: l10n.textColorsDarkDesc,
        ),
        _ColorPickerRow(
          label: l10n.textPrimary,
          description: l10n.textPrimaryDesc,
          color: theme.darkTextPrimary,
          onColorChanged: (c) => onColorChange('darkTextPrimary', c),
        ),
        _ColorPickerRow(
          label: l10n.textSecondary,
          description: l10n.textSecondaryDesc,
          color: theme.darkTextSecondary,
          onColorChanged: (c) => onColorChange('darkTextSecondary', c),
        ),

        const SizedBox(height: 20),
        // Preview Card
        _ThemePreviewCard(theme: theme, isDark: true),
      ],
    );
  }
}

// ============== SECTION HEADER ==============

class _ColorSectionHeader extends StatelessWidget {
  final String title;
  final String description;

  const _ColorSectionHeader({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.typography.body?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: theme.typography.caption?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== UPDATED COLOR PICKER ROW ==============

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final String? description;
  final Color color;
  final Function(Color) onColorChanged;

  const _ColorPickerRow({
    required this.label,
    this.description,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.typography.caption?.color,
                    ),
                  ),
              ],
            ),
          ),

          // Color Swatch Button
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Hex Code Display (Clickable)
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.inactiveBackgroundColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final selectedColor = await FluentColorPickerDialog.show(
      context: context,
      title: label,
      initialColor: color,
    );

    if (selectedColor != null) {
      onColorChanged(selectedColor);
    }
  }
}

// ============== THEME PREVIEW CARD ==============

class _ThemePreviewCard extends StatelessWidget {
  final CustomThemeData theme;
  final bool isDark;

  const _ThemePreviewCard({
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final background = isDark ? theme.darkBackground : theme.lightBackground;
    final surface = isDark ? theme.darkSurface : theme.lightSurface;
    final border = isDark ? theme.darkBorder : theme.lightBorder;
    final textPrimary = isDark ? theme.darkTextPrimary : theme.lightTextPrimary;
    final textSecondary =
        isDark ? theme.darkTextSecondary : theme.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewMode(isDark ? l10n.dark : l10n.light),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Sample Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sampleCardTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.sampleSecondaryText,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PreviewButton(
                      color: theme.primaryAccent,
                      label: l10n.primary,
                    ),
                    const SizedBox(width: 8),
                    _PreviewButton(
                      color: theme.successColor,
                      label: l10n.success,
                    ),
                    const SizedBox(width: 8),
                    _PreviewButton(
                      color: theme.errorColor,
                      label: l10n.error,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Color Swatches Row
          Row(
            children: [
              _PreviewSwatch(color: theme.primaryAccent, label: l10n.primary),
              _PreviewSwatch(
                  color: theme.secondaryAccent, label: l10n.secondary),
              _PreviewSwatch(color: theme.successColor, label: l10n.success),
              _PreviewSwatch(color: theme.warningColor, label: l10n.warning),
              _PreviewSwatch(color: theme.errorColor, label: l10n.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final Color color;
  final String label;

  const _PreviewButton({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PreviewSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _PreviewSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 8),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
