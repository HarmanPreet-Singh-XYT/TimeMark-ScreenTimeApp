import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;
import './approw.dart';

// Application Limits Card
class ApplicationLimitsCard extends StatelessWidget {
  final List<AppUsageSummary> appSummaries;
  final ScreenTimeDataController controller;
  final VoidCallback onDataChanged;

  const ApplicationLimitsCard({
    super.key,
    required this.appSummaries,
    required this.controller,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredApps =
        appSummaries.where((app) => app.appName.trim().isNotEmpty).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return rub.Card(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(FluentIcons.app_icon_default,
                          size: 18, color: theme.accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.applicationLimits,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${filteredApps.length} applications tracked',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.typography.caption?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.add, size: 12),
                          const SizedBox(width: 6),
                          Text(l10n.addLimit),
                        ],
                      ),
                      onPressed: () => _showAddLimitDialog(context),
                    ),
                  ],
                ),
              ),

              // Table header - FIXED column spacing
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.03),
                  border: Border(
                    top: BorderSide(
                        color: theme.inactiveBackgroundColor
                            .withValues(alpha: 0.5)),
                    bottom: BorderSide(
                        color: theme.inactiveBackgroundColor
                            .withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Application', style: _headerStyle),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Category', style: _headerStyle),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Daily Limit', style: _headerStyle),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Current Usage', style: _headerStyle),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      child: Text('Edit',
                          style: _headerStyle, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),

              // App list
              if (filteredApps.isEmpty)
                Container(
                  height: 300, // Fixed height for empty state
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.app_icon_default,
                          size: 48,
                          color: theme.inactiveColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noApplicationsToDisplay,
                          style: TextStyle(color: theme.inactiveColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredApps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final app = entry.value;
                  return AppRow(
                    app: app,
                    onEdit: () => _showEditLimitDialog(context, app),
                    isLast: index == filteredApps.length - 1,
                  );
                }),

              // Bottom padding
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
  );

  void _showAddLimitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    String? selectedApp;
    double hours = 1.0;
    double minutes = 0.0;
    bool limitEnabled = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final totalMinutes = (hours * 60 + minutes).round();
          final formattedTime = _formatDuration(hours.round(), minutes.round());

          return ContentDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.add,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.addApplicationLimit,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(l10n.selectApplication),
                  const SizedBox(height: 8),
                  ComboBox<String>(
                    placeholder: Text(
                      l10n.selectApplicationPlaceholder,
                      style: TextStyle(
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                    isExpanded: true,
                    items: appSummaries
                        .where((app) => app.appName.trim().isNotEmpty)
                        .map((app) => ComboBoxItem<String>(
                              value: app.appName,
                              child: Text(
                                app.appName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: selectedApp,
                    onChanged: (value) => setState(() => selectedApp = value),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildToggleRow(
                    context: context,
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (value) => setState(() => limitEnabled = value),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: limitEnabled ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !limitEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n.dailyLimit),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          rub.SliderRow(
                            label: l10n.hours,
                            value: hours,
                            max: 12,
                            divisions: 12,
                            onChanged: (v) => setState(() => hours = v),
                          ),
                          const SizedBox(height: 12),
                          rub.SliderRow(
                            label: l10n.minutes,
                            value: minutes,
                            max: 55,
                            divisions: 11,
                            step: 5,
                            onChanged: (v) => setState(() => minutes = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                onPressed: selectedApp != null && totalMinutes > 0
                    ? () {
                        final duration = Duration(
                          hours: hours.round(),
                          minutes: (minutes.round() ~/ 5 * 5),
                        );
                        controller.updateAppLimit(
                            selectedApp!, duration, limitEnabled);
                        onDataChanged();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLimitDialog(BuildContext context, AppUsageSummary app) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    double hours = app.dailyLimit.inHours.toDouble();
    double minutes = (app.dailyLimit.inMinutes % 60).toDouble();
    bool limitEnabled = app.limitStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final formattedTime = _formatDuration(hours.round(), minutes.round());

          return ContentDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.edit,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.editLimitTitle(app.appName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleRow(
                    context: context,
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (value) => setState(() => limitEnabled = value),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: limitEnabled ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !limitEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n.dailyLimit),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          rub.SliderRow(
                            label: l10n.hours,
                            value: hours,
                            max: 12,
                            divisions: 12,
                            onChanged: (v) => setState(() => hours = v),
                          ),
                          const SizedBox(height: 12),
                          rub.SliderRow(
                            label: l10n.minutes,
                            value: minutes,
                            max: 55,
                            divisions: 11,
                            step: 5,
                            onChanged: (v) => setState(() => minutes = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: Text(l10n.save),
                onPressed: () {
                  final duration = Duration(
                    hours: hours.round(),
                    minutes: (minutes.round() ~/ 5 * 5),
                  );
                  controller.updateAppLimit(
                      app.appName, duration, limitEnabled);
                  onDataChanged();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper Widgets

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.resources.dividerStrokeColorDefault,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          ToggleSwitch(
            checked: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int hours, int minutes) {
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    }
    return '0m';
  }
}
