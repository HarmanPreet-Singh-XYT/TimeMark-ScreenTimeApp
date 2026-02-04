import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  String _searchQuery = '';
  int? _expandedCategoryIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFaqData(
      List<Map<String, dynamic>> faqData) {
    if (_searchQuery.isEmpty) return faqData;

    return faqData
        .map((category) {
          final filteredFaqs = (category['faqs'] as List).where((faq) {
            final question = (faq['question'] as String).toLowerCase();
            final answer = (faq['answer'] as String).toLowerCase();
            final query = _searchQuery.toLowerCase();
            return question.contains(query) || answer.contains(query);
          }).toList();

          return {
            'category': category['category'],
            'icon': category['icon'],
            'faqs': filteredFaqs,
          };
        })
        .where((category) => (category['faqs'] as List).isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final List<Map<String, dynamic>> faqData = [
      {
        "category": l10n.faqCategoryGeneral,
        "icon": FluentIcons.info,
        "faqs": [
          {"question": l10n.faqGeneralQ1, "answer": l10n.faqGeneralA1},
          {"question": l10n.faqGeneralQ2, "answer": l10n.faqGeneralA2},
          {"question": l10n.faqGeneralQ3, "answer": l10n.faqGeneralA3},
          {"question": l10n.faqGeneralQ4, "answer": l10n.faqGeneralA4},
          {"question": l10n.faqGeneralQ5, "answer": l10n.faqGeneralA5},
          {"question": l10n.faqGeneralQ6, "answer": l10n.faqGeneralA6},
          {"question": l10n.faqGeneralQ7, "answer": l10n.faqGeneralA7},
        ]
      },
      {
        "category": l10n.faqCategoryApplications,
        "icon": FluentIcons.app_icon_default,
        "faqs": [
          {"question": l10n.faqAppsQ1, "answer": l10n.faqAppsA1},
          {"question": l10n.faqAppsQ2, "answer": l10n.faqAppsA2},
          {"question": l10n.faqAppsQ3, "answer": l10n.faqAppsA3},
          {"question": l10n.faqAppsQ4, "answer": l10n.faqAppsA4},
        ]
      },
      {
        "category": l10n.faqCategoryReports,
        "icon": FluentIcons.chart,
        "faqs": [
          {"question": l10n.faqReportsQ1, "answer": l10n.faqReportsA1},
          {"question": l10n.faqReportsQ2, "answer": l10n.faqReportsA2},
          {"question": l10n.faqReportsQ3, "answer": l10n.faqReportsA3},
          {"question": l10n.faqReportsQ4, "answer": l10n.faqReportsA4},
        ]
      },
      {
        "category": l10n.faqCategoryAlerts,
        "icon": FluentIcons.ringer,
        "faqs": [
          {"question": l10n.faqAlertsQ1, "answer": l10n.faqAlertsA1},
          {"question": l10n.faqAlertsQ2, "answer": l10n.faqAlertsA2},
          {"question": l10n.faqAlertsQ3, "answer": l10n.faqAlertsA3},
        ]
      },
      {
        "category": l10n.faqCategoryFocusMode,
        "icon": FluentIcons.focus,
        "faqs": [
          {"question": l10n.faqFocusQ1, "answer": l10n.faqFocusA1},
          {"question": l10n.faqFocusQ2, "answer": l10n.faqFocusA2},
          {"question": l10n.faqFocusQ3, "answer": l10n.faqFocusA3},
          {"question": l10n.faqFocusQ4, "answer": l10n.faqFocusA4},
        ]
      },
      {
        "category": l10n.faqCategorySettings,
        "icon": FluentIcons.settings,
        "faqs": [
          {"question": l10n.faqSettingsQ1, "answer": l10n.faqSettingsA1},
          {"question": l10n.faqSettingsQ2, "answer": l10n.faqSettingsA2},
          {"question": l10n.faqSettingsQ3, "answer": l10n.faqSettingsA3},
          {"question": l10n.faqSettingsQ4, "answer": l10n.faqSettingsA4},
        ]
      },
      {
        "category": l10n.faqCategoryTroubleshooting,
        "icon": FluentIcons.repair,
        "faqs": [
          {"question": l10n.faqTroubleQ1, "answer": l10n.faqTroubleA1},
          {"question": l10n.faqTroubleQ2, "answer": l10n.faqTroubleA2},
        ]
      }
    ];

    final filteredData = _getFilteredFaqData(faqData);
    final totalQuestions =
        faqData.fold<int>(0, (sum, cat) => sum + (cat['faqs'] as List).length);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          // Header Section
          _buildHeader(context, l10n, theme, totalQuestions),

          // Content
          Expanded(
            child: filteredData.isEmpty
                ? _buildEmptyState(context, l10n, theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return _buildCategorySection(
                        context,
                        filteredData[index],
                        index,
                        theme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n,
      FluentThemeData theme, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FluentIcons.help,
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
                      l10n.helpTitle,
                      style: theme.typography.subtitle?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.helpSubtitle(totalQuestions),
                      style: theme.typography.caption?.copyWith(
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          SizedBox(
            height: 36,
            child: TextBox(
              placeholder: l10n.searchForHelp,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  FluentIcons.search,
                  size: 14,
                  color: theme.resources.textFillColorSecondary,
                ),
              ),
              suffix: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(FluentIcons.clear, size: 12),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Quick navigation chips
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 12),
            _buildQuickNavigation(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickNavigation(BuildContext context, FluentThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      (FluentIcons.info, l10n.quickNavGeneral, 0),
      (FluentIcons.app_icon_default, l10n.quickNavApps, 1),
      (FluentIcons.chart, l10n.quickNavReports, 2),
      (FluentIcons.focus, l10n.quickNavFocus, 4),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _expandedCategoryIndex == cat.$3;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: HoverButton(
              onPressed: () {
                setState(() {
                  _expandedCategoryIndex = isSelected ? null : cat.$3;
                });
              },
              builder: (context, states) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.accentColor.withValues(alpha: 0.15)
                        : states.isHovered
                            ? theme.resources.subtleFillColorSecondary
                            : theme.resources.subtleFillColorTransparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.accentColor.withValues(alpha: 0.5)
                          : theme.resources.dividerStrokeColorDefault,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.$1,
                        size: 12,
                        color: isSelected
                            ? theme.accentColor
                            : theme.resources.textFillColorSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.$2,
                        style: theme.typography.caption?.copyWith(
                          color: isSelected
                              ? theme.accentColor
                              : theme.resources.textFillColorPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    Map<String, dynamic> categoryData,
    int categoryIndex,
    FluentThemeData theme,
  ) {
    final isExpanded =
        _expandedCategoryIndex == categoryIndex || _searchQuery.isNotEmpty;
    final faqs = categoryData['faqs'] as List;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          HoverButton(
            onPressed: () {
              setState(() {
                _expandedCategoryIndex = isExpanded ? null : categoryIndex;
              });
            },
            builder: (context, states) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: states.isHovered
                      ? theme.resources.subtleFillColorSecondary
                      : theme.resources.subtleFillColorTransparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        categoryData['icon'] as IconData,
                        size: 14,
                        color: theme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        categoryData['category'] as String,
                        style: theme.typography.bodyStrong,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.resources.subtleFillColorSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${faqs.length}',
                        style: theme.typography.caption?.copyWith(
                          color: theme.resources.textFillColorSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        FluentIcons.chevron_down,
                        size: 12,
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // FAQ Items
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: FAQItem(
                      question: entry.value['question'] as String,
                      answer: entry.value['answer'] as String,
                      searchQuery: _searchQuery,
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.search,
            size: 48,
            color: theme.resources.textFillColorDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: theme.typography.bodyLarge?.copyWith(
              color: theme.resources.textFillColorSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tryDifferentKeywords,
            style: theme.typography.caption?.copyWith(
              color: theme.resources.textFillColorDisabled,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => setState(() => _searchQuery = ''),
            child: Text(l10n.clearSearch),
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final String searchQuery;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    this.searchQuery = '',
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return HoverButton(
      onPressed: () => setState(() => _isExpanded = !_isExpanded),
      builder: (context, states) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isExpanded
                ? theme.resources.subtleFillColorSecondary
                : states.isHovered
                    ? theme.resources.subtleFillColorSecondary
                        .withValues(alpha: 0.5)
                    : theme.resources.subtleFillColorTransparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isExpanded
                  ? theme.resources.dividerStrokeColorDefault
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.status_circle_question_mark,
                      size: 14,
                      color: theme.accentColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHighlightedText(
                        widget.question,
                        widget.searchQuery,
                        theme.typography.body?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        theme,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        FluentIcons.chevron_down,
                        size: 10,
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Answer
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(36, 0, 12, 12),
                  child: _buildHighlightedText(
                    widget.answer,
                    widget.searchQuery,
                    theme.typography.body?.copyWith(
                      color: theme.resources.textFillColorSecondary,
                      height: 1.5,
                    ),
                    theme,
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle? baseStyle,
    FluentThemeData theme,
  ) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        matches.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }

      matches.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: theme.accentColor.withValues(alpha: 0.3),
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: matches,
      ),
    );
  }
}
