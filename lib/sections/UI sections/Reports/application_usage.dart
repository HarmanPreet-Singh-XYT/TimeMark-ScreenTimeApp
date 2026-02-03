import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../controller/data_controllers/reports_controller.dart';
import './appdetails.dialog.dart';

class ApplicationUsage extends StatefulWidget {
  final List<AppUsageSummary> appUsageDetails;

  const ApplicationUsage({
    super.key,
    required this.appUsageDetails,
  });

  @override
  State<ApplicationUsage> createState() => _ApplicationUsageState();
}

class _ApplicationUsageState extends State<ApplicationUsage> {
  late List<AppUsageSummary> _filteredAppUsageDetails;
  String _searchQuery = '';
  String _sortBy = 'Usage';
  bool _sortAscending = false;
  int? _hoveredIndex;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredAppUsageDetails = List.from(widget.appUsageDetails);
    _sortAppList();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ApplicationUsage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appUsageDetails != widget.appUsageDetails) {
      _filteredAppUsageDetails = List.from(widget.appUsageDetails);
      _filterAndSortAppList();
    }
  }

  void _filterAndSortAppList() {
    setState(() {
      _filteredAppUsageDetails = widget.appUsageDetails
          .where((app) =>
              app.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      _sortAppList();
    });
  }

  void _sortAppList() {
    switch (_sortBy) {
      case 'Name':
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.appName.compareTo(b.appName)
            : b.appName.compareTo(a.appName));
        break;
      case 'Category':
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category));
        break;
      case 'Usage':
      default:
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.totalTime.compareTo(b.totalTime)
            : b.totalTime.compareTo(a.totalTime));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredApps = _filteredAppUsageDetails
        .where((app) => app.appName.trim().isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.resources.dividerStrokeColorDefault,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, l10n, theme),

              // Toolbar
              _buildToolbar(context, l10n, theme),

              // Column Headers
              _buildColumnHeaders(context, l10n, theme),

              // List
              Expanded(
                child: filteredApps.isEmpty
                    ? _buildEmptyState(context, l10n, theme)
                    : _buildAppList(context, filteredApps, theme),
              ),

              // Footer Stats
              _buildFooterStats(context, l10n, theme, filteredApps),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FluentIcons.app_icon_default_list,
            size: 20,
            color: theme.accentColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.detailedApplicationUsage,
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _buildQuickStats(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final totalApps = _filteredAppUsageDetails.length;
    final productiveApps =
        _filteredAppUsageDetails.where((a) => a.isProductive).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniStat(
          context,
          '$totalApps',
          "l10n.apps",
          FluentIcons.grid_view_medium,
          theme.accentColor,
        ),
        const SizedBox(width: 16),
        _buildMiniStat(
          context,
          '$productiveApps',
          l10n.productive,
          FluentIcons.check_mark,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String label,
      IconData icon, Color color) {
    final theme = FluentTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.typography.caption?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: theme.typography.caption?.copyWith(
                fontSize: 10,
                color: theme.inactiveColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 200,
            height: 32,
            child: TextBox(
              focusNode: _searchFocusNode,
              placeholder: l10n.searchApplications,
              style: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterAndSortAppList();
                });
              },
              prefix: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(FluentIcons.search,
                    size: 14, color: theme.inactiveColor),
              ),
              suffix: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(FluentIcons.clear,
                          size: 12, color: theme.inactiveColor),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _filterAndSortAppList();
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Sort Pills
          Expanded(
            child: _buildSortPills(context, l10n, theme),
          ),

          const SizedBox(width: 8),

          // Sort Direction
          Tooltip(
            message:
                _sortAscending ? "l10n.sortAscending" : "l10n.sortDescending",
            child: ToggleButton(
              checked: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                  _sortAppList();
                });
              },
              child: Icon(
                _sortAscending ? FluentIcons.sort_up : FluentIcons.sort_down,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortPills(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final sortOptions = [
      ('Usage', l10n.sortByUsage, FluentIcons.timer),
      ('Name', l10n.sortByName, FluentIcons.text_field),
      ('Category', l10n.sortByCategory, FluentIcons.tag),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: sortOptions.map((option) {
          final isSelected = _sortBy == option.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ToggleButton(
              checked: isSelected,
              onChanged: (value) {
                if (value) {
                  setState(() {
                    _sortBy = option.$1;
                    _sortAppList();
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.$3, size: 12),
                  const SizedBox(width: 4),
                  Text(option.$2, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnHeaders(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell(l10n.nameHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.categoryHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.totalTimeHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.productivityHeader, theme)),
          const SizedBox(
              width: 50, child: Center(child: Text(''))), // Actions column
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, FluentThemeData theme) {
    return Text(
      text,
      style: theme.typography.caption?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.inactiveColor,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAppList(
      BuildContext context, List<AppUsageSummary> apps, FluentThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isHovered = _hoveredIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? theme.accentColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isHovered
                  ? Border.all(color: theme.accentColor.withValues(alpha: 0.2))
                  : Border.all(color: Colors.transparent),
            ),
            child: _buildAppListItem(context, app, isHovered, theme),
          ),
        );
      },
    );
  }

  Widget _buildAppListItem(BuildContext context, AppUsageSummary app,
      bool isHovered, FluentThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return HoverButton(
      onPressed: () => _showAppDetails(context, app),
      builder: (context, states) {
        return Container(
          color: states.isHovered
              ? theme.accentColor.withValues(alpha: 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              // App Name with Icon
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: app.isProductive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        FluentIcons.app_icon_default,
                        size: 14,
                        color: app.isProductive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        app.appName,
                        style: theme.typography.body?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Category
              Expanded(
                flex: 2,
                child: _buildCategoryChip(app.category, theme),
              ),
              // Total Time
              Expanded(
                flex: 2,
                child: _buildTimeDisplay(app.totalTime, theme),
              ),
              // Productivity
              Expanded(
                flex: 2,
                child: _buildProductivityBadge(app.isProductive, l10n, theme),
              ),
              // Actions
              SizedBox(
                width: 50,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: states.isHovered ? 1.0 : 0.5,
                    child: Icon(
                      FluentIcons.info,
                      size: 14,
                      color: theme.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category, FluentThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Text(
          category,
          style: theme.typography.caption?.copyWith(fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(Duration duration, FluentThemeData theme) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hours > 0) ...[
          Text(
            '$hours',
            style: theme.typography.body?.copyWith(
              fontWeight: FontWeight.bold,
              color: hours > 2 ? Colors.orange : null,
            ),
          ),
          Text(
            'h ',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
        ],
        Text(
          '$minutes',
          style: theme.typography.body?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'm',
          style: theme.typography.caption?.copyWith(
            color: theme.inactiveColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductivityBadge(
      bool isProductive, AppLocalizations l10n, FluentThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isProductive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isProductive ? FluentIcons.check_mark : FluentIcons.cancel,
              size: 10,
              color: isProductive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isProductive ? l10n.productive : l10n.nonProductive,
                style: TextStyle(
                  fontSize: 11,
                  color: isProductive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.search,
            size: 40,
            color: theme.inactiveColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noApplicationsMatch,
            style: theme.typography.body?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Button(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterAndSortAppList();
                });
              },
              child: Text("l10n.clearSearch"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterStats(BuildContext context, AppLocalizations l10n,
      FluentThemeData theme, List<AppUsageSummary> apps) {
    final totalTime = apps.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.totalTime,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${apps.length} ${"l10n.applicationsShowing"}',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          const Spacer(),
          Text(
            '${"l10n.totalTime"}: ',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          Text(
            _formatDuration(totalTime),
            style: theme.typography.caption?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== APP DETAILS DIALOG ====================

  void _showAppDetails(BuildContext context, AppUsageSummary app) async {
    // Fetch your data here (keeping your existing logic)
    // For now showing improved dialog

    if (!context.mounted) return;

    showAppDetailsDialog(context, app);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return "${hours}h ${minutes}m";
    return "${minutes}m";
  }
}
