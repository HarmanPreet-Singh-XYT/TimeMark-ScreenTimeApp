// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appWindowTitle => 'TimeMark - Track Screen Time & App Usage';

  @override
  String get appName => 'TimeMark';

  @override
  String get appTitle => 'Productive ScreenTime';

  @override
  String get sidebarTitle => 'ScreenTime';

  @override
  String get sidebarSubtitle => 'Open Source';

  @override
  String get trayShowWindow => 'Show Window';

  @override
  String get trayStartFocusMode => 'Start Focus Mode';

  @override
  String get trayStopFocusMode => 'Stop Focus Mode';

  @override
  String get trayReports => 'Reports';

  @override
  String get trayAlertsLimits => 'Alerts & Limits';

  @override
  String get trayApplications => 'Applications';

  @override
  String get trayDisableNotifications => 'Disable Notifications';

  @override
  String get trayEnableNotifications => 'Enable Notifications';

  @override
  String get trayVersionPrefix => 'Version: ';

  @override
  String trayVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get trayExit => 'Exit';

  @override
  String get navOverview => 'Overview';

  @override
  String get navApplications => 'Applications';

  @override
  String get navAlertsLimits => 'Alerts & Limits';

  @override
  String get navReports => 'Reports';

  @override
  String get navFocusMode => 'Focus Mode';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

  @override
  String get helpTitle => 'Help';

  @override
  String get faqCategoryGeneral => 'General Questions';

  @override
  String get faqCategoryApplications => 'Applications Management';

  @override
  String get faqCategoryReports => 'Usage Analytics & Reports';

  @override
  String get faqCategoryAlerts => 'Alerts & Limits';

  @override
  String get faqCategoryFocusMode => 'Focus Mode & Pomodoro Timer';

  @override
  String get faqCategorySettings => 'Settings & Customization';

  @override
  String get faqCategoryTroubleshooting => 'Troubleshooting';

  @override
  String get faqGeneralQ1 => 'How does this app track screen time?';

  @override
  String get faqGeneralA1 =>
      'The app monitors your device\'s usage in real-time, tracking the time spent on different applications. It provides comprehensive insights into your digital habits, including total screen time, productive time, and application-specific usage.';

  @override
  String get faqGeneralQ2 => 'What makes an app \'Productive\'?';

  @override
  String get faqGeneralA2 =>
      'You can manually mark apps as productive in the \'Applications\' section. Productive apps contribute to your Productive Score, which calculates the percentage of screen time spent on work-related or beneficial applications.';

  @override
  String get faqGeneralQ3 => 'How accurate is the screen time tracking?';

  @override
  String get faqGeneralA3 =>
      'The app uses system-level tracking to provide precise measurement of your device usage. It captures foreground time for each application with minimal battery impact.';

  @override
  String get faqGeneralQ4 => 'Can I customize my app categorization?';

  @override
  String get faqGeneralA4 =>
      'Absolutely! You can create custom categories, assign apps to specific categories, and easily modify these assignments in the \'Applications\' section. This helps in creating more meaningful usage analytics.';

  @override
  String get faqGeneralQ5 => 'What insights can I gain from this app?';

  @override
  String get faqGeneralA5 =>
      'The app offers comprehensive insights including Productive Score, usage patterns by time of day, detailed application usage, focus session tracking, and visual analytics like graphs and pie charts to help you understand and improve your digital habits.';

  @override
  String get faqAppsQ1 => 'How do I hide specific apps from tracking?';

  @override
  String get faqAppsA1 =>
      'In the \'Applications\' section, you can toggle the visibility of apps.';

  @override
  String get faqAppsQ2 => 'Can I search and filter my applications?';

  @override
  String get faqAppsA2 =>
      'Yes, the Applications section includes a search functionality and filtering options. You can filter apps by category, productivity status, tracking status, and visibility.';

  @override
  String get faqAppsQ3 =>
      'What editing options are available for applications?';

  @override
  String get faqAppsA3 =>
      'For each application, you can edit: category assignment, productivity status, tracking usage, visibility in reports, and set individual daily time limits.';

  @override
  String get faqAppsQ4 => 'How are application categories determined?';

  @override
  String get faqAppsA4 =>
      'Initial categories are system-suggested, but you have full control to create, modify, and assign custom categories based on your workflow and preferences.';

  @override
  String get faqReportsQ1 => 'What types of reports are available?';

  @override
  String get faqReportsA1 =>
      'Reports include: Total screen time, Productive time, Most used apps, Focus sessions, Daily screen time graph, Category breakdown pie chart, Detailed application usage, Weekly usage trends, and Usage pattern analysis by time of day.';

  @override
  String get faqReportsQ2 => 'How detailed are the application usage reports?';

  @override
  String get faqReportsA2 =>
      'Detailed application usage reports show: App name, Category, Total time spent, Productivity status, and offer an \'Actions\' section with deeper insights like usage summary, daily limits, usage trends, and productivity metrics.';

  @override
  String get faqReportsQ3 => 'Can I analyze my usage trends over time?';

  @override
  String get faqReportsA3 =>
      'Yes! The app provides week-over-week comparisons, showing graphs of usage over past weeks, average daily usage, longest sessions, and weekly totals to help you track your digital habits.';

  @override
  String get faqReportsQ4 => 'What is the \'Usage Pattern\' analysis?';

  @override
  String get faqReportsA4 =>
      'Usage Pattern breaks down your screen time into morning, afternoon, evening, and night segments. This helps you understand when you\'re most active on your device and identify potential areas for improvement.';

  @override
  String get faqAlertsQ1 => 'How granular are the screen time limits?';

  @override
  String get faqAlertsA1 =>
      'You can set overall daily screen time limits and individual app limits. Limits can be configured in hours and minutes, with options to reset or adjust as needed.';

  @override
  String get faqAlertsQ2 => 'What notification options are available?';

  @override
  String get faqAlertsA2 =>
      'The app offers multiple notification types: System alerts when you exceed screen time, Frequent alerts at customizable intervals (1, 5, 15, 30, or 60 minutes), and toggles for focus mode, screen time, and application-specific notifications.';

  @override
  String get faqAlertsQ3 => 'Can I customize limit alerts?';

  @override
  String get faqAlertsA3 =>
      'Yes, you can customize alert frequency, enable/disable specific types of alerts, and set different limits for overall screen time and individual applications.';

  @override
  String get faqFocusQ1 => 'What types of Focus Modes are available?';

  @override
  String get faqFocusA1 =>
      'Available modes include Deep Work (longer focused sessions), Quick Tasks (short bursts of work), and Reading Mode. Each mode helps you structure your work and break times effectively.';

  @override
  String get faqFocusQ2 => 'How flexible is the Pomodoro Timer?';

  @override
  String get faqFocusA2 =>
      'The timer is highly customizable. You can adjust work duration, short break length, and long break duration. Additional options include auto-start for next sessions and notification settings.';

  @override
  String get faqFocusQ3 => 'What does the Focus Mode history show?';

  @override
  String get faqFocusA3 =>
      'Focus Mode history tracks daily focus sessions, showing the number of sessions per day, trends graph, average session duration, total focus time, and a time distribution pie chart breaking down work sessions, short breaks, and long breaks.';

  @override
  String get faqFocusQ4 => 'Can I track my focus session progress?';

  @override
  String get faqFocusA4 =>
      'The app features a circular timer UI with play/pause, reload, and settings buttons. You can easily track and manage your focus sessions with intuitive controls.';

  @override
  String get faqSettingsQ1 => 'What customization options are available?';

  @override
  String get faqSettingsA1 =>
      'Customization includes theme selection (System, Light, Dark), language settings, startup behavior, comprehensive notification controls, and data management options like clearing data or resetting settings.';

  @override
  String get faqSettingsQ2 => 'How do I provide feedback or report issues?';

  @override
  String get faqSettingsA2 =>
      'At the bottom of the Settings section, you\'ll find buttons to Report a Bug, Submit Feedback, or Contact Support. These will redirect you to the appropriate support channels.';

  @override
  String get faqSettingsQ3 => 'What happens when I clear my data?';

  @override
  String get faqSettingsA3 =>
      'Clearing data will reset all your usage statistics, focus session history, and custom settings. This is useful for starting fresh or troubleshooting.';

  @override
  String get faqTroubleQ1 => 'Data is not showing, hive is not opening error';

  @override
  String get faqTroubleA1 =>
      'The issue is known, the temporary fix is to clear data through settings and if it doesn\'t work then go to Documents and delete the following files if they exist - harman_screentime_app_usage_box.hive and harman_screentime_app_usage.lock, you are also suggested to update the app to the latest version.';

  @override
  String get faqTroubleQ2 => 'App opens on every startup, what to do?';

  @override
  String get faqTroubleA2 =>
      'This is a known issue that occurs on Windows 10, the temporary fix is to enable Launch as Minimized in settings so it launches as Minimized.';

  @override
  String get usageAnalytics => 'Usage Analytics';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get last3Months => 'Last 3 Months';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get custom => 'Custom';

  @override
  String get loadingAnalyticsData => 'Loading analytics data...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get failedToInitialize =>
      'Failed to initialize analytics. Please restart the application.';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error. Please try again later.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Error loading analytics data: $error. Please check your connection and try again.';
  }

  @override
  String get customDialogTitle => 'Custom';

  @override
  String get dateRange => 'Date Range';

  @override
  String get specificDate => 'Specific Date';

  @override
  String get startDate => 'Start Date: ';

  @override
  String get endDate => 'End Date: ';

  @override
  String get date => 'Date: ';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Invalid Date Range';

  @override
  String get startDateBeforeEndDate =>
      'Start date must be before or equal to end date.';

  @override
  String get totalScreenTime => 'Total Screen Time';

  @override
  String get productiveTime => 'Productive Time';

  @override
  String get mostUsedApp => 'Most Used App';

  @override
  String get focusSessions => 'Focus Sessions';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs previous period';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs previous period';
  }

  @override
  String iconLabel(String title) {
    return '$title icon';
  }

  @override
  String get dailyScreenTime => 'Daily Screen Time';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String sectionLabel(String title) {
    return '$title section';
  }

  @override
  String get detailedApplicationUsage => 'Detailed Application Usage';

  @override
  String get searchApplications => 'Search applications';

  @override
  String get nameHeader => 'Name';

  @override
  String get categoryHeader => 'Category';

  @override
  String get totalTimeHeader => 'Total Time';

  @override
  String get productivityHeader => 'Productivity';

  @override
  String get actionsHeader => 'Actions';

  @override
  String sortByOption(String option) {
    return 'Sort by: $option';
  }

  @override
  String get sortByName => 'Name';

  @override
  String get sortByCategory => 'Category';

  @override
  String get sortByUsage => 'Usage';

  @override
  String get productive => 'Productive';

  @override
  String get nonProductive => 'Non-Productive';

  @override
  String get noApplicationsMatch =>
      'No applications match your search criteria';

  @override
  String get viewDetails => 'View details';

  @override
  String get usageSummary => 'Usage Summary';

  @override
  String get usageOverPastWeek => 'Usage Over Past Week';

  @override
  String get usagePatternByTimeOfDay => 'Usage Pattern by Time of Day';

  @override
  String get patternAnalysis => 'Pattern Analysis';

  @override
  String get today => 'Today';

  @override
  String get dailyLimit => 'Daily Limit';

  @override
  String get noLimit => 'No limit';

  @override
  String get usageTrend => 'Usage Trend';

  @override
  String get productivity => 'Productivity';

  @override
  String get increasing => 'Increasing';

  @override
  String get decreasing => 'Decreasing';

  @override
  String get stable => 'Stable';

  @override
  String get avgDailyUsage => 'Avg. Daily Usage';

  @override
  String get longestSession => 'Longest Session';

  @override
  String get weeklyTotal => 'Weekly Total';

  @override
  String get noHistoricalData => 'No historical data available';

  @override
  String get morning => 'Morning (6-12)';

  @override
  String get afternoon => 'Afternoon (12-5)';

  @override
  String get evening => 'Evening (5-9)';

  @override
  String get night => 'Night (9-6)';

  @override
  String get usageInsights => 'Usage Insights';

  @override
  String get limitStatus => 'Limit Status';

  @override
  String get close => 'Close';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'You primarily use $appName during $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Your usage has increased significantly ($percentage%) compared to the previous period.';
  }

  @override
  String get trendingUpward =>
      'Your usage is trending upward compared to the previous period.';

  @override
  String significantDecrease(String percentage) {
    return 'Your usage has decreased significantly ($percentage%) compared to the previous period.';
  }

  @override
  String get trendingDownward =>
      'Your usage is trending downward compared to the previous period.';

  @override
  String get consistentUsage =>
      'Your usage has been consistent compared to the previous period.';

  @override
  String get markedAsProductive =>
      'This is marked as a productive app in your settings.';

  @override
  String get markedAsNonProductive =>
      'This is marked as a non-productive app in your settings.';

  @override
  String mostActiveTime(String time) {
    return 'Your most active time is around $time.';
  }

  @override
  String get noLimitSet => 'No usage limit has been set for this application.';

  @override
  String get limitReached =>
      'You\'ve reached your daily limit for this application.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'You\'re about to reach your daily limit with only $remainingTime remaining.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'You\'ve used $percent% of your daily limit with $remainingTime remaining.';
  }

  @override
  String remainingTime(String time) {
    return 'You have $time remaining out of your daily limit.';
  }

  @override
  String get todayChart => 'Today';

  @override
  String hourPeriodAM(int hour) {
    return '$hour AM';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour PM';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get alertsLimitsTitle => 'Alerts & Limits';

  @override
  String get notificationsSettings => 'Notifications Settings';

  @override
  String get overallScreenTimeLimit => 'Overall Screen Time Limit';

  @override
  String get applicationLimits => 'Application Limits';

  @override
  String get popupAlerts => 'Pop-up Alerts';

  @override
  String get frequentAlerts => 'Frequent Alerts';

  @override
  String get soundAlerts => 'Sound Alerts';

  @override
  String get systemAlerts => 'System Alerts';

  @override
  String get dailyTotalLimit => 'Daily Total Limit: ';

  @override
  String get hours => 'Hours: ';

  @override
  String get minutes => 'Minutes: ';

  @override
  String get currentUsage => 'Current Usage: ';

  @override
  String get tableName => 'Name';

  @override
  String get tableCategory => 'Category';

  @override
  String get tableDailyLimit => 'Daily Limit';

  @override
  String get tableCurrentUsage => 'Current Usage';

  @override
  String get tableStatus => 'Status';

  @override
  String get tableActions => 'Actions';

  @override
  String get addLimit => 'Add Limit';

  @override
  String get noApplicationsToDisplay => 'No applications to display';

  @override
  String get statusActive => 'Active';

  @override
  String get statusOff => 'Off';

  @override
  String get durationNone => 'None';

  @override
  String get addApplicationLimit => 'Add Application Limit';

  @override
  String get selectApplication => 'Select Application';

  @override
  String get selectApplicationPlaceholder => 'Select an application';

  @override
  String get enableLimit => 'Enable Limit: ';

  @override
  String editLimitTitle(String appName) {
    return 'Edit Limit: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Failed to load data: $error';
  }

  @override
  String get resetSettingsTitle => 'Reset Settings?';

  @override
  String get resetSettingsContent =>
      'If you reset settings, you won\'t be able to recover it. Do you want to reset it?';

  @override
  String get resetAll => 'Reset All';

  @override
  String get refresh => 'Refresh';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get applicationsTitle => 'Applications';

  @override
  String get searchApplication => 'Search Application';

  @override
  String get tracking => 'Tracking';

  @override
  String get hiddenVisible => 'Hidden/Visible';

  @override
  String get selectCategory => 'Select a Category';

  @override
  String get allCategories => 'All';

  @override
  String get tableScreenTime => 'Screen Time';

  @override
  String get tableTracking => 'Tracking';

  @override
  String get tableHidden => 'Hidden';

  @override
  String get tableEdit => 'Edit';

  @override
  String editAppTitle(String appName) {
    return 'Edit $appName';
  }

  @override
  String get categorySection => 'Category';

  @override
  String get customCategory => 'Custom';

  @override
  String get customCategoryPlaceholder => 'Enter custom category name';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get isProductive => 'Is Productive';

  @override
  String get trackUsage => 'Track Usage';

  @override
  String get visibleInReports => 'Visible in Reports';

  @override
  String get timeLimitsSection => 'Time Limits';

  @override
  String get enableDailyLimit => 'Enable Daily Limit';

  @override
  String get setDailyTimeLimit => 'Set daily time limit:';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String errorLoadingData(String error) {
    return 'Error loading overview data: $error';
  }

  @override
  String get focusModeTitle => 'Focus Mode';

  @override
  String get historySection => 'History';

  @override
  String get trendsSection => 'Trends';

  @override
  String get timeDistributionSection => 'Time Distribution';

  @override
  String get sessionHistorySection => 'Session History';

  @override
  String get workSession => 'Work Session';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get dateHeader => 'Date';

  @override
  String get durationHeader => 'Duration';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get focusModeSettingsTitle => 'Focus Mode Settings';

  @override
  String get modeCustom => 'Custom';

  @override
  String get modeDeepWork => 'Deep Work (60 min)';

  @override
  String get modeQuickTasks => 'Quick Tasks (25 min)';

  @override
  String get modeReading => 'Reading (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Work Duration: $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Short Break: $minutes min';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Long Break: $minutes min';
  }

  @override
  String get autoStartNextSession => 'Auto-start next session';

  @override
  String get blockDistractions => 'Block distractions during focus mode';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get saved => 'Saved';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Error loading focus mode data: $error';
  }

  @override
  String get overviewTitle => 'Today\'s Overview';

  @override
  String get startFocusMode => 'Start Focus Mode';

  @override
  String get loadingProductivityData => 'Loading your productivity data...';

  @override
  String get noActivityDataAvailable => 'No activity data available yet';

  @override
  String get startUsingApplications =>
      'Start using your applications to track screen time and productivity.';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get topApplications => 'Top Applications';

  @override
  String get noAppUsageDataAvailable =>
      'No application usage data available yet';

  @override
  String get noApplicationDataAvailable => 'No application data available';

  @override
  String get noCategoryDataAvailable => 'No category data available';

  @override
  String get noApplicationLimitsSet => 'No application limits set';

  @override
  String get screenLabel => 'Screen';

  @override
  String get timeLabel => 'Time';

  @override
  String get productiveLabel => 'Productive';

  @override
  String get scoreLabel => 'Score';

  @override
  String get defaultNone => 'None';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Unknown';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get dataSection => 'Data';

  @override
  String get versionSection => 'Version';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeDescription =>
      'Color theme of the application (Change Requires Restart)';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Language of the application';

  @override
  String get startupBehaviourTitle => 'Startup Behaviour';

  @override
  String get startupBehaviourDescription => 'Launch at OS startup';

  @override
  String get launchMinimizedTitle => 'Launch as Minimized';

  @override
  String get launchMinimizedDescription =>
      'Start the application in System Tray (Recommended for Windows 10)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllDescription =>
      'All notifications of the application';

  @override
  String get focusModeNotificationsTitle => 'Focus Mode';

  @override
  String get focusModeNotificationsDescription =>
      'All Notifications for focus mode';

  @override
  String get screenTimeNotificationsTitle => 'Screen Time';

  @override
  String get screenTimeNotificationsDescription =>
      'All Notifications for screen time restriction';

  @override
  String get appScreenTimeNotificationsTitle => 'Application Screen Time';

  @override
  String get appScreenTimeNotificationsDescription =>
      'All Notifications for application screen time restriction';

  @override
  String get frequentAlertsTitle => 'Frequent Alerts Interval';

  @override
  String get frequentAlertsDescription =>
      'Set interval for frequent notifications (minutes)';

  @override
  String get clearDataTitle => 'Clear Data';

  @override
  String get clearDataDescription =>
      'Clear all the history and other related data';

  @override
  String get resetSettingsTitle2 => 'Reset Settings';

  @override
  String get resetSettingsDescription => 'Reset all the settings';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionDescription => 'Current version of the app';

  @override
  String get contactButton => 'Contact';

  @override
  String get reportBugButton => 'Report Bug';

  @override
  String get submitFeedbackButton => 'Submit Feedback';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Clear Data?';

  @override
  String get clearDataDialogContent =>
      'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?';

  @override
  String get clearDataButtonLabel => 'Clear Data';

  @override
  String get resetSettingsDialogTitle => 'Reset Settings?';

  @override
  String get resetSettingsDialogContent =>
      'This will reset all settings to their default values. Do you want to proceed?';

  @override
  String get resetButtonLabel => 'Reset';

  @override
  String get cancelButton => 'Cancel';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Could not launch $url';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get chart_focusTrends => 'Focus Trends';

  @override
  String get chart_sessionCount => 'Session Count';

  @override
  String get chart_avgDuration => 'Avg Duration';

  @override
  String get chart_totalFocus => 'Total Focus';

  @override
  String get chart_yAxis_sessions => 'Sessions';

  @override
  String get chart_yAxis_minutes => 'Minutes';

  @override
  String get chart_yAxis_value => 'Value';

  @override
  String get chart_monthOverMonthChange => 'Month-over-month change: ';

  @override
  String get chart_customRange => 'Custom Range';

  @override
  String get day_monday => 'Monday';

  @override
  String get day_mondayShort => 'Mon';

  @override
  String get day_mondayAbbr => 'Mn';

  @override
  String get day_tuesday => 'Tuesday';

  @override
  String get day_tuesdayShort => 'Tue';

  @override
  String get day_tuesdayAbbr => 'Tu';

  @override
  String get day_wednesday => 'Wednesday';

  @override
  String get day_wednesdayShort => 'Wed';

  @override
  String get day_wednesdayAbbr => 'Wd';

  @override
  String get day_thursday => 'Thursday';

  @override
  String get day_thursdayShort => 'Thu';

  @override
  String get day_thursdayAbbr => 'Th';

  @override
  String get day_friday => 'Friday';

  @override
  String get day_fridayShort => 'Fri';

  @override
  String get day_fridayAbbr => 'Fr';

  @override
  String get day_saturday => 'Saturday';

  @override
  String get day_saturdayShort => 'Sat';

  @override
  String get day_saturdayAbbr => 'St';

  @override
  String get day_sunday => 'Sunday';

  @override
  String get day_sundayShort => 'Sun';

  @override
  String get day_sundayAbbr => 'Sn';

  @override
  String time_hours(int count) {
    return '${count}h';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count min';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: ${hours}h ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count hours';
  }

  @override
  String get month_january => 'January';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'February';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'March';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'April';

  @override
  String get month_aprilShort => 'Apr';

  @override
  String get month_may => 'May';

  @override
  String get month_mayShort => 'May';

  @override
  String get month_june => 'June';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'July';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'August';

  @override
  String get month_augustShort => 'Aug';

  @override
  String get month_september => 'September';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'October';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'November';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'December';

  @override
  String get month_decemberShort => 'Dec';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categorySocialMedia => 'Social Media';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryWebBrowsing => 'Web Browsing';

  @override
  String get categoryCreative => 'Creative';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryUtility => 'Utility';

  @override
  String get categoryUncategorized => 'Uncategorized';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google Docs';

  @override
  String get appNotion => 'Notion';

  @override
  String get appEvernote => 'Evernote';

  @override
  String get appTrello => 'Trello';

  @override
  String get appAsana => 'Asana';

  @override
  String get appSlack => 'Slack';

  @override
  String get appMicrosoftTeams => 'Microsoft Teams';

  @override
  String get appZoom => 'Zoom';

  @override
  String get appGoogleCalendar => 'Google Calendar';

  @override
  String get appAppleCalendar => 'Calendar';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Command Prompt';

  @override
  String get appChrome => 'Chrome';

  @override
  String get appFirefox => 'Firefox';

  @override
  String get appSafari => 'Safari';

  @override
  String get appEdge => 'Edge';

  @override
  String get appOpera => 'Opera';

  @override
  String get appBrave => 'Brave';

  @override
  String get appNetflix => 'Netflix';

  @override
  String get appYouTube => 'YouTube';

  @override
  String get appSpotify => 'Spotify';

  @override
  String get appAppleMusic => 'Apple Music';

  @override
  String get appCalculator => 'Calculator';

  @override
  String get appNotes => 'Notes';

  @override
  String get appSystemPreferences => 'System Preferences';

  @override
  String get appTaskManager => 'Task Manager';

  @override
  String get appFileExplorer => 'File Explorer';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';
}
