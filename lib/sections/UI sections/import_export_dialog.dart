// lib/sections/backup_restore_dialog.dart

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../controller/services/data_export_services.dart';
import '../controller/models/export_models.dart';
import '../controller/app_data_controller.dart';

/// Main dialog for backup and restore operations
class BackupRestoreDialog extends StatefulWidget {
  final bool startWithImport;
  
  const BackupRestoreDialog({
    super.key,
    this.startWithImport = false,
  });

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  late final DataExportService _exportService;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _status = '';
  String? _resultMessage;
  bool? _isSuccess;

  @override
  void initState() {
    super.initState();
    _exportService = DataExportService(AppDataStore());
    
    // Auto-start import if specified
    if (widget.startWithImport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleImport();
      });
    }
  }

  Future<void> _handleExport() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _status = l10n.exportStarting;
      _resultMessage = null;
      _isSuccess = null;
    });

    final result = await _exportService.exportData(
      onProgress: (progress, status) {
        setState(() {
          _progress = progress;
          _status = status;
        });
      },
    );

    setState(() {
      _isProcessing = false;
      _isSuccess = result.success;
      
      if (result.success) {
        _resultMessage = '${l10n.exportSuccessful}\n'
            '${l10n.fileLabel}: ${result.fileName}\n'
            '${l10n.sizeLabel}: ${_formatFileSize(result.fileSize ?? 0)}\n'
            '${l10n.recordsLabel}: ${result.recordCount}';
      } else {
        _resultMessage = '${l10n.exportFailed}: ${result.error}';
      }
    });

    // Offer to share the file
    if (result.success && result.filePath != null && mounted) {
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: Text(l10n.exportComplete),
          content: Text(l10n.shareBackupQuestion),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.noButton),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.shareButton),
            ),
          ],
        ),
      );

      if (shouldShare == true) {
        await _exportService.shareExport(result.filePath!);
      }
    }
  }

  Future<void> _handleImport() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show import mode selection dialog
    final importMode = await showDialog<ImportMode>(
      context: context,
      builder: (context) => ImportModeDialog(),
    );

    if (importMode == null) return;

    // Confirm if replacing
    if (importMode == ImportMode.replace) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: Text(l10n.warningTitle),
          content: Text(
            l10n.replaceWarningMessage
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.replaceAllButton),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _status = l10n.importStarting;
      _resultMessage = null;
      _isSuccess = null;
    });

    final result = await _exportService.importData(
      mode: importMode,
      onProgress: (progress, status) {
        setState(() {
          _progress = progress;
          _status = status;
        });
      },
    );

    setState(() {
      _isProcessing = false;
      _isSuccess = result.success;
      
      if (result.success) {
        _resultMessage = '${l10n.importSuccessful}\n'
            '${l10n.usageRecordsLabel}: ${result.usageRecordsImported}\n'
            '${l10n.focusSessionsLabel}: ${result.focusSessionsImported}\n'
            '${l10n.appMetadataLabel}: ${result.metadataRecordsImported}\n'
            '${l10n.updatedLabel}: ${result.recordsUpdated}\n'
            '${l10n.skippedLabel}: ${result.recordsSkipped}';
      } else {
        _resultMessage = '${l10n.importFailed}: ${result.error}';
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ContentDialog(
      title: Text(l10n.backupRestoreTitle),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProcessing) ...[
              ProgressBar(value: _progress * 100),
              const SizedBox(height: 12),
              Text(
                _status,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            
            if (_resultMessage != null) ...[
              _ResultMessageBox(
                message: _resultMessage!,
                isSuccess: _isSuccess ?? false,
              ),
              const SizedBox(height: 20),
            ],
            
            if (!_isProcessing) ...[
              _ActionButton(
                icon: FluentIcons.upload,
                title: l10n.exportDataTitle,
                subtitle: l10n.exportDataDescription,
                onPressed: _handleExport,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                icon: FluentIcons.download,
                title: l10n.importDataTitle,
                subtitle: l10n.importDataDescription,
                onPressed: _handleImport,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: Text(l10n.closeButton),
        ),
      ],
    );
  }
}

/// Dialog for selecting import mode
class ImportModeDialog extends StatelessWidget {
  const ImportModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ContentDialog(
      title: Text(l10n.importOptionsTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importOptionsQuestion),
            const SizedBox(height: 20),
            _ImportModeOption(
              icon: FluentIcons.switch_user,
              title: l10n.replaceModeTitle,
              subtitle: l10n.replaceModeDescription,
              mode: ImportMode.replace,
            ),
            const SizedBox(height: 12),
            _ImportModeOption(
              icon: FluentIcons.merge,
              title: l10n.mergeModeTitle,
              subtitle: l10n.mergeModeDescription,
              mode: ImportMode.merge,
            ),
            const SizedBox(height: 12),
            _ImportModeOption(
              icon: FluentIcons.add,
              title: l10n.appendModeTitle,
              subtitle: l10n.appendModeDescription,
              mode: ImportMode.append,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.pop(context, null),
          child: Text(l10n.cancelButton),
        ),
      ],
    );
  }
}

/// Individual import mode option button
class _ImportModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ImportMode mode;

  const _ImportModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: () => Navigator.pop(context, mode),
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: states.isHovering 
                ? FluentTheme.of(context).accentColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FluentTheme.of(context).inactiveBackgroundColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff555555),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(FluentIcons.chevron_right, size: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Action button for export/import operations
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final AccentColor color;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: states.isHovering 
                ? color.withOpacity(0.1)
                : FluentTheme.of(context).micaBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: states.isHovering
                  ? color
                  : FluentTheme.of(context).inactiveBackgroundColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff555555),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(FluentIcons.chevron_right, size: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Result message display box
class _ResultMessageBox extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _ResultMessageBox({
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess 
                ? FluentIcons.completed_solid
                : FluentIcons.error_badge,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isSuccess ? Colors.green.dark : Colors.red.dark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings section widget for adding to settings page
class BackupRestoreSection extends StatelessWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.backupRestoreSection,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 15),
        Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(
              color: FluentTheme.of(context).inactiveBackgroundColor,
              width: 1
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSettingRow(
                context,
                title: l10n.exportDataTitle,
                description: l10n.exportDataDescription,
                buttonText: l10n.exportButton,
                onPressed: () => _showBackupRestoreDialog(context, startWithImport: false),
              ),
              _buildSettingRow(
                context,
                title: l10n.importDataTitle,
                description: l10n.importDataDescription,
                buttonText: l10n.importButton,
                onPressed: () => _showBackupRestoreDialog(context, startWithImport: true),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Color(0xff555555))
            ),
          ],
        ),
        Button(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            ),
          ),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _showBackupRestoreDialog(BuildContext context, {required bool startWithImport}) {
    showDialog(
      context: context,
      builder: (context) => BackupRestoreDialog(startWithImport: startWithImport),
    );
  }
}