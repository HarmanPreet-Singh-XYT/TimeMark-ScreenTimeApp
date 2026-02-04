// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appWindowTitle =>
      'TimeMark - Отслеживание экранного времени и использования приложений';

  @override
  String get appName => 'TimeMark';

  @override
  String get appTitle => 'Продуктивное экранное время';

  @override
  String get sidebarTitle => 'Экранное время';

  @override
  String get sidebarSubtitle => 'Открытый исходный код';

  @override
  String get trayShowWindow => 'Показать окно';

  @override
  String get trayStartFocusMode => 'Запустить режим фокусировки';

  @override
  String get trayStopFocusMode => 'Остановить режим фокусировки';

  @override
  String get trayReports => 'Отчёты';

  @override
  String get trayAlertsLimits => 'Оповещения и лимиты';

  @override
  String get trayApplications => 'Приложения';

  @override
  String get trayDisableNotifications => 'Отключить уведомления';

  @override
  String get trayEnableNotifications => 'Включить уведомления';

  @override
  String get trayVersionPrefix => 'Версия: ';

  @override
  String trayVersion(String version) {
    return 'Версия: $version';
  }

  @override
  String get trayExit => 'Выход';

  @override
  String get navOverview => 'Обзор';

  @override
  String get navApplications => 'Приложения';

  @override
  String get navAlertsLimits => 'Оповещения и лимиты';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navFocusMode => 'Режим фокусировки';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navHelp => 'Помощь';

  @override
  String get helpTitle => 'Помощь';

  @override
  String get faqCategoryGeneral => 'Общие вопросы';

  @override
  String get faqCategoryApplications => 'Управление приложениями';

  @override
  String get faqCategoryReports => 'Аналитика использования и отчёты';

  @override
  String get faqCategoryAlerts => 'Оповещения и лимиты';

  @override
  String get faqCategoryFocusMode => 'Режим фокусировки и таймер Помодоро';

  @override
  String get faqCategorySettings => 'Настройки и персонализация';

  @override
  String get faqCategoryTroubleshooting => 'Устранение неполадок';

  @override
  String get faqGeneralQ1 => 'Как приложение отслеживает экранное время?';

  @override
  String get faqGeneralA1 =>
      'Приложение отслеживает использование вашего устройства в реальном времени, фиксируя время, проведённое в различных приложениях. Оно предоставляет полную информацию о ваших цифровых привычках, включая общее экранное время, продуктивное время и использование конкретных приложений.';

  @override
  String get faqGeneralQ2 => 'Что делает приложение \'Продуктивным\'?';

  @override
  String get faqGeneralA2 =>
      'Вы можете вручную отметить приложения как продуктивные в разделе \'Приложения\'. Продуктивные приложения учитываются в вашем показателе продуктивности, который рассчитывает процент экранного времени, потраченного на рабочие или полезные приложения.';

  @override
  String get faqGeneralQ3 => 'Насколько точно отслеживание экранного времени?';

  @override
  String get faqGeneralA3 =>
      'Приложение использует отслеживание на системном уровне для точного измерения использования вашего устройства. Оно фиксирует время активного использования каждого приложения с минимальным влиянием на батарею.';

  @override
  String get faqGeneralQ4 => 'Могу ли я настроить категоризацию приложений?';

  @override
  String get faqGeneralA4 =>
      'Конечно! Вы можете создавать пользовательские категории, назначать приложения определённым категориям и легко изменять эти назначения в разделе \'Приложения\'. Это помогает создавать более осмысленную аналитику использования.';

  @override
  String get faqGeneralQ5 =>
      'Какую информацию я могу получить из этого приложения?';

  @override
  String get faqGeneralA5 =>
      'Приложение предлагает комплексную аналитику, включая показатель продуктивности, паттерны использования по времени суток, детальное использование приложений, отслеживание сессий фокусировки и визуальную аналитику в виде графиков и диаграмм, чтобы помочь вам понять и улучшить ваши цифровые привычки.';

  @override
  String get faqAppsQ1 => 'Как скрыть определённые приложения из отслеживания?';

  @override
  String get faqAppsA1 =>
      'В разделе \'Приложения\' вы можете переключить видимость приложений.';

  @override
  String get faqAppsQ2 => 'Можно ли искать и фильтровать приложения?';

  @override
  String get faqAppsA2 =>
      'Да, раздел Приложения включает функцию поиска и параметры фильтрации. Вы можете фильтровать приложения по категории, статусу продуктивности, статусу отслеживания и видимости.';

  @override
  String get faqAppsQ3 =>
      'Какие параметры редактирования доступны для приложений?';

  @override
  String get faqAppsA3 =>
      'Для каждого приложения вы можете редактировать: назначение категории, статус продуктивности, отслеживание использования, видимость в отчётах и устанавливать индивидуальные дневные лимиты времени.';

  @override
  String get faqAppsQ4 => 'Как определяются категории приложений?';

  @override
  String get faqAppsA4 =>
      'Начальные категории предлагаются системой, но вы имеете полный контроль для создания, изменения и назначения пользовательских категорий в соответствии с вашим рабочим процессом и предпочтениями.';

  @override
  String get faqReportsQ1 => 'Какие типы отчётов доступны?';

  @override
  String get faqReportsA1 =>
      'Отчёты включают: общее экранное время, продуктивное время, наиболее используемые приложения, сессии фокусировки, график дневного экранного времени, круговую диаграмму распределения по категориям, детальное использование приложений, недельные тренды использования и анализ паттернов использования по времени суток.';

  @override
  String get faqReportsQ2 =>
      'Насколько детальны отчёты об использовании приложений?';

  @override
  String get faqReportsA2 =>
      'Детальные отчёты об использовании приложений показывают: название приложения, категорию, общее время использования, статус продуктивности и предлагают раздел \'Действия\' с более глубокой аналитикой, такой как сводка использования, дневные лимиты, тренды использования и метрики продуктивности.';

  @override
  String get faqReportsQ3 =>
      'Можно ли анализировать тренды использования за период?';

  @override
  String get faqReportsA3 =>
      'Да! Приложение предоставляет сравнения по неделям, показывая графики использования за прошлые недели, среднее дневное использование, самые длинные сессии и недельные итоги, чтобы помочь вам отслеживать ваши цифровые привычки.';

  @override
  String get faqReportsQ4 => 'Что такое анализ \'Паттерна использования\'?';

  @override
  String get faqReportsA4 =>
      'Паттерн использования разбивает ваше экранное время на сегменты: утро, день, вечер и ночь. Это помогает понять, когда вы наиболее активно используете устройство, и определить потенциальные области для улучшения.';

  @override
  String get faqAlertsQ1 =>
      'Насколько детально можно настроить лимиты экранного времени?';

  @override
  String get faqAlertsA1 =>
      'Вы можете установить общие дневные лимиты экранного времени и индивидуальные лимиты для приложений. Лимиты можно настроить в часах и минутах с возможностью сброса или корректировки по мере необходимости.';

  @override
  String get faqAlertsQ2 => 'Какие параметры уведомлений доступны?';

  @override
  String get faqAlertsA2 =>
      'Приложение предлагает несколько типов уведомлений: системные оповещения при превышении экранного времени, частые оповещения с настраиваемыми интервалами (1, 5, 15, 30 или 60 минут) и переключатели для уведомлений режима фокусировки, экранного времени и конкретных приложений.';

  @override
  String get faqAlertsQ3 => 'Можно ли настроить оповещения о лимитах?';

  @override
  String get faqAlertsA3 =>
      'Да, вы можете настроить частоту оповещений, включить/отключить определённые типы оповещений и установить разные лимиты для общего экранного времени и отдельных приложений.';

  @override
  String get faqFocusQ1 => 'Какие типы режимов фокусировки доступны?';

  @override
  String get faqFocusA1 =>
      'Доступные режимы включают Глубокую работу (длительные сфокусированные сессии), Быстрые задачи (короткие рабочие интервалы) и Режим чтения. Каждый режим помогает эффективно структурировать ваше рабочее время и перерывы.';

  @override
  String get faqFocusQ2 => 'Насколько гибок таймер Помодоро?';

  @override
  String get faqFocusA2 =>
      'Таймер очень настраиваемый. Вы можете регулировать продолжительность работы, длину короткого перерыва и продолжительность длинного перерыва. Дополнительные опции включают автозапуск следующих сессий и настройки уведомлений.';

  @override
  String get faqFocusQ3 => 'Что показывает история режима фокусировки?';

  @override
  String get faqFocusA3 =>
      'История режима фокусировки отслеживает дневные сессии фокусировки, показывая количество сессий в день, график трендов, среднюю продолжительность сессии, общее время фокусировки и круговую диаграмму распределения времени между рабочими сессиями, короткими и длинными перерывами.';

  @override
  String get faqFocusQ4 => 'Можно ли отслеживать прогресс сессии фокусировки?';

  @override
  String get faqFocusA4 =>
      'Приложение имеет круговой интерфейс таймера с кнопками воспроизведения/паузы, перезагрузки и настроек. Вы можете легко отслеживать и управлять сессиями фокусировки с помощью интуитивного управления.';

  @override
  String get faqSettingsQ1 => 'Какие параметры настройки доступны?';

  @override
  String get faqSettingsA1 =>
      'Настройка включает выбор темы (Системная, Светлая, Тёмная), языковые настройки, поведение при запуске, комплексное управление уведомлениями и параметры управления данными, такие как очистка данных или сброс настроек.';

  @override
  String get faqSettingsQ2 => 'Как отправить отзыв или сообщить о проблеме?';

  @override
  String get faqSettingsA2 =>
      'В нижней части раздела Настройки вы найдёте кнопки для сообщения об ошибке, отправки отзыва или связи с поддержкой. Они перенаправят вас в соответствующие каналы поддержки.';

  @override
  String get faqSettingsQ3 => 'Что происходит при очистке данных?';

  @override
  String get faqSettingsA3 =>
      'Очистка данных сбросит всю вашу статистику использования, историю сессий фокусировки и пользовательские настройки. Это полезно для начала с чистого листа или устранения неполадок.';

  @override
  String get faqTroubleQ1 => 'Данные не отображаются, ошибка открытия hive';

  @override
  String get faqTroubleA1 =>
      'Проблема известна, временное решение — очистить данные через настройки, и если это не помогает, перейдите в Документы и удалите следующие файлы, если они существуют — harman_screentime_app_usage_box.hive и harman_screentime_app_usage.lock, также рекомендуется обновить приложение до последней версии.';

  @override
  String get faqTroubleQ2 =>
      'Приложение открывается при каждом запуске, что делать?';

  @override
  String get faqTroubleA2 =>
      'Это известная проблема, которая возникает в Windows 10, временное решение — включить Запуск в свёрнутом виде в настройках, чтобы оно запускалось свёрнутым.';

  @override
  String get usageAnalytics => 'Аналитика использования';

  @override
  String get last7Days => 'Последние 7 дней';

  @override
  String get lastMonth => 'Последний месяц';

  @override
  String get last3Months => 'Последние 3 месяца';

  @override
  String get lifetime => 'За всё время';

  @override
  String get custom => 'Пользовательский';

  @override
  String get loadingAnalyticsData => 'Загрузка аналитических данных...';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get failedToInitialize =>
      'Не удалось инициализировать аналитику. Пожалуйста, перезапустите приложение.';

  @override
  String unexpectedError(String error) {
    return 'Произошла непредвиденная ошибка: $error. Пожалуйста, попробуйте позже.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Ошибка загрузки аналитических данных: $error. Пожалуйста, проверьте подключение и попробуйте снова.';
  }

  @override
  String get customDialogTitle => 'Пользовательский';

  @override
  String get dateRange => 'Диапазон дат';

  @override
  String get specificDate => 'Конкретная дата';

  @override
  String get startDate => 'Дата начала: ';

  @override
  String get endDate => 'Дата окончания: ';

  @override
  String get date => 'Дата: ';

  @override
  String get cancel => 'Отмена';

  @override
  String get apply => 'Применить';

  @override
  String get ok => 'ОК';

  @override
  String get invalidDateRange => 'Недопустимый диапазон дат';

  @override
  String get startDateBeforeEndDate =>
      'Дата начала должна быть раньше или равна дате окончания.';

  @override
  String get totalScreenTime => 'Общее экранное время';

  @override
  String get productiveTime => 'Продуктивное время';

  @override
  String get mostUsedApp => 'Самое используемое приложение';

  @override
  String get focusSessions => 'Сессии фокусировки';

  @override
  String positiveComparison(String percent) {
    return '+$percent% по сравнению с предыдущим периодом';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% по сравнению с предыдущим периодом';
  }

  @override
  String iconLabel(String title) {
    return 'Иконка $title';
  }

  @override
  String get dailyScreenTime => 'Дневное экранное время';

  @override
  String get categoryBreakdown => 'Распределение по категориям';

  @override
  String get noDataAvailable => 'Данные недоступны';

  @override
  String sectionLabel(String title) {
    return 'Раздел $title';
  }

  @override
  String get detailedApplicationUsage => 'Детальное использование приложений';

  @override
  String get searchApplications => 'Поиск приложений';

  @override
  String get nameHeader => 'Название';

  @override
  String get categoryHeader => 'Категория';

  @override
  String get totalTimeHeader => 'Общее время';

  @override
  String get productivityHeader => 'Продуктивность';

  @override
  String get actionsHeader => 'Действия';

  @override
  String sortByOption(String option) {
    return 'Сортировать по: $option';
  }

  @override
  String get sortByName => 'Название';

  @override
  String get sortByCategory => 'Категория';

  @override
  String get sortByUsage => 'Использование';

  @override
  String get productive => 'Продуктивное';

  @override
  String get nonProductive => 'Непродуктивное';

  @override
  String get noApplicationsMatch =>
      'Нет приложений, соответствующих критериям поиска';

  @override
  String get viewDetails => 'Просмотр деталей';

  @override
  String get usageSummary => 'Сводка использования';

  @override
  String get usageOverPastWeek => 'Использование за прошлую неделю';

  @override
  String get usagePatternByTimeOfDay =>
      'Паттерн использования по времени суток';

  @override
  String get patternAnalysis => 'Анализ паттернов';

  @override
  String get today => 'Сегодня';

  @override
  String get dailyLimit => 'Дневной лимит';

  @override
  String get noLimit => 'Без лимита';

  @override
  String get usageTrend => 'Тренд использования';

  @override
  String get productivity => 'Продуктивность';

  @override
  String get increasing => 'Растёт';

  @override
  String get decreasing => 'Снижается';

  @override
  String get stable => 'Стабильно';

  @override
  String get avgDailyUsage => 'Среднее дневное использование';

  @override
  String get longestSession => 'Самая длинная сессия';

  @override
  String get weeklyTotal => 'Недельный итог';

  @override
  String get noHistoricalData => 'Исторические данные недоступны';

  @override
  String get morning => 'Утро (6-12)';

  @override
  String get afternoon => 'День (12-17)';

  @override
  String get evening => 'Вечер (17-21)';

  @override
  String get night => 'Ночь (21-6)';

  @override
  String get usageInsights => 'Инсайты использования';

  @override
  String get limitStatus => 'Статус лимита';

  @override
  String get close => 'Закрыть';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Вы преимущественно используете $appName в $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Ваше использование значительно выросло ($percentage%) по сравнению с предыдущим периодом.';
  }

  @override
  String get trendingUpward =>
      'Ваше использование имеет тенденцию к росту по сравнению с предыдущим периодом.';

  @override
  String significantDecrease(String percentage) {
    return 'Ваше использование значительно снизилось ($percentage%) по сравнению с предыдущим периодом.';
  }

  @override
  String get trendingDownward =>
      'Ваше использование имеет тенденцию к снижению по сравнению с предыдущим периодом.';

  @override
  String get consistentUsage =>
      'Ваше использование было стабильным по сравнению с предыдущим периодом.';

  @override
  String get markedAsProductive =>
      'Это приложение отмечено как продуктивное в ваших настройках.';

  @override
  String get markedAsNonProductive =>
      'Это приложение отмечено как непродуктивное в ваших настройках.';

  @override
  String mostActiveTime(String time) {
    return 'Ваше самое активное время — около $time.';
  }

  @override
  String get noLimitSet =>
      'Лимит использования для этого приложения не установлен.';

  @override
  String get limitReached =>
      'Вы достигли дневного лимита для этого приложения.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Вы близки к достижению дневного лимита, осталось всего $remainingTime.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Вы использовали $percent% дневного лимита, осталось $remainingTime.';
  }

  @override
  String remainingTime(String time) {
    return 'У вас осталось $time от дневного лимита.';
  }

  @override
  String get todayChart => 'Сегодня';

  @override
  String hourPeriodAM(int hour) {
    return '$hour утра';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour вечера';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesм';
  }

  @override
  String get alertsLimitsTitle => 'Оповещения и лимиты';

  @override
  String get notificationsSettings => 'Настройки уведомлений';

  @override
  String get overallScreenTimeLimit => 'Общий лимит экранного времени';

  @override
  String get applicationLimits => 'Лимиты приложений';

  @override
  String get popupAlerts => 'Всплывающие оповещения';

  @override
  String get frequentAlerts => 'Частые оповещения';

  @override
  String get soundAlerts => 'Звуковые оповещения';

  @override
  String get systemAlerts => 'Системные оповещения';

  @override
  String get dailyTotalLimit => 'Дневной общий лимит: ';

  @override
  String get hours => 'Часы: ';

  @override
  String get minutes => 'Минуты: ';

  @override
  String get currentUsage => 'Текущее использование: ';

  @override
  String get tableName => 'Название';

  @override
  String get tableCategory => 'Категория';

  @override
  String get tableDailyLimit => 'Дневной лимит';

  @override
  String get tableCurrentUsage => 'Текущее использование';

  @override
  String get tableStatus => 'Статус';

  @override
  String get tableActions => 'Действия';

  @override
  String get addLimit => 'Добавить лимит';

  @override
  String get noApplicationsToDisplay => 'Нет приложений для отображения';

  @override
  String get statusActive => 'Активен';

  @override
  String get statusOff => 'Выкл';

  @override
  String get durationNone => 'Нет';

  @override
  String get addApplicationLimit => 'Добавить лимит приложения';

  @override
  String get selectApplication => 'Выбрать приложение';

  @override
  String get selectApplicationPlaceholder => 'Выберите приложение';

  @override
  String get enableLimit => 'Включить лимит: ';

  @override
  String editLimitTitle(String appName) {
    return 'Редактировать лимит: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Не удалось загрузить данные: $error';
  }

  @override
  String get resetSettingsTitle => 'Сбросить настройки?';

  @override
  String get resetSettingsContent =>
      'Если вы сбросите настройки, вы не сможете их восстановить. Вы хотите сбросить?';

  @override
  String get resetAll => 'Сбросить всё';

  @override
  String get refresh => 'Обновить';

  @override
  String get save => 'Сохранить';

  @override
  String get add => 'Добавить';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get applicationsTitle => 'Приложения';

  @override
  String get searchApplication => 'Поиск приложения';

  @override
  String get tracking => 'Отслеживание';

  @override
  String get hiddenVisible => 'Скрытые/Видимые';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get allCategories => 'Все';

  @override
  String get tableScreenTime => 'Экранное время';

  @override
  String get tableTracking => 'Отслеживание';

  @override
  String get tableHidden => 'Скрыто';

  @override
  String get tableEdit => 'Редактировать';

  @override
  String editAppTitle(String appName) {
    return 'Редактировать $appName';
  }

  @override
  String get categorySection => 'Категория';

  @override
  String get customCategory => 'Пользовательская';

  @override
  String get customCategoryPlaceholder =>
      'Введите название пользовательской категории';

  @override
  String get uncategorized => 'Без категории';

  @override
  String get isProductive => 'Продуктивное';

  @override
  String get trackUsage => 'Отслеживать использование';

  @override
  String get visibleInReports => 'Видимое в отчётах';

  @override
  String get timeLimitsSection => 'Временные лимиты';

  @override
  String get enableDailyLimit => 'Включить дневной лимит';

  @override
  String get setDailyTimeLimit => 'Установить дневной лимит времени:';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String errorLoadingData(String error) {
    return 'Ошибка загрузки данных обзора: $error';
  }

  @override
  String get focusModeTitle => 'Режим фокусировки';

  @override
  String get historySection => 'История';

  @override
  String get trendsSection => 'Тренды';

  @override
  String get timeDistributionSection => 'Распределение времени';

  @override
  String get sessionHistorySection => 'История сессий';

  @override
  String get workSession => 'Рабочая сессия';

  @override
  String get shortBreak => 'Короткий перерыв';

  @override
  String get longBreak => 'Длинный перерыв';

  @override
  String get dateHeader => 'Дата';

  @override
  String get durationHeader => 'Продолжительность';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get focusModeSettingsTitle => 'Настройки режима фокусировки';

  @override
  String get modeCustom => 'Пользовательский';

  @override
  String get modeDeepWork => 'Глубокая работа (60 мин)';

  @override
  String get modeQuickTasks => 'Быстрые задачи (25 мин)';

  @override
  String get modeReading => 'Чтение (45 мин)';

  @override
  String workDurationLabel(int minutes) {
    return 'Продолжительность работы: $minutes мин';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Короткий перерыв: $minutes мин';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Длинный перерыв: $minutes мин';
  }

  @override
  String get autoStartNextSession => 'Автозапуск следующей сессии';

  @override
  String get blockDistractions =>
      'Блокировать отвлечения во время режима фокусировки';

  @override
  String get enableNotifications => 'Включить уведомления';

  @override
  String get saved => 'Сохранено';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Ошибка загрузки данных режима фокусировки: $error';
  }

  @override
  String get overviewTitle => 'Обзор за сегодня';

  @override
  String get startFocusMode => 'Запустить режим фокусировки';

  @override
  String get loadingProductivityData =>
      'Загрузка ваших данных продуктивности...';

  @override
  String get noActivityDataAvailable => 'Данные об активности пока недоступны';

  @override
  String get startUsingApplications =>
      'Начните использовать приложения для отслеживания экранного времени и продуктивности.';

  @override
  String get refreshData => 'Обновить данные';

  @override
  String get topApplications => 'Топ приложений';

  @override
  String get noAppUsageDataAvailable =>
      'Данные об использовании приложений пока недоступны';

  @override
  String get noApplicationDataAvailable => 'Данные о приложениях недоступны';

  @override
  String get noCategoryDataAvailable => 'Данные о категориях недоступны';

  @override
  String get noApplicationLimitsSet => 'Лимиты приложений не установлены';

  @override
  String get screenLabel => 'Экран';

  @override
  String get timeLabel => 'Время';

  @override
  String get productiveLabel => 'Продуктивное';

  @override
  String get scoreLabel => 'Оценка';

  @override
  String get defaultNone => 'Нет';

  @override
  String get defaultTime => '0ч 0м';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Неизвестно';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get generalSection => 'Общие';

  @override
  String get notificationsSection => 'Уведомления';

  @override
  String get dataSection => 'Данные';

  @override
  String get versionSection => 'Версия';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageDescription => 'Язык приложения';

  @override
  String get startupBehaviourTitle => 'Поведение при запуске';

  @override
  String get startupBehaviourDescription => 'Запускать при старте ОС';

  @override
  String get launchMinimizedTitle => 'Запускать свёрнутым';

  @override
  String get launchMinimizedDescription =>
      'Запускать приложение в системном трее (рекомендуется для Windows 10)';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsAllDescription => 'Все уведомления приложения';

  @override
  String get focusModeNotificationsTitle => 'Режим фокусировки';

  @override
  String get focusModeNotificationsDescription =>
      'Все уведомления для режима фокусировки';

  @override
  String get screenTimeNotificationsTitle => 'Экранное время';

  @override
  String get screenTimeNotificationsDescription =>
      'Все уведомления для ограничения экранного времени';

  @override
  String get appScreenTimeNotificationsTitle => 'Экранное время приложений';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Все уведомления для ограничения экранного времени приложений';

  @override
  String get frequentAlertsTitle => 'Интервал частых оповещений';

  @override
  String get frequentAlertsDescription =>
      'Установить интервал для частых уведомлений (минуты)';

  @override
  String get clearDataTitle => 'Очистить данные';

  @override
  String get clearDataDescription => 'Очистить всю историю и связанные данные';

  @override
  String get resetSettingsTitle2 => 'Сбросить настройки';

  @override
  String get resetSettingsDescription => 'Сбросить все настройки';

  @override
  String get versionTitle => 'Версия';

  @override
  String get versionDescription => 'Текущая версия приложения';

  @override
  String get contactButton => 'Связаться';

  @override
  String get reportBugButton => 'Сообщить об ошибке';

  @override
  String get submitFeedbackButton => 'Отправить отзыв';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Очистить данные?';

  @override
  String get clearDataDialogContent =>
      'Это очистит всю историю и связанные данные. Вы не сможете их восстановить. Вы хотите продолжить?';

  @override
  String get clearDataButtonLabel => 'Очистить данные';

  @override
  String get resetSettingsDialogTitle => 'Сбросить настройки?';

  @override
  String get resetSettingsDialogContent =>
      'Это сбросит все настройки к значениям по умолчанию. Вы хотите продолжить?';

  @override
  String get resetButtonLabel => 'Сбросить';

  @override
  String get cancelButton => 'Отмена';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Не удалось открыть $url';
  }

  @override
  String errorMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get chart_focusTrends => 'Тренды фокусировки';

  @override
  String get chart_sessionCount => 'Количество сессий';

  @override
  String get chart_avgDuration => 'Средняя продолжительность';

  @override
  String get chart_totalFocus => 'Общее время фокусировки';

  @override
  String get chart_yAxis_sessions => 'Сессии';

  @override
  String get chart_yAxis_minutes => 'Минуты';

  @override
  String get chart_yAxis_value => 'Значение';

  @override
  String get chart_monthOverMonthChange =>
      'Изменение по сравнению с прошлым месяцем: ';

  @override
  String get chart_customRange => 'Пользовательский диапазон';

  @override
  String get day_monday => 'Понедельник';

  @override
  String get day_mondayShort => 'Пн';

  @override
  String get day_mondayAbbr => 'Пн';

  @override
  String get day_tuesday => 'Вторник';

  @override
  String get day_tuesdayShort => 'Вт';

  @override
  String get day_tuesdayAbbr => 'Вт';

  @override
  String get day_wednesday => 'Среда';

  @override
  String get day_wednesdayShort => 'Ср';

  @override
  String get day_wednesdayAbbr => 'Ср';

  @override
  String get day_thursday => 'Четверг';

  @override
  String get day_thursdayShort => 'Чт';

  @override
  String get day_thursdayAbbr => 'Чт';

  @override
  String get day_friday => 'Пятница';

  @override
  String get day_fridayShort => 'Пт';

  @override
  String get day_fridayAbbr => 'Пт';

  @override
  String get day_saturday => 'Суббота';

  @override
  String get day_saturdayShort => 'Сб';

  @override
  String get day_saturdayAbbr => 'Сб';

  @override
  String get day_sunday => 'Воскресенье';

  @override
  String get day_sundayShort => 'Вс';

  @override
  String get day_sundayAbbr => 'Вс';

  @override
  String time_hours(int count) {
    return '$countч';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count мин';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursч $minutesм';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count часов';
  }

  @override
  String get month_january => 'Январь';

  @override
  String get month_januaryShort => 'Янв';

  @override
  String get month_february => 'Февраль';

  @override
  String get month_februaryShort => 'Фев';

  @override
  String get month_march => 'Март';

  @override
  String get month_marchShort => 'Мар';

  @override
  String get month_april => 'Апрель';

  @override
  String get month_aprilShort => 'Апр';

  @override
  String get month_may => 'Май';

  @override
  String get month_mayShort => 'Май';

  @override
  String get month_june => 'Июнь';

  @override
  String get month_juneShort => 'Июн';

  @override
  String get month_july => 'Июль';

  @override
  String get month_julyShort => 'Июл';

  @override
  String get month_august => 'Август';

  @override
  String get month_augustShort => 'Авг';

  @override
  String get month_september => 'Сентябрь';

  @override
  String get month_septemberShort => 'Сен';

  @override
  String get month_october => 'Октябрь';

  @override
  String get month_octoberShort => 'Окт';

  @override
  String get month_november => 'Ноябрь';

  @override
  String get month_novemberShort => 'Ноя';

  @override
  String get month_december => 'Декабрь';

  @override
  String get month_decemberShort => 'Дек';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryProductivity => 'Продуктивность';

  @override
  String get categoryDevelopment => 'Разработка';

  @override
  String get categorySocialMedia => 'Социальные сети';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryGaming => 'Игры';

  @override
  String get categoryCommunication => 'Общение';

  @override
  String get categoryWebBrowsing => 'Веб-сёрфинг';

  @override
  String get categoryCreative => 'Творчество';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryUtility => 'Утилиты';

  @override
  String get categoryUncategorized => 'Без категории';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google Документы';

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
  String get appGoogleCalendar => 'Google Календарь';

  @override
  String get appAppleCalendar => 'Календарь';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Терминал';

  @override
  String get appCommandPrompt => 'Командная строка';

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
  String get appCalculator => 'Калькулятор';

  @override
  String get appNotes => 'Заметки';

  @override
  String get appSystemPreferences => 'Системные настройки';

  @override
  String get appTaskManager => 'Диспетчер задач';

  @override
  String get appFileExplorer => 'Проводник';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Диск';

  @override
  String get loadingApplication => 'Загрузка приложения...';

  @override
  String get loadingData => 'Загрузка данных...';

  @override
  String get reportsError => 'Ошибка';

  @override
  String get reportsRetry => 'Повторить';

  @override
  String get backupRestoreSection => 'Резервное копирование и восстановление';

  @override
  String get backupRestoreTitle => 'Резервное копирование и восстановление';

  @override
  String get exportDataTitle => 'Экспорт данных';

  @override
  String get exportDataDescription =>
      'Создать резервную копию всех ваших данных';

  @override
  String get importDataTitle => 'Импорт данных';

  @override
  String get importDataDescription => 'Восстановить из файла резервной копии';

  @override
  String get exportButton => 'Экспорт';

  @override
  String get importButton => 'Импорт';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get noButton => 'Нет';

  @override
  String get shareButton => 'Поделиться';

  @override
  String get exportStarting => 'Начало экспорта...';

  @override
  String get exportSuccessful =>
      'Экспорт успешен! Файл сохранён в Документы/TimeMark-Backups';

  @override
  String get exportFailed => 'Ошибка экспорта';

  @override
  String get exportComplete => 'Экспорт завершён';

  @override
  String get shareBackupQuestion => 'Хотите поделиться файлом резервной копии?';

  @override
  String get importStarting => 'Начало импорта...';

  @override
  String get importSuccessful => 'Импорт успешен!';

  @override
  String get importFailed => 'Ошибка импорта';

  @override
  String get importOptionsTitle => 'Параметры импорта';

  @override
  String get importOptionsQuestion => 'Как вы хотите импортировать данные?';

  @override
  String get replaceModeTitle => 'Заменить';

  @override
  String get replaceModeDescription => 'Заменить все существующие данные';

  @override
  String get mergeModeTitle => 'Объединить';

  @override
  String get mergeModeDescription => 'Объединить с существующими данными';

  @override
  String get appendModeTitle => 'Добавить';

  @override
  String get appendModeDescription => 'Добавить только новые записи';

  @override
  String get warningTitle => '⚠️ Предупреждение';

  @override
  String get replaceWarningMessage =>
      'Это заменит ВСЕ ваши существующие данные. Вы уверены, что хотите продолжить?';

  @override
  String get replaceAllButton => 'Заменить всё';

  @override
  String get fileLabel => 'Файл';

  @override
  String get sizeLabel => 'Размер';

  @override
  String get recordsLabel => 'Записи';

  @override
  String get usageRecordsLabel => 'Записи использования';

  @override
  String get focusSessionsLabel => 'Сессии фокусировки';

  @override
  String get appMetadataLabel => 'Метаданные приложений';

  @override
  String get updatedLabel => 'Обновлено';

  @override
  String get skippedLabel => 'Пропущено';

  @override
  String get faqSettingsQ4 =>
      'Как я могу восстановить или экспортировать свои данные?';

  @override
  String get faqSettingsA4 =>
      'Вы можете перейти в настройки, там вы найдёте раздел Резервное копирование и восстановление. Здесь вы можете экспортировать или импортировать данные. Обратите внимание, что экспортированный файл данных сохраняется в Документах в папке TimeMark-Backups, и только этот файл можно использовать для восстановления данных, никакой другой файл.';

  @override
  String get faqGeneralQ6 =>
      'Как я могу изменить язык и какие языки доступны, а также что делать, если я обнаружил неправильный перевод?';

  @override
  String get faqGeneralA6 =>
      'Язык можно изменить в разделе Настройки - Общие, все доступные языки перечислены там. Вы можете запросить перевод, нажав на Связаться и отправив свой запрос с указанием нужного языка. Имейте в виду, что перевод может быть неточным, так как он генерируется ИИ из английского, и если вы хотите сообщить об этом, вы можете сделать это через сообщение об ошибке, связаться с нами или, если вы разработчик, открыть issue на Github. Вклад в перевод также приветствуется!';

  @override
  String get faqGeneralQ7 =>
      'Что делать, если я обнаружил неправильный перевод?';

  @override
  String get faqGeneralA7 =>
      'Перевод может быть неточным, так как он генерируется ИИ из английского, и если вы хотите сообщить об этом, вы можете сделать это через сообщение об ошибке, связаться с нами или, если вы разработчик, открыть issue на Github. Вклад в перевод также приветствуется!';

  @override
  String get activityTrackingSection => 'Отслеживание Активности';

  @override
  String get idleDetectionTitle => 'Обнаружение Бездействия';

  @override
  String get idleDetectionDescription =>
      'Прекратить отслеживание при неактивности';

  @override
  String get idleTimeoutTitle => 'Тайм-аут Бездействия';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Время до признания бездействующим ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Расширенные функции могут увеличить использование ресурсов. Включайте только при необходимости.';

  @override
  String get monitorAudioTitle => 'Мониторинг Системного Звука';

  @override
  String get monitorAudioDescription =>
      'Обнаружение активности по воспроизведению звука';

  @override
  String get audioSensitivityTitle => 'Чувствительность Звука';

  @override
  String audioSensitivityDescription(String value) {
    return 'Порог обнаружения ($value)';
  }

  @override
  String get monitorControllersTitle => 'Мониторинг Игровых Контроллеров';

  @override
  String get monitorControllersDescription =>
      'Обнаружение контроллеров Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Мониторинг HID Устройств';

  @override
  String get monitorHIDDescription =>
      'Обнаружение рулей, планшетов, пользовательских устройств';

  @override
  String get setIdleTimeoutTitle => 'Установить Тайм-аут Бездействия';

  @override
  String get idleTimeoutDialogDescription =>
      'Выберите, сколько ждать перед признанием вас бездействующим:';

  @override
  String get seconds30 => '30 секунд';

  @override
  String get minute1 => '1 минута';

  @override
  String get minutes2 => '2 минуты';

  @override
  String get minutes5 => '5 минут';

  @override
  String get minutes10 => '10 минут';

  @override
  String get customOption => 'Пользовательский';

  @override
  String get customDurationTitle => 'Пользовательская Длительность';

  @override
  String get minutesLabel => 'Минуты';

  @override
  String get secondsLabel => 'Секунды';

  @override
  String get minAbbreviation => 'мин';

  @override
  String get secAbbreviation => 'сек';

  @override
  String totalLabel(String duration) {
    return 'Итого: $duration';
  }

  @override
  String minimumError(String value) {
    return 'Минимум $value';
  }

  @override
  String maximumError(String value) {
    return 'Максимум $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Диапазон: $min - $max';
  }

  @override
  String get saveButton => 'Сохранить';

  @override
  String timeFormatSeconds(int seconds) {
    return '$secondsс';
  }

  @override
  String get timeFormatMinute => '1 мин';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes мин $secondsс';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeDescription =>
      'Цветовая тема приложения (требуется перезапуск)';

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
