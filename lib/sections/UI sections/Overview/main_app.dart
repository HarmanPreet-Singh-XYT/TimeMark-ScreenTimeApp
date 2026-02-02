import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart';

class TopApplicationsList extends StatelessWidget {
  final List<dynamic> data;

  const TopApplicationsList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final filteredData = data
        .where((app) =>
            app['name'] != null &&
            app['name'].toString().trim().isNotEmpty &&
            app['isVisible'] == true)
        .toList()
      ..sort((a, b) => (b['percentageOfTotalTime'] ?? 0)
          .compareTo(a['percentageOfTotalTime'] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.app_icon_default_list,
                  size: 14,
                  color: Color(0xff3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.topApplications,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredData.length} apps',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.inactiveColor,
                ),
              ),
            ],
          ),
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: const EdgeInsets.symmetric(horizontal: 16),
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? EmptyState(
                  icon: FluentIcons.app_icon_default,
                  message: l10n.noApplicationDataAvailable,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredData.take(20).length,
                  itemBuilder: (context, index) {
                    final app = filteredData[index];
                    return _ApplicationItem(
                      name: app['name'] ?? l10n.unknownApp,
                      category: app['category'] ?? l10n.uncategorized,
                      screenTime: app['screenTime'] ?? l10n.defaultTime,
                      percentage:
                          (app['percentageOfTotalTime'] ?? 0).toDouble(),
                      color: const Color(0xff3B82F6),
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CategoryBreakdownList extends StatelessWidget {
  final List<dynamic> data;

  const CategoryBreakdownList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final filteredData = data
        .where((cat) =>
            cat['name'] != null && cat['name'].toString().trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.category_classification,
                  size: 14,
                  color: Color(0xff22C55E),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.categoryBreakdown,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredData.length} categories',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.inactiveColor,
                ),
              ),
            ],
          ),
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: const EdgeInsets.symmetric(horizontal: 16),
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? EmptyState(
                  icon: FluentIcons.category_classification,
                  message: l10n.noCategoryDataAvailable,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final category = filteredData[index];
                    return _CategoryItem(
                      name: category['name'] ?? l10n.uncategorized,
                      screenTime:
                          category['totalScreenTime'] ?? l10n.defaultTime,
                      percentage:
                          (category['percentageOfTotalTime'] ?? 0).toDouble(),
                      color: _getCategoryColor(index),
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xff22C55E),
      const Color(0xff3B82F6),
      const Color(0xffA855F7),
      const Color(0xffF97316),
      const Color(0xffEF4444),
      const Color(0xff06B6D4),
    ];
    return colors[index % colors.length];
  }
}

class _ApplicationItem extends StatefulWidget {
  final String name;
  final String category;
  final String screenTime;
  final double percentage;
  final Color color;
  final int index;

  const _ApplicationItem({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentage,
    required this.color,
    required this.index,
  });

  @override
  State<_ApplicationItem> createState() => _ApplicationItemState();
}

class _ApplicationItemState extends State<_ApplicationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Container(
            //   width: 36,
            //   height: 36,
            //   decoration: BoxDecoration(
            //     color: widget.color.withValues(alpha:0.12),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Center(
            //     child: Text(
            //       widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
            //       style: TextStyle(
            //         color: widget.color,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.inactiveColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearPercentIndicator(
                      animation: true,
                      animationDuration: 800 + (widget.index * 100),
                      lineHeight: 6,
                      percent: (widget.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: widget.color.withValues(alpha: 0.12),
                      progressColor: widget.color,
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.screenTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.typography.body?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String name;
  final String screenTime;
  final double percentage;
  final Color color;
  final int index;

  const _CategoryItem({
    required this.name,
    required this.screenTime,
    required this.percentage,
    required this.color,
    required this.index,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.inactiveColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearPercentIndicator(
                      animation: true,
                      animationDuration: 800 + (widget.index * 150),
                      lineHeight: 8,
                      percent: (widget.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: widget.color.withValues(alpha: 0.12),
                      progressColor: widget.color,
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.screenTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.typography.body?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
