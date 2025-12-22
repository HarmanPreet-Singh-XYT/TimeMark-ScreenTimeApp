// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appWindowTitle => 'تايم مارك - تتبع وقت الشاشة واستخدام التطبيقات';

  @override
  String get appName => 'تايم مارك';

  @override
  String get appTitle => 'وقت شاشة منتج';

  @override
  String get sidebarTitle => 'وقت الشاشة';

  @override
  String get sidebarSubtitle => 'مفتوح المصدر';

  @override
  String get trayShowWindow => 'إظهار النافذة';

  @override
  String get trayStartFocusMode => 'بدء وضع التركيز';

  @override
  String get trayStopFocusMode => 'إيقاف وضع التركيز';

  @override
  String get trayReports => 'التقارير';

  @override
  String get trayAlertsLimits => 'التنبيهات والحدود';

  @override
  String get trayApplications => 'التطبيقات';

  @override
  String get trayDisableNotifications => 'تعطيل الإشعارات';

  @override
  String get trayEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get trayVersionPrefix => 'الإصدار: ';

  @override
  String trayVersion(String version) {
    return 'الإصدار: $version';
  }

  @override
  String get trayExit => 'خروج';

  @override
  String get navOverview => 'نظرة عامة';

  @override
  String get navApplications => 'التطبيقات';

  @override
  String get navAlertsLimits => 'التنبيهات والحدود';

  @override
  String get navReports => 'التقارير';

  @override
  String get navFocusMode => 'وضع التركيز';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navHelp => 'المساعدة';

  @override
  String get helpTitle => 'المساعدة';

  @override
  String get faqCategoryGeneral => 'أسئلة عامة';

  @override
  String get faqCategoryApplications => 'إدارة التطبيقات';

  @override
  String get faqCategoryReports => 'تحليلات الاستخدام والتقارير';

  @override
  String get faqCategoryAlerts => 'التنبيهات والحدود';

  @override
  String get faqCategoryFocusMode => 'وضع التركيز ومؤقت بومودورو';

  @override
  String get faqCategorySettings => 'الإعدادات والتخصيص';

  @override
  String get faqCategoryTroubleshooting => 'استكشاف الأخطاء وإصلاحها';

  @override
  String get faqGeneralQ1 => 'كيف يتتبع هذا التطبيق وقت الشاشة؟';

  @override
  String get faqGeneralA1 =>
      'يراقب التطبيق استخدام جهازك في الوقت الفعلي، ويتتبع الوقت المستغرق في التطبيقات المختلفة. يوفر رؤى شاملة حول عاداتك الرقمية، بما في ذلك إجمالي وقت الشاشة والوقت المنتج واستخدام كل تطبيق.';

  @override
  String get faqGeneralQ2 => 'ما الذي يجعل التطبيق \'منتجاً\'؟';

  @override
  String get faqGeneralA2 =>
      'يمكنك تحديد التطبيقات كمنتجة يدوياً في قسم \'التطبيقات\'. تساهم التطبيقات المنتجة في نقاط الإنتاجية الخاصة بك، والتي تحسب نسبة وقت الشاشة المستغرق في التطبيقات المتعلقة بالعمل أو المفيدة.';

  @override
  String get faqGeneralQ3 => 'ما مدى دقة تتبع وقت الشاشة؟';

  @override
  String get faqGeneralA3 =>
      'يستخدم التطبيق التتبع على مستوى النظام لتوفير قياس دقيق لاستخدام جهازك. يلتقط وقت المقدمة لكل تطبيق مع تأثير ضئيل على البطارية.';

  @override
  String get faqGeneralQ4 => 'هل يمكنني تخصيص تصنيف التطبيقات؟';

  @override
  String get faqGeneralA4 =>
      'بالتأكيد! يمكنك إنشاء فئات مخصصة وتعيين التطبيقات لفئات محددة وتعديل هذه التعيينات بسهولة في قسم \'التطبيقات\'. يساعد هذا في إنشاء تحليلات استخدام أكثر فائدة.';

  @override
  String get faqGeneralQ5 =>
      'ما الرؤى التي يمكنني الحصول عليها من هذا التطبيق؟';

  @override
  String get faqGeneralA5 =>
      'يقدم التطبيق رؤى شاملة تشمل نقاط الإنتاجية وأنماط الاستخدام حسب الوقت من اليوم واستخدام التطبيقات التفصيلي وتتبع جلسات التركيز والتحليلات المرئية مثل الرسوم البيانية والمخططات الدائرية لمساعدتك على فهم وتحسين عاداتك الرقمية.';

  @override
  String get faqAppsQ1 => 'كيف أخفي تطبيقات معينة من التتبع؟';

  @override
  String get faqAppsA1 => 'في قسم \'التطبيقات\'، يمكنك تبديل رؤية التطبيقات.';

  @override
  String get faqAppsQ2 => 'هل يمكنني البحث وتصفية التطبيقات؟';

  @override
  String get faqAppsA2 =>
      'نعم، يتضمن قسم التطبيقات وظيفة البحث وخيارات التصفية. يمكنك تصفية التطبيقات حسب الفئة وحالة الإنتاجية وحالة التتبع والرؤية.';

  @override
  String get faqAppsQ3 => 'ما خيارات التحرير المتاحة للتطبيقات؟';

  @override
  String get faqAppsA3 =>
      'لكل تطبيق، يمكنك تحرير: تعيين الفئة وحالة الإنتاجية وتتبع الاستخدام والرؤية في التقارير وتعيين حدود زمنية يومية فردية.';

  @override
  String get faqAppsQ4 => 'كيف يتم تحديد فئات التطبيقات؟';

  @override
  String get faqAppsA4 =>
      'الفئات الأولية مقترحة من النظام، لكن لديك السيطرة الكاملة لإنشاء وتعديل وتعيين فئات مخصصة بناءً على سير عملك وتفضيلاتك.';

  @override
  String get faqReportsQ1 => 'ما أنواع التقارير المتاحة؟';

  @override
  String get faqReportsA1 =>
      'تشمل التقارير: إجمالي وقت الشاشة، الوقت المنتج، التطبيقات الأكثر استخداماً، جلسات التركيز، رسم بياني لوقت الشاشة اليومي، مخطط دائري لتوزيع الفئات، استخدام التطبيقات التفصيلي، اتجاهات الاستخدام الأسبوعية، وتحليل أنماط الاستخدام حسب الوقت من اليوم.';

  @override
  String get faqReportsQ2 => 'ما مدى تفصيل تقارير استخدام التطبيقات؟';

  @override
  String get faqReportsA2 =>
      'تعرض تقارير استخدام التطبيقات التفصيلية: اسم التطبيق والفئة وإجمالي الوقت المستغرق وحالة الإنتاجية، وتوفر قسم \'الإجراءات\' مع رؤى أعمق مثل ملخص الاستخدام والحدود اليومية واتجاهات الاستخدام ومقاييس الإنتاجية.';

  @override
  String get faqReportsQ3 => 'هل يمكنني تحليل اتجاهات الاستخدام بمرور الوقت؟';

  @override
  String get faqReportsA3 =>
      'نعم! يوفر التطبيق مقارنات أسبوعية، تعرض رسوماً بيانية للاستخدام على مدى الأسابيع الماضية ومتوسط الاستخدام اليومي وأطول الجلسات والإجماليات الأسبوعية لمساعدتك على تتبع عاداتك الرقمية.';

  @override
  String get faqReportsQ4 => 'ما هو تحليل \'نمط الاستخدام\'؟';

  @override
  String get faqReportsA4 =>
      'يقسم نمط الاستخدام وقت الشاشة إلى فترات الصباح والظهر والمساء والليل. يساعدك هذا على فهم متى تكون أكثر نشاطاً على جهازك وتحديد المجالات المحتملة للتحسين.';

  @override
  String get faqAlertsQ1 => 'ما مدى دقة حدود وقت الشاشة؟';

  @override
  String get faqAlertsA1 =>
      'يمكنك تعيين حدود يومية إجمالية لوقت الشاشة وحدود فردية للتطبيقات. يمكن تكوين الحدود بالساعات والدقائق، مع خيارات لإعادة التعيين أو التعديل حسب الحاجة.';

  @override
  String get faqAlertsQ2 => 'ما خيارات الإشعارات المتاحة؟';

  @override
  String get faqAlertsA2 =>
      'يقدم التطبيق أنواعاً متعددة من الإشعارات: تنبيهات النظام عند تجاوز وقت الشاشة، تنبيهات متكررة بفترات قابلة للتخصيص (1 أو 5 أو 15 أو 30 أو 60 دقيقة)، ومفاتيح تبديل لوضع التركيز ووقت الشاشة والإشعارات الخاصة بالتطبيقات.';

  @override
  String get faqAlertsQ3 => 'هل يمكنني تخصيص تنبيهات الحدود؟';

  @override
  String get faqAlertsA3 =>
      'نعم، يمكنك تخصيص تردد التنبيهات وتمكين/تعطيل أنواع محددة من التنبيهات وتعيين حدود مختلفة لوقت الشاشة الإجمالي والتطبيقات الفردية.';

  @override
  String get faqFocusQ1 => 'ما أنواع أوضاع التركيز المتاحة؟';

  @override
  String get faqFocusA1 =>
      'تشمل الأوضاع المتاحة العمل العميق (جلسات تركيز أطول) والمهام السريعة (فترات عمل قصيرة) ووضع القراءة. يساعدك كل وضع على هيكلة عملك وأوقات الراحة بفعالية.';

  @override
  String get faqFocusQ2 => 'ما مدى مرونة مؤقت بومودورو؟';

  @override
  String get faqFocusA2 =>
      'المؤقت قابل للتخصيص بدرجة عالية. يمكنك ضبط مدة العمل وطول الاستراحة القصيرة ومدة الاستراحة الطويلة. تشمل الخيارات الإضافية البدء التلقائي للجلسات التالية وإعدادات الإشعارات.';

  @override
  String get faqFocusQ3 => 'ماذا يظهر سجل وضع التركيز؟';

  @override
  String get faqFocusA3 =>
      'يتتبع سجل وضع التركيز جلسات التركيز اليومية، ويعرض عدد الجلسات في اليوم ورسم بياني للاتجاهات ومتوسط مدة الجلسة وإجمالي وقت التركيز ومخطط دائري لتوزيع الوقت يقسم جلسات العمل والاستراحات القصيرة والاستراحات الطويلة.';

  @override
  String get faqFocusQ4 => 'هل يمكنني تتبع تقدم جلسة التركيز؟';

  @override
  String get faqFocusA4 =>
      'يتميز التطبيق بواجهة مؤقت دائرية مع أزرار التشغيل/الإيقاف وإعادة التحميل والإعدادات. يمكنك بسهولة تتبع وإدارة جلسات التركيز بعناصر تحكم بديهية.';

  @override
  String get faqSettingsQ1 => 'ما خيارات التخصيص المتاحة؟';

  @override
  String get faqSettingsA1 =>
      'يشمل التخصيص اختيار السمة (النظام، فاتح، داكن) وإعدادات اللغة وسلوك بدء التشغيل وعناصر تحكم شاملة في الإشعارات وخيارات إدارة البيانات مثل مسح البيانات أو إعادة تعيين الإعدادات.';

  @override
  String get faqSettingsQ2 => 'كيف أقدم ملاحظات أو أبلغ عن مشاكل؟';

  @override
  String get faqSettingsA2 =>
      'في أسفل قسم الإعدادات، ستجد أزراراً للإبلاغ عن خطأ أو إرسال ملاحظات أو الاتصال بالدعم. ستوجهك هذه إلى قنوات الدعم المناسبة.';

  @override
  String get faqSettingsQ3 => 'ماذا يحدث عند مسح البيانات؟';

  @override
  String get faqSettingsA3 =>
      'سيؤدي مسح البيانات إلى إعادة تعيين جميع إحصائيات الاستخدام وسجل جلسات التركيز والإعدادات المخصصة. هذا مفيد للبدء من جديد أو استكشاف الأخطاء وإصلاحها.';

  @override
  String get faqTroubleQ1 => 'البيانات لا تظهر، خطأ عدم فتح hive';

  @override
  String get faqTroubleA1 =>
      'المشكلة معروفة، الحل المؤقت هو مسح البيانات من خلال الإعدادات وإذا لم ينجح ذلك فانتقل إلى المستندات واحذف الملفات التالية إذا كانت موجودة - harman_screentime_app_usage_box.hive و harman_screentime_app_usage.lock، يُنصح أيضاً بتحديث التطبيق إلى أحدث إصدار.';

  @override
  String get faqTroubleQ2 => 'التطبيق يفتح عند كل بدء تشغيل، ماذا أفعل؟';

  @override
  String get faqTroubleA2 =>
      'هذه مشكلة معروفة تحدث في ويندوز 10، الحل المؤقت هو تمكين التشغيل كمصغر في الإعدادات حتى يتم تشغيله كمصغر.';

  @override
  String get usageAnalytics => 'تحليلات الاستخدام';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get lifetime => 'كل الوقت';

  @override
  String get custom => 'مخصص';

  @override
  String get loadingAnalyticsData => 'جارٍ تحميل بيانات التحليلات...';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get failedToInitialize =>
      'فشل في تهيئة التحليلات. يرجى إعادة تشغيل التطبيق.';

  @override
  String unexpectedError(String error) {
    return 'حدث خطأ غير متوقع: $error. يرجى المحاولة لاحقاً.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'خطأ في تحميل بيانات التحليلات: $error. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
  }

  @override
  String get customDialogTitle => 'مخصص';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get specificDate => 'تاريخ محدد';

  @override
  String get startDate => 'تاريخ البداية: ';

  @override
  String get endDate => 'تاريخ النهاية: ';

  @override
  String get date => 'التاريخ: ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get ok => 'موافق';

  @override
  String get invalidDateRange => 'نطاق تاريخ غير صالح';

  @override
  String get startDateBeforeEndDate =>
      'يجب أن يكون تاريخ البداية قبل أو يساوي تاريخ النهاية.';

  @override
  String get totalScreenTime => 'إجمالي وقت الشاشة';

  @override
  String get productiveTime => 'الوقت المنتج';

  @override
  String get mostUsedApp => 'التطبيق الأكثر استخداماً';

  @override
  String get focusSessions => 'جلسات التركيز';

  @override
  String positiveComparison(String percent) {
    return '+$percent% مقارنة بالفترة السابقة';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% مقارنة بالفترة السابقة';
  }

  @override
  String iconLabel(String title) {
    return 'أيقونة $title';
  }

  @override
  String get dailyScreenTime => 'وقت الشاشة اليومي';

  @override
  String get categoryBreakdown => 'توزيع الفئات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String sectionLabel(String title) {
    return 'قسم $title';
  }

  @override
  String get detailedApplicationUsage => 'استخدام التطبيقات التفصيلي';

  @override
  String get searchApplications => 'البحث عن تطبيقات';

  @override
  String get nameHeader => 'الاسم';

  @override
  String get categoryHeader => 'الفئة';

  @override
  String get totalTimeHeader => 'إجمالي الوقت';

  @override
  String get productivityHeader => 'الإنتاجية';

  @override
  String get actionsHeader => 'الإجراءات';

  @override
  String sortByOption(String option) {
    return 'ترتيب حسب: $option';
  }

  @override
  String get sortByName => 'الاسم';

  @override
  String get sortByCategory => 'الفئة';

  @override
  String get sortByUsage => 'الاستخدام';

  @override
  String get productive => 'منتج';

  @override
  String get nonProductive => 'غير منتج';

  @override
  String get noApplicationsMatch => 'لا توجد تطبيقات تطابق معايير البحث';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get usageSummary => 'ملخص الاستخدام';

  @override
  String get usageOverPastWeek => 'الاستخدام خلال الأسبوع الماضي';

  @override
  String get usagePatternByTimeOfDay => 'نمط الاستخدام حسب الوقت من اليوم';

  @override
  String get patternAnalysis => 'تحليل الأنماط';

  @override
  String get today => 'اليوم';

  @override
  String get dailyLimit => 'الحد اليومي';

  @override
  String get noLimit => 'بدون حد';

  @override
  String get usageTrend => 'اتجاه الاستخدام';

  @override
  String get productivity => 'الإنتاجية';

  @override
  String get increasing => 'متزايد';

  @override
  String get decreasing => 'متناقص';

  @override
  String get stable => 'مستقر';

  @override
  String get avgDailyUsage => 'متوسط الاستخدام اليومي';

  @override
  String get longestSession => 'أطول جلسة';

  @override
  String get weeklyTotal => 'الإجمالي الأسبوعي';

  @override
  String get noHistoricalData => 'لا توجد بيانات تاريخية متاحة';

  @override
  String get morning => 'الصباح (6-12)';

  @override
  String get afternoon => 'الظهر (12-5)';

  @override
  String get evening => 'المساء (5-9)';

  @override
  String get night => 'الليل (9-6)';

  @override
  String get usageInsights => 'رؤى الاستخدام';

  @override
  String get limitStatus => 'حالة الحد';

  @override
  String get close => 'إغلاق';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'تستخدم $appName بشكل أساسي خلال $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'زاد استخدامك بشكل ملحوظ ($percentage%) مقارنة بالفترة السابقة.';
  }

  @override
  String get trendingUpward =>
      'استخدامك يتجه نحو الارتفاع مقارنة بالفترة السابقة.';

  @override
  String significantDecrease(String percentage) {
    return 'انخفض استخدامك بشكل ملحوظ ($percentage%) مقارنة بالفترة السابقة.';
  }

  @override
  String get trendingDownward =>
      'استخدامك يتجه نحو الانخفاض مقارنة بالفترة السابقة.';

  @override
  String get consistentUsage => 'كان استخدامك متسقاً مقارنة بالفترة السابقة.';

  @override
  String get markedAsProductive => 'هذا مُعلَّم كتطبيق منتج في إعداداتك.';

  @override
  String get markedAsNonProductive =>
      'هذا مُعلَّم كتطبيق غير منتج في إعداداتك.';

  @override
  String mostActiveTime(String time) {
    return 'وقتك الأكثر نشاطاً هو حوالي الساعة $time.';
  }

  @override
  String get noLimitSet => 'لم يتم تعيين حد استخدام لهذا التطبيق.';

  @override
  String get limitReached => 'لقد وصلت إلى الحد اليومي لهذا التطبيق.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'أنت على وشك الوصول إلى الحد اليومي مع بقاء $remainingTime فقط.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'لقد استخدمت $percent% من الحد اليومي مع بقاء $remainingTime.';
  }

  @override
  String remainingTime(String time) {
    return 'لديك $time متبقٍ من الحد اليومي.';
  }

  @override
  String get todayChart => 'اليوم';

  @override
  String hourPeriodAM(int hour) {
    return '$hour صباحاً';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour مساءً';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesد';
  }

  @override
  String get alertsLimitsTitle => 'التنبيهات والحدود';

  @override
  String get notificationsSettings => 'إعدادات الإشعارات';

  @override
  String get overallScreenTimeLimit => 'الحد الإجمالي لوقت الشاشة';

  @override
  String get applicationLimits => 'حدود التطبيقات';

  @override
  String get popupAlerts => 'التنبيهات المنبثقة';

  @override
  String get frequentAlerts => 'التنبيهات المتكررة';

  @override
  String get soundAlerts => 'التنبيهات الصوتية';

  @override
  String get systemAlerts => 'تنبيهات النظام';

  @override
  String get dailyTotalLimit => 'الحد اليومي الإجمالي: ';

  @override
  String get hours => 'الساعات: ';

  @override
  String get minutes => 'الدقائق: ';

  @override
  String get currentUsage => 'الاستخدام الحالي: ';

  @override
  String get tableName => 'الاسم';

  @override
  String get tableCategory => 'الفئة';

  @override
  String get tableDailyLimit => 'الحد اليومي';

  @override
  String get tableCurrentUsage => 'الاستخدام الحالي';

  @override
  String get tableStatus => 'الحالة';

  @override
  String get tableActions => 'الإجراءات';

  @override
  String get addLimit => 'إضافة حد';

  @override
  String get noApplicationsToDisplay => 'لا توجد تطبيقات للعرض';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusOff => 'متوقف';

  @override
  String get durationNone => 'لا يوجد';

  @override
  String get addApplicationLimit => 'إضافة حد للتطبيق';

  @override
  String get selectApplication => 'اختر تطبيقاً';

  @override
  String get selectApplicationPlaceholder => 'اختر تطبيقاً';

  @override
  String get enableLimit => 'تفعيل الحد: ';

  @override
  String editLimitTitle(String appName) {
    return 'تعديل الحد: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'فشل في تحميل البيانات: $error';
  }

  @override
  String get resetSettingsTitle => 'إعادة تعيين الإعدادات؟';

  @override
  String get resetSettingsContent =>
      'إذا قمت بإعادة تعيين الإعدادات، لن تتمكن من استعادتها. هل تريد إعادة التعيين؟';

  @override
  String get resetAll => 'إعادة تعيين الكل';

  @override
  String get refresh => 'تحديث';

  @override
  String get save => 'حفظ';

  @override
  String get add => 'إضافة';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get applicationsTitle => 'التطبيقات';

  @override
  String get searchApplication => 'البحث عن تطبيق';

  @override
  String get tracking => 'التتبع';

  @override
  String get hiddenVisible => 'مخفي/مرئي';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get allCategories => 'الكل';

  @override
  String get tableScreenTime => 'وقت الشاشة';

  @override
  String get tableTracking => 'التتبع';

  @override
  String get tableHidden => 'مخفي';

  @override
  String get tableEdit => 'تعديل';

  @override
  String editAppTitle(String appName) {
    return 'تعديل $appName';
  }

  @override
  String get categorySection => 'الفئة';

  @override
  String get customCategory => 'مخصص';

  @override
  String get customCategoryPlaceholder => 'أدخل اسم الفئة المخصصة';

  @override
  String get uncategorized => 'غير مصنف';

  @override
  String get isProductive => 'منتج';

  @override
  String get trackUsage => 'تتبع الاستخدام';

  @override
  String get visibleInReports => 'مرئي في التقارير';

  @override
  String get timeLimitsSection => 'حدود الوقت';

  @override
  String get enableDailyLimit => 'تفعيل الحد اليومي';

  @override
  String get setDailyTimeLimit => 'تعيين الحد الزمني اليومي:';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String errorLoadingData(String error) {
    return 'خطأ في تحميل بيانات النظرة العامة: $error';
  }

  @override
  String get focusModeTitle => 'وضع التركيز';

  @override
  String get historySection => 'السجل';

  @override
  String get trendsSection => 'الاتجاهات';

  @override
  String get timeDistributionSection => 'توزيع الوقت';

  @override
  String get sessionHistorySection => 'سجل الجلسات';

  @override
  String get workSession => 'جلسة عمل';

  @override
  String get shortBreak => 'استراحة قصيرة';

  @override
  String get longBreak => 'استراحة طويلة';

  @override
  String get dateHeader => 'التاريخ';

  @override
  String get durationHeader => 'المدة';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get focusModeSettingsTitle => 'إعدادات وضع التركيز';

  @override
  String get modeCustom => 'مخصص';

  @override
  String get modeDeepWork => 'عمل عميق (60 دقيقة)';

  @override
  String get modeQuickTasks => 'مهام سريعة (25 دقيقة)';

  @override
  String get modeReading => 'قراءة (45 دقيقة)';

  @override
  String workDurationLabel(int minutes) {
    return 'مدة العمل: $minutes دقيقة';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'استراحة قصيرة: $minutes دقيقة';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'استراحة طويلة: $minutes دقيقة';
  }

  @override
  String get autoStartNextSession => 'البدء التلقائي للجلسة التالية';

  @override
  String get blockDistractions => 'حظر المشتتات أثناء وضع التركيز';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get saved => 'تم الحفظ';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'خطأ في تحميل بيانات وضع التركيز: $error';
  }

  @override
  String get overviewTitle => 'نظرة عامة على اليوم';

  @override
  String get startFocusMode => 'بدء وضع التركيز';

  @override
  String get loadingProductivityData => 'جارٍ تحميل بيانات الإنتاجية...';

  @override
  String get noActivityDataAvailable => 'لا توجد بيانات نشاط متاحة بعد';

  @override
  String get startUsingApplications =>
      'ابدأ باستخدام تطبيقاتك لتتبع وقت الشاشة والإنتاجية.';

  @override
  String get refreshData => 'تحديث البيانات';

  @override
  String get topApplications => 'أكثر التطبيقات استخداماً';

  @override
  String get noAppUsageDataAvailable =>
      'لا توجد بيانات استخدام التطبيقات متاحة بعد';

  @override
  String get noApplicationDataAvailable => 'لا توجد بيانات تطبيقات متاحة';

  @override
  String get noCategoryDataAvailable => 'لا توجد بيانات فئات متاحة';

  @override
  String get noApplicationLimitsSet => 'لم يتم تعيين حدود للتطبيقات';

  @override
  String get screenLabel => 'الشاشة';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get productiveLabel => 'منتج';

  @override
  String get scoreLabel => 'النتيجة';

  @override
  String get defaultNone => 'لا يوجد';

  @override
  String get defaultTime => '0س 0د';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'غير معروف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get generalSection => 'عام';

  @override
  String get notificationsSection => 'الإشعارات';

  @override
  String get dataSection => 'البيانات';

  @override
  String get versionSection => 'الإصدار';

  @override
  String get themeTitle => 'السمة';

  @override
  String get themeDescription => 'سمة ألوان التطبيق (يتطلب إعادة التشغيل)';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageDescription => 'لغة التطبيق';

  @override
  String get startupBehaviourTitle => 'سلوك بدء التشغيل';

  @override
  String get startupBehaviourDescription => 'التشغيل عند بدء نظام التشغيل';

  @override
  String get launchMinimizedTitle => 'التشغيل كمصغر';

  @override
  String get launchMinimizedDescription =>
      'بدء التطبيق في شريط النظام (موصى به لويندوز 10)';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsAllDescription => 'جميع إشعارات التطبيق';

  @override
  String get focusModeNotificationsTitle => 'وضع التركيز';

  @override
  String get focusModeNotificationsDescription => 'جميع إشعارات وضع التركيز';

  @override
  String get screenTimeNotificationsTitle => 'وقت الشاشة';

  @override
  String get screenTimeNotificationsDescription =>
      'جميع إشعارات تقييد وقت الشاشة';

  @override
  String get appScreenTimeNotificationsTitle => 'وقت شاشة التطبيق';

  @override
  String get appScreenTimeNotificationsDescription =>
      'جميع إشعارات تقييد وقت شاشة التطبيق';

  @override
  String get frequentAlertsTitle => 'فترة التنبيهات المتكررة';

  @override
  String get frequentAlertsDescription =>
      'تعيين فترة الإشعارات المتكررة (بالدقائق)';

  @override
  String get clearDataTitle => 'مسح البيانات';

  @override
  String get clearDataDescription => 'مسح جميع السجلات والبيانات ذات الصلة';

  @override
  String get resetSettingsTitle2 => 'إعادة تعيين الإعدادات';

  @override
  String get resetSettingsDescription => 'إعادة تعيين جميع الإعدادات';

  @override
  String get versionTitle => 'الإصدار';

  @override
  String get versionDescription => 'الإصدار الحالي للتطبيق';

  @override
  String get contactButton => 'اتصل بنا';

  @override
  String get reportBugButton => 'الإبلاغ عن خطأ';

  @override
  String get submitFeedbackButton => 'إرسال ملاحظات';

  @override
  String get githubButton => 'جيت هب';

  @override
  String get clearDataDialogTitle => 'مسح البيانات؟';

  @override
  String get clearDataDialogContent =>
      'سيؤدي هذا إلى مسح جميع السجلات والبيانات ذات الصلة. لن تتمكن من استعادتها. هل تريد المتابعة؟';

  @override
  String get clearDataButtonLabel => 'مسح البيانات';

  @override
  String get resetSettingsDialogTitle => 'إعادة تعيين الإعدادات؟';

  @override
  String get resetSettingsDialogContent =>
      'سيؤدي هذا إلى إعادة تعيين جميع الإعدادات إلى قيمها الافتراضية. هل تريد المتابعة؟';

  @override
  String get resetButtonLabel => 'إعادة تعيين';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String couldNotLaunchUrl(String url) {
    return 'تعذر فتح $url';
  }

  @override
  String errorMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get chart_focusTrends => 'اتجاهات التركيز';

  @override
  String get chart_sessionCount => 'عدد الجلسات';

  @override
  String get chart_avgDuration => 'متوسط المدة';

  @override
  String get chart_totalFocus => 'إجمالي التركيز';

  @override
  String get chart_yAxis_sessions => 'الجلسات';

  @override
  String get chart_yAxis_minutes => 'الدقائق';

  @override
  String get chart_yAxis_value => 'القيمة';

  @override
  String get chart_monthOverMonthChange => 'التغيير من شهر لآخر: ';

  @override
  String get chart_customRange => 'نطاق مخصص';

  @override
  String get day_monday => 'الإثنين';

  @override
  String get day_mondayShort => 'إثن';

  @override
  String get day_mondayAbbr => 'ن';

  @override
  String get day_tuesday => 'الثلاثاء';

  @override
  String get day_tuesdayShort => 'ثلا';

  @override
  String get day_tuesdayAbbr => 'ث';

  @override
  String get day_wednesday => 'الأربعاء';

  @override
  String get day_wednesdayShort => 'أرب';

  @override
  String get day_wednesdayAbbr => 'ر';

  @override
  String get day_thursday => 'الخميس';

  @override
  String get day_thursdayShort => 'خمي';

  @override
  String get day_thursdayAbbr => 'خ';

  @override
  String get day_friday => 'الجمعة';

  @override
  String get day_fridayShort => 'جمع';

  @override
  String get day_fridayAbbr => 'ج';

  @override
  String get day_saturday => 'السبت';

  @override
  String get day_saturdayShort => 'سبت';

  @override
  String get day_saturdayAbbr => 'س';

  @override
  String get day_sunday => 'الأحد';

  @override
  String get day_sundayShort => 'أحد';

  @override
  String get day_sundayAbbr => 'ح';

  @override
  String time_hours(int count) {
    return '$countس';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count دقيقة';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursس $minutesد';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count ساعة';
  }

  @override
  String get month_january => 'يناير';

  @override
  String get month_januaryShort => 'ينا';

  @override
  String get month_february => 'فبراير';

  @override
  String get month_februaryShort => 'فبر';

  @override
  String get month_march => 'مارس';

  @override
  String get month_marchShort => 'مار';

  @override
  String get month_april => 'أبريل';

  @override
  String get month_aprilShort => 'أبر';

  @override
  String get month_may => 'مايو';

  @override
  String get month_mayShort => 'ماي';

  @override
  String get month_june => 'يونيو';

  @override
  String get month_juneShort => 'يون';

  @override
  String get month_july => 'يوليو';

  @override
  String get month_julyShort => 'يول';

  @override
  String get month_august => 'أغسطس';

  @override
  String get month_augustShort => 'أغس';

  @override
  String get month_september => 'سبتمبر';

  @override
  String get month_septemberShort => 'سبت';

  @override
  String get month_october => 'أكتوبر';

  @override
  String get month_octoberShort => 'أكت';

  @override
  String get month_november => 'نوفمبر';

  @override
  String get month_novemberShort => 'نوف';

  @override
  String get month_december => 'ديسمبر';

  @override
  String get month_decemberShort => 'ديس';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryProductivity => 'الإنتاجية';

  @override
  String get categoryDevelopment => 'التطوير';

  @override
  String get categorySocialMedia => 'وسائل التواصل الاجتماعي';

  @override
  String get categoryEntertainment => 'الترفيه';

  @override
  String get categoryGaming => 'الألعاب';

  @override
  String get categoryCommunication => 'التواصل';

  @override
  String get categoryWebBrowsing => 'تصفح الويب';

  @override
  String get categoryCreative => 'الإبداع';

  @override
  String get categoryEducation => 'التعليم';

  @override
  String get categoryUtility => 'الأدوات المساعدة';

  @override
  String get categoryUncategorized => 'غير مصنف';

  @override
  String get appMicrosoftWord => 'مايكروسوفت وورد';

  @override
  String get appExcel => 'إكسل';

  @override
  String get appPowerPoint => 'باوربوينت';

  @override
  String get appGoogleDocs => 'مستندات جوجل';

  @override
  String get appNotion => 'نوشن';

  @override
  String get appEvernote => 'إيفرنوت';

  @override
  String get appTrello => 'تريلو';

  @override
  String get appAsana => 'أسانا';

  @override
  String get appSlack => 'سلاك';

  @override
  String get appMicrosoftTeams => 'مايكروسوفت تيمز';

  @override
  String get appZoom => 'زووم';

  @override
  String get appGoogleCalendar => 'تقويم جوجل';

  @override
  String get appAppleCalendar => 'التقويم';

  @override
  String get appVisualStudioCode => 'فيجوال ستوديو كود';

  @override
  String get appTerminal => 'الطرفية';

  @override
  String get appCommandPrompt => 'موجه الأوامر';

  @override
  String get appChrome => 'كروم';

  @override
  String get appFirefox => 'فايرفوكس';

  @override
  String get appSafari => 'سفاري';

  @override
  String get appEdge => 'إيدج';

  @override
  String get appOpera => 'أوبرا';

  @override
  String get appBrave => 'بريف';

  @override
  String get appNetflix => 'نتفليكس';

  @override
  String get appYouTube => 'يوتيوب';

  @override
  String get appSpotify => 'سبوتيفاي';

  @override
  String get appAppleMusic => 'آبل ميوزك';

  @override
  String get appCalculator => 'الآلة الحاسبة';

  @override
  String get appNotes => 'الملاحظات';

  @override
  String get appSystemPreferences => 'تفضيلات النظام';

  @override
  String get appTaskManager => 'إدارة المهام';

  @override
  String get appFileExplorer => 'مستكشف الملفات';

  @override
  String get appDropbox => 'دروب بوكس';

  @override
  String get appGoogleDrive => 'جوجل درايف';

  @override
  String get loadingApplication => 'جارٍ تحميل التطبيق...';

  @override
  String get loadingData => 'جارٍ تحميل البيانات...';

  @override
  String get reportsError => 'خطأ';

  @override
  String get reportsRetry => 'إعادة المحاولة';

  @override
  String get backupRestoreSection => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupRestoreTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get exportDataTitle => 'تصدير البيانات';

  @override
  String get exportDataDescription => 'إنشاء نسخة احتياطية من جميع بياناتك';

  @override
  String get importDataTitle => 'استيراد البيانات';

  @override
  String get importDataDescription => 'الاستعادة من ملف النسخ الاحتياطي';

  @override
  String get exportButton => 'تصدير';

  @override
  String get importButton => 'استيراد';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get noButton => 'لا';

  @override
  String get shareButton => 'مشاركة';

  @override
  String get exportStarting => 'جارٍ بدء التصدير...';

  @override
  String get exportSuccessful =>
      'تم التصدير بنجاح! تم حفظ الملف في المستندات/TimeMark-Backups';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String get exportComplete => 'اكتمل التصدير';

  @override
  String get shareBackupQuestion => 'هل تريد مشاركة ملف النسخ الاحتياطي؟';

  @override
  String get importStarting => 'جارٍ بدء الاستيراد...';

  @override
  String get importSuccessful => 'تم الاستيراد بنجاح!';

  @override
  String get importFailed => 'فشل الاستيراد';

  @override
  String get importOptionsTitle => 'خيارات الاستيراد';

  @override
  String get importOptionsQuestion => 'كيف تريد استيراد البيانات؟';

  @override
  String get replaceModeTitle => 'استبدال';

  @override
  String get replaceModeDescription => 'استبدال جميع البيانات الموجودة';

  @override
  String get mergeModeTitle => 'دمج';

  @override
  String get mergeModeDescription => 'الدمج مع البيانات الموجودة';

  @override
  String get appendModeTitle => 'إلحاق';

  @override
  String get appendModeDescription => 'إضافة السجلات الجديدة فقط';

  @override
  String get warningTitle => '⚠️ تحذير';

  @override
  String get replaceWarningMessage =>
      'سيؤدي هذا إلى استبدال جميع بياناتك الموجودة. هل أنت متأكد أنك تريد المتابعة؟';

  @override
  String get replaceAllButton => 'استبدال الكل';

  @override
  String get fileLabel => 'الملف';

  @override
  String get sizeLabel => 'الحجم';

  @override
  String get recordsLabel => 'السجلات';

  @override
  String get usageRecordsLabel => 'سجلات الاستخدام';

  @override
  String get focusSessionsLabel => 'جلسات التركيز';

  @override
  String get appMetadataLabel => 'بيانات التطبيق الوصفية';

  @override
  String get updatedLabel => 'تم التحديث';

  @override
  String get skippedLabel => 'تم التخطي';

  @override
  String get faqSettingsQ4 => 'كيف يمكنني استعادة أو تصدير بياناتي؟';

  @override
  String get faqSettingsA4 =>
      'يمكنك الذهاب إلى الإعدادات، وهناك ستجد قسم النسخ الاحتياطي والاستعادة. يمكنك تصدير أو استيراد البيانات من هنا، لاحظ أن ملف البيانات المصدّر يتم تخزينه في المستندات في مجلد TimeMark-Backups ويمكن استخدام هذا الملف فقط لاستعادة البيانات، ولا يمكن استخدام أي ملف آخر.';

  @override
  String get faqGeneralQ6 =>
      'كيف يمكنني تغيير اللغة وما اللغات المتاحة، وماذا لو وجدت أن الترجمة خاطئة؟';

  @override
  String get faqGeneralA6 =>
      'يمكن تغيير اللغة من خلال قسم الإعدادات العامة، جميع اللغات المتاحة مدرجة هناك، يمكنك طلب ترجمة بالنقر على اتصل بنا وإرسال طلبك مع اللغة المحددة. اعلم أن الترجمة قد تكون خاطئة لأنها مُولّدة بالذكاء الاصطناعي من الإنجليزية وإذا كنت تريد الإبلاغ فيمكنك الإبلاغ من خلال الإبلاغ عن خطأ أو اتصل بنا، أو إذا كنت مطوراً يمكنك فتح مشكلة على جيت هب. المساهمات المتعلقة باللغة مرحب بها أيضاً!';

  @override
  String get faqGeneralQ7 => 'ماذا لو وجدت أن الترجمة خاطئة؟';

  @override
  String get faqGeneralA7 =>
      'قد تكون الترجمة خاطئة لأنها مُولّدة بالذكاء الاصطناعي من الإنجليزية وإذا كنت تريد الإبلاغ فيمكنك الإبلاغ من خلال الإبلاغ عن خطأ أو اتصل بنا، أو إذا كنت مطوراً يمكنك فتح مشكلة على جيت هب. المساهمات المتعلقة باللغة مرحب بها أيضاً!';
}
