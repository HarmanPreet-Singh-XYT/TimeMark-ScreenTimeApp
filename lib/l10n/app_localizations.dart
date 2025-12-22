import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The title shown in the window title bar
  ///
  /// In en, this message translates to:
  /// **'TimeMark - Track Screen Time & App Usage'**
  String get appWindowTitle;

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'TimeMark'**
  String get appName;

  /// The app title/tagline
  ///
  /// In en, this message translates to:
  /// **'Productive ScreenTime'**
  String get appTitle;

  /// Title shown in the sidebar
  ///
  /// In en, this message translates to:
  /// **'ScreenTime'**
  String get sidebarTitle;

  /// Subtitle shown in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get sidebarSubtitle;

  /// Tray menu item to show the main window
  ///
  /// In en, this message translates to:
  /// **'Show Window'**
  String get trayShowWindow;

  /// Tray menu item to start focus mode
  ///
  /// In en, this message translates to:
  /// **'Start Focus Mode'**
  String get trayStartFocusMode;

  /// Tray menu item to stop focus mode
  ///
  /// In en, this message translates to:
  /// **'Stop Focus Mode'**
  String get trayStopFocusMode;

  /// Tray menu item for reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get trayReports;

  /// Tray menu item for alerts and limits
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get trayAlertsLimits;

  /// Tray menu item for applications
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get trayApplications;

  /// Tray menu item to disable notifications
  ///
  /// In en, this message translates to:
  /// **'Disable Notifications'**
  String get trayDisableNotifications;

  /// Tray menu item to enable notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get trayEnableNotifications;

  /// Prefix text for version display in tray
  ///
  /// In en, this message translates to:
  /// **'Version: '**
  String get trayVersionPrefix;

  /// Version display with placeholder
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String trayVersion(String version);

  /// Tray menu item to exit the application
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trayExit;

  /// Navigation item for overview page
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// Navigation item for applications page
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get navApplications;

  /// Navigation item for alerts and limits page
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get navAlertsLimits;

  /// Navigation item for reports page
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Navigation item for focus mode page
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get navFocusMode;

  /// Navigation item for settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Navigation item for help page
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @faqCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Questions'**
  String get faqCategoryGeneral;

  /// No description provided for @faqCategoryApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications Management'**
  String get faqCategoryApplications;

  /// No description provided for @faqCategoryReports.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics & Reports'**
  String get faqCategoryReports;

  /// No description provided for @faqCategoryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get faqCategoryAlerts;

  /// No description provided for @faqCategoryFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode & Pomodoro Timer'**
  String get faqCategoryFocusMode;

  /// No description provided for @faqCategorySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings & Customization'**
  String get faqCategorySettings;

  /// No description provided for @faqCategoryTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get faqCategoryTroubleshooting;

  /// No description provided for @faqGeneralQ1.
  ///
  /// In en, this message translates to:
  /// **'How does this app track screen time?'**
  String get faqGeneralQ1;

  /// No description provided for @faqGeneralA1.
  ///
  /// In en, this message translates to:
  /// **'The app monitors your device\'s usage in real-time, tracking the time spent on different applications. It provides comprehensive insights into your digital habits, including total screen time, productive time, and application-specific usage.'**
  String get faqGeneralA1;

  /// No description provided for @faqGeneralQ2.
  ///
  /// In en, this message translates to:
  /// **'What makes an app \'Productive\'?'**
  String get faqGeneralQ2;

  /// No description provided for @faqGeneralA2.
  ///
  /// In en, this message translates to:
  /// **'You can manually mark apps as productive in the \'Applications\' section. Productive apps contribute to your Productive Score, which calculates the percentage of screen time spent on work-related or beneficial applications.'**
  String get faqGeneralA2;

  /// No description provided for @faqGeneralQ3.
  ///
  /// In en, this message translates to:
  /// **'How accurate is the screen time tracking?'**
  String get faqGeneralQ3;

  /// No description provided for @faqGeneralA3.
  ///
  /// In en, this message translates to:
  /// **'The app uses system-level tracking to provide precise measurement of your device usage. It captures foreground time for each application with minimal battery impact.'**
  String get faqGeneralA3;

  /// No description provided for @faqGeneralQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I customize my app categorization?'**
  String get faqGeneralQ4;

  /// No description provided for @faqGeneralA4.
  ///
  /// In en, this message translates to:
  /// **'Absolutely! You can create custom categories, assign apps to specific categories, and easily modify these assignments in the \'Applications\' section. This helps in creating more meaningful usage analytics.'**
  String get faqGeneralA4;

  /// No description provided for @faqGeneralQ5.
  ///
  /// In en, this message translates to:
  /// **'What insights can I gain from this app?'**
  String get faqGeneralQ5;

  /// No description provided for @faqGeneralA5.
  ///
  /// In en, this message translates to:
  /// **'The app offers comprehensive insights including Productive Score, usage patterns by time of day, detailed application usage, focus session tracking, and visual analytics like graphs and pie charts to help you understand and improve your digital habits.'**
  String get faqGeneralA5;

  /// No description provided for @faqAppsQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I hide specific apps from tracking?'**
  String get faqAppsQ1;

  /// No description provided for @faqAppsA1.
  ///
  /// In en, this message translates to:
  /// **'In the \'Applications\' section, you can toggle the visibility of apps.'**
  String get faqAppsA1;

  /// No description provided for @faqAppsQ2.
  ///
  /// In en, this message translates to:
  /// **'Can I search and filter my applications?'**
  String get faqAppsQ2;

  /// No description provided for @faqAppsA2.
  ///
  /// In en, this message translates to:
  /// **'Yes, the Applications section includes a search functionality and filtering options. You can filter apps by category, productivity status, tracking status, and visibility.'**
  String get faqAppsA2;

  /// No description provided for @faqAppsQ3.
  ///
  /// In en, this message translates to:
  /// **'What editing options are available for applications?'**
  String get faqAppsQ3;

  /// No description provided for @faqAppsA3.
  ///
  /// In en, this message translates to:
  /// **'For each application, you can edit: category assignment, productivity status, tracking usage, visibility in reports, and set individual daily time limits.'**
  String get faqAppsA3;

  /// No description provided for @faqAppsQ4.
  ///
  /// In en, this message translates to:
  /// **'How are application categories determined?'**
  String get faqAppsQ4;

  /// No description provided for @faqAppsA4.
  ///
  /// In en, this message translates to:
  /// **'Initial categories are system-suggested, but you have full control to create, modify, and assign custom categories based on your workflow and preferences.'**
  String get faqAppsA4;

  /// No description provided for @faqReportsQ1.
  ///
  /// In en, this message translates to:
  /// **'What types of reports are available?'**
  String get faqReportsQ1;

  /// No description provided for @faqReportsA1.
  ///
  /// In en, this message translates to:
  /// **'Reports include: Total screen time, Productive time, Most used apps, Focus sessions, Daily screen time graph, Category breakdown pie chart, Detailed application usage, Weekly usage trends, and Usage pattern analysis by time of day.'**
  String get faqReportsA1;

  /// No description provided for @faqReportsQ2.
  ///
  /// In en, this message translates to:
  /// **'How detailed are the application usage reports?'**
  String get faqReportsQ2;

  /// No description provided for @faqReportsA2.
  ///
  /// In en, this message translates to:
  /// **'Detailed application usage reports show: App name, Category, Total time spent, Productivity status, and offer an \'Actions\' section with deeper insights like usage summary, daily limits, usage trends, and productivity metrics.'**
  String get faqReportsA2;

  /// No description provided for @faqReportsQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I analyze my usage trends over time?'**
  String get faqReportsQ3;

  /// No description provided for @faqReportsA3.
  ///
  /// In en, this message translates to:
  /// **'Yes! The app provides week-over-week comparisons, showing graphs of usage over past weeks, average daily usage, longest sessions, and weekly totals to help you track your digital habits.'**
  String get faqReportsA3;

  /// No description provided for @faqReportsQ4.
  ///
  /// In en, this message translates to:
  /// **'What is the \'Usage Pattern\' analysis?'**
  String get faqReportsQ4;

  /// No description provided for @faqReportsA4.
  ///
  /// In en, this message translates to:
  /// **'Usage Pattern breaks down your screen time into morning, afternoon, evening, and night segments. This helps you understand when you\'re most active on your device and identify potential areas for improvement.'**
  String get faqReportsA4;

  /// No description provided for @faqAlertsQ1.
  ///
  /// In en, this message translates to:
  /// **'How granular are the screen time limits?'**
  String get faqAlertsQ1;

  /// No description provided for @faqAlertsA1.
  ///
  /// In en, this message translates to:
  /// **'You can set overall daily screen time limits and individual app limits. Limits can be configured in hours and minutes, with options to reset or adjust as needed.'**
  String get faqAlertsA1;

  /// No description provided for @faqAlertsQ2.
  ///
  /// In en, this message translates to:
  /// **'What notification options are available?'**
  String get faqAlertsQ2;

  /// No description provided for @faqAlertsA2.
  ///
  /// In en, this message translates to:
  /// **'The app offers multiple notification types: System alerts when you exceed screen time, Frequent alerts at customizable intervals (1, 5, 15, 30, or 60 minutes), and toggles for focus mode, screen time, and application-specific notifications.'**
  String get faqAlertsA2;

  /// No description provided for @faqAlertsQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I customize limit alerts?'**
  String get faqAlertsQ3;

  /// No description provided for @faqAlertsA3.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can customize alert frequency, enable/disable specific types of alerts, and set different limits for overall screen time and individual applications.'**
  String get faqAlertsA3;

  /// No description provided for @faqFocusQ1.
  ///
  /// In en, this message translates to:
  /// **'What types of Focus Modes are available?'**
  String get faqFocusQ1;

  /// No description provided for @faqFocusA1.
  ///
  /// In en, this message translates to:
  /// **'Available modes include Deep Work (longer focused sessions), Quick Tasks (short bursts of work), and Reading Mode. Each mode helps you structure your work and break times effectively.'**
  String get faqFocusA1;

  /// No description provided for @faqFocusQ2.
  ///
  /// In en, this message translates to:
  /// **'How flexible is the Pomodoro Timer?'**
  String get faqFocusQ2;

  /// No description provided for @faqFocusA2.
  ///
  /// In en, this message translates to:
  /// **'The timer is highly customizable. You can adjust work duration, short break length, and long break duration. Additional options include auto-start for next sessions and notification settings.'**
  String get faqFocusA2;

  /// No description provided for @faqFocusQ3.
  ///
  /// In en, this message translates to:
  /// **'What does the Focus Mode history show?'**
  String get faqFocusQ3;

  /// No description provided for @faqFocusA3.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode history tracks daily focus sessions, showing the number of sessions per day, trends graph, average session duration, total focus time, and a time distribution pie chart breaking down work sessions, short breaks, and long breaks.'**
  String get faqFocusA3;

  /// No description provided for @faqFocusQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I track my focus session progress?'**
  String get faqFocusQ4;

  /// No description provided for @faqFocusA4.
  ///
  /// In en, this message translates to:
  /// **'The app features a circular timer UI with play/pause, reload, and settings buttons. You can easily track and manage your focus sessions with intuitive controls.'**
  String get faqFocusA4;

  /// No description provided for @faqSettingsQ1.
  ///
  /// In en, this message translates to:
  /// **'What customization options are available?'**
  String get faqSettingsQ1;

  /// No description provided for @faqSettingsA1.
  ///
  /// In en, this message translates to:
  /// **'Customization includes theme selection (System, Light, Dark), language settings, startup behavior, comprehensive notification controls, and data management options like clearing data or resetting settings.'**
  String get faqSettingsA1;

  /// No description provided for @faqSettingsQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I provide feedback or report issues?'**
  String get faqSettingsQ2;

  /// No description provided for @faqSettingsA2.
  ///
  /// In en, this message translates to:
  /// **'At the bottom of the Settings section, you\'ll find buttons to Report a Bug, Submit Feedback, or Contact Support. These will redirect you to the appropriate support channels.'**
  String get faqSettingsA2;

  /// No description provided for @faqSettingsQ3.
  ///
  /// In en, this message translates to:
  /// **'What happens when I clear my data?'**
  String get faqSettingsQ3;

  /// No description provided for @faqSettingsA3.
  ///
  /// In en, this message translates to:
  /// **'Clearing data will reset all your usage statistics, focus session history, and custom settings. This is useful for starting fresh or troubleshooting.'**
  String get faqSettingsA3;

  /// No description provided for @faqTroubleQ1.
  ///
  /// In en, this message translates to:
  /// **'Data is not showing, hive is not opening error'**
  String get faqTroubleQ1;

  /// No description provided for @faqTroubleA1.
  ///
  /// In en, this message translates to:
  /// **'The issue is known, the temporary fix is to clear data through settings and if it doesn\'t work then go to Documents and delete the following files if they exist - harman_screentime_app_usage_box.hive and harman_screentime_app_usage.lock, you are also suggested to update the app to the latest version.'**
  String get faqTroubleA1;

  /// No description provided for @faqTroubleQ2.
  ///
  /// In en, this message translates to:
  /// **'App opens on every startup, what to do?'**
  String get faqTroubleQ2;

  /// No description provided for @faqTroubleA2.
  ///
  /// In en, this message translates to:
  /// **'This is a known issue that occurs on Windows 10, the temporary fix is to enable Launch as Minimized in settings so it launches as Minimized.'**
  String get faqTroubleA2;

  /// Main page title for the analytics/reports section
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get usageAnalytics;

  /// Time period option - last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// Time period option - last month
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// Time period option - last 3 months
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// Time period option - all available data
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// Time period option - custom date range
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Loading message while fetching analytics
  ///
  /// In en, this message translates to:
  /// **'Loading analytics data...'**
  String get loadingAnalyticsData;

  /// Button to retry after an error
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error message when analytics system fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize analytics. Please restart the application.'**
  String get failedToInitialize;

  /// Generic error message with error details
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}. Please try again later.'**
  String unexpectedError(String error);

  /// Error message when loading analytics data fails
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics data: {error}. Please check your connection and try again.'**
  String errorLoadingAnalytics(String error);

  /// Title for custom date selection dialog
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDialogTitle;

  /// Label for date range selection mode
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// Label for single date selection mode
  ///
  /// In en, this message translates to:
  /// **'Specific Date'**
  String get specificDate;

  /// Label for start date picker
  ///
  /// In en, this message translates to:
  /// **'Start Date: '**
  String get startDate;

  /// Label for end date picker
  ///
  /// In en, this message translates to:
  /// **'End Date: '**
  String get endDate;

  /// Label for single date picker
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get date;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Apply/Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error dialog title for invalid date selection
  ///
  /// In en, this message translates to:
  /// **'Invalid Date Range'**
  String get invalidDateRange;

  /// Validation message for date range
  ///
  /// In en, this message translates to:
  /// **'Start date must be before or equal to end date.'**
  String get startDateBeforeEndDate;

  /// Analytics box title for total screen time
  ///
  /// In en, this message translates to:
  /// **'Total Screen Time'**
  String get totalScreenTime;

  /// Analytics box title for productive time
  ///
  /// In en, this message translates to:
  /// **'Productive Time'**
  String get productiveTime;

  /// Analytics box title for most used application
  ///
  /// In en, this message translates to:
  /// **'Most Used App'**
  String get mostUsedApp;

  /// Analytics box title for focus sessions count
  ///
  /// In en, this message translates to:
  /// **'Focus Sessions'**
  String get focusSessions;

  /// Comparison text for positive change
  ///
  /// In en, this message translates to:
  /// **'+{percent}% vs previous period'**
  String positiveComparison(String percent);

  /// Comparison text for negative change
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs previous period'**
  String negativeComparison(String percent);

  /// Accessibility label for icons
  ///
  /// In en, this message translates to:
  /// **'{title} icon'**
  String iconLabel(String title);

  /// Title for daily screen time chart
  ///
  /// In en, this message translates to:
  /// **'Daily Screen Time'**
  String get dailyScreenTime;

  /// Title for category breakdown pie chart
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// Empty state message when no data exists
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Accessibility label for sections
  ///
  /// In en, this message translates to:
  /// **'{title} section'**
  String sectionLabel(String title);

  /// Title for detailed application usage table
  ///
  /// In en, this message translates to:
  /// **'Detailed Application Usage'**
  String get detailedApplicationUsage;

  /// Placeholder text for search box
  ///
  /// In en, this message translates to:
  /// **'Search applications'**
  String get searchApplications;

  /// Table column header for app name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHeader;

  /// Table column header for category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryHeader;

  /// Table column header for total time
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTimeHeader;

  /// Table column header for productivity status
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivityHeader;

  /// Table column header for action buttons
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsHeader;

  /// Sort dropdown option text
  ///
  /// In en, this message translates to:
  /// **'Sort by: {option}'**
  String sortByOption(String option);

  /// Sort option - by name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// Sort option - by category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sortByCategory;

  /// Sort option - by usage time
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get sortByUsage;

  /// Label for productive apps
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get productive;

  /// Label for non-productive apps
  ///
  /// In en, this message translates to:
  /// **'Non-Productive'**
  String get nonProductive;

  /// Empty state when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No applications match your search criteria'**
  String get noApplicationsMatch;

  /// Tooltip for view details button
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Section title in app details dialog
  ///
  /// In en, this message translates to:
  /// **'Usage Summary'**
  String get usageSummary;

  /// Section title for weekly usage chart
  ///
  /// In en, this message translates to:
  /// **'Usage Over Past Week'**
  String get usageOverPastWeek;

  /// Section title for time of day breakdown
  ///
  /// In en, this message translates to:
  /// **'Usage Pattern by Time of Day'**
  String get usagePatternByTimeOfDay;

  /// Section title for usage pattern insights
  ///
  /// In en, this message translates to:
  /// **'Pattern Analysis'**
  String get patternAnalysis;

  /// Label for today's usage
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for daily usage limit
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get dailyLimit;

  /// Text shown when no limit is set
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// Label for usage trend indicator
  ///
  /// In en, this message translates to:
  /// **'Usage Trend'**
  String get usageTrend;

  /// Label for productivity status
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// Trend label - usage increasing
  ///
  /// In en, this message translates to:
  /// **'Increasing'**
  String get increasing;

  /// Trend label - usage decreasing
  ///
  /// In en, this message translates to:
  /// **'Decreasing'**
  String get decreasing;

  /// Trend label - usage stable
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// Stat card label for average daily usage
  ///
  /// In en, this message translates to:
  /// **'Avg. Daily Usage'**
  String get avgDailyUsage;

  /// Stat card label for longest session
  ///
  /// In en, this message translates to:
  /// **'Longest Session'**
  String get longestSession;

  /// Stat card label for weekly total
  ///
  /// In en, this message translates to:
  /// **'Weekly Total'**
  String get weeklyTotal;

  /// Empty state for chart with no data
  ///
  /// In en, this message translates to:
  /// **'No historical data available'**
  String get noHistoricalData;

  /// Time of day label - morning hours
  ///
  /// In en, this message translates to:
  /// **'Morning (6-12)'**
  String get morning;

  /// Time of day label - afternoon hours
  ///
  /// In en, this message translates to:
  /// **'Afternoon (12-5)'**
  String get afternoon;

  /// Time of day label - evening hours
  ///
  /// In en, this message translates to:
  /// **'Evening (5-9)'**
  String get evening;

  /// Time of day label - night hours
  ///
  /// In en, this message translates to:
  /// **'Night (9-6)'**
  String get night;

  /// Section title for usage insights
  ///
  /// In en, this message translates to:
  /// **'Usage Insights'**
  String get usageInsights;

  /// Section title for limit status
  ///
  /// In en, this message translates to:
  /// **'Limit Status'**
  String get limitStatus;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Insight about primary usage time
  ///
  /// In en, this message translates to:
  /// **'You primarily use {appName} during {timeOfDay}.'**
  String primaryUsageTime(String appName, String timeOfDay);

  /// Insight about significant usage increase
  ///
  /// In en, this message translates to:
  /// **'Your usage has increased significantly ({percentage}%) compared to the previous period.'**
  String significantIncrease(String percentage);

  /// Insight about upward usage trend
  ///
  /// In en, this message translates to:
  /// **'Your usage is trending upward compared to the previous period.'**
  String get trendingUpward;

  /// Insight about significant usage decrease
  ///
  /// In en, this message translates to:
  /// **'Your usage has decreased significantly ({percentage}%) compared to the previous period.'**
  String significantDecrease(String percentage);

  /// Insight about downward usage trend
  ///
  /// In en, this message translates to:
  /// **'Your usage is trending downward compared to the previous period.'**
  String get trendingDownward;

  /// Insight about consistent usage
  ///
  /// In en, this message translates to:
  /// **'Your usage has been consistent compared to the previous period.'**
  String get consistentUsage;

  /// Insight about productive app status
  ///
  /// In en, this message translates to:
  /// **'This is marked as a productive app in your settings.'**
  String get markedAsProductive;

  /// Insight about non-productive app status
  ///
  /// In en, this message translates to:
  /// **'This is marked as a non-productive app in your settings.'**
  String get markedAsNonProductive;

  /// Insight about most active hour
  ///
  /// In en, this message translates to:
  /// **'Your most active time is around {time}.'**
  String mostActiveTime(String time);

  /// Message when no limit is configured
  ///
  /// In en, this message translates to:
  /// **'No usage limit has been set for this application.'**
  String get noLimitSet;

  /// Message when limit is reached
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your daily limit for this application.'**
  String get limitReached;

  /// Warning message when approaching limit
  ///
  /// In en, this message translates to:
  /// **'You\'re about to reach your daily limit with only {remainingTime} remaining.'**
  String aboutToReachLimit(String remainingTime);

  /// Message showing percentage used
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your daily limit with {remainingTime} remaining.'**
  String percentOfLimitUsed(int percent, String remainingTime);

  /// Message showing remaining time
  ///
  /// In en, this message translates to:
  /// **'You have {time} remaining out of your daily limit.'**
  String remainingTime(String time);

  /// Label for today on charts
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayChart;

  /// Time format - AM hours
  ///
  /// In en, this message translates to:
  /// **'{hour} AM'**
  String hourPeriodAM(int hour);

  /// Time format - PM hours
  ///
  /// In en, this message translates to:
  /// **'{hour} PM'**
  String hourPeriodPM(int hour);

  /// Duration format with hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// Duration format with minutes only
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesOnly(int minutes);

  /// No description provided for @alertsLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get alertsLimitsTitle;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications Settings'**
  String get notificationsSettings;

  /// No description provided for @overallScreenTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Overall Screen Time Limit'**
  String get overallScreenTimeLimit;

  /// No description provided for @applicationLimits.
  ///
  /// In en, this message translates to:
  /// **'Application Limits'**
  String get applicationLimits;

  /// No description provided for @popupAlerts.
  ///
  /// In en, this message translates to:
  /// **'Pop-up Alerts'**
  String get popupAlerts;

  /// No description provided for @frequentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Frequent Alerts'**
  String get frequentAlerts;

  /// No description provided for @soundAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sound Alerts'**
  String get soundAlerts;

  /// No description provided for @systemAlerts.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get systemAlerts;

  /// No description provided for @dailyTotalLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Total Limit: '**
  String get dailyTotalLimit;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours: '**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes: '**
  String get minutes;

  /// No description provided for @currentUsage.
  ///
  /// In en, this message translates to:
  /// **'Current Usage: '**
  String get currentUsage;

  /// No description provided for @tableName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tableName;

  /// No description provided for @tableCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tableCategory;

  /// No description provided for @tableDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get tableDailyLimit;

  /// No description provided for @tableCurrentUsage.
  ///
  /// In en, this message translates to:
  /// **'Current Usage'**
  String get tableCurrentUsage;

  /// No description provided for @tableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tableStatus;

  /// No description provided for @tableActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get tableActions;

  /// No description provided for @addLimit.
  ///
  /// In en, this message translates to:
  /// **'Add Limit'**
  String get addLimit;

  /// No description provided for @noApplicationsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No applications to display'**
  String get noApplicationsToDisplay;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get statusOff;

  /// No description provided for @durationNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get durationNone;

  /// No description provided for @addApplicationLimit.
  ///
  /// In en, this message translates to:
  /// **'Add Application Limit'**
  String get addApplicationLimit;

  /// No description provided for @selectApplication.
  ///
  /// In en, this message translates to:
  /// **'Select Application'**
  String get selectApplication;

  /// No description provided for @selectApplicationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select an application'**
  String get selectApplicationPlaceholder;

  /// No description provided for @enableLimit.
  ///
  /// In en, this message translates to:
  /// **'Enable Limit: '**
  String get enableLimit;

  /// No description provided for @editLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Limit: {appName}'**
  String editLimitTitle(String appName);

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String failedToLoadData(String error);

  /// No description provided for @resetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsTitle;

  /// No description provided for @resetSettingsContent.
  ///
  /// In en, this message translates to:
  /// **'If you reset settings, you won\'t be able to recover it. Do you want to reset it?'**
  String get resetSettingsContent;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @applicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applicationsTitle;

  /// No description provided for @searchApplication.
  ///
  /// In en, this message translates to:
  /// **'Search Application'**
  String get searchApplication;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @hiddenVisible.
  ///
  /// In en, this message translates to:
  /// **'Hidden/Visible'**
  String get hiddenVisible;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a Category'**
  String get selectCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @tableScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get tableScreenTime;

  /// No description provided for @tableTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tableTracking;

  /// No description provided for @tableHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get tableHidden;

  /// No description provided for @tableEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tableEdit;

  /// No description provided for @editAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {appName}'**
  String editAppTitle(String appName);

  /// No description provided for @categorySection.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categorySection;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customCategory;

  /// No description provided for @customCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter custom category name'**
  String get customCategoryPlaceholder;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @isProductive.
  ///
  /// In en, this message translates to:
  /// **'Is Productive'**
  String get isProductive;

  /// No description provided for @trackUsage.
  ///
  /// In en, this message translates to:
  /// **'Track Usage'**
  String get trackUsage;

  /// No description provided for @visibleInReports.
  ///
  /// In en, this message translates to:
  /// **'Visible in Reports'**
  String get visibleInReports;

  /// No description provided for @timeLimitsSection.
  ///
  /// In en, this message translates to:
  /// **'Time Limits'**
  String get timeLimitsSection;

  /// No description provided for @enableDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Enable Daily Limit'**
  String get enableDailyLimit;

  /// No description provided for @setDailyTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Set daily time limit:'**
  String get setDailyTimeLimit;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading overview data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @focusModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusModeTitle;

  /// No description provided for @historySection.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historySection;

  /// No description provided for @trendsSection.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trendsSection;

  /// No description provided for @timeDistributionSection.
  ///
  /// In en, this message translates to:
  /// **'Time Distribution'**
  String get timeDistributionSection;

  /// No description provided for @sessionHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistorySection;

  /// No description provided for @workSession.
  ///
  /// In en, this message translates to:
  /// **'Work Session'**
  String get workSession;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @dateHeader.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateHeader;

  /// No description provided for @durationHeader.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationHeader;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @focusModeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode Settings'**
  String get focusModeSettingsTitle;

  /// No description provided for @modeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get modeCustom;

  /// No description provided for @modeDeepWork.
  ///
  /// In en, this message translates to:
  /// **'Deep Work (60 min)'**
  String get modeDeepWork;

  /// No description provided for @modeQuickTasks.
  ///
  /// In en, this message translates to:
  /// **'Quick Tasks (25 min)'**
  String get modeQuickTasks;

  /// No description provided for @modeReading.
  ///
  /// In en, this message translates to:
  /// **'Reading (45 min)'**
  String get modeReading;

  /// No description provided for @workDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Duration: {minutes} min'**
  String workDurationLabel(int minutes);

  /// No description provided for @shortBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Break: {minutes} min'**
  String shortBreakLabel(int minutes);

  /// No description provided for @longBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Long Break: {minutes} min'**
  String longBreakLabel(int minutes);

  /// No description provided for @autoStartNextSession.
  ///
  /// In en, this message translates to:
  /// **'Auto-start next session'**
  String get autoStartNextSession;

  /// No description provided for @blockDistractions.
  ///
  /// In en, this message translates to:
  /// **'Block distractions during focus mode'**
  String get blockDistractions;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @errorLoadingFocusModeData.
  ///
  /// In en, this message translates to:
  /// **'Error loading focus mode data: {error}'**
  String errorLoadingFocusModeData(String error);

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get overviewTitle;

  /// No description provided for @startFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Start Focus Mode'**
  String get startFocusMode;

  /// No description provided for @loadingProductivityData.
  ///
  /// In en, this message translates to:
  /// **'Loading your productivity data...'**
  String get loadingProductivityData;

  /// No description provided for @noActivityDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No activity data available yet'**
  String get noActivityDataAvailable;

  /// No description provided for @startUsingApplications.
  ///
  /// In en, this message translates to:
  /// **'Start using your applications to track screen time and productivity.'**
  String get startUsingApplications;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @topApplications.
  ///
  /// In en, this message translates to:
  /// **'Top Applications'**
  String get topApplications;

  /// No description provided for @noAppUsageDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No application usage data available yet'**
  String get noAppUsageDataAvailable;

  /// No description provided for @noApplicationDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No application data available'**
  String get noApplicationDataAvailable;

  /// No description provided for @noCategoryDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No category data available'**
  String get noCategoryDataAvailable;

  /// No description provided for @noApplicationLimitsSet.
  ///
  /// In en, this message translates to:
  /// **'No application limits set'**
  String get noApplicationLimitsSet;

  /// No description provided for @screenLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screenLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @productiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get productiveLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @defaultNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get defaultNone;

  /// No description provided for @defaultTime.
  ///
  /// In en, this message translates to:
  /// **'0h 0m'**
  String get defaultTime;

  /// No description provided for @defaultCount.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get defaultCount;

  /// No description provided for @unknownApp.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownApp;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @versionSection.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionSection;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Color theme of the application (Change Requires Restart)'**
  String get themeDescription;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Language of the application'**
  String get languageDescription;

  /// No description provided for @startupBehaviourTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup Behaviour'**
  String get startupBehaviourTitle;

  /// No description provided for @startupBehaviourDescription.
  ///
  /// In en, this message translates to:
  /// **'Launch at OS startup'**
  String get startupBehaviourDescription;

  /// No description provided for @launchMinimizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch as Minimized'**
  String get launchMinimizedTitle;

  /// No description provided for @launchMinimizedDescription.
  ///
  /// In en, this message translates to:
  /// **'Start the application in System Tray (Recommended for Windows 10)'**
  String get launchMinimizedDescription;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsAllDescription.
  ///
  /// In en, this message translates to:
  /// **'All notifications of the application'**
  String get notificationsAllDescription;

  /// No description provided for @focusModeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusModeNotificationsTitle;

  /// No description provided for @focusModeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for focus mode'**
  String get focusModeNotificationsDescription;

  /// No description provided for @screenTimeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get screenTimeNotificationsTitle;

  /// No description provided for @screenTimeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for screen time restriction'**
  String get screenTimeNotificationsDescription;

  /// No description provided for @appScreenTimeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Screen Time'**
  String get appScreenTimeNotificationsTitle;

  /// No description provided for @appScreenTimeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for application screen time restriction'**
  String get appScreenTimeNotificationsDescription;

  /// No description provided for @frequentAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequent Alerts Interval'**
  String get frequentAlertsTitle;

  /// No description provided for @frequentAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set interval for frequent notifications (minutes)'**
  String get frequentAlertsDescription;

  /// No description provided for @clearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearDataTitle;

  /// No description provided for @clearDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Clear all the history and other related data'**
  String get clearDataDescription;

  /// No description provided for @resetSettingsTitle2.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettingsTitle2;

  /// No description provided for @resetSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset all the settings'**
  String get resetSettingsDescription;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @versionDescription.
  ///
  /// In en, this message translates to:
  /// **'Current version of the app'**
  String get versionDescription;

  /// No description provided for @contactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactButton;

  /// No description provided for @reportBugButton.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBugButton;

  /// No description provided for @submitFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedbackButton;

  /// No description provided for @githubButton.
  ///
  /// In en, this message translates to:
  /// **'Github'**
  String get githubButton;

  /// No description provided for @clearDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Data?'**
  String get clearDataDialogTitle;

  /// No description provided for @clearDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?'**
  String get clearDataDialogContent;

  /// No description provided for @clearDataButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearDataButtonLabel;

  /// No description provided for @resetSettingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsDialogTitle;

  /// No description provided for @resetSettingsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will reset all settings to their default values. Do you want to proceed?'**
  String get resetSettingsDialogContent;

  /// No description provided for @resetButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButtonLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// Title for focus trends chart
  ///
  /// In en, this message translates to:
  /// **'Focus Trends'**
  String get chart_focusTrends;

  /// Label for session count metric
  ///
  /// In en, this message translates to:
  /// **'Session Count'**
  String get chart_sessionCount;

  /// Label for average duration metric
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get chart_avgDuration;

  /// Label for total focus time metric
  ///
  /// In en, this message translates to:
  /// **'Total Focus'**
  String get chart_totalFocus;

  /// Y-axis label for session count
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get chart_yAxis_sessions;

  /// Y-axis label for time in minutes
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get chart_yAxis_minutes;

  /// Generic y-axis label
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get chart_yAxis_value;

  /// Label for percentage change display
  ///
  /// In en, this message translates to:
  /// **'Month-over-month change: '**
  String get chart_monthOverMonthChange;

  /// Label for custom date range
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get chart_customRange;

  /// No description provided for @day_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get day_monday;

  /// No description provided for @day_mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get day_mondayShort;

  /// No description provided for @day_mondayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Mn'**
  String get day_mondayAbbr;

  /// No description provided for @day_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get day_tuesday;

  /// No description provided for @day_tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get day_tuesdayShort;

  /// No description provided for @day_tuesdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get day_tuesdayAbbr;

  /// No description provided for @day_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get day_wednesday;

  /// No description provided for @day_wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get day_wednesdayShort;

  /// No description provided for @day_wednesdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Wd'**
  String get day_wednesdayAbbr;

  /// No description provided for @day_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get day_thursday;

  /// No description provided for @day_thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get day_thursdayShort;

  /// No description provided for @day_thursdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get day_thursdayAbbr;

  /// No description provided for @day_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get day_friday;

  /// No description provided for @day_fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get day_fridayShort;

  /// No description provided for @day_fridayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get day_fridayAbbr;

  /// No description provided for @day_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get day_saturday;

  /// No description provided for @day_saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get day_saturdayShort;

  /// No description provided for @day_saturdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'St'**
  String get day_saturdayAbbr;

  /// No description provided for @day_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get day_sunday;

  /// No description provided for @day_sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get day_sundayShort;

  /// No description provided for @day_sundayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sn'**
  String get day_sundayAbbr;

  /// Hours format
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String time_hours(int count);

  /// Hours and minutes format
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String time_hoursMinutes(int hours, int minutes);

  /// Minutes format for tooltips
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String time_minutesFormat(String count);

  /// Tooltip showing date and screen time
  ///
  /// In en, this message translates to:
  /// **'{date}: {hours}h {minutes}m'**
  String tooltip_dateScreenTime(String date, int hours, int minutes);

  /// Hours format for tooltip fallback
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String tooltip_hoursFormat(String count);

  /// No description provided for @month_january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month_january;

  /// No description provided for @month_januaryShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get month_januaryShort;

  /// No description provided for @month_february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month_february;

  /// No description provided for @month_februaryShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get month_februaryShort;

  /// No description provided for @month_march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month_march;

  /// No description provided for @month_marchShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get month_marchShort;

  /// No description provided for @month_april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month_april;

  /// No description provided for @month_aprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get month_aprilShort;

  /// No description provided for @month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_may;

  /// No description provided for @month_mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_mayShort;

  /// No description provided for @month_june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month_june;

  /// No description provided for @month_juneShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get month_juneShort;

  /// No description provided for @month_july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month_july;

  /// No description provided for @month_julyShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get month_julyShort;

  /// No description provided for @month_august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month_august;

  /// No description provided for @month_augustShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get month_augustShort;

  /// No description provided for @month_september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month_september;

  /// No description provided for @month_septemberShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get month_septemberShort;

  /// No description provided for @month_october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month_october;

  /// No description provided for @month_octoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get month_octoberShort;

  /// No description provided for @month_november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month_november;

  /// No description provided for @month_novemberShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get month_novemberShort;

  /// No description provided for @month_december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month_december;

  /// No description provided for @month_decemberShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get month_decemberShort;

  /// Category filter for all applications
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get categoryDevelopment;

  /// No description provided for @categorySocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get categorySocialMedia;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// No description provided for @categoryWebBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Web Browsing'**
  String get categoryWebBrowsing;

  /// No description provided for @categoryCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get categoryCreative;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryUtility.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get categoryUtility;

  /// No description provided for @categoryUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get categoryUncategorized;

  /// No description provided for @appMicrosoftWord.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Word'**
  String get appMicrosoftWord;

  /// No description provided for @appExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get appExcel;

  /// No description provided for @appPowerPoint.
  ///
  /// In en, this message translates to:
  /// **'PowerPoint'**
  String get appPowerPoint;

  /// No description provided for @appGoogleDocs.
  ///
  /// In en, this message translates to:
  /// **'Google Docs'**
  String get appGoogleDocs;

  /// No description provided for @appNotion.
  ///
  /// In en, this message translates to:
  /// **'Notion'**
  String get appNotion;

  /// No description provided for @appEvernote.
  ///
  /// In en, this message translates to:
  /// **'Evernote'**
  String get appEvernote;

  /// No description provided for @appTrello.
  ///
  /// In en, this message translates to:
  /// **'Trello'**
  String get appTrello;

  /// No description provided for @appAsana.
  ///
  /// In en, this message translates to:
  /// **'Asana'**
  String get appAsana;

  /// No description provided for @appSlack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get appSlack;

  /// No description provided for @appMicrosoftTeams.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Teams'**
  String get appMicrosoftTeams;

  /// No description provided for @appZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get appZoom;

  /// No description provided for @appGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get appGoogleCalendar;

  /// No description provided for @appAppleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get appAppleCalendar;

  /// No description provided for @appVisualStudioCode.
  ///
  /// In en, this message translates to:
  /// **'Visual Studio Code'**
  String get appVisualStudioCode;

  /// No description provided for @appTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get appTerminal;

  /// No description provided for @appCommandPrompt.
  ///
  /// In en, this message translates to:
  /// **'Command Prompt'**
  String get appCommandPrompt;

  /// No description provided for @appChrome.
  ///
  /// In en, this message translates to:
  /// **'Chrome'**
  String get appChrome;

  /// No description provided for @appFirefox.
  ///
  /// In en, this message translates to:
  /// **'Firefox'**
  String get appFirefox;

  /// No description provided for @appSafari.
  ///
  /// In en, this message translates to:
  /// **'Safari'**
  String get appSafari;

  /// No description provided for @appEdge.
  ///
  /// In en, this message translates to:
  /// **'Edge'**
  String get appEdge;

  /// No description provided for @appOpera.
  ///
  /// In en, this message translates to:
  /// **'Opera'**
  String get appOpera;

  /// No description provided for @appBrave.
  ///
  /// In en, this message translates to:
  /// **'Brave'**
  String get appBrave;

  /// No description provided for @appNetflix.
  ///
  /// In en, this message translates to:
  /// **'Netflix'**
  String get appNetflix;

  /// No description provided for @appYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get appYouTube;

  /// No description provided for @appSpotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get appSpotify;

  /// No description provided for @appAppleMusic.
  ///
  /// In en, this message translates to:
  /// **'Apple Music'**
  String get appAppleMusic;

  /// No description provided for @appCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get appCalculator;

  /// No description provided for @appNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appNotes;

  /// No description provided for @appSystemPreferences.
  ///
  /// In en, this message translates to:
  /// **'System Preferences'**
  String get appSystemPreferences;

  /// No description provided for @appTaskManager.
  ///
  /// In en, this message translates to:
  /// **'Task Manager'**
  String get appTaskManager;

  /// No description provided for @appFileExplorer.
  ///
  /// In en, this message translates to:
  /// **'File Explorer'**
  String get appFileExplorer;

  /// No description provided for @appDropbox.
  ///
  /// In en, this message translates to:
  /// **'Dropbox'**
  String get appDropbox;

  /// No description provided for @appGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get appGoogleDrive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
