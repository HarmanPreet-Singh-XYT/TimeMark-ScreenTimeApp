import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Enhanced clipboard import dialog with validation
class ClipboardImportDialog extends StatefulWidget {
  final Function(String) onImport;

  const ClipboardImportDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ClipboardImportDialog> createState() => _ClipboardImportDialogState();
}

class _ClipboardImportDialogState extends State<ClipboardImportDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _loadFromClipboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        _controller.text = clipboardData!.text!;
        _validateJson(clipboardData.text!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load clipboard: $e';
      });
    }
  }

  void _validateJson(String text) {
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    try {
      final json = jsonDecode(text);

      // Validate required fields
      final requiredFields = [
        'id',
        'name',
        'primaryAccent',
        'secondaryAccent',
        'lightBackground',
        'darkBackground'
      ];

      for (final field in requiredFields) {
        if (!json.containsKey(field)) {
          setState(() {
            _errorMessage = 'Missing required field: $field';
            _isValidating = false;
          });
          return;
        }
      }

      setState(() {
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON format';
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      title: const Row(
        children: [
          Icon(FluentIcons.paste, size: 20),
          SizedBox(width: 12),
          Text('Import from Clipboard'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste or edit the theme JSON data below:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),

            // JSON Text Box
            TextBox(
              controller: _controller,
              maxLines: 12,
              placeholder: 'Paste theme JSON here...',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              onChanged: (value) => _validateJson(value),
            ),

            const SizedBox(height: 12),

            // Validation Status
            if (_isValidating)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Validating...',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.typography.caption?.color,
                    ),
                  ),
                ],
              )
            else if (_errorMessage != null)
              Row(
                children: [
                  Icon(
                    FluentIcons.error_badge,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            else if (_controller.text.isNotEmpty)
              Row(
                children: [
                  Icon(
                    FluentIcons.completed,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Valid theme data',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                    ),
                  ),
                ],
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
          onPressed: _errorMessage == null && _controller.text.isNotEmpty
              ? () {
                  widget.onImport(_controller.text);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Import'),
        ),
      ],
    );
  }
}
