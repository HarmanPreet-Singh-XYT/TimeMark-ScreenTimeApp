// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appWindowTitle =>
      'টাইমমার্ক - স্ক্রিন টাইম এবং অ্যাপ ব্যবহার ট্র্যাক করুন';

  @override
  String get appName => 'টাইমমার্ক';

  @override
  String get appTitle => 'উৎপাদনশীল স্ক্রিনটাইম';

  @override
  String get sidebarTitle => 'স্ক্রিনটাইম';

  @override
  String get sidebarSubtitle => 'ওপেন সোর্স';

  @override
  String get trayShowWindow => 'উইন্ডো দেখান';

  @override
  String get trayStartFocusMode => 'ফোকাস মোড শুরু করুন';

  @override
  String get trayStopFocusMode => 'ফোকাস মোড বন্ধ করুন';

  @override
  String get trayReports => 'রিপোর্ট';

  @override
  String get trayAlertsLimits => 'সতর্কতা এবং সীমা';

  @override
  String get trayApplications => 'অ্যাপ্লিকেশন';

  @override
  String get trayDisableNotifications => 'বিজ্ঞপ্তি বন্ধ করুন';

  @override
  String get trayEnableNotifications => 'বিজ্ঞপ্তি চালু করুন';

  @override
  String get trayVersionPrefix => 'সংস্করণ: ';

  @override
  String trayVersion(String version) {
    return 'সংস্করণ: $version';
  }

  @override
  String get trayExit => 'বের হন';

  @override
  String get navOverview => 'সারসংক্ষেপ';

  @override
  String get navApplications => 'অ্যাপ্লিকেশন';

  @override
  String get navAlertsLimits => 'সতর্কতা এবং সীমা';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navFocusMode => 'ফোকাস মোড';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get navHelp => 'সাহায্য';

  @override
  String get helpTitle => 'সাহায্য';

  @override
  String get faqCategoryGeneral => 'সাধারণ প্রশ্ন';

  @override
  String get faqCategoryApplications => 'অ্যাপ্লিকেশন ব্যবস্থাপনা';

  @override
  String get faqCategoryReports => 'ব্যবহার বিশ্লেষণ এবং রিপোর্ট';

  @override
  String get faqCategoryAlerts => 'সতর্কতা এবং সীমা';

  @override
  String get faqCategoryFocusMode => 'ফোকাস মোড এবং পোমোডোরো টাইমার';

  @override
  String get faqCategorySettings => 'সেটিংস এবং কাস্টমাইজেশন';

  @override
  String get faqCategoryTroubleshooting => 'সমস্যা সমাধান';

  @override
  String get faqGeneralQ1 => 'এই অ্যাপ কীভাবে স্ক্রিন টাইম ট্র্যাক করে?';

  @override
  String get faqGeneralA1 =>
      'অ্যাপটি আপনার ডিভাইসের ব্যবহার রিয়েল-টাইমে পর্যবেক্ষণ করে, বিভিন্ন অ্যাপ্লিকেশনে ব্যয় করা সময় ট্র্যাক করে। এটি আপনার ডিজিটাল অভ্যাসের ব্যাপক অন্তর্দৃষ্টি প্রদান করে, যার মধ্যে মোট স্ক্রিন টাইম, উৎপাদনশীল সময় এবং অ্যাপ্লিকেশন-নির্দিষ্ট ব্যবহার অন্তর্ভুক্ত।';

  @override
  String get faqGeneralQ2 => 'কোন অ্যাপকে \'উৎপাদনশীল\' করে তোলে?';

  @override
  String get faqGeneralA2 =>
      'আপনি \'অ্যাপ্লিকেশন\' বিভাগে ম্যানুয়ালি অ্যাপগুলিকে উৎপাদনশীল হিসাবে চিহ্নিত করতে পারেন। উৎপাদনশীল অ্যাপগুলি আপনার উৎপাদনশীলতা স্কোরে অবদান রাখে, যা কাজ-সম্পর্কিত বা উপকারী অ্যাপ্লিকেশনে ব্যয় করা স্ক্রিন টাইমের শতাংশ গণনা করে।';

  @override
  String get faqGeneralQ3 => 'স্ক্রিন টাইম ট্র্যাকিং কতটা সঠিক?';

  @override
  String get faqGeneralA3 =>
      'অ্যাপটি আপনার ডিভাইস ব্যবহারের সুনির্দিষ্ট পরিমাপ প্রদান করতে সিস্টেম-স্তরের ট্র্যাকিং ব্যবহার করে। এটি ন্যূনতম ব্যাটারি প্রভাবে প্রতিটি অ্যাপ্লিকেশনের ফোরগ্রাউন্ড সময় ক্যাপচার করে।';

  @override
  String get faqGeneralQ4 =>
      'আমি কি আমার অ্যাপ শ্রেণীবিভাগ কাস্টমাইজ করতে পারি?';

  @override
  String get faqGeneralA4 =>
      'অবশ্যই! আপনি কাস্টম ক্যাটাগরি তৈরি করতে পারেন, নির্দিষ্ট ক্যাটাগরিতে অ্যাপ বরাদ্দ করতে পারেন এবং \'অ্যাপ্লিকেশন\' বিভাগে এই বরাদ্দগুলি সহজেই পরিবর্তন করতে পারেন। এটি আরও অর্থপূর্ণ ব্যবহার বিশ্লেষণ তৈরি করতে সাহায্য করে।';

  @override
  String get faqGeneralQ5 => 'এই অ্যাপ থেকে আমি কী অন্তর্দৃষ্টি পেতে পারি?';

  @override
  String get faqGeneralA5 =>
      'অ্যাপটি ব্যাপক অন্তর্দৃষ্টি প্রদান করে যার মধ্যে উৎপাদনশীলতা স্কোর, দিনের সময় অনুযায়ী ব্যবহারের প্যাটার্ন, বিস্তারিত অ্যাপ্লিকেশন ব্যবহার, ফোকাস সেশন ট্র্যাকিং এবং গ্রাফ এবং পাই চার্টের মতো ভিজ্যুয়াল বিশ্লেষণ অন্তর্ভুক্ত যা আপনাকে আপনার ডিজিটাল অভ্যাস বুঝতে এবং উন্নত করতে সাহায্য করে।';

  @override
  String get faqAppsQ1 =>
      'আমি কীভাবে নির্দিষ্ট অ্যাপ ট্র্যাকিং থেকে লুকাতে পারি?';

  @override
  String get faqAppsA1 =>
      '\'অ্যাপ্লিকেশন\' বিভাগে, আপনি অ্যাপগুলির দৃশ্যমানতা টগল করতে পারেন।';

  @override
  String get faqAppsQ2 =>
      'আমি কি আমার অ্যাপ্লিকেশনগুলি অনুসন্ধান এবং ফিল্টার করতে পারি?';

  @override
  String get faqAppsA2 =>
      'হ্যাঁ, অ্যাপ্লিকেশন বিভাগে একটি অনুসন্ধান কার্যকারিতা এবং ফিল্টারিং বিকল্প অন্তর্ভুক্ত রয়েছে। আপনি ক্যাটাগরি, উৎপাদনশীলতার স্থিতি, ট্র্যাকিং স্থিতি এবং দৃশ্যমানতা অনুযায়ী অ্যাপ ফিল্টার করতে পারেন।';

  @override
  String get faqAppsQ3 => 'অ্যাপ্লিকেশনের জন্য কোন সম্পাদনা বিকল্প উপলব্ধ?';

  @override
  String get faqAppsA3 =>
      'প্রতিটি অ্যাপ্লিকেশনের জন্য, আপনি সম্পাদনা করতে পারেন: ক্যাটাগরি বরাদ্দ, উৎপাদনশীলতার স্থিতি, ব্যবহার ট্র্যাকিং, রিপোর্টে দৃশ্যমানতা এবং পৃথক দৈনিক সময়সীমা সেট করুন।';

  @override
  String get faqAppsQ4 => 'অ্যাপ্লিকেশন ক্যাটাগরি কীভাবে নির্ধারণ করা হয়?';

  @override
  String get faqAppsA4 =>
      'প্রাথমিক ক্যাটাগরিগুলি সিস্টেম-প্রস্তাবিত, কিন্তু আপনার কর্মপ্রবাহ এবং পছন্দ অনুযায়ী কাস্টম ক্যাটাগরি তৈরি, পরিবর্তন এবং বরাদ্দ করার সম্পূর্ণ নিয়ন্ত্রণ আপনার কাছে রয়েছে।';

  @override
  String get faqReportsQ1 => 'কোন ধরনের রিপোর্ট উপলব্ধ?';

  @override
  String get faqReportsA1 =>
      'রিপোর্টে অন্তর্ভুক্ত: মোট স্ক্রিন টাইম, উৎপাদনশীল সময়, সবচেয়ে ব্যবহৃত অ্যাপ, ফোকাস সেশন, দৈনিক স্ক্রিন টাইম গ্রাফ, ক্যাটাগরি ব্রেকডাউন পাই চার্ট, বিস্তারিত অ্যাপ্লিকেশন ব্যবহার, সাপ্তাহিক ব্যবহারের প্রবণতা এবং দিনের সময় অনুযায়ী ব্যবহারের প্যাটার্ন বিশ্লেষণ।';

  @override
  String get faqReportsQ2 => 'অ্যাপ্লিকেশন ব্যবহারের রিপোর্ট কতটা বিস্তারিত?';

  @override
  String get faqReportsA2 =>
      'বিস্তারিত অ্যাপ্লিকেশন ব্যবহারের রিপোর্টে দেখানো হয়: অ্যাপের নাম, ক্যাটাগরি, মোট ব্যয় করা সময়, উৎপাদনশীলতার স্থিতি এবং ব্যবহারের সারাংশ, দৈনিক সীমা, ব্যবহারের প্রবণতা এবং উৎপাদনশীলতা মেট্রিক্সের মতো গভীর অন্তর্দৃষ্টি সহ একটি \'অ্যাকশন\' বিভাগ অফার করে।';

  @override
  String get faqReportsQ3 =>
      'আমি কি সময়ের সাথে আমার ব্যবহারের প্রবণতা বিশ্লেষণ করতে পারি?';

  @override
  String get faqReportsA3 =>
      'হ্যাঁ! অ্যাপটি সপ্তাহ-থেকে-সপ্তাহ তুলনা প্রদান করে, গত সপ্তাহগুলিতে ব্যবহারের গ্রাফ, গড় দৈনিক ব্যবহার, দীর্ঘতম সেশন এবং সাপ্তাহিক মোট দেখায় যা আপনাকে আপনার ডিজিটাল অভ্যাস ট্র্যাক করতে সাহায্য করে।';

  @override
  String get faqReportsQ4 => '\'ব্যবহারের প্যাটার্ন\' বিশ্লেষণ কী?';

  @override
  String get faqReportsA4 =>
      'ব্যবহারের প্যাটার্ন আপনার স্ক্রিন টাইমকে সকাল, বিকেল, সন্ধ্যা এবং রাতের অংশে ভাগ করে। এটি আপনাকে বুঝতে সাহায্য করে যে আপনি কখন আপনার ডিভাইসে সবচেয়ে বেশি সক্রিয় এবং উন্নতির সম্ভাব্য ক্ষেত্রগুলি চিহ্নিত করতে।';

  @override
  String get faqAlertsQ1 => 'স্ক্রিন টাইম সীমা কতটা সূক্ষ্ম?';

  @override
  String get faqAlertsA1 =>
      'আপনি সামগ্রিক দৈনিক স্ক্রিন টাইম সীমা এবং পৃথক অ্যাপ সীমা সেট করতে পারেন। সীমাগুলি ঘন্টা এবং মিনিটে কনফিগার করা যেতে পারে, প্রয়োজনমতো রিসেট বা সামঞ্জস্য করার বিকল্প সহ।';

  @override
  String get faqAlertsQ2 => 'কোন বিজ্ঞপ্তি বিকল্প উপলব্ধ?';

  @override
  String get faqAlertsA2 =>
      'অ্যাপটি একাধিক বিজ্ঞপ্তি প্রকার অফার করে: স্ক্রিন টাইম অতিক্রম করলে সিস্টেম সতর্কতা, কাস্টমাইজযোগ্য বিরতিতে ঘন ঘন সতর্কতা (১, ৫, ১৫, ৩০, বা ৬০ মিনিট) এবং ফোকাস মোড, স্ক্রিন টাইম এবং অ্যাপ্লিকেশন-নির্দিষ্ট বিজ্ঞপ্তির জন্য টগল।';

  @override
  String get faqAlertsQ3 => 'আমি কি সীমা সতর্কতা কাস্টমাইজ করতে পারি?';

  @override
  String get faqAlertsA3 =>
      'হ্যাঁ, আপনি সতর্কতার ফ্রিকোয়েন্সি কাস্টমাইজ করতে পারেন, নির্দিষ্ট ধরনের সতর্কতা সক্ষম/অক্ষম করতে পারেন এবং সামগ্রিক স্ক্রিন টাইম এবং পৃথক অ্যাপ্লিকেশনের জন্য বিভিন্ন সীমা সেট করতে পারেন।';

  @override
  String get faqFocusQ1 => 'কোন ধরনের ফোকাস মোড উপলব্ধ?';

  @override
  String get faqFocusA1 =>
      'উপলব্ধ মোডগুলির মধ্যে রয়েছে ডিপ ওয়ার্ক (দীর্ঘ ফোকাসড সেশন), কুইক টাস্ক (কাজের সংক্ষিপ্ত বিস্ফোরণ) এবং রিডিং মোড। প্রতিটি মোড আপনাকে আপনার কাজ এবং বিরতির সময় কার্যকরভাবে গঠন করতে সাহায্য করে।';

  @override
  String get faqFocusQ2 => 'পোমোডোরো টাইমার কতটা নমনীয়?';

  @override
  String get faqFocusA2 =>
      'টাইমারটি অত্যন্ত কাস্টমাইজযোগ্য। আপনি কাজের সময়কাল, সংক্ষিপ্ত বিরতির দৈর্ঘ্য এবং দীর্ঘ বিরতির সময়কাল সামঞ্জস্য করতে পারেন। অতিরিক্ত বিকল্পগুলির মধ্যে পরবর্তী সেশনের জন্য অটো-স্টার্ট এবং বিজ্ঞপ্তি সেটিংস অন্তর্ভুক্ত।';

  @override
  String get faqFocusQ3 => 'ফোকাস মোড ইতিহাস কী দেখায়?';

  @override
  String get faqFocusA3 =>
      'ফোকাস মোড ইতিহাস দৈনিক ফোকাস সেশন ট্র্যাক করে, প্রতিদিন সেশনের সংখ্যা, প্রবণতা গ্রাফ, গড় সেশনের সময়কাল, মোট ফোকাস সময় এবং কাজের সেশন, সংক্ষিপ্ত বিরতি এবং দীর্ঘ বিরতির ব্রেকডাউন সহ একটি সময় বিতরণ পাই চার্ট দেখায়।';

  @override
  String get faqFocusQ4 =>
      'আমি কি আমার ফোকাস সেশনের অগ্রগতি ট্র্যাক করতে পারি?';

  @override
  String get faqFocusA4 =>
      'অ্যাপটিতে প্লে/পজ, রিলোড এবং সেটিংস বোতাম সহ একটি বৃত্তাকার টাইমার UI রয়েছে। আপনি সহজাত নিয়ন্ত্রণগুলির সাথে সহজেই আপনার ফোকাস সেশনগুলি ট্র্যাক এবং পরিচালনা করতে পারেন।';

  @override
  String get faqSettingsQ1 => 'কোন কাস্টমাইজেশন বিকল্প উপলব্ধ?';

  @override
  String get faqSettingsA1 =>
      'কাস্টমাইজেশনে অন্তর্ভুক্ত থিম নির্বাচন (সিস্টেম, লাইট, ডার্ক), ভাষা সেটিংস, স্টার্টআপ আচরণ, ব্যাপক বিজ্ঞপ্তি নিয়ন্ত্রণ এবং ডেটা মুছে ফেলা বা সেটিংস রিসেট করার মতো ডেটা ব্যবস্থাপনা বিকল্প।';

  @override
  String get faqSettingsQ2 =>
      'আমি কীভাবে প্রতিক্রিয়া প্রদান করতে বা সমস্যা রিপোর্ট করতে পারি?';

  @override
  String get faqSettingsA2 =>
      'সেটিংস বিভাগের নীচে, আপনি বাগ রিপোর্ট, প্রতিক্রিয়া জমা দিন বা সাপোর্টে যোগাযোগ করার বোতাম পাবেন। এগুলি আপনাকে উপযুক্ত সাপোর্ট চ্যানেলে পুনঃনির্দেশ করবে।';

  @override
  String get faqSettingsQ3 => 'আমি যখন আমার ডেটা মুছে ফেলি তখন কী হয়?';

  @override
  String get faqSettingsA3 =>
      'ডেটা মুছে ফেলা আপনার সমস্ত ব্যবহারের পরিসংখ্যান, ফোকাস সেশন ইতিহাস এবং কাস্টম সেটিংস রিসেট করবে। এটি নতুন করে শুরু করতে বা সমস্যা সমাধানের জন্য দরকারী।';

  @override
  String get faqTroubleQ1 => 'ডেটা দেখা যাচ্ছে না, হাইভ খুলছে না ত্রুটি';

  @override
  String get faqTroubleA1 =>
      'সমস্যাটি জানা আছে, অস্থায়ী সমাধান হল সেটিংসের মাধ্যমে ডেটা মুছে ফেলা এবং যদি এটি কাজ না করে তবে ডকুমেন্টসে যান এবং নিম্নলিখিত ফাইলগুলি মুছে ফেলুন যদি সেগুলি বিদ্যমান থাকে - harman_screentime_app_usage_box.hive এবং harman_screentime_app_usage.lock, আপনাকে অ্যাপটি সর্বশেষ সংস্করণে আপডেট করার পরামর্শ দেওয়া হচ্ছে।';

  @override
  String get faqTroubleQ2 => 'অ্যাপ প্রতিটি স্টার্টআপে খোলে, কী করব?';

  @override
  String get faqTroubleA2 =>
      'এটি একটি জানা সমস্যা যা Windows 10-এ ঘটে, অস্থায়ী সমাধান হল সেটিংসে মিনিমাইজড হিসাবে লঞ্চ সক্ষম করা যাতে এটি মিনিমাইজড হিসাবে চালু হয়।';

  @override
  String get usageAnalytics => 'ব্যবহার বিশ্লেষণ';

  @override
  String get last7Days => 'গত ৭ দিন';

  @override
  String get lastMonth => 'গত মাস';

  @override
  String get last3Months => 'গত ৩ মাস';

  @override
  String get lifetime => 'সারাজীবন';

  @override
  String get custom => 'কাস্টম';

  @override
  String get loadingAnalyticsData => 'বিশ্লেষণ ডেটা লোড হচ্ছে...';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get failedToInitialize =>
      'বিশ্লেষণ শুরু করতে ব্যর্থ। অনুগ্রহ করে অ্যাপ্লিকেশনটি পুনরায় চালু করুন।';

  @override
  String unexpectedError(String error) {
    return 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে: $error। অনুগ্রহ করে পরে আবার চেষ্টা করুন।';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'বিশ্লেষণ ডেটা লোড করতে ত্রুটি: $error। অনুগ্রহ করে আপনার সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।';
  }

  @override
  String get customDialogTitle => 'কাস্টম';

  @override
  String get dateRange => 'তারিখ পরিসীমা';

  @override
  String get specificDate => 'নির্দিষ্ট তারিখ';

  @override
  String get startDate => 'শুরুর তারিখ: ';

  @override
  String get endDate => 'শেষ তারিখ: ';

  @override
  String get date => 'তারিখ: ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get apply => 'প্রয়োগ করুন';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get invalidDateRange => 'অবৈধ তারিখ পরিসীমা';

  @override
  String get startDateBeforeEndDate =>
      'শুরুর তারিখ শেষ তারিখের আগে বা সমান হতে হবে।';

  @override
  String get totalScreenTime => 'মোট স্ক্রিন টাইম';

  @override
  String get productiveTime => 'উৎপাদনশীল সময়';

  @override
  String get mostUsedApp => 'সবচেয়ে ব্যবহৃত অ্যাপ';

  @override
  String get focusSessions => 'ফোকাস সেশন';

  @override
  String positiveComparison(String percent) {
    return '+$percent% বনাম পূর্ববর্তী সময়কাল';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% বনাম পূর্ববর্তী সময়কাল';
  }

  @override
  String iconLabel(String title) {
    return '$title আইকন';
  }

  @override
  String get dailyScreenTime => 'দৈনিক স্ক্রিন টাইম';

  @override
  String get categoryBreakdown => 'ক্যাটাগরি ব্রেকডাউন';

  @override
  String get noDataAvailable => 'কোন ডেটা উপলব্ধ নেই';

  @override
  String sectionLabel(String title) {
    return '$title বিভাগ';
  }

  @override
  String get detailedApplicationUsage => 'বিস্তারিত অ্যাপ্লিকেশন ব্যবহার';

  @override
  String get searchApplications => 'অ্যাপ্লিকেশন অনুসন্ধান করুন';

  @override
  String get nameHeader => 'নাম';

  @override
  String get categoryHeader => 'ক্যাটাগরি';

  @override
  String get totalTimeHeader => 'মোট সময়';

  @override
  String get productivityHeader => 'উৎপাদনশীলতা';

  @override
  String get actionsHeader => 'অ্যাকশন';

  @override
  String sortByOption(String option) {
    return 'সাজান: $option';
  }

  @override
  String get sortByName => 'নাম';

  @override
  String get sortByCategory => 'ক্যাটাগরি';

  @override
  String get sortByUsage => 'ব্যবহার';

  @override
  String get productive => 'উৎপাদনশীল';

  @override
  String get nonProductive => 'অ-উৎপাদনশীল';

  @override
  String get noApplicationsMatch =>
      'আপনার অনুসন্ধান মানদণ্ডের সাথে কোন অ্যাপ্লিকেশন মেলেনি';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get usageSummary => 'ব্যবহারের সারাংশ';

  @override
  String get usageOverPastWeek => 'গত সপ্তাহের ব্যবহার';

  @override
  String get usagePatternByTimeOfDay =>
      'দিনের সময় অনুযায়ী ব্যবহারের প্যাটার্ন';

  @override
  String get patternAnalysis => 'প্যাটার্ন বিশ্লেষণ';

  @override
  String get today => 'আজ';

  @override
  String get dailyLimit => 'দৈনিক সীমা';

  @override
  String get noLimit => 'কোন সীমা নেই';

  @override
  String get usageTrend => 'ব্যবহারের প্রবণতা';

  @override
  String get productivity => 'উৎপাদনশীলতা';

  @override
  String get increasing => 'বৃদ্ধি পাচ্ছে';

  @override
  String get decreasing => 'হ্রাস পাচ্ছে';

  @override
  String get stable => 'স্থিতিশীল';

  @override
  String get avgDailyUsage => 'গড় দৈনিক ব্যবহার';

  @override
  String get longestSession => 'দীর্ঘতম সেশন';

  @override
  String get weeklyTotal => 'সাপ্তাহিক মোট';

  @override
  String get noHistoricalData => 'কোন ঐতিহাসিক ডেটা উপলব্ধ নেই';

  @override
  String get morning => 'সকাল (৬-১২)';

  @override
  String get afternoon => 'বিকেল (১২-৫)';

  @override
  String get evening => 'সন্ধ্যা (৫-৯)';

  @override
  String get night => 'রাত (৯-৬)';

  @override
  String get usageInsights => 'ব্যবহারের অন্তর্দৃষ্টি';

  @override
  String get limitStatus => 'সীমার স্থিতি';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'আপনি প্রধানত $timeOfDay-এ $appName ব্যবহার করেন।';
  }

  @override
  String significantIncrease(String percentage) {
    return 'পূর্ববর্তী সময়কালের তুলনায় আপনার ব্যবহার উল্লেখযোগ্যভাবে বেড়েছে ($percentage%)।';
  }

  @override
  String get trendingUpward =>
      'পূর্ববর্তী সময়কালের তুলনায় আপনার ব্যবহার ঊর্ধ্বমুখী।';

  @override
  String significantDecrease(String percentage) {
    return 'পূর্ববর্তী সময়কালের তুলনায় আপনার ব্যবহার উল্লেখযোগ্যভাবে কমেছে ($percentage%)।';
  }

  @override
  String get trendingDownward =>
      'পূর্ববর্তী সময়কালের তুলনায় আপনার ব্যবহার নিম্নমুখী।';

  @override
  String get consistentUsage =>
      'পূর্ববর্তী সময়কালের তুলনায় আপনার ব্যবহার সামঞ্জস্যপূর্ণ রয়েছে।';

  @override
  String get markedAsProductive =>
      'এটি আপনার সেটিংসে একটি উৎপাদনশীল অ্যাপ হিসাবে চিহ্নিত।';

  @override
  String get markedAsNonProductive =>
      'এটি আপনার সেটিংসে একটি অ-উৎপাদনশীল অ্যাপ হিসাবে চিহ্নিত।';

  @override
  String mostActiveTime(String time) {
    return 'আপনার সবচেয়ে সক্রিয় সময় প্রায় $time।';
  }

  @override
  String get noLimitSet =>
      'এই অ্যাপ্লিকেশনের জন্য কোন ব্যবহার সীমা সেট করা হয়নি।';

  @override
  String get limitReached => 'আপনি এই অ্যাপ্লিকেশনের দৈনিক সীমায় পৌঁছে গেছেন।';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'আপনি আপনার দৈনিক সীমায় প্রায় পৌঁছে যাচ্ছেন, মাত্র $remainingTime বাকি।';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'আপনি আপনার দৈনিক সীমার $percent% ব্যবহার করেছেন, $remainingTime বাকি।';
  }

  @override
  String remainingTime(String time) {
    return 'আপনার দৈনিক সীমা থেকে $time বাকি।';
  }

  @override
  String get todayChart => 'আজ';

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
    return '$hoursঘ $minutesমি';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesমি';
  }

  @override
  String get alertsLimitsTitle => 'সতর্কতা এবং সীমা';

  @override
  String get notificationsSettings => 'বিজ্ঞপ্তি সেটিংস';

  @override
  String get overallScreenTimeLimit => 'সামগ্রিক স্ক্রিন টাইম সীমা';

  @override
  String get applicationLimits => 'অ্যাপ্লিকেশন সীমা';

  @override
  String get popupAlerts => 'পপ-আপ সতর্কতা';

  @override
  String get frequentAlerts => 'ঘন ঘন সতর্কতা';

  @override
  String get soundAlerts => 'শব্দ সতর্কতা';

  @override
  String get systemAlerts => 'সিস্টেম সতর্কতা';

  @override
  String get dailyTotalLimit => 'দৈনিক মোট সীমা: ';

  @override
  String get hours => 'ঘন্টা: ';

  @override
  String get minutes => 'মিনিট: ';

  @override
  String get currentUsage => 'বর্তমান ব্যবহার: ';

  @override
  String get tableName => 'নাম';

  @override
  String get tableCategory => 'ক্যাটাগরি';

  @override
  String get tableDailyLimit => 'দৈনিক সীমা';

  @override
  String get tableCurrentUsage => 'বর্তমান ব্যবহার';

  @override
  String get tableStatus => 'স্থিতি';

  @override
  String get tableActions => 'অ্যাকশন';

  @override
  String get addLimit => 'সীমা যোগ করুন';

  @override
  String get noApplicationsToDisplay =>
      'প্রদর্শন করার জন্য কোন অ্যাপ্লিকেশন নেই';

  @override
  String get statusActive => 'সক্রিয়';

  @override
  String get statusOff => 'বন্ধ';

  @override
  String get durationNone => 'কোনটি নয়';

  @override
  String get addApplicationLimit => 'অ্যাপ্লিকেশন সীমা যোগ করুন';

  @override
  String get selectApplication => 'অ্যাপ্লিকেশন নির্বাচন করুন';

  @override
  String get selectApplicationPlaceholder => 'একটি অ্যাপ্লিকেশন নির্বাচন করুন';

  @override
  String get enableLimit => 'সীমা সক্ষম করুন: ';

  @override
  String editLimitTitle(String appName) {
    return 'সীমা সম্পাদনা: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'ডেটা লোড করতে ব্যর্থ: $error';
  }

  @override
  String get resetSettingsTitle => 'সেটিংস রিসেট করবেন?';

  @override
  String get resetSettingsContent =>
      'আপনি যদি সেটিংস রিসেট করেন, আপনি এটি পুনরুদ্ধার করতে পারবেন না। আপনি কি এটি রিসেট করতে চান?';

  @override
  String get resetAll => 'সব রিসেট করুন';

  @override
  String get refresh => 'রিফ্রেশ';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get add => 'যোগ করুন';

  @override
  String get error => 'ত্রুটি';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get applicationsTitle => 'অ্যাপ্লিকেশন';

  @override
  String get searchApplication => 'অ্যাপ্লিকেশন অনুসন্ধান করুন';

  @override
  String get tracking => 'ট্র্যাকিং';

  @override
  String get hiddenVisible => 'লুকানো/দৃশ্যমান';

  @override
  String get selectCategory => 'একটি ক্যাটাগরি নির্বাচন করুন';

  @override
  String get allCategories => 'সব';

  @override
  String get tableScreenTime => 'স্ক্রিন টাইম';

  @override
  String get tableTracking => 'ট্র্যাকিং';

  @override
  String get tableHidden => 'লুকানো';

  @override
  String get tableEdit => 'সম্পাদনা';

  @override
  String editAppTitle(String appName) {
    return '$appName সম্পাদনা করুন';
  }

  @override
  String get categorySection => 'ক্যাটাগরি';

  @override
  String get customCategory => 'কাস্টম';

  @override
  String get customCategoryPlaceholder => 'কাস্টম ক্যাটাগরির নাম লিখুন';

  @override
  String get uncategorized => 'শ্রেণীবিহীন';

  @override
  String get isProductive => 'উৎপাদনশীল';

  @override
  String get trackUsage => 'ব্যবহার ট্র্যাক করুন';

  @override
  String get visibleInReports => 'রিপোর্টে দৃশ্যমান';

  @override
  String get timeLimitsSection => 'সময় সীমা';

  @override
  String get enableDailyLimit => 'দৈনিক সীমা সক্ষম করুন';

  @override
  String get setDailyTimeLimit => 'দৈনিক সময় সীমা সেট করুন:';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String errorLoadingData(String error) {
    return 'ওভারভিউ ডেটা লোড করতে ত্রুটি: $error';
  }

  @override
  String get focusModeTitle => 'ফোকাস মোড';

  @override
  String get historySection => 'ইতিহাস';

  @override
  String get trendsSection => 'প্রবণতা';

  @override
  String get timeDistributionSection => 'সময় বিতরণ';

  @override
  String get sessionHistorySection => 'সেশন ইতিহাস';

  @override
  String get workSession => 'কাজের সেশন';

  @override
  String get shortBreak => 'সংক্ষিপ্ত বিরতি';

  @override
  String get longBreak => 'দীর্ঘ বিরতি';

  @override
  String get dateHeader => 'তারিখ';

  @override
  String get durationHeader => 'সময়কাল';

  @override
  String get monday => 'সোমবার';

  @override
  String get tuesday => 'মঙ্গলবার';

  @override
  String get wednesday => 'বুধবার';

  @override
  String get thursday => 'বৃহস্পতিবার';

  @override
  String get friday => 'শুক্রবার';

  @override
  String get saturday => 'শনিবার';

  @override
  String get sunday => 'রবিবার';

  @override
  String get focusModeSettingsTitle => 'ফোকাস মোড সেটিংস';

  @override
  String get modeCustom => 'কাস্টম';

  @override
  String get modeDeepWork => 'ডিপ ওয়ার্ক (৬০ মিনিট)';

  @override
  String get modeQuickTasks => 'কুইক টাস্ক (২৫ মিনিট)';

  @override
  String get modeReading => 'রিডিং (৪৫ মিনিট)';

  @override
  String workDurationLabel(int minutes) {
    return 'কাজের সময়কাল: $minutes মিনিট';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'সংক্ষিপ্ত বিরতি: $minutes মিনিট';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'দীর্ঘ বিরতি: $minutes মিনিট';
  }

  @override
  String get autoStartNextSession => 'পরবর্তী সেশন অটো-স্টার্ট করুন';

  @override
  String get blockDistractions => 'ফোকাস মোডের সময় বিভ্রান্তি ব্লক করুন';

  @override
  String get enableNotifications => 'বিজ্ঞপ্তি সক্ষম করুন';

  @override
  String get saved => 'সংরক্ষিত';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'ফোকাস মোড ডেটা লোড করতে ত্রুটি: $error';
  }

  @override
  String get overviewTitle => 'আজকের সারসংক্ষেপ';

  @override
  String get startFocusMode => 'ফোকাস মোড শুরু করুন';

  @override
  String get loadingProductivityData => 'আপনার উৎপাদনশীলতা ডেটা লোড হচ্ছে...';

  @override
  String get noActivityDataAvailable => 'এখনও কোন কার্যকলাপ ডেটা উপলব্ধ নেই';

  @override
  String get startUsingApplications =>
      'স্ক্রিন টাইম এবং উৎপাদনশীলতা ট্র্যাক করতে আপনার অ্যাপ্লিকেশনগুলি ব্যবহার শুরু করুন।';

  @override
  String get refreshData => 'ডেটা রিফ্রেশ করুন';

  @override
  String get topApplications => 'শীর্ষ অ্যাপ্লিকেশন';

  @override
  String get noAppUsageDataAvailable =>
      'এখনও কোন অ্যাপ্লিকেশন ব্যবহারের ডেটা উপলব্ধ নেই';

  @override
  String get noApplicationDataAvailable => 'কোন অ্যাপ্লিকেশন ডেটা উপলব্ধ নেই';

  @override
  String get noCategoryDataAvailable => 'কোন ক্যাটাগরি ডেটা উপলব্ধ নেই';

  @override
  String get noApplicationLimitsSet => 'কোন অ্যাপ্লিকেশন সীমা সেট করা নেই';

  @override
  String get screenLabel => 'স্ক্রিন';

  @override
  String get timeLabel => 'সময়';

  @override
  String get productiveLabel => 'উৎপাদনশীল';

  @override
  String get scoreLabel => 'স্কোর';

  @override
  String get defaultNone => 'কোনটি নয়';

  @override
  String get defaultTime => '০ঘ ০মি';

  @override
  String get defaultCount => '০';

  @override
  String get unknownApp => 'অজানা';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get generalSection => 'সাধারণ';

  @override
  String get notificationsSection => 'বিজ্ঞপ্তি';

  @override
  String get dataSection => 'ডেটা';

  @override
  String get versionSection => 'সংস্করণ';

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageDescription => 'অ্যাপ্লিকেশনের ভাষা';

  @override
  String get startupBehaviourTitle => 'স্টার্টআপ আচরণ';

  @override
  String get startupBehaviourDescription => 'OS স্টার্টআপে লঞ্চ করুন';

  @override
  String get launchMinimizedTitle => 'মিনিমাইজড হিসাবে লঞ্চ করুন';

  @override
  String get launchMinimizedDescription =>
      'সিস্টেম ট্রেতে অ্যাপ্লিকেশন শুরু করুন (Windows 10-এর জন্য প্রস্তাবিত)';

  @override
  String get notificationsTitle => 'বিজ্ঞপ্তি';

  @override
  String get notificationsAllDescription => 'অ্যাপ্লিকেশনের সমস্ত বিজ্ঞপ্তি';

  @override
  String get focusModeNotificationsTitle => 'ফোকাস মোড';

  @override
  String get focusModeNotificationsDescription =>
      'ফোকাস মোডের জন্য সমস্ত বিজ্ঞপ্তি';

  @override
  String get screenTimeNotificationsTitle => 'স্ক্রিন টাইম';

  @override
  String get screenTimeNotificationsDescription =>
      'স্ক্রিন টাইম সীমাবদ্ধতার জন্য সমস্ত বিজ্ঞপ্তি';

  @override
  String get appScreenTimeNotificationsTitle => 'অ্যাপ্লিকেশন স্ক্রিন টাইম';

  @override
  String get appScreenTimeNotificationsDescription =>
      'অ্যাপ্লিকেশন স্ক্রিন টাইম সীমাবদ্ধতার জন্য সমস্ত বিজ্ঞপ্তি';

  @override
  String get frequentAlertsTitle => 'ঘন ঘন সতর্কতার বিরতি';

  @override
  String get frequentAlertsDescription =>
      'ঘন ঘন বিজ্ঞপ্তির জন্য বিরতি সেট করুন (মিনিট)';

  @override
  String get clearDataTitle => 'ডেটা মুছে ফেলুন';

  @override
  String get clearDataDescription =>
      'সমস্ত ইতিহাস এবং অন্যান্য সম্পর্কিত ডেটা মুছে ফেলুন';

  @override
  String get resetSettingsTitle2 => 'সেটিংস রিসেট করুন';

  @override
  String get resetSettingsDescription => 'সমস্ত সেটিংস রিসেট করুন';

  @override
  String get versionTitle => 'সংস্করণ';

  @override
  String get versionDescription => 'অ্যাপের বর্তমান সংস্করণ';

  @override
  String get contactButton => 'যোগাযোগ';

  @override
  String get reportBugButton => 'বাগ রিপোর্ট করুন';

  @override
  String get submitFeedbackButton => 'প্রতিক্রিয়া জমা দিন';

  @override
  String get githubButton => 'গিটহাব';

  @override
  String get clearDataDialogTitle => 'ডেটা মুছে ফেলবেন?';

  @override
  String get clearDataDialogContent =>
      'এটি সমস্ত ইতিহাস এবং সম্পর্কিত ডেটা মুছে ফেলবে। আপনি এটি পুনরুদ্ধার করতে পারবেন না। আপনি কি এগিয়ে যেতে চান?';

  @override
  String get clearDataButtonLabel => 'ডেটা মুছে ফেলুন';

  @override
  String get resetSettingsDialogTitle => 'সেটিংস রিসেট করবেন?';

  @override
  String get resetSettingsDialogContent =>
      'এটি সমস্ত সেটিংস তাদের ডিফল্ট মানে রিসেট করবে। আপনি কি এগিয়ে যেতে চান?';

  @override
  String get resetButtonLabel => 'রিসেট';

  @override
  String get cancelButton => 'বাতিল';

  @override
  String couldNotLaunchUrl(String url) {
    return '$url লঞ্চ করা যায়নি';
  }

  @override
  String errorMessage(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String get chart_focusTrends => 'ফোকাস প্রবণতা';

  @override
  String get chart_sessionCount => 'সেশন সংখ্যা';

  @override
  String get chart_avgDuration => 'গড় সময়কাল';

  @override
  String get chart_totalFocus => 'মোট ফোকাস';

  @override
  String get chart_yAxis_sessions => 'সেশন';

  @override
  String get chart_yAxis_minutes => 'মিনিট';

  @override
  String get chart_yAxis_value => 'মান';

  @override
  String get chart_monthOverMonthChange => 'মাস-থেকে-মাস পরিবর্তন: ';

  @override
  String get chart_customRange => 'কাস্টম পরিসীমা';

  @override
  String get day_monday => 'সোমবার';

  @override
  String get day_mondayShort => 'সোম';

  @override
  String get day_mondayAbbr => 'সো';

  @override
  String get day_tuesday => 'মঙ্গলবার';

  @override
  String get day_tuesdayShort => 'মঙ্গল';

  @override
  String get day_tuesdayAbbr => 'মং';

  @override
  String get day_wednesday => 'বুধবার';

  @override
  String get day_wednesdayShort => 'বুধ';

  @override
  String get day_wednesdayAbbr => 'বু';

  @override
  String get day_thursday => 'বৃহস্পতিবার';

  @override
  String get day_thursdayShort => 'বৃহ';

  @override
  String get day_thursdayAbbr => 'বৃ';

  @override
  String get day_friday => 'শুক্রবার';

  @override
  String get day_fridayShort => 'শুক্র';

  @override
  String get day_fridayAbbr => 'শু';

  @override
  String get day_saturday => 'শনিবার';

  @override
  String get day_saturdayShort => 'শনি';

  @override
  String get day_saturdayAbbr => 'শ';

  @override
  String get day_sunday => 'রবিবার';

  @override
  String get day_sundayShort => 'রবি';

  @override
  String get day_sundayAbbr => 'র';

  @override
  String time_hours(int count) {
    return '$countঘ';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursঘ $minutesমি';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count মিনিট';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursঘ $minutesমি';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count ঘন্টা';
  }

  @override
  String get month_january => 'জানুয়ারি';

  @override
  String get month_januaryShort => 'জানু';

  @override
  String get month_february => 'ফেব্রুয়ারি';

  @override
  String get month_februaryShort => 'ফেব্রু';

  @override
  String get month_march => 'মার্চ';

  @override
  String get month_marchShort => 'মার্চ';

  @override
  String get month_april => 'এপ্রিল';

  @override
  String get month_aprilShort => 'এপ্রি';

  @override
  String get month_may => 'মে';

  @override
  String get month_mayShort => 'মে';

  @override
  String get month_june => 'জুন';

  @override
  String get month_juneShort => 'জুন';

  @override
  String get month_july => 'জুলাই';

  @override
  String get month_julyShort => 'জুলা';

  @override
  String get month_august => 'আগস্ট';

  @override
  String get month_augustShort => 'আগ';

  @override
  String get month_september => 'সেপ্টেম্বর';

  @override
  String get month_septemberShort => 'সেপ্টে';

  @override
  String get month_october => 'অক্টোবর';

  @override
  String get month_octoberShort => 'অক্টো';

  @override
  String get month_november => 'নভেম্বর';

  @override
  String get month_novemberShort => 'নভে';

  @override
  String get month_december => 'ডিসেম্বর';

  @override
  String get month_decemberShort => 'ডিসে';

  @override
  String get categoryAll => 'সব';

  @override
  String get categoryProductivity => 'উৎপাদনশীলতা';

  @override
  String get categoryDevelopment => 'ডেভেলপমেন্ট';

  @override
  String get categorySocialMedia => 'সোশ্যাল মিডিয়া';

  @override
  String get categoryEntertainment => 'বিনোদন';

  @override
  String get categoryGaming => 'গেমিং';

  @override
  String get categoryCommunication => 'যোগাযোগ';

  @override
  String get categoryWebBrowsing => 'ওয়েব ব্রাউজিং';

  @override
  String get categoryCreative => 'সৃজনশীল';

  @override
  String get categoryEducation => 'শিক্ষা';

  @override
  String get categoryUtility => 'ইউটিলিটি';

  @override
  String get categoryUncategorized => 'শ্রেণীবিহীন';

  @override
  String get appMicrosoftWord => 'মাইক্রোসফট ওয়ার্ড';

  @override
  String get appExcel => 'এক্সেল';

  @override
  String get appPowerPoint => 'পাওয়ারপয়েন্ট';

  @override
  String get appGoogleDocs => 'গুগল ডক্স';

  @override
  String get appNotion => 'নোশন';

  @override
  String get appEvernote => 'এভারনোট';

  @override
  String get appTrello => 'ট্রেলো';

  @override
  String get appAsana => 'আসানা';

  @override
  String get appSlack => 'স্ল্যাক';

  @override
  String get appMicrosoftTeams => 'মাইক্রোসফট টিমস';

  @override
  String get appZoom => 'জুম';

  @override
  String get appGoogleCalendar => 'গুগল ক্যালেন্ডার';

  @override
  String get appAppleCalendar => 'ক্যালেন্ডার';

  @override
  String get appVisualStudioCode => 'ভিজ্যুয়াল স্টুডিও কোড';

  @override
  String get appTerminal => 'টার্মিনাল';

  @override
  String get appCommandPrompt => 'কমান্ড প্রম্পট';

  @override
  String get appChrome => 'ক্রোম';

  @override
  String get appFirefox => 'ফায়ারফক্স';

  @override
  String get appSafari => 'সাফারি';

  @override
  String get appEdge => 'এজ';

  @override
  String get appOpera => 'অপেরা';

  @override
  String get appBrave => 'ব্রেভ';

  @override
  String get appNetflix => 'নেটফ্লিক্স';

  @override
  String get appYouTube => 'ইউটিউব';

  @override
  String get appSpotify => 'স্পটিফাই';

  @override
  String get appAppleMusic => 'অ্যাপল মিউজিক';

  @override
  String get appCalculator => 'ক্যালকুলেটর';

  @override
  String get appNotes => 'নোটস';

  @override
  String get appSystemPreferences => 'সিস্টেম প্রেফারেন্স';

  @override
  String get appTaskManager => 'টাস্ক ম্যানেজার';

  @override
  String get appFileExplorer => 'ফাইল এক্সপ্লোরার';

  @override
  String get appDropbox => 'ড্রপবক্স';

  @override
  String get appGoogleDrive => 'গুগল ড্রাইভ';

  @override
  String get loadingApplication => 'অ্যাপ্লিকেশন লোড হচ্ছে...';

  @override
  String get loadingData => 'ডেটা লোড হচ্ছে...';

  @override
  String get reportsError => 'ত্রুটি';

  @override
  String get reportsRetry => 'পুনরায় চেষ্টা করুন';

  @override
  String get backupRestoreSection => 'ব্যাকআপ এবং পুনরুদ্ধার';

  @override
  String get backupRestoreTitle => 'ব্যাকআপ এবং পুনরুদ্ধার';

  @override
  String get exportDataTitle => 'ডেটা রপ্তানি করুন';

  @override
  String get exportDataDescription =>
      'আপনার সমস্ত ডেটার একটি ব্যাকআপ তৈরি করুন';

  @override
  String get importDataTitle => 'ডেটা আমদানি করুন';

  @override
  String get importDataDescription => 'একটি ব্যাকআপ ফাইল থেকে পুনরুদ্ধার করুন';

  @override
  String get exportButton => 'রপ্তানি';

  @override
  String get importButton => 'আমদানি';

  @override
  String get closeButton => 'বন্ধ করুন';

  @override
  String get noButton => 'না';

  @override
  String get shareButton => 'শেয়ার করুন';

  @override
  String get exportStarting => 'রপ্তানি শুরু হচ্ছে...';

  @override
  String get exportSuccessful =>
      'রপ্তানি সফল! ফাইল Documents/TimeMark-Backups-এ সংরক্ষিত হয়েছে';

  @override
  String get exportFailed => 'রপ্তানি ব্যর্থ হয়েছে';

  @override
  String get exportComplete => 'রপ্তানি সম্পন্ন';

  @override
  String get shareBackupQuestion => 'আপনি কি ব্যাকআপ ফাইল শেয়ার করতে চান?';

  @override
  String get importStarting => 'আমদানি শুরু হচ্ছে...';

  @override
  String get importSuccessful => 'আমদানি সফল!';

  @override
  String get importFailed => 'আমদানি ব্যর্থ হয়েছে';

  @override
  String get importOptionsTitle => 'আমদানি বিকল্প';

  @override
  String get importOptionsQuestion => 'আপনি কীভাবে ডেটা আমদানি করতে চান?';

  @override
  String get replaceModeTitle => 'প্রতিস্থাপন';

  @override
  String get replaceModeDescription => 'সমস্ত বিদ্যমান ডেটা প্রতিস্থাপন করুন';

  @override
  String get mergeModeTitle => 'মার্জ';

  @override
  String get mergeModeDescription => 'বিদ্যমান ডেটার সাথে একত্রিত করুন';

  @override
  String get appendModeTitle => 'সংযুক্ত';

  @override
  String get appendModeDescription => 'শুধুমাত্র নতুন রেকর্ড যোগ করুন';

  @override
  String get warningTitle => '⚠️ সতর্কতা';

  @override
  String get replaceWarningMessage =>
      'এটি আপনার সমস্ত বিদ্যমান ডেটা প্রতিস্থাপন করবে। আপনি কি নিশ্চিতভাবে এগিয়ে যেতে চান?';

  @override
  String get replaceAllButton => 'সব প্রতিস্থাপন করুন';

  @override
  String get fileLabel => 'ফাইল';

  @override
  String get sizeLabel => 'আকার';

  @override
  String get recordsLabel => 'রেকর্ড';

  @override
  String get usageRecordsLabel => 'ব্যবহারের রেকর্ড';

  @override
  String get focusSessionsLabel => 'ফোকাস সেশন';

  @override
  String get appMetadataLabel => 'অ্যাপ মেটাডেটা';

  @override
  String get updatedLabel => 'আপডেট হয়েছে';

  @override
  String get skippedLabel => 'এড়িয়ে গেছে';

  @override
  String get faqSettingsQ4 =>
      'আমি কীভাবে আমার ডেটা পুনরুদ্ধার বা রপ্তানি করতে পারি?';

  @override
  String get faqSettingsA4 =>
      'আপনি সেটিংসে যেতে পারেন, এবং সেখানে আপনি ব্যাকআপ এবং পুনরুদ্ধার বিভাগ পাবেন। আপনি এখান থেকে ডেটা রপ্তানি বা আমদানি করতে পারেন, মনে রাখবেন যে রপ্তানি করা ডেটা ফাইল Documents-এ TimeMark-Backups ফোল্ডারে সংরক্ষিত হয় এবং শুধুমাত্র এই ফাইলটি ডেটা পুনরুদ্ধার করতে ব্যবহার করা যেতে পারে, অন্য কোন ফাইল নয়।';

  @override
  String get faqGeneralQ6 =>
      'আমি কীভাবে ভাষা পরিবর্তন করতে পারি এবং কোন ভাষাগুলি উপলব্ধ, এছাড়াও অনুবাদ ভুল হলে কী করব?';

  @override
  String get faqGeneralA6 =>
      'ভাষা সেটিংস সাধারণ বিভাগের মাধ্যমে পরিবর্তন করা যেতে পারে, সমস্ত উপলব্ধ ভাষা সেখানে তালিকাভুক্ত আছে, আপনি যোগাযোগে ক্লিক করে এবং প্রদত্ত ভাষা সহ আপনার অনুরোধ পাঠিয়ে অনুবাদের অনুরোধ করতে পারেন। শুধু জানবেন যে অনুবাদ ভুল হতে পারে কারণ এটি ইংরেজি থেকে AI দ্বারা তৈরি করা হয়েছে এবং আপনি যদি রিপোর্ট করতে চান তবে আপনি বাগ রিপোর্ট, বা যোগাযোগের মাধ্যমে রিপোর্ট করতে পারেন, অথবা আপনি যদি একজন ডেভেলপার হন তবে গিটহাবে ইস্যু খুলুন। ভাষা সম্পর্কিত অবদানও স্বাগত!';

  @override
  String get faqGeneralQ7 => 'অনুবাদ ভুল হলে কী করব?';

  @override
  String get faqGeneralA7 =>
      'অনুবাদ ভুল হতে পারে কারণ এটি ইংরেজি থেকে AI দ্বারা তৈরি করা হয়েছে এবং আপনি যদি রিপোর্ট করতে চান তবে আপনি বাগ রিপোর্ট, বা যোগাযোগের মাধ্যমে রিপোর্ট করতে পারেন, অথবা আপনি যদি একজন ডেভেলপার হন তবে গিটহাবে ইস্যু খুলুন। ভাষা সম্পর্কিত অবদানও স্বাগত!';

  @override
  String get activityTrackingSection => 'কার্যকলাপ ট্র্যাকিং';

  @override
  String get idleDetectionTitle => 'নিষ্ক্রিয় সনাক্তকরণ';

  @override
  String get idleDetectionDescription => 'নিষ্ক্রিয় থাকলে ট্র্যাকিং বন্ধ করুন';

  @override
  String get idleTimeoutTitle => 'নিষ্ক্রিয় সময়সীমা';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'নিষ্ক্রিয় বিবেচনা করার আগে সময় ($timeout)';
  }

  @override
  String get advancedWarning =>
      'উন্নত বৈশিষ্ট্যগুলি সম্পদের ব্যবহার বাড়াতে পারে। শুধুমাত্র প্রয়োজন হলে সক্ষম করুন।';

  @override
  String get monitorAudioTitle => 'সিস্টেম অডিও মনিটর করুন';

  @override
  String get monitorAudioDescription =>
      'অডিও প্লেব্যাক থেকে কার্যকলাপ সনাক্ত করুন';

  @override
  String get audioSensitivityTitle => 'অডিও সংবেদনশীলতা';

  @override
  String audioSensitivityDescription(String value) {
    return 'সনাক্তকরণ থ্রেশহোল্ড ($value)';
  }

  @override
  String get monitorControllersTitle => 'গেম কন্ট্রোলার মনিটর করুন';

  @override
  String get monitorControllersDescription =>
      'Xbox/XInput কন্ট্রোলার সনাক্ত করুন';

  @override
  String get monitorHIDTitle => 'HID ডিভাইস মনিটর করুন';

  @override
  String get monitorHIDDescription =>
      'হুইল, ট্যাবলেট, কাস্টম ডিভাইস সনাক্ত করুন';

  @override
  String get setIdleTimeoutTitle => 'নিষ্ক্রিয় সময়সীমা সেট করুন';

  @override
  String get idleTimeoutDialogDescription =>
      'আপনাকে নিষ্ক্রিয় বিবেচনা করার আগে কতক্ষণ অপেক্ষা করতে হবে তা চয়ন করুন:';

  @override
  String get seconds30 => '30 সেকেন্ড';

  @override
  String get minute1 => '1 মিনিট';

  @override
  String get minutes2 => '2 মিনিট';

  @override
  String get minutes5 => '5 মিনিট';

  @override
  String get minutes10 => '10 মিনিট';

  @override
  String get customOption => 'কাস্টম';

  @override
  String get customDurationTitle => 'কাস্টম সময়কাল';

  @override
  String get minutesLabel => 'মিনিট';

  @override
  String get secondsLabel => 'সেকেন্ড';

  @override
  String get minAbbreviation => 'মি';

  @override
  String get secAbbreviation => 'সে';

  @override
  String totalLabel(String duration) {
    return 'মোট: $duration';
  }

  @override
  String minimumError(String value) {
    return 'সর্বনিম্ন হল $value';
  }

  @override
  String maximumError(String value) {
    return 'সর্বোচ্চ হল $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'পরিসীমা: $min - $max';
  }

  @override
  String get saveButton => 'সংরক্ষণ করুন';

  @override
  String timeFormatSeconds(int seconds) {
    return '$secondsসে';
  }

  @override
  String get timeFormatMinute => '1 মিনিট';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes মি $secondsসে';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeTitle => 'থিম';

  @override
  String get themeDescription =>
      'অ্যাপ্লিকেশনের রঙের থিম (পরিবর্তনের জন্য পুনরায় চালু করা প্রয়োজন)';
}
