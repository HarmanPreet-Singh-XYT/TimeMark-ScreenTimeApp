// lib/sections/backup_restore_dialog.dart

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../controller/services/data_export_services.dart';
import '../controller/models/export_models.dart';
import '../controller/app_data_controller.dart';
import 'package:flutter/material.dart' as mt;

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? FluentTheme.of(context).inactiveBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Icon(widget.icon, size: 18),
          ),
        ),
      ),
    );
  }
}

// ============== SETTINGS CARD ==============
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final Widget? trailing;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
    this.trailing,
    this.isExpanded = true,
    this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Replace mt.InkWell with GestureDetector
          GestureDetector(
            onTap: onExpandToggle,
            child: MouseRegion(
              cursor: onExpandToggle != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          theme.inactiveBackgroundColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (iconColor ?? theme.accentColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon,
                          size: 16, color: iconColor ?? theme.accentColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null) trailing!,
                    if (onExpandToggle != null) ...[
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(FluentIcons.chevron_down, size: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

// ============== SETTING ROW ==============

class SettingRow extends StatefulWidget {
  final String title;
  final String description;
  final Widget control;
  final IconData? icon;
  final bool isSubSetting;
  final bool showDivider;

  const SettingRow({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.icon,
    this.isSubSetting = false,
    this.showDivider = true,
  });

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSubSetting ? 12 : 8,
              vertical: 10,
            ),
            margin: EdgeInsets.only(left: widget.isSubSetting ? 20 : 0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
                  : null,
              borderRadius: BorderRadius.circular(6),
              border: widget.isSubSetting
                  ? Border(
                      left: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: theme.accentColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.isSubSetting ? Colors.grey[80] : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                widget.control,
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            style: DividerThemeData(
              thickness: 1,
              decoration: BoxDecoration(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}
// ============== BACKUP RESTORE SECTION (Integrated) ==============

class BackupRestoreSection extends StatelessWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.backupRestoreSection,
      icon: FluentIcons.cloud_upload,
      iconColor: Colors.blue,
      trailing: _LastBackupIndicator(),
      children: [
        SettingRow(
          title: l10n.exportDataTitle,
          description: l10n.exportDataDescription,
          control: _BackupActionButton(
            icon: FluentIcons.cloud_upload,
            label: l10n.exportButton,
            color: Colors.blue,
            onPressed: () =>
                _showBackupRestoreDialog(context, startWithImport: false),
          ),
        ),
        SettingRow(
          title: l10n.importDataTitle,
          description: l10n.importDataDescription,
          showDivider: false,
          control: _BackupActionButton(
            icon: FluentIcons.cloud_download,
            label: l10n.importButton,
            color: Colors.green,
            onPressed: () =>
                _showBackupRestoreDialog(context, startWithImport: true),
          ),
        ),
      ],
    );
  }

  void _showBackupRestoreDialog(BuildContext context,
      {required bool startWithImport}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          BackupRestoreDialog(startWithImport: startWithImport),
    );
  }
}

// Last backup indicator widget
class _LastBackupIndicator extends StatelessWidget {
  const _LastBackupIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // You can implement logic to show last backup date from settings/storage
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.cloud, size: 12, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            l10n.sync_ready,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

// Styled action button for backup/restore
class _BackupActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BackupActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_BackupActionButton> createState() => _BackupActionButtonState();
}

class _BackupActionButtonState extends State<_BackupActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.15)
                : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.6)
                  : widget.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== REFINED BACKUP RESTORE DIALOG ==============

class BackupRestoreDialog extends StatefulWidget {
  final bool startWithImport;

  const BackupRestoreDialog({
    super.key,
    this.startWithImport = false,
  });

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog>
    with SingleTickerProviderStateMixin {
  late final DataExportService _exportService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isProcessing = false;
  double _progress = 0.0;
  String _status = '';
  String? _resultMessage;
  bool? _isSuccess;
  int? _currentStep;
  final int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _exportService = DataExportService(AppDataStore());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    if (widget.startWithImport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleImport();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _currentStep = 1;
      _status = l10n.exportStarting;
      _resultMessage = null;
      _isSuccess = null;
    });

    final result = await _exportService.exportData(
      onProgress: (progress, status) {
        setState(() {
          _progress = progress;
          _status = status;
          _currentStep = (progress * _totalSteps).ceil().clamp(1, _totalSteps);
        });
      },
    );

    setState(() {
      _isProcessing = false;
      _isSuccess = result.success;

      if (result.success) {
        // Extract just the directory path for display
        final directory =
            result.filePath!.substring(0, result.filePath!.lastIndexOf('/'));

        _resultMessage = '${l10n.exportSuccessful}\n'
            '${l10n.fileLabel}: ${result.fileName}\n'
            '${l10n.sizeLabel}: ${_formatFileSize(result.fileSize ?? 0)}\n'
            '${l10n.recordsLabel}: ${result.recordCount}\n'
            '\nLocation: ${Platform.isMacOS ? "~/Desktop/TimeMark-Backups/" : directory}';
      } else {
        _resultMessage = '${l10n.exportFailed}: ${result.error}';
      }
    });

    if (result.success && result.filePath != null && mounted) {
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => _ShareDialog(l10n: l10n),
      );

      if (shouldShare == true) {
        await _exportService.shareExport(result.filePath!);
      }
    }
  }

  Future<void> _handleImport() async {
    final l10n = AppLocalizations.of(context)!;

    final importMode = await showDialog<ImportMode>(
      context: context,
      builder: (context) => _RefinedImportModeDialog(),
    );

    if (importMode == null) return;

    if (importMode == ImportMode.replace) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _ReplaceConfirmDialog(l10n: l10n),
      );

      if (confirmed != true) return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _currentStep = 1;
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
          _currentStep = (progress * _totalSteps).ceil().clamp(1, _totalSteps);
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ContentDialog(
        constraints: const BoxConstraints(maxWidth: 480),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FluentIcons.cloud_upload,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.backupRestoreTitle),
            const Spacer(),
            if (!_isProcessing)
              _QuickActionButton(
                icon: FluentIcons.cancel,
                tooltip: l10n.closeButton,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Processing State
            if (_isProcessing) ...[
              _ProcessingIndicator(
                progress: _progress,
                status: _status,
                currentStep: _currentStep ?? 1,
                totalSteps: _totalSteps,
              ),
              const SizedBox(height: 20),
            ],

            // Result Message
            if (_resultMessage != null) ...[
              _AnimatedResultBox(
                message: _resultMessage!,
                isSuccess: _isSuccess ?? false,
              ),
              const SizedBox(height: 20),
            ],

            // Action Cards (only when not processing)
            if (!_isProcessing) ...[
              _ActionCard(
                icon: FluentIcons.cloud_upload,
                title: l10n.exportDataTitle,
                subtitle: l10n.exportDataDescription,
                color: Colors.blue,
                onPressed: _handleExport,
                features: [
                  'Save to JSON file',
                  'All app data included',
                  'Share via system dialog',
                ],
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: FluentIcons.cloud_download,
                title: l10n.importDataTitle,
                subtitle: l10n.importDataDescription,
                color: Colors.green,
                onPressed: _handleImport,
                features: [
                  'Multiple import modes',
                  'Merge or replace data',
                  'Validation checks',
                ],
              ),
            ],
          ],
        ),
        actions: _isProcessing
            ? null
            : [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.closeButton),
                ),
              ],
      ),
    );
  }
}

// ============== PROCESSING INDICATOR ==============

class _ProcessingIndicator extends StatelessWidget {
  final double progress;
  final String status;
  final int currentStep;
  final int totalSteps;

  const _ProcessingIndicator({
    required this.progress,
    required this.status,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep - 1;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCurrent ? 28 : 24,
                    height: isCurrent ? 28 : 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.accentColor
                          : theme.inactiveBackgroundColor
                              .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: theme.accentColor, width: 2)
                          : null,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(FluentIcons.check_mark,
                              size: 12, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isCurrent ? theme.accentColor : Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Container(
                      width: 30,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.accentColor
                            : theme.inactiveBackgroundColor
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),

          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: mt.LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  theme.inactiveBackgroundColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Status text with animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: ProgressRing(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[80],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== ANIMATED RESULT BOX ==============

class _AnimatedResultBox extends StatefulWidget {
  final String message;
  final bool isSuccess;

  const _AnimatedResultBox({
    required this.message,
    required this.isSuccess,
  });

  @override
  State<_AnimatedResultBox> createState() => _AnimatedResultBoxState();
}

class _AnimatedResultBoxState extends State<_AnimatedResultBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? Colors.green : Colors.red;
    final l10n = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isSuccess
                      ? FluentIcons.completed_solid
                      : FluentIcons.error_badge,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isSuccess ? l10n.success : l10n.error,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[80],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== ACTION CARD ==============

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;
  final List<String> features;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
    required this.features,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.08)
                : theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      widget.color.withValues(alpha: _isHovered ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 24,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _isHovered ? widget.color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Feature tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.inactiveBackgroundColor
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[100],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Arrow
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.color.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  FluentIcons.chevron_right,
                  size: 16,
                  color: _isHovered ? widget.color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== REFINED IMPORT MODE DIALOG ==============

class _RefinedImportModeDialog extends StatelessWidget {
  const _RefinedImportModeDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 440),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(FluentIcons.cloud_download, size: 18, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Text(l10n.importOptionsTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.importOptionsQuestion,
            style: TextStyle(fontSize: 12, color: Colors.grey[100]),
          ),
          const SizedBox(height: 20),
          _ImportModeCard(
            icon: FluentIcons.switch_user,
            title: l10n.replaceModeTitle,
            subtitle: l10n.replaceModeDescription,
            mode: ImportMode.replace,
            color: Colors.red,
            badge: l10n.destructive_badge,
          ),
          const SizedBox(height: 10),
          _ImportModeCard(
            icon: FluentIcons.merge,
            title: l10n.mergeModeTitle,
            subtitle: l10n.mergeModeDescription,
            mode: ImportMode.merge,
            color: Colors.orange,
            badge: l10n.recommended_badge,
            isRecommended: true,
          ),
          const SizedBox(height: 10),
          _ImportModeCard(
            icon: FluentIcons.add,
            title: l10n.appendModeTitle,
            subtitle: l10n.appendModeDescription,
            mode: ImportMode.append,
            color: Colors.green,
            badge: l10n.safe_badge,
          ),
        ],
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

class _ImportModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ImportMode mode;
  final Color color;
  final String badge;
  final bool isRecommended;

  const _ImportModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.color,
    required this.badge,
    this.isRecommended = false,
  });

  @override
  State<_ImportModeCard> createState() => _ImportModeCardState();
}

class _ImportModeCardState extends State<_ImportModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pop(context, widget.mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.08)
                : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : (widget.isRecommended
                      ? widget.color.withValues(alpha: 0.3)
                      : theme.inactiveBackgroundColor.withValues(alpha: 0.5)),
              width: widget.isRecommended ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 20, color: widget.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _isHovered ? widget.color : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: widget.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.chevron_right,
                size: 14,
                color: _isHovered ? widget.color : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== REPLACE CONFIRM DIALOG ==============

class _ReplaceConfirmDialog extends StatelessWidget {
  final AppLocalizations l10n;

  const _ReplaceConfirmDialog({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.warning, size: 18, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Text(l10n.warningTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.info, size: 16, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.replaceWarningMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.delete, size: 12, color: Colors.white),
              const SizedBox(width: 6),
              Text(l10n.replaceAllButton),
            ],
          ),
        ),
      ],
    );
  }
}

// ============== SHARE DIALOG ==============

class _ShareDialog extends StatelessWidget {
  final AppLocalizations l10n;

  const _ShareDialog({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.completed_solid,
                size: 18, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Text(l10n.exportComplete),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.share, size: 24, color: Colors.blue),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.shareBackupQuestion,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.noButton),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.share, size: 12, color: Colors.white),
              const SizedBox(width: 6),
              Text(l10n.shareButton),
            ],
          ),
        ),
      ],
    );
  }
}
