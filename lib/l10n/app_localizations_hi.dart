// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appWindowTitle =>
      'टाइममार्क - स्क्रीन टाइम और ऐप उपयोग ट्रैक करें';

  @override
  String get appName => 'टाइममार्क';

  @override
  String get appTitle => 'उत्पादक स्क्रीनटाइम';

  @override
  String get sidebarTitle => 'स्क्रीनटाइम';

  @override
  String get sidebarSubtitle => 'ओपन सोर्स';

  @override
  String get trayShowWindow => 'विंडो दिखाएं';

  @override
  String get trayStartFocusMode => 'फोकस मोड शुरू करें';

  @override
  String get trayStopFocusMode => 'फोकस मोड बंद करें';

  @override
  String get trayReports => 'रिपोर्ट';

  @override
  String get trayAlertsLimits => 'अलर्ट और सीमाएं';

  @override
  String get trayApplications => 'एप्लिकेशन';

  @override
  String get trayDisableNotifications => 'नोटिफिकेशन बंद करें';

  @override
  String get trayEnableNotifications => 'नोटिफिकेशन चालू करें';

  @override
  String get trayVersionPrefix => 'संस्करण: ';

  @override
  String trayVersion(String version) {
    return 'संस्करण: $version';
  }

  @override
  String get trayExit => 'बाहर निकलें';

  @override
  String get navOverview => 'अवलोकन';

  @override
  String get navApplications => 'एप्लिकेशन';

  @override
  String get navAlertsLimits => 'अलर्ट और सीमाएं';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navFocusMode => 'फोकस मोड';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get navHelp => 'मदद';

  @override
  String get helpTitle => 'मदद';

  @override
  String get faqCategoryGeneral => 'सामान्य प्रश्न';

  @override
  String get faqCategoryApplications => 'एप्लिकेशन प्रबंधन';

  @override
  String get faqCategoryReports => 'उपयोग विश्लेषण और रिपोर्ट';

  @override
  String get faqCategoryAlerts => 'अलर्ट और सीमाएं';

  @override
  String get faqCategoryFocusMode => 'फोकस मोड और पोमोडोरो टाइमर';

  @override
  String get faqCategorySettings => 'सेटिंग्स और अनुकूलन';

  @override
  String get faqCategoryTroubleshooting => 'समस्या निवारण';

  @override
  String get faqGeneralQ1 => 'यह ऐप स्क्रीन टाइम कैसे ट्रैक करता है?';

  @override
  String get faqGeneralA1 =>
      'ऐप आपके डिवाइस के उपयोग को रियल-टाइम में मॉनिटर करता है, विभिन्न एप्लिकेशन पर बिताए गए समय को ट्रैक करता है। यह आपकी डिजिटल आदतों के बारे में व्यापक जानकारी प्रदान करता है, जिसमें कुल स्क्रीन टाइम, उत्पादक समय और एप्लिकेशन-विशिष्ट उपयोग शामिल है।';

  @override
  String get faqGeneralQ2 => 'किसी ऐप को \'उत्पादक\' क्या बनाता है?';

  @override
  String get faqGeneralA2 =>
      'आप \'एप्लिकेशन\' सेक्शन में ऐप्स को मैन्युअल रूप से उत्पादक के रूप में चिह्नित कर सकते हैं। उत्पादक ऐप्स आपके उत्पादकता स्कोर में योगदान करते हैं, जो काम से संबंधित या लाभदायक एप्लिकेशन पर बिताए गए स्क्रीन टाइम का प्रतिशत गणना करता है।';

  @override
  String get faqGeneralQ3 => 'स्क्रीन टाइम ट्रैकिंग कितनी सटीक है?';

  @override
  String get faqGeneralA3 =>
      'ऐप आपके डिवाइस उपयोग का सटीक माप प्रदान करने के लिए सिस्टम-लेवल ट्रैकिंग का उपयोग करता है। यह न्यूनतम बैटरी प्रभाव के साथ प्रत्येक एप्लिकेशन के फोरग्राउंड समय को कैप्चर करता है।';

  @override
  String get faqGeneralQ4 =>
      'क्या मैं अपनी ऐप श्रेणीकरण को अनुकूलित कर सकता हूं?';

  @override
  String get faqGeneralA4 =>
      'बिल्कुल! आप कस्टम श्रेणियां बना सकते हैं, ऐप्स को विशिष्ट श्रेणियों में असाइन कर सकते हैं, और \'एप्लिकेशन\' सेक्शन में इन असाइनमेंट को आसानी से संशोधित कर सकते हैं। यह अधिक सार्थक उपयोग विश्लेषण बनाने में मदद करता है।';

  @override
  String get faqGeneralQ5 => 'मुझे इस ऐप से कौन सी जानकारी मिल सकती है?';

  @override
  String get faqGeneralA5 =>
      'ऐप व्यापक जानकारी प्रदान करता है जिसमें उत्पादकता स्कोर, दिन के समय के अनुसार उपयोग पैटर्न, विस्तृत एप्लिकेशन उपयोग, फोकस सेशन ट्रैकिंग, और आपकी डिजिटल आदतों को समझने और सुधारने में मदद करने के लिए ग्राफ और पाई चार्ट जैसे विजुअल एनालिटिक्स शामिल हैं।';

  @override
  String get faqAppsQ1 => 'मैं विशिष्ट ऐप्स को ट्रैकिंग से कैसे छिपाऊं?';

  @override
  String get faqAppsA1 =>
      '\'एप्लिकेशन\' सेक्शन में, आप ऐप्स की दृश्यता को टॉगल कर सकते हैं।';

  @override
  String get faqAppsQ2 => 'क्या मैं अपने एप्लिकेशन खोज और फिल्टर कर सकता हूं?';

  @override
  String get faqAppsA2 =>
      'हां, एप्लिकेशन सेक्शन में सर्च फंक्शनालिटी और फिल्टरिंग ऑप्शन शामिल हैं। आप श्रेणी, उत्पादकता स्थिति, ट्रैकिंग स्थिति और दृश्यता के आधार पर ऐप्स फिल्टर कर सकते हैं।';

  @override
  String get faqAppsQ3 => 'एप्लिकेशन के लिए कौन से एडिटिंग विकल्प उपलब्ध हैं?';

  @override
  String get faqAppsA3 =>
      'प्रत्येक एप्लिकेशन के लिए, आप एडिट कर सकते हैं: श्रेणी असाइनमेंट, उत्पादकता स्थिति, उपयोग ट्रैकिंग, रिपोर्ट में दृश्यता, और व्यक्तिगत दैनिक समय सीमा सेट करें।';

  @override
  String get faqAppsQ4 => 'एप्लिकेशन श्रेणियां कैसे निर्धारित होती हैं?';

  @override
  String get faqAppsA4 =>
      'प्रारंभिक श्रेणियां सिस्टम-सुझाई गई हैं, लेकिन आपके पास अपने वर्कफ्लो और प्राथमिकताओं के आधार पर कस्टम श्रेणियां बनाने, संशोधित करने और असाइन करने का पूर्ण नियंत्रण है।';

  @override
  String get faqReportsQ1 => 'किस प्रकार की रिपोर्ट उपलब्ध हैं?';

  @override
  String get faqReportsA1 =>
      'रिपोर्ट में शामिल हैं: कुल स्क्रीन टाइम, उत्पादक समय, सबसे अधिक उपयोग किए गए ऐप्स, फोकस सेशन, दैनिक स्क्रीन टाइम ग्राफ, श्रेणी ब्रेकडाउन पाई चार्ट, विस्तृत एप्लिकेशन उपयोग, साप्ताहिक उपयोग ट्रेंड, और दिन के समय के अनुसार उपयोग पैटर्न विश्लेषण।';

  @override
  String get faqReportsQ2 => 'एप्लिकेशन उपयोग रिपोर्ट कितनी विस्तृत हैं?';

  @override
  String get faqReportsA2 =>
      'विस्तृत एप्लिकेशन उपयोग रिपोर्ट दिखाती हैं: ऐप नाम, श्रेणी, बिताया गया कुल समय, उत्पादकता स्थिति, और उपयोग सारांश, दैनिक सीमाएं, उपयोग ट्रेंड, और उत्पादकता मेट्रिक्स जैसी गहरी जानकारी के साथ \'एक्शन\' सेक्शन प्रदान करती हैं।';

  @override
  String get faqReportsQ3 =>
      'क्या मैं समय के साथ अपने उपयोग ट्रेंड का विश्लेषण कर सकता हूं?';

  @override
  String get faqReportsA3 =>
      'हां! ऐप सप्ताह-दर-सप्ताह तुलना प्रदान करता है, पिछले हफ्तों के उपयोग के ग्राफ, औसत दैनिक उपयोग, सबसे लंबे सेशन, और साप्ताहिक कुल दिखाता है ताकि आप अपनी डिजिटल आदतों को ट्रैक कर सकें।';

  @override
  String get faqReportsQ4 => '\'उपयोग पैटर्न\' विश्लेषण क्या है?';

  @override
  String get faqReportsA4 =>
      'उपयोग पैटर्न आपके स्क्रीन टाइम को सुबह, दोपहर, शाम और रात के खंडों में विभाजित करता है। यह आपको समझने में मदद करता है कि आप अपने डिवाइस पर कब सबसे अधिक सक्रिय हैं और सुधार के संभावित क्षेत्रों की पहचान करता है।';

  @override
  String get faqAlertsQ1 => 'स्क्रीन टाइम सीमाएं कितनी विस्तृत हैं?';

  @override
  String get faqAlertsA1 =>
      'आप समग्र दैनिक स्क्रीन टाइम सीमाएं और व्यक्तिगत ऐप सीमाएं सेट कर सकते हैं। सीमाएं घंटों और मिनटों में कॉन्फ़िगर की जा सकती हैं, आवश्यकतानुसार रीसेट या समायोजित करने के विकल्पों के साथ।';

  @override
  String get faqAlertsQ2 => 'कौन से नोटिफिकेशन विकल्प उपलब्ध हैं?';

  @override
  String get faqAlertsA2 =>
      'ऐप कई प्रकार के नोटिफिकेशन प्रदान करता है: स्क्रीन टाइम पार करने पर सिस्टम अलर्ट, अनुकूलन योग्य अंतराल (1, 5, 15, 30, या 60 मिनट) पर बार-बार अलर्ट, और फोकस मोड, स्क्रीन टाइम, और एप्लिकेशन-विशिष्ट नोटिफिकेशन के लिए टॉगल।';

  @override
  String get faqAlertsQ3 => 'क्या मैं सीमा अलर्ट को अनुकूलित कर सकता हूं?';

  @override
  String get faqAlertsA3 =>
      'हां, आप अलर्ट की आवृत्ति को अनुकूलित कर सकते हैं, विशिष्ट प्रकार के अलर्ट को सक्षम/अक्षम कर सकते हैं, और समग्र स्क्रीन टाइम और व्यक्तिगत एप्लिकेशन के लिए अलग-अलग सीमाएं सेट कर सकते हैं।';

  @override
  String get faqFocusQ1 => 'किस प्रकार के फोकस मोड उपलब्ध हैं?';

  @override
  String get faqFocusA1 =>
      'उपलब्ध मोड में डीप वर्क (लंबे फोकस्ड सेशन), क्विक टास्क (काम के छोटे बर्स्ट), और रीडिंग मोड शामिल हैं। प्रत्येक मोड आपके काम और ब्रेक टाइम को प्रभावी ढंग से संरचित करने में मदद करता है।';

  @override
  String get faqFocusQ2 => 'पोमोडोरो टाइमर कितना लचीला है?';

  @override
  String get faqFocusA2 =>
      'टाइमर अत्यधिक अनुकूलन योग्य है। आप काम की अवधि, छोटे ब्रेक की लंबाई, और लंबे ब्रेक की अवधि समायोजित कर सकते हैं। अतिरिक्त विकल्पों में अगले सेशन के लिए ऑटो-स्टार्ट और नोटिफिकेशन सेटिंग्स शामिल हैं।';

  @override
  String get faqFocusQ3 => 'फोकस मोड हिस्ट्री क्या दिखाती है?';

  @override
  String get faqFocusA3 =>
      'फोकस मोड हिस्ट्री दैनिक फोकस सेशन को ट्रैक करती है, प्रति दिन सेशन की संख्या, ट्रेंड ग्राफ, औसत सेशन अवधि, कुल फोकस समय, और वर्क सेशन, शॉर्ट ब्रेक, और लॉन्ग ब्रेक को विभाजित करने वाला टाइम डिस्ट्रीब्यूशन पाई चार्ट दिखाती है।';

  @override
  String get faqFocusQ4 =>
      'क्या मैं अपने फोकस सेशन प्रोग्रेस को ट्रैक कर सकता हूं?';

  @override
  String get faqFocusA4 =>
      'ऐप में प्ले/पॉज़, रीलोड, और सेटिंग्स बटन के साथ एक सर्कुलर टाइमर UI है। आप सहज नियंत्रणों के साथ अपने फोकस सेशन को आसानी से ट्रैक और प्रबंधित कर सकते हैं।';

  @override
  String get faqSettingsQ1 => 'कौन से अनुकूलन विकल्प उपलब्ध हैं?';

  @override
  String get faqSettingsA1 =>
      'अनुकूलन में थीम चयन (सिस्टम, लाइट, डार्क), भाषा सेटिंग्स, स्टार्टअप व्यवहार, व्यापक नोटिफिकेशन नियंत्रण, और डेटा क्लियर करने या सेटिंग्स रीसेट करने जैसे डेटा प्रबंधन विकल्प शामिल हैं।';

  @override
  String get faqSettingsQ2 =>
      'मैं फीडबैक कैसे दूं या समस्याएं कैसे रिपोर्ट करूं?';

  @override
  String get faqSettingsA2 =>
      'सेटिंग्स सेक्शन के नीचे, आपको बग रिपोर्ट करने, फीडबैक सबमिट करने, या सपोर्ट से संपर्क करने के बटन मिलेंगे। ये आपको उचित सपोर्ट चैनलों पर रीडायरेक्ट करेंगे।';

  @override
  String get faqSettingsQ3 =>
      'जब मैं अपना डेटा क्लियर करता हूं तो क्या होता है?';

  @override
  String get faqSettingsA3 =>
      'डेटा क्लियर करने से आपके सभी उपयोग आंकड़े, फोकस सेशन हिस्ट्री, और कस्टम सेटिंग्स रीसेट हो जाएंगी। यह फ्रेश स्टार्ट या समस्या निवारण के लिए उपयोगी है।';

  @override
  String get faqTroubleQ1 => 'डेटा नहीं दिख रहा, hive नहीं खुल रहा एरर';

  @override
  String get faqTroubleA1 =>
      'यह समस्या ज्ञात है, अस्थायी समाधान है सेटिंग्स के माध्यम से डेटा क्लियर करना और अगर यह काम नहीं करता है तो Documents में जाएं और यदि वे मौजूद हैं तो निम्नलिखित फाइलें हटाएं - harman_screentime_app_usage_box.hive और harman_screentime_app_usage.lock, आपको ऐप को नवीनतम संस्करण में अपडेट करने का भी सुझाव दिया जाता है।';

  @override
  String get faqTroubleQ2 => 'ऐप हर स्टार्टअप पर खुलता है, क्या करें?';

  @override
  String get faqTroubleA2 =>
      'यह एक ज्ञात समस्या है जो Windows 10 पर होती है, अस्थायी समाधान है सेटिंग्स में Launch as Minimized को सक्षम करना ताकि यह Minimized के रूप में लॉन्च हो।';

  @override
  String get usageAnalytics => 'उपयोग विश्लेषण';

  @override
  String get last7Days => 'पिछले 7 दिन';

  @override
  String get lastMonth => 'पिछला महीना';

  @override
  String get last3Months => 'पिछले 3 महीने';

  @override
  String get lifetime => 'लाइफटाइम';

  @override
  String get custom => 'कस्टम';

  @override
  String get loadingAnalyticsData => 'विश्लेषण डेटा लोड हो रहा है...';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get failedToInitialize =>
      'विश्लेषण प्रारंभ करने में विफल। कृपया एप्लिकेशन को पुनरारंभ करें।';

  @override
  String unexpectedError(String error) {
    return 'एक अप्रत्याशित त्रुटि हुई: $error। कृपया बाद में पुनः प्रयास करें।';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'विश्लेषण डेटा लोड करने में त्रुटि: $error। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।';
  }

  @override
  String get customDialogTitle => 'कस्टम';

  @override
  String get dateRange => 'तिथि सीमा';

  @override
  String get specificDate => 'विशिष्ट तिथि';

  @override
  String get startDate => 'प्रारंभ तिथि: ';

  @override
  String get endDate => 'समाप्ति तिथि: ';

  @override
  String get date => 'तिथि: ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get invalidDateRange => 'अमान्य तिथि सीमा';

  @override
  String get startDateBeforeEndDate =>
      'प्रारंभ तिथि समाप्ति तिथि से पहले या बराबर होनी चाहिए।';

  @override
  String get totalScreenTime => 'कुल स्क्रीन टाइम';

  @override
  String get productiveTime => 'उत्पादक समय';

  @override
  String get mostUsedApp => 'सबसे अधिक उपयोग किया गया ऐप';

  @override
  String get focusSessions => 'फोकस सेशन';

  @override
  String positiveComparison(String percent) {
    return '+$percent% पिछली अवधि की तुलना में';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% पिछली अवधि की तुलना में';
  }

  @override
  String iconLabel(String title) {
    return '$title आइकन';
  }

  @override
  String get dailyScreenTime => 'दैनिक स्क्रीन टाइम';

  @override
  String get categoryBreakdown => 'श्रेणी विभाजन';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String sectionLabel(String title) {
    return '$title सेक्शन';
  }

  @override
  String get detailedApplicationUsage => 'विस्तृत एप्लिकेशन उपयोग';

  @override
  String get searchApplications => 'एप्लिकेशन खोजें';

  @override
  String get nameHeader => 'नाम';

  @override
  String get categoryHeader => 'श्रेणी';

  @override
  String get totalTimeHeader => 'कुल समय';

  @override
  String get productivityHeader => 'उत्पादकता';

  @override
  String get actionsHeader => 'क्रियाएं';

  @override
  String sortByOption(String option) {
    return 'क्रमबद्ध करें: $option';
  }

  @override
  String get sortByName => 'नाम';

  @override
  String get sortByCategory => 'श्रेणी';

  @override
  String get sortByUsage => 'उपयोग';

  @override
  String get productive => 'उत्पादक';

  @override
  String get nonProductive => 'गैर-उत्पादक';

  @override
  String get noApplicationsMatch =>
      'आपके खोज मानदंडों से कोई एप्लिकेशन मेल नहीं खाता';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get usageSummary => 'उपयोग सारांश';

  @override
  String get usageOverPastWeek => 'पिछले सप्ताह का उपयोग';

  @override
  String get usagePatternByTimeOfDay => 'दिन के समय के अनुसार उपयोग पैटर्न';

  @override
  String get patternAnalysis => 'पैटर्न विश्लेषण';

  @override
  String get today => 'आज';

  @override
  String get dailyLimit => 'दैनिक सीमा';

  @override
  String get noLimit => 'कोई सीमा नहीं';

  @override
  String get usageTrend => 'उपयोग ट्रेंड';

  @override
  String get productivity => 'उत्पादकता';

  @override
  String get increasing => 'बढ़ रहा है';

  @override
  String get decreasing => 'घट रहा है';

  @override
  String get stable => 'स्थिर';

  @override
  String get avgDailyUsage => 'औसत दैनिक उपयोग';

  @override
  String get longestSession => 'सबसे लंबा सेशन';

  @override
  String get weeklyTotal => 'साप्ताहिक कुल';

  @override
  String get noHistoricalData => 'कोई ऐतिहासिक डेटा उपलब्ध नहीं';

  @override
  String get morning => 'सुबह (6-12)';

  @override
  String get afternoon => 'दोपहर (12-5)';

  @override
  String get evening => 'शाम (5-9)';

  @override
  String get night => 'रात (9-6)';

  @override
  String get usageInsights => 'उपयोग अंतर्दृष्टि';

  @override
  String get limitStatus => 'सीमा स्थिति';

  @override
  String get close => 'बंद करें';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'आप मुख्य रूप से $appName का उपयोग $timeOfDay के दौरान करते हैं।';
  }

  @override
  String significantIncrease(String percentage) {
    return 'आपका उपयोग पिछली अवधि की तुलना में काफी बढ़ा है ($percentage%)।';
  }

  @override
  String get trendingUpward =>
      'आपका उपयोग पिछली अवधि की तुलना में ऊपर की ओर ट्रेंड कर रहा है।';

  @override
  String significantDecrease(String percentage) {
    return 'आपका उपयोग पिछली अवधि की तुलना में काफी घटा है ($percentage%)।';
  }

  @override
  String get trendingDownward =>
      'आपका उपयोग पिछली अवधि की तुलना में नीचे की ओर ट्रेंड कर रहा है।';

  @override
  String get consistentUsage =>
      'आपका उपयोग पिछली अवधि की तुलना में सुसंगत रहा है।';

  @override
  String get markedAsProductive =>
      'यह आपकी सेटिंग्स में एक उत्पादक ऐप के रूप में चिह्नित है।';

  @override
  String get markedAsNonProductive =>
      'यह आपकी सेटिंग्स में एक गैर-उत्पादक ऐप के रूप में चिह्नित है।';

  @override
  String mostActiveTime(String time) {
    return 'आपका सबसे सक्रिय समय लगभग $time है।';
  }

  @override
  String get noLimitSet =>
      'इस एप्लिकेशन के लिए कोई उपयोग सीमा सेट नहीं की गई है।';

  @override
  String get limitReached =>
      'आपने इस एप्लिकेशन के लिए अपनी दैनिक सीमा तक पहुंच गई है।';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'आप अपनी दैनिक सीमा तक पहुंचने वाले हैं, केवल $remainingTime शेष है।';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'आपने अपनी दैनिक सीमा का $percent% उपयोग किया है, $remainingTime शेष है।';
  }

  @override
  String remainingTime(String time) {
    return 'आपके पास अपनी दैनिक सीमा में से $time शेष है।';
  }

  @override
  String get todayChart => 'आज';

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
    return '$hoursघं $minutesमि';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesमि';
  }

  @override
  String get alertsLimitsTitle => 'अलर्ट और सीमाएं';

  @override
  String get notificationsSettings => 'नोटिफिकेशन सेटिंग्स';

  @override
  String get overallScreenTimeLimit => 'समग्र स्क्रीन टाइम सीमा';

  @override
  String get applicationLimits => 'एप्लिकेशन सीमाएं';

  @override
  String get popupAlerts => 'पॉप-अप अलर्ट';

  @override
  String get frequentAlerts => 'बार-बार अलर्ट';

  @override
  String get soundAlerts => 'ध्वनि अलर्ट';

  @override
  String get systemAlerts => 'सिस्टम अलर्ट';

  @override
  String get dailyTotalLimit => 'दैनिक कुल सीमा: ';

  @override
  String get hours => 'घंटे: ';

  @override
  String get minutes => 'मिनट: ';

  @override
  String get currentUsage => 'वर्तमान उपयोग: ';

  @override
  String get tableName => 'नाम';

  @override
  String get tableCategory => 'श्रेणी';

  @override
  String get tableDailyLimit => 'दैनिक सीमा';

  @override
  String get tableCurrentUsage => 'वर्तमान उपयोग';

  @override
  String get tableStatus => 'स्थिति';

  @override
  String get tableActions => 'क्रियाएं';

  @override
  String get addLimit => 'सीमा जोड़ें';

  @override
  String get noApplicationsToDisplay =>
      'प्रदर्शित करने के लिए कोई एप्लिकेशन नहीं';

  @override
  String get statusActive => 'सक्रिय';

  @override
  String get statusOff => 'बंद';

  @override
  String get durationNone => 'कोई नहीं';

  @override
  String get addApplicationLimit => 'एप्लिकेशन सीमा जोड़ें';

  @override
  String get selectApplication => 'एप्लिकेशन चुनें';

  @override
  String get selectApplicationPlaceholder => 'एक एप्लिकेशन चुनें';

  @override
  String get enableLimit => 'सीमा सक्षम करें: ';

  @override
  String editLimitTitle(String appName) {
    return 'सीमा संपादित करें: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'डेटा लोड करने में विफल: $error';
  }

  @override
  String get resetSettingsTitle => 'सेटिंग्स रीसेट करें?';

  @override
  String get resetSettingsContent =>
      'यदि आप सेटिंग्स रीसेट करते हैं, तो आप इसे पुनर्प्राप्त नहीं कर पाएंगे। क्या आप इसे रीसेट करना चाहते हैं?';

  @override
  String get resetAll => 'सब रीसेट करें';

  @override
  String get refresh => 'रीफ्रेश';

  @override
  String get save => 'सहेजें';

  @override
  String get add => 'जोड़ें';

  @override
  String get error => 'त्रुटि';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get applicationsTitle => 'एप्लिकेशन';

  @override
  String get searchApplication => 'एप्लिकेशन खोजें';

  @override
  String get tracking => 'ट्रैकिंग';

  @override
  String get hiddenVisible => 'छिपा/दृश्यमान';

  @override
  String get selectCategory => 'एक श्रेणी चुनें';

  @override
  String get allCategories => 'सभी';

  @override
  String get tableScreenTime => 'स्क्रीन टाइम';

  @override
  String get tableTracking => 'ट्रैकिंग';

  @override
  String get tableHidden => 'छिपा';

  @override
  String get tableEdit => 'संपादित करें';

  @override
  String editAppTitle(String appName) {
    return '$appName संपादित करें';
  }

  @override
  String get categorySection => 'श्रेणी';

  @override
  String get customCategory => 'कस्टम';

  @override
  String get customCategoryPlaceholder => 'कस्टम श्रेणी नाम दर्ज करें';

  @override
  String get uncategorized => 'अवर्गीकृत';

  @override
  String get isProductive => 'उत्पादक है';

  @override
  String get trackUsage => 'उपयोग ट्रैक करें';

  @override
  String get visibleInReports => 'रिपोर्ट में दृश्यमान';

  @override
  String get timeLimitsSection => 'समय सीमाएं';

  @override
  String get enableDailyLimit => 'दैनिक सीमा सक्षम करें';

  @override
  String get setDailyTimeLimit => 'दैनिक समय सीमा सेट करें:';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String errorLoadingData(String error) {
    return 'अवलोकन डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String get focusModeTitle => 'फोकस मोड';

  @override
  String get historySection => 'इतिहास';

  @override
  String get trendsSection => 'ट्रेंड';

  @override
  String get timeDistributionSection => 'समय वितरण';

  @override
  String get sessionHistorySection => 'सेशन इतिहास';

  @override
  String get workSession => 'कार्य सेशन';

  @override
  String get shortBreak => 'छोटा ब्रेक';

  @override
  String get longBreak => 'लंबा ब्रेक';

  @override
  String get dateHeader => 'तिथि';

  @override
  String get durationHeader => 'अवधि';

  @override
  String get monday => 'सोमवार';

  @override
  String get tuesday => 'मंगलवार';

  @override
  String get wednesday => 'बुधवार';

  @override
  String get thursday => 'गुरुवार';

  @override
  String get friday => 'शुक्रवार';

  @override
  String get saturday => 'शनिवार';

  @override
  String get sunday => 'रविवार';

  @override
  String get focusModeSettingsTitle => 'फोकस मोड सेटिंग्स';

  @override
  String get modeCustom => 'कस्टम';

  @override
  String get modeDeepWork => 'डीप वर्क (60 मिनट)';

  @override
  String get modeQuickTasks => 'क्विक टास्क (25 मिनट)';

  @override
  String get modeReading => 'रीडिंग (45 मिनट)';

  @override
  String workDurationLabel(int minutes) {
    return 'कार्य अवधि: $minutes मिनट';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'छोटा ब्रेक: $minutes मिनट';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'लंबा ब्रेक: $minutes मिनट';
  }

  @override
  String get autoStartNextSession => 'अगला सेशन ऑटो-स्टार्ट करें';

  @override
  String get blockDistractions => 'फोकस मोड के दौरान विचलन को ब्लॉक करें';

  @override
  String get enableNotifications => 'नोटिफिकेशन सक्षम करें';

  @override
  String get saved => 'सहेजा गया';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'फोकस मोड डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String get overviewTitle => 'आज का अवलोकन';

  @override
  String get startFocusMode => 'फोकस मोड शुरू करें';

  @override
  String get loadingProductivityData => 'आपका उत्पादकता डेटा लोड हो रहा है...';

  @override
  String get noActivityDataAvailable =>
      'अभी तक कोई गतिविधि डेटा उपलब्ध नहीं है';

  @override
  String get startUsingApplications =>
      'स्क्रीन टाइम और उत्पादकता ट्रैक करने के लिए अपने एप्लिकेशन का उपयोग शुरू करें।';

  @override
  String get refreshData => 'डेटा रीफ्रेश करें';

  @override
  String get topApplications => 'शीर्ष एप्लिकेशन';

  @override
  String get noAppUsageDataAvailable =>
      'अभी तक कोई एप्लिकेशन उपयोग डेटा उपलब्ध नहीं है';

  @override
  String get noApplicationDataAvailable => 'कोई एप्लिकेशन डेटा उपलब्ध नहीं है';

  @override
  String get noCategoryDataAvailable => 'कोई श्रेणी डेटा उपलब्ध नहीं है';

  @override
  String get noApplicationLimitsSet =>
      'कोई एप्लिकेशन सीमाएं सेट नहीं की गई हैं';

  @override
  String get screenLabel => 'स्क्रीन';

  @override
  String get timeLabel => 'समय';

  @override
  String get productiveLabel => 'उत्पादक';

  @override
  String get scoreLabel => 'स्कोर';

  @override
  String get defaultNone => 'कोई नहीं';

  @override
  String get defaultTime => '0घं 0मि';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'अज्ञात';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get generalSection => 'सामान्य';

  @override
  String get notificationsSection => 'नोटिफिकेशन';

  @override
  String get dataSection => 'डेटा';

  @override
  String get versionSection => 'संस्करण';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageDescription => 'एप्लिकेशन की भाषा';

  @override
  String get startupBehaviourTitle => 'स्टार्टअप व्यवहार';

  @override
  String get startupBehaviourDescription => 'OS स्टार्टअप पर लॉन्च करें';

  @override
  String get launchMinimizedTitle => 'मिनिमाइज़ के रूप में लॉन्च करें';

  @override
  String get launchMinimizedDescription =>
      'एप्लिकेशन को सिस्टम ट्रे में शुरू करें (Windows 10 के लिए अनुशंसित)';

  @override
  String get notificationsTitle => 'नोटिफिकेशन';

  @override
  String get notificationsAllDescription => 'एप्लिकेशन की सभी नोटिफिकेशन';

  @override
  String get focusModeNotificationsTitle => 'फोकस मोड';

  @override
  String get focusModeNotificationsDescription =>
      'फोकस मोड के लिए सभी नोटिफिकेशन';

  @override
  String get screenTimeNotificationsTitle => 'स्क्रीन टाइम';

  @override
  String get screenTimeNotificationsDescription =>
      'स्क्रीन टाइम प्रतिबंध के लिए सभी नोटिफिकेशन';

  @override
  String get appScreenTimeNotificationsTitle => 'एप्लिकेशन स्क्रीन टाइम';

  @override
  String get appScreenTimeNotificationsDescription =>
      'एप्लिकेशन स्क्रीन टाइम प्रतिबंध के लिए सभी नोटिफिकेशन';

  @override
  String get frequentAlertsTitle => 'बार-बार अलर्ट अंतराल';

  @override
  String get frequentAlertsDescription =>
      'बार-बार नोटिफिकेशन के लिए अंतराल सेट करें (मिनट)';

  @override
  String get clearDataTitle => 'डेटा साफ़ करें';

  @override
  String get clearDataDescription =>
      'सभी इतिहास और अन्य संबंधित डेटा साफ़ करें';

  @override
  String get resetSettingsTitle2 => 'सेटिंग्स रीसेट करें';

  @override
  String get resetSettingsDescription => 'सभी सेटिंग्स रीसेट करें';

  @override
  String get versionTitle => 'संस्करण';

  @override
  String get versionDescription => 'ऐप का वर्तमान संस्करण';

  @override
  String get contactButton => 'संपर्क';

  @override
  String get reportBugButton => 'बग रिपोर्ट करें';

  @override
  String get submitFeedbackButton => 'प्रतिक्रिया सबमिट करें';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'डेटा साफ़ करें?';

  @override
  String get clearDataDialogContent =>
      'यह सभी इतिहास और संबंधित डेटा साफ़ कर देगा। आप इसे पुनर्प्राप्त नहीं कर पाएंगे। क्या आप आगे बढ़ना चाहते हैं?';

  @override
  String get clearDataButtonLabel => 'डेटा साफ़ करें';

  @override
  String get resetSettingsDialogTitle => 'सेटिंग्स रीसेट करें?';

  @override
  String get resetSettingsDialogContent =>
      'यह सभी सेटिंग्स को उनके डिफ़ॉल्ट मानों पर रीसेट कर देगा। क्या आप आगे बढ़ना चाहते हैं?';

  @override
  String get resetButtonLabel => 'रीसेट';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String couldNotLaunchUrl(String url) {
    return '$url लॉन्च नहीं किया जा सका';
  }

  @override
  String errorMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get chart_focusTrends => 'फोकस ट्रेंड';

  @override
  String get chart_sessionCount => 'सेशन गिनती';

  @override
  String get chart_avgDuration => 'औसत अवधि';

  @override
  String get chart_totalFocus => 'कुल फोकस';

  @override
  String get chart_yAxis_sessions => 'सेशन';

  @override
  String get chart_yAxis_minutes => 'मिनट';

  @override
  String get chart_yAxis_value => 'मान';

  @override
  String get chart_monthOverMonthChange => 'महीने-दर-महीने परिवर्तन: ';

  @override
  String get chart_customRange => 'कस्टम रेंज';

  @override
  String get day_monday => 'सोमवार';

  @override
  String get day_mondayShort => 'सोम';

  @override
  String get day_mondayAbbr => 'सो';

  @override
  String get day_tuesday => 'मंगलवार';

  @override
  String get day_tuesdayShort => 'मंग';

  @override
  String get day_tuesdayAbbr => 'मं';

  @override
  String get day_wednesday => 'बुधवार';

  @override
  String get day_wednesdayShort => 'बुध';

  @override
  String get day_wednesdayAbbr => 'बु';

  @override
  String get day_thursday => 'गुरुवार';

  @override
  String get day_thursdayShort => 'गुरु';

  @override
  String get day_thursdayAbbr => 'गु';

  @override
  String get day_friday => 'शुक्रवार';

  @override
  String get day_fridayShort => 'शुक्र';

  @override
  String get day_fridayAbbr => 'शु';

  @override
  String get day_saturday => 'शनिवार';

  @override
  String get day_saturdayShort => 'शनि';

  @override
  String get day_saturdayAbbr => 'श';

  @override
  String get day_sunday => 'रविवार';

  @override
  String get day_sundayShort => 'रवि';

  @override
  String get day_sundayAbbr => 'र';

  @override
  String time_hours(int count) {
    return '$countघं';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count मिनट';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursघं $minutesमि';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count घंटे';
  }

  @override
  String get month_january => 'जनवरी';

  @override
  String get month_januaryShort => 'जन';

  @override
  String get month_february => 'फरवरी';

  @override
  String get month_februaryShort => 'फर';

  @override
  String get month_march => 'मार्च';

  @override
  String get month_marchShort => 'मार्च';

  @override
  String get month_april => 'अप्रैल';

  @override
  String get month_aprilShort => 'अप्रै';

  @override
  String get month_may => 'मई';

  @override
  String get month_mayShort => 'मई';

  @override
  String get month_june => 'जून';

  @override
  String get month_juneShort => 'जून';

  @override
  String get month_july => 'जुलाई';

  @override
  String get month_julyShort => 'जुला';

  @override
  String get month_august => 'अगस्त';

  @override
  String get month_augustShort => 'अग';

  @override
  String get month_september => 'सितंबर';

  @override
  String get month_septemberShort => 'सित';

  @override
  String get month_october => 'अक्टूबर';

  @override
  String get month_octoberShort => 'अक्टू';

  @override
  String get month_november => 'नवंबर';

  @override
  String get month_novemberShort => 'नव';

  @override
  String get month_december => 'दिसंबर';

  @override
  String get month_decemberShort => 'दिस';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryProductivity => 'उत्पादकता';

  @override
  String get categoryDevelopment => 'विकास';

  @override
  String get categorySocialMedia => 'सोशल मीडिया';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryGaming => 'गेमिंग';

  @override
  String get categoryCommunication => 'संचार';

  @override
  String get categoryWebBrowsing => 'वेब ब्राउज़िंग';

  @override
  String get categoryCreative => 'क्रिएटिव';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryUtility => 'उपयोगिता';

  @override
  String get categoryUncategorized => 'अवर्गीकृत';

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
  String get appCalculator => 'कैलकुलेटर';

  @override
  String get appNotes => 'नोट्स';

  @override
  String get appSystemPreferences => 'सिस्टम प्राथमिकताएं';

  @override
  String get appTaskManager => 'टास्क मैनेजर';

  @override
  String get appFileExplorer => 'फाइल एक्सप्लोरर';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'एप्लिकेशन लोड हो रहा है...';

  @override
  String get loadingData => 'डेटा लोड हो रहा है...';

  @override
  String get reportsError => 'त्रुटि';

  @override
  String get reportsRetry => 'पुनः प्रयास करें';

  @override
  String get backupRestoreSection => 'बैकअप और पुनर्स्थापना';

  @override
  String get backupRestoreTitle => 'बैकअप और पुनर्स्थापना';

  @override
  String get exportDataTitle => 'डेटा निर्यात करें';

  @override
  String get exportDataDescription => 'अपने सभी डेटा का बैकअप बनाएं';

  @override
  String get importDataTitle => 'डेटा आयात करें';

  @override
  String get importDataDescription => 'बैकअप फाइल से पुनर्स्थापित करें';

  @override
  String get exportButton => 'निर्यात';

  @override
  String get importButton => 'आयात';

  @override
  String get closeButton => 'बंद करें';

  @override
  String get noButton => 'नहीं';

  @override
  String get shareButton => 'शेयर करें';

  @override
  String get exportStarting => 'निर्यात शुरू हो रहा है...';

  @override
  String get exportSuccessful =>
      'निर्यात सफल! फाइल Documents/TimeMark-Backups में सहेजी गई';

  @override
  String get exportFailed => 'निर्यात विफल';

  @override
  String get exportComplete => 'निर्यात पूर्ण';

  @override
  String get shareBackupQuestion => 'क्या आप बैकअप फाइल शेयर करना चाहेंगे?';

  @override
  String get importStarting => 'आयात शुरू हो रहा है...';

  @override
  String get importSuccessful => 'आयात सफल!';

  @override
  String get importFailed => 'आयात विफल';

  @override
  String get importOptionsTitle => 'आयात विकल्प';

  @override
  String get importOptionsQuestion => 'आप डेटा कैसे आयात करना चाहेंगे?';

  @override
  String get replaceModeTitle => 'प्रतिस्थापित करें';

  @override
  String get replaceModeDescription => 'सभी मौजूदा डेटा प्रतिस्थापित करें';

  @override
  String get mergeModeTitle => 'मर्ज करें';

  @override
  String get mergeModeDescription => 'मौजूदा डेटा के साथ जोड़ें';

  @override
  String get appendModeTitle => 'जोड़ें';

  @override
  String get appendModeDescription => 'केवल नए रिकॉर्ड जोड़ें';

  @override
  String get warningTitle => '⚠️ चेतावनी';

  @override
  String get replaceWarningMessage =>
      'यह आपके सभी मौजूदा डेटा को प्रतिस्थापित कर देगा। क्या आप वाकई जारी रखना चाहते हैं?';

  @override
  String get replaceAllButton => 'सभी प्रतिस्थापित करें';

  @override
  String get fileLabel => 'फाइल';

  @override
  String get sizeLabel => 'आकार';

  @override
  String get recordsLabel => 'रिकॉर्ड';

  @override
  String get usageRecordsLabel => 'उपयोग रिकॉर्ड';

  @override
  String get focusSessionsLabel => 'फोकस सेशन';

  @override
  String get appMetadataLabel => 'ऐप मेटाडेटा';

  @override
  String get updatedLabel => 'अपडेट किया गया';

  @override
  String get skippedLabel => 'छोड़ा गया';

  @override
  String get faqSettingsQ4 =>
      'मैं अपना डेटा कैसे पुनर्स्थापित या निर्यात कर सकता हूं?';

  @override
  String get faqSettingsA4 =>
      'आप सेटिंग्स में जा सकते हैं, और वहां आपको बैकअप और पुनर्स्थापना सेक्शन मिलेगा। आप यहां से डेटा निर्यात या आयात कर सकते हैं, ध्यान दें कि निर्यात की गई डेटा फाइल Documents में TimeMark-Backups फोल्डर में संग्रहीत है और केवल इस फाइल का उपयोग डेटा पुनर्स्थापित करने के लिए किया जा सकता है, कोई अन्य फाइल नहीं।';

  @override
  String get faqGeneralQ6 =>
      'मैं भाषा कैसे बदल सकता हूं और कौन सी भाषाएं उपलब्ध हैं, अगर मुझे लगे कि अनुवाद गलत है तो क्या करूं?';

  @override
  String get faqGeneralA6 =>
      'भाषा को सेटिंग्स सामान्य सेक्शन के माध्यम से बदला जा सकता है, सभी उपलब्ध भाषाएं वहां सूचीबद्ध हैं, आप संपर्क पर क्लिक करके और दी गई भाषा के साथ अपना अनुरोध भेजकर अनुवाद का अनुरोध कर सकते हैं। बस जान लें कि अनुवाद गलत हो सकता है क्योंकि यह AI द्वारा अंग्रेजी से उत्पन्न किया गया है और यदि आप रिपोर्ट करना चाहते हैं तो आप बग रिपोर्ट करें, या संपर्क के माध्यम से रिपोर्ट कर सकते हैं, या यदि आप डेवलपर हैं तो Github पर इश्यू खोलें। भाषा के संबंध में योगदान का भी स्वागत है!';

  @override
  String get faqGeneralQ7 => 'अगर मुझे लगे कि अनुवाद गलत है तो क्या करूं?';

  @override
  String get faqGeneralA7 =>
      'अनुवाद गलत हो सकता है क्योंकि यह AI द्वारा अंग्रेजी से उत्पन्न किया गया है और यदि आप रिपोर्ट करना चाहते हैं तो आप बग रिपोर्ट करें, या संपर्क के माध्यम से रिपोर्ट कर सकते हैं, या यदि आप डेवलपर हैं तो Github पर इश्यू खोलें। भाषा के संबंध में योगदान का भी स्वागत है!';

  @override
  String get activityTrackingSection => 'गतिविधि ट्रैकिंग';

  @override
  String get idleDetectionTitle => 'निष्क्रिय पहचान';

  @override
  String get idleDetectionDescription => 'निष्क्रिय होने पर ट्रैकिंग बंद करें';

  @override
  String get idleTimeoutTitle => 'निष्क्रिय समय सीमा';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'निष्क्रिय मानने से पहले का समय ($timeout)';
  }

  @override
  String get advancedWarning =>
      'उन्नत सुविधाएं संसाधन उपयोग बढ़ा सकती हैं। केवल आवश्यकता होने पर सक्षम करें।';

  @override
  String get monitorAudioTitle => 'सिस्टम ऑडियो मॉनिटर करें';

  @override
  String get monitorAudioDescription => 'ऑडियो प्लेबैक से गतिविधि का पता लगाएं';

  @override
  String get audioSensitivityTitle => 'ऑडियो संवेदनशीलता';

  @override
  String audioSensitivityDescription(String value) {
    return 'पता लगाने की सीमा ($value)';
  }

  @override
  String get monitorControllersTitle => 'गेम कंट्रोलर मॉनिटर करें';

  @override
  String get monitorControllersDescription =>
      'Xbox/XInput कंट्रोलर का पता लगाएं';

  @override
  String get monitorHIDTitle => 'HID उपकरण मॉनिटर करें';

  @override
  String get monitorHIDDescription =>
      'व्हील, टैबलेट, कस्टम उपकरणों का पता लगाएं';

  @override
  String get setIdleTimeoutTitle => 'निष्क्रिय समय सीमा सेट करें';

  @override
  String get idleTimeoutDialogDescription =>
      'आपको निष्क्रिय मानने से पहले कितनी देर प्रतीक्षा करनी है चुनें:';

  @override
  String get seconds30 => '30 सेकंड';

  @override
  String get minute1 => '1 मिनट';

  @override
  String get minutes2 => '2 मिनट';

  @override
  String get minutes5 => '5 मिनट';

  @override
  String get minutes10 => '10 मिनट';

  @override
  String get customOption => 'कस्टम';

  @override
  String get customDurationTitle => 'कस्टम अवधि';

  @override
  String get minutesLabel => 'मिनट';

  @override
  String get secondsLabel => 'सेकंड';

  @override
  String get minAbbreviation => 'मि';

  @override
  String get secAbbreviation => 'से';

  @override
  String totalLabel(String duration) {
    return 'कुल: $duration';
  }

  @override
  String minimumError(String value) {
    return 'न्यूनतम $value है';
  }

  @override
  String maximumError(String value) {
    return 'अधिकतम $value है';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'सीमा: $min - $max';
  }

  @override
  String get saveButton => 'सहेजें';

  @override
  String timeFormatSeconds(int seconds) {
    return '$secondsसे';
  }

  @override
  String get timeFormatMinute => '1 मिनट';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes मि $secondsसे';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeTitle => 'थीम';

  @override
  String get themeDescription =>
      'एप्लिकेशन की रंग थीम (बदलाव के लिए पुनरारंभ आवश्यक)';

  @override
  String get voiceGenderTitle => 'Voice Gender';

  @override
  String get voiceGenderDescription =>
      'Choose the voice gender for timer notifications';

  @override
  String get voiceGenderMale => 'Male';

  @override
  String get voiceGenderFemale => 'Female';
}
