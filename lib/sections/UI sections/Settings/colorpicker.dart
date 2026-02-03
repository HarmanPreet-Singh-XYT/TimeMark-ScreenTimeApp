import 'package:fluent_ui/fluent_ui.dart';

// ============== FLUENT COLOR PICKER DIALOG ==============

class FluentColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final Function(Color) onColorSelected;

  const FluentColorPickerDialog({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorSelected,
  });

  static Future<Color?> show({
    required BuildContext context,
    required String title,
    required Color initialColor,
  }) async {
    Color? selectedColor;

    await showDialog<Color>(
      context: context,
      builder: (context) => FluentColorPickerDialog(
        title: title,
        initialColor: initialColor,
        onColorSelected: (color) {
          selectedColor = color;
        },
      ),
    );

    return selectedColor;
  }

  @override
  State<FluentColorPickerDialog> createState() =>
      _FluentColorPickerDialogState();
}

class _FluentColorPickerDialogState extends State<FluentColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late Color _currentColor;
  late double _hue;
  late double _saturation;
  late double _value;
  late TextEditingController _hexController;

  int _selectedTab = 0; // 0: Spectrum, 1: Presets, 2: Custom

  // Preset color palettes
  static const List<Color> _basicColors = [
    Color(0xFFFF0000),
    Color(0xFFFF4500),
    Color(0xFFFFA500),
    Color(0xFFFFD700),
    Color(0xFFFFFF00),
    Color(0xFF9ACD32),
    Color(0xFF32CD32),
    Color(0xFF00FA9A),
    Color(0xFF00FFFF),
    Color(0xFF1E90FF),
    Color(0xFF0000FF),
    Color(0xFF8A2BE2),
    Color(0xFFFF00FF),
    Color(0xFFFF1493),
    Color(0xFFFFFFFF),
    Color(0xFFC0C0C0),
    Color(0xFF808080),
    Color(0xFF404040),
    Color(0xFF000000),
    Color(0xFF8B4513),
  ];

  static const List<Color> _extendedColors = [
    // Reds
    Color(0xFFFFCDD2), Color(0xFFEF9A9A), Color(0xFFE57373), Color(0xFFEF5350),
    Color(0xFFF44336), Color(0xFFE53935), Color(0xFFD32F2F), Color(0xFFC62828),
    // Pinks
    Color(0xFFF8BBD9), Color(0xFFF48FB1), Color(0xFFF06292), Color(0xFFEC407A),
    Color(0xFFE91E63), Color(0xFFD81B60), Color(0xFFC2185B), Color(0xFFAD1457),
    // Purples
    Color(0xFFE1BEE7), Color(0xFFCE93D8), Color(0xFFBA68C8), Color(0xFFAB47BC),
    Color(0xFF9C27B0), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A),
    // Blues
    Color(0xFFBBDEFB), Color(0xFF90CAF9), Color(0xFF64B5F6), Color(0xFF42A5F5),
    Color(0xFF2196F3), Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),
    // Cyans
    Color(0xFFB2EBF2), Color(0xFF80DEEA), Color(0xFF4DD0E1), Color(0xFF26C6DA),
    Color(0xFF00BCD4), Color(0xFF00ACC1), Color(0xFF0097A7), Color(0xFF00838F),
    // Greens
    Color(0xFFC8E6C9), Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFF66BB6A),
    Color(0xFF4CAF50), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF2E7D32),
    // Yellows/Oranges
    Color(0xFFFFF9C4), Color(0xFFFFF59D), Color(0xFFFFF176), Color(0xFFFFEE58),
    Color(0xFFFFEB3B), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFF9A825),
    // Oranges
    Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFFB74D), Color(0xFFFFA726),
    Color(0xFFFF9800), Color(0xFFFB8C00), Color(0xFFF57C00), Color(0xFFEF6C00),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _updateHSVFromColor(_currentColor);
    _hexController = TextEditingController(text: _colorToHex(_currentColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateHSVFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColorFromHSV() {
    setState(() {
      _currentColor =
          HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
      _hexController.text = _colorToHex(_currentColor);
    });
  }

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  Color? _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Invalid hex
    }
    return null;
  }

  void _setColor(Color color) {
    setState(() {
      _currentColor = color;
      _updateHSVFromColor(color);
      _hexController.text = _colorToHex(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Selector
          _buildTabSelector(theme),
          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: _buildTabContent(theme, isDark),
          ),

          const SizedBox(height: 16),

          // Hex Input & Preview
          _buildHexInputRow(theme, isDark),
        ],
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Select'),
          onPressed: () {
            widget.onColorSelected(_currentColor);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildTabSelector(FluentThemeData theme) {
    return Row(
      children: [
        _TabChip(
          label: 'Spectrum',
          icon: FluentIcons.color,
          isSelected: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: 'Presets',
          icon: FluentIcons.grid_view_medium,
          isSelected: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: 'Sliders',
          icon: FluentIcons.slider,
          isSelected: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
      ],
    );
  }

  Widget _buildTabContent(FluentThemeData theme, bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildSpectrumPicker(isDark);
      case 1:
        return _buildPresetsPicker(isDark);
      case 2:
        return _buildSlidersPicker(theme, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSpectrumPicker(bool isDark) {
    return Column(
      children: [
        // Saturation/Value Picker
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _SaturationValuePicker(
              hue: _hue,
              saturation: _saturation,
              value: _value,
              onChanged: (sat, val) {
                _saturation = sat;
                _value = val;
                _updateColorFromHSV();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Hue Slider
        _HueSlider(
          hue: _hue,
          onChanged: (hue) {
            _hue = hue;
            _updateColorFromHSV();
          },
        ),
      ],
    );
  }

  Widget _buildPresetsPicker(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Colors',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildColorGrid(_basicColors, isDark),
          const SizedBox(height: 16),
          const Text(
            'Extended Palette',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildColorGrid(_extendedColors, isDark),
        ],
      ),
    );
  }

  Widget _buildColorGrid(List<Color> colors, bool isDark) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: colors.map((color) {
        final isSelected = _currentColor.value == color.value;
        return GestureDetector(
          onTap: () => _setColor(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.transparent,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    FluentIcons.check_mark,
                    size: 14,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlidersPicker(FluentThemeData theme, bool isDark) {
    final r = _currentColor.red;
    final g = _currentColor.green;
    final b = _currentColor.blue;

    return SingleChildScrollView(
      child: Column(
        children: [
          // RGB Sliders
          _ColorSliderRow(
            label: 'Red',
            value: r.toDouble(),
            max: 255,
            activeColor: Colors.red,
            onChanged: (val) {
              _setColor(Color.fromARGB(255, val.round(), g, b));
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: 'Green',
            value: g.toDouble(),
            max: 255,
            activeColor: Colors.green,
            onChanged: (val) {
              _setColor(Color.fromARGB(255, r, val.round(), b));
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: 'Blue',
            value: b.toDouble(),
            max: 255,
            activeColor: Colors.blue,
            onChanged: (val) {
              _setColor(Color.fromARGB(255, r, g, val.round()));
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // HSV Sliders
          _ColorSliderRow(
            label: 'Hue',
            value: _hue,
            max: 360,
            activeColor: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
            onChanged: (val) {
              _hue = val;
              _updateColorFromHSV();
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: 'Saturation',
            value: _saturation * 100,
            max: 100,
            activeColor: _currentColor,
            onChanged: (val) {
              _saturation = val / 100;
              _updateColorFromHSV();
            },
          ),
          const SizedBox(height: 12),
          _ColorSliderRow(
            label: 'Brightness',
            value: _value * 100,
            max: 100,
            activeColor: _currentColor,
            onChanged: (val) {
              _value = val / 100;
              _updateColorFromHSV();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHexInputRow(FluentThemeData theme, bool isDark) {
    return Row(
      children: [
        // Current Color Preview
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: _currentColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Hex Input
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hex Color',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    '#',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextBox(
                      controller: _hexController,
                      placeholder: 'RRGGBB',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      maxLength: 6,
                      onChanged: (value) {
                        final color = _hexToColor(value);
                        if (color != null) {
                          setState(() {
                            _currentColor = color;
                            _updateHSVFromColor(color);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // RGB Values Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'RGB',
              style: TextStyle(
                fontSize: 10,
                color: theme.typography.caption?.color,
              ),
            ),
            Text(
              '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============== TAB CHIP ==============

class _TabChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.accentColor.withValues(alpha: 0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? theme.accentColor : Colors.transparent,
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

// ============== SATURATION/VALUE PICKER ==============

class _SaturationValuePicker extends StatefulWidget {
  final double hue;
  final double saturation;
  final double value;
  final Function(double saturation, double value) onChanged;

  const _SaturationValuePicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SaturationValuePicker> createState() => _SaturationValuePickerState();
}

class _SaturationValuePickerState extends State<_SaturationValuePicker> {
  void _handlePanUpdate(Offset localPosition, Size size) {
    final sat = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final val = 1.0 - (localPosition.dy / size.height).clamp(0.0, 1.0);
    widget.onChanged(sat, val);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (details) =>
              _handlePanUpdate(details.localPosition, size),
          onPanUpdate: (details) =>
              _handlePanUpdate(details.localPosition, size),
          onTapDown: (details) => _handlePanUpdate(details.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: _SaturationValuePainter(
              hue: widget.hue,
              saturation: widget.saturation,
              value: widget.value,
            ),
          ),
        );
      },
    );
  }
}

class _SaturationValuePainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;

  _SaturationValuePainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw saturation gradient (white to hue color)
    final saturationGradient = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      ],
    );
    canvas.drawRect(
        rect, Paint()..shader = saturationGradient.createShader(rect));

    // Draw value gradient (transparent to black)
    final valueGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    );
    canvas.drawRect(rect, Paint()..shader = valueGradient.createShader(rect));

    // Draw indicator circle
    final indicatorX = saturation * size.width;
    final indicatorY = (1 - value) * size.height;
    final indicatorCenter = Offset(indicatorX, indicatorY);

    // Outer circle (white)
    canvas.drawCircle(
      indicatorCenter,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Inner circle (black)
    canvas.drawCircle(
      indicatorCenter,
      10,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Fill with current color
    canvas.drawCircle(
      indicatorCenter,
      8,
      Paint()..color = HSVColor.fromAHSV(1, hue, saturation, value).toColor(),
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) {
    return hue != oldDelegate.hue ||
        saturation != oldDelegate.saturation ||
        value != oldDelegate.value;
  }
}

// ============== HUE SLIDER ==============

class _HueSlider extends StatefulWidget {
  final double hue;
  final Function(double) onChanged;

  const _HueSlider({
    required this.hue,
    required this.onChanged,
  });

  @override
  State<_HueSlider> createState() => _HueSliderState();
}

class _HueSliderState extends State<_HueSlider> {
  void _handlePanUpdate(Offset localPosition, double width) {
    final hue = (localPosition.dx / width * 360).clamp(0.0, 360.0);
    widget.onChanged(hue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            onPanStart: (details) =>
                _handlePanUpdate(details.localPosition, width),
            onPanUpdate: (details) =>
                _handlePanUpdate(details.localPosition, width),
            onTapDown: (details) =>
                _handlePanUpdate(details.localPosition, width),
            child: CustomPaint(
              size: Size(width, 24),
              painter: _HueSliderPainter(hue: widget.hue),
            ),
          );
        },
      ),
    );
  }
}

class _HueSliderPainter extends CustomPainter {
  final double hue;

  _HueSliderPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    // Draw hue gradient
    final colors = List.generate(
      7,
      (index) => HSVColor.fromAHSV(1, index * 60.0, 1, 1).toColor(),
    );

    final gradient = LinearGradient(colors: colors);
    canvas.drawRRect(
      rect,
      Paint()..shader = gradient.createShader(Offset.zero & size),
    );

    // Draw indicator
    final indicatorX = (hue / 360) * size.width;
    final indicatorCenter = Offset(indicatorX, size.height / 2);

    // Outer circle
    canvas.drawCircle(
      indicatorCenter,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      indicatorCenter,
      8,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawCircle(
      indicatorCenter,
      6,
      Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
    );
  }

  @override
  bool shouldRepaint(covariant _HueSliderPainter oldDelegate) {
    return hue != oldDelegate.hue;
  }
}

// ============== FIXED FLUENT COMPATIBLE SLIDER ==============

class _ColorSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color activeColor;
  final Function(double) onChanged;

  const _ColorSliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            onChanged: onChanged,
            style: SliderThemeData(
              activeColor: WidgetStateProperty.all(activeColor),
              inactiveColor:
                  WidgetStateProperty.all(activeColor.withValues(alpha: 0.2)),
              thumbColor: WidgetStateProperty.all(activeColor),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.round().toString(),
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
