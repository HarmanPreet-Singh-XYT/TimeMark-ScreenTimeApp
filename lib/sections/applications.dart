import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'controller/settings_data_controller.dart';
import './controller/data_controllers/applications_data_controller.dart';
import './controller/categories_controller.dart';
import 'dart:async';
import 'package:screentime/l10n/app_localizations.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications>
    with SingleTickerProviderStateMixin {
  SettingsManager settingsManager = SettingsManager();
  bool isTracking = false;
  bool isHidden = false;
  List<dynamic> apps = [];
  String selectedCategory = "All";
  String searchValue = '';
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    isTracking = settingsManager.getSetting("applications.tracking");
    isHidden = settingsManager.getSetting("applications.isHidden");
    selectedCategory =
        settingsManager.getSetting("applications.selectedCategory");
    // Register this screen's refresh callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationState.registerRefreshCallback(_loadData);
    });
    _loadData();
  }

  bool _isLoading = true;

  Future<void> _loadData() async {
    try {
      final appDataProvider = ApplicationsDataProvider();
      final List<ApplicationBasicDetail> allApps =
          await appDataProvider.fetchAllApplications();

      setState(() {
        apps = allApps
            .map((app) => {
                  "name": app.name,
                  "category": app.category,
                  "screenTime": app.formattedScreenTime,
                  "isTracking": app.isTracking,
                  "isHidden": app.isHidden,
                  "isProductive": app.isProductive,
                  "dailyLimit": app.dailyLimit,
                  "limitStatus": app.limitStatus
                })
            .toList();

        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint('Error loading overview data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    _animationController.reset();
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  void changeSearchValue(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (searchValue != value) {
        setState(() {
          searchValue = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    void setSetting(String key, dynamic value) {
      switch (key) {
        case 'tracking':
          setState(() {
            isTracking = value;
            settingsManager.updateSetting("applications.tracking", value);
          });
          break;
        case 'isHidden':
          setState(() {
            isHidden = value;
            settingsManager.updateSetting("applications.isHidden", value);
          });
          break;
      }
    }

    void changeCategory(String category) {
      setState(() {
        selectedCategory = category;
        settingsManager.updateSetting(
            "applications.selectedCategory", category);
      });
    }

    void changeIndividualParam(String type, bool value, String name) async {
      switch (type) {
        case 'isTracking':
          apps = apps
              .map((app) =>
                  app['name'] == name ? {...app, "isTracking": value} : app)
              .toList();
          await AppDataStore().updateAppMetadata(name, isTracking: value);
          setState(() {});
          break;
        case 'isHidden':
          apps = apps
              .map((app) =>
                  app['name'] == name ? {...app, "isHidden": value} : app)
              .toList();
          await AppDataStore().updateAppMetadata(name, isVisible: !value);
          setState(() {});
          break;
      }
    }

    final filteredApps = apps
        .where((app) =>
            (app["isTracking"] == isTracking && app["isHidden"] == isHidden) &&
            app["screenTime"] != "0s" &&
            app['name'] != '' &&
            (selectedCategory == "All" ||
                selectedCategory.contains(app["category"])) &&
            (searchValue.isEmpty ||
                app["name"].toLowerCase().contains(searchValue.toLowerCase())))
        .toList();

    if (_isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ProgressRing(),
              const SizedBox(height: 16),
              Text(l10n.applicationsTitle, style: theme.typography.body),
            ],
          ),
        ),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _Header(
                changeSearchValue: changeSearchValue,
                onRefresh: refreshData,
              ),
              const SizedBox(height: 20),

              // Filter Bar
              _FilterBar(
                isTracking: isTracking,
                isHidden: isHidden,
                selectedCategory: selectedCategory,
                onTrackingChanged: (v) => setSetting('tracking', v),
                onHiddenChanged: (v) => setSetting('isHidden', v),
                onCategoryChanged: changeCategory,
              ),
              const SizedBox(height: 16),

              // Results count
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.applicationCount(filteredApps.length),
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Data Table
              Expanded(
                child: _DataTable(
                  apps: filteredApps,
                  changeIndividualParam: changeIndividualParam,
                  refreshData: refreshData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final void Function(String value) changeSearchValue;
  final VoidCallback onRefresh;

  const _Header({
    required this.changeSearchValue,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.accentColor.withValues(alpha: 0.2),
                    theme.accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FluentIcons.app_icon_default,
                size: 24,
                color: theme.accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.applicationsTitle,
                  style: theme.typography.subtitle?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.applicationsSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Search Box
            Container(
              width: 260,
              height: 36,
              decoration: BoxDecoration(
                color: theme.micaBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.inactiveBackgroundColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    FluentIcons.search,
                    size: 14,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextBox(
                      placeholder: l10n.searchApplication,
                      onChanged: changeSearchValue,
                      decoration: WidgetStateProperty.all(
                        const BoxDecoration(
                          border: Border(),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Refresh Button
            Tooltip(
              message: l10n.refresh,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.micaBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.inactiveBackgroundColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FluentIcons.refresh,
                    size: 14,
                    color: theme.typography.body?.color,
                  ),
                ),
                onPressed: onRefresh,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final bool isTracking;
  final bool isHidden;
  final String selectedCategory;
  final ValueChanged<bool> onTrackingChanged;
  final ValueChanged<bool> onHiddenChanged;
  final ValueChanged<String> onCategoryChanged;

  const _FilterBar({
    required this.isTracking,
    required this.isHidden,
    required this.selectedCategory,
    required this.onTrackingChanged,
    required this.onHiddenChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _FilterChip(
                icon: FluentIcons.checkbox_composite,
                label: l10n.tracking,
                isActive: isTracking,
                onChanged: onTrackingChanged,
                activeColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 24),
              _FilterChip(
                icon: FluentIcons.hide3,
                label: l10n.hiddenVisible,
                isActive: isHidden,
                onChanged: onHiddenChanged,
                activeColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          _CategoryDropdown(
            selectedCategory: selectedCategory,
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.isActive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.activeColor.withValues(alpha: 0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? widget.activeColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.activeColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  widget.icon,
                  size: 12,
                  color: widget.isActive
                      ? widget.activeColor
                      : theme.typography.body?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isActive
                      ? widget.activeColor
                      : theme.typography.body?.color,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.activeColor
                      : theme.inactiveBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: widget.isActive
                    ? const Icon(FluentIcons.check_mark,
                        size: 10, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropDownButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FluentIcons.filter,
              size: 12,
              color: theme.accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              selectedCategory == 'All' ? l10n.allCategories : selectedCategory,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        items: [
          MenuFlyoutItem(
            leading: const Icon(FluentIcons.globe, size: 14),
            text: Text(l10n.allCategories),
            onPressed: () => onChanged('All'),
          ),
          const MenuFlyoutSeparator(),
          ...AppCategories.categories.map((category) => MenuFlyoutItem(
                text: Text(category.name),
                onPressed: () => onChanged(category.name),
              )),
        ],
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  final List<dynamic> apps;
  final void Function(String type, bool value, String name)
      changeIndividualParam;
  final Future<void> Function() refreshData;

  const _DataTable({
    required this.apps,
    required this.changeIndividualParam,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.app_icon_default,
              size: 48,
              color: theme.inactiveBackgroundColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noApplicationsFound,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.typography.body?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryAdjustingFilters,
              style: TextStyle(
                fontSize: 13,
                color: theme.typography.caption?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _TableHeader(label: l10n.tableName, flex: 3),
                  _TableHeader(label: l10n.tableCategory, flex: 2),
                  _TableHeader(
                      label: l10n.tableScreenTime, flex: 2, centered: true),
                  _TableHeader(
                      label: l10n.tableTracking, flex: 1, centered: true),
                  _TableHeader(
                      label: l10n.tableHidden, flex: 1, centered: true),
                  _TableHeader(label: l10n.tableEdit, flex: 1, centered: true),
                ],
              ),
            ),
            // Table Body
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return _ApplicationRow(
                    name: app["name"],
                    category: app["category"],
                    screenTime: app["screenTime"],
                    tracking: app["isTracking"],
                    isHidden: app["isHidden"],
                    isProductive: app["isProductive"] ?? false,
                    dailyLimit: app["dailyLimit"] ?? const Duration(),
                    limitStatus: app["limitStatus"] ?? false,
                    changeIndividualParam: changeIndividualParam,
                    refreshData: refreshData,
                    isLast: index == apps.length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;
  final bool centered;

  const _TableHeader({
    required this.label,
    required this.flex,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Expanded(
      flex: flex,
      child: Container(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.typography.body?.color?.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _ApplicationRow extends StatefulWidget {
  final String name;
  final String category;
  final String screenTime;
  final bool tracking;
  final bool isHidden;
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;
  final void Function(String type, bool value, String name)
      changeIndividualParam;
  final Future<void> Function() refreshData;
  final bool isLast;

  const _ApplicationRow({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.tracking,
    required this.isHidden,
    required this.isProductive,
    required this.dailyLimit,
    required this.limitStatus,
    required this.changeIndividualParam,
    required this.refreshData,
    required this.isLast,
  });

  @override
  State<_ApplicationRow> createState() => _ApplicationRowState();
}

class _ApplicationRowState extends State<_ApplicationRow> {
  bool _isHovered = false;

  void _showEditDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    String selectedCategory = widget.category;
    bool isProductiveValue = widget.isProductive;
    bool isTrackingValue = widget.tracking;
    bool isVisibleValue = !widget.isHidden;
    bool limitStatusValue = widget.limitStatus;
    int limitHours = widget.dailyLimit.inHours;
    int limitMinutes = widget.dailyLimit.inMinutes.remainder(60);
    bool isCustomCategory =
        !AppCategories.categories.any((c) => c.name == selectedCategory);
    final customCategoryController = TextEditingController(
      text: isCustomCategory ? selectedCategory : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 480),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FluentIcons.edit,
                  size: 20,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.editAppTitle(widget.name),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.configureAppSettings,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: theme.typography.caption?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Section
                    _DialogSection(
                      icon: FluentIcons.tag,
                      title: l10n.categorySection,
                      iconColor: const Color(0xFF3B82F6),
                      child: Column(
                        children: [
                          ComboBox<String>(
                            value: isCustomCategory
                                ? l10n.customCategory
                                : selectedCategory,
                            isExpanded: true,
                            items: [
                              ...AppCategories.categories
                                  .map((category) => ComboBoxItem<String>(
                                        value: category.name,
                                        child: Text(category.name),
                                      )),
                              ComboBoxItem<String>(
                                value: l10n.customCategory,
                                child: Text(l10n.customCategory),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  if (value == l10n.customCategory) {
                                    isCustomCategory = true;
                                  } else {
                                    isCustomCategory = false;
                                    selectedCategory = value;
                                  }
                                });
                              }
                            },
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: isCustomCategory
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextBox(
                                      controller: customCategoryController,
                                      placeholder:
                                          l10n.customCategoryPlaceholder,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategory = value;
                                        });
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Behavior Section
                    _DialogSection(
                      icon: FluentIcons.settings,
                      title: l10n.behaviorSection,
                      iconColor: const Color(0xFF10B981),
                      child: Column(
                        children: [
                          _DialogToggle(
                            icon: FluentIcons.chart,
                            label: l10n.isProductive,
                            value: isProductiveValue,
                            onChanged: (v) =>
                                setState(() => isProductiveValue = v),
                            activeColor: const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 8),
                          _DialogToggle(
                            icon: FluentIcons.timer,
                            label: l10n.trackUsage,
                            value: isTrackingValue,
                            onChanged: (v) =>
                                setState(() => isTrackingValue = v),
                            activeColor: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(height: 8),
                          _DialogToggle(
                            icon: FluentIcons.view,
                            label: l10n.visibleInReports,
                            value: isVisibleValue,
                            onChanged: (v) =>
                                setState(() => isVisibleValue = v),
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Limits Section
                    _DialogSection(
                      icon: FluentIcons.clock,
                      title: l10n.timeLimitsSection,
                      iconColor: const Color(0xFFF59E0B),
                      child: Column(
                        children: [
                          _DialogToggle(
                            icon: FluentIcons.stopwatch,
                            label: l10n.enableDailyLimit,
                            value: limitStatusValue,
                            onChanged: (v) =>
                                setState(() => limitStatusValue = v),
                            activeColor: const Color(0xFFF59E0B),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: limitStatusValue
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _TimeInputField(
                                              label: l10n.hours,
                                              value: limitHours,
                                              max: 24,
                                              onChanged: (v) => setState(() =>
                                                  limitHours = v?.toInt() ?? 0),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _TimeInputField(
                                              label: l10n.minutes,
                                              value: limitMinutes,
                                              max: 59,
                                              onChanged: (v) => setState(() =>
                                                  limitMinutes =
                                                      v?.toInt() ?? 0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            Button(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(l10n.cancel),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.save, size: 14),
                    const SizedBox(width: 8),
                    Text(l10n.saveChanges),
                  ],
                ),
              ),
              onPressed: () async {
                final finalCategory = isCustomCategory
                    ? customCategoryController.text.isNotEmpty
                        ? customCategoryController.text
                        : l10n.uncategorized
                    : selectedCategory;

                final newDailyLimit = Duration(
                  hours: limitHours,
                  minutes: limitMinutes,
                );

                await AppDataStore().updateAppMetadata(
                  widget.name,
                  category: finalCategory,
                  isProductive: isProductiveValue,
                  isTracking: isTrackingValue,
                  isVisible: isVisibleValue,
                  dailyLimit: newDailyLimit,
                  limitStatus: limitStatusValue,
                );

                await widget.refreshData();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  // Container(
                  //   width: 32,
                  //   height: 32,
                  //   decoration: BoxDecoration(
                  //     color: theme.accentColor.withValues(alpha:0.1),
                  //     borderRadius: BorderRadius.circular(6),
                  //   ),
                  //   child: Center(
                  //     child: Text(
                  //       widget.name.isNotEmpty
                  //           ? widget.name[0].toUpperCase()
                  //           : '?',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600,
                  //         color: theme.accentColor,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Category
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.typography.body?.color?.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Screen Time
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.screenTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
                ),
              ),
            ),

            // Tracking Toggle
            Expanded(
              flex: 1,
              child: Center(
                child: _CompactToggle(
                  value: widget.tracking,
                  onChanged: (v) => widget.changeIndividualParam(
                      'isTracking', v, widget.name),
                  activeColor: const Color(0xFF10B981),
                ),
              ),
            ),

            // Hidden Toggle
            Expanded(
              flex: 1,
              child: Center(
                child: _CompactToggle(
                  value: widget.isHidden,
                  onChanged: (v) =>
                      widget.changeIndividualParam('isHidden', v, widget.name),
                  activeColor: const Color(0xFF8B5CF6),
                ),
              ),
            ),

            // Edit Button
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? theme.accentColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      FluentIcons.edit,
                      size: 14,
                      color: _isHovered
                          ? theme.accentColor
                          : theme.typography.body?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _CompactToggle({
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          color: value
              ? activeColor
              : FluentTheme.of(context).inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;

  const _DialogSection({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.body?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DialogToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _DialogToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.08)
            : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: value
                    ? activeColor
                    : theme.typography.body?.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: value ? activeColor : theme.typography.body?.color,
                ),
              ),
            ],
          ),
          _CompactToggle(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _TimeInputField extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Function(num?) onChanged;

  const _TimeInputField({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(height: 6),
        NumberBox(
          value: value,
          min: 0,
          max: max,
          mode: SpinButtonPlacementMode.inline,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
