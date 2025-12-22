// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appWindowTitle =>
      'TimeMark - Seguimiento de Tiempo de Pantalla y Uso de Aplicaciones';

  @override
  String get appName => 'TimeMark';

  @override
  String get appTitle => 'Tiempo de Pantalla Productivo';

  @override
  String get sidebarTitle => 'Tiempo de Pantalla';

  @override
  String get sidebarSubtitle => 'Código Abierto';

  @override
  String get trayShowWindow => 'Mostrar Ventana';

  @override
  String get trayStartFocusMode => 'Iniciar Modo Enfoque';

  @override
  String get trayStopFocusMode => 'Detener Modo Enfoque';

  @override
  String get trayReports => 'Informes';

  @override
  String get trayAlertsLimits => 'Alertas y Límites';

  @override
  String get trayApplications => 'Aplicaciones';

  @override
  String get trayDisableNotifications => 'Desactivar Notificaciones';

  @override
  String get trayEnableNotifications => 'Activar Notificaciones';

  @override
  String get trayVersionPrefix => 'Versión: ';

  @override
  String trayVersion(String version) {
    return 'Versión: $version';
  }

  @override
  String get trayExit => 'Salir';

  @override
  String get navOverview => 'Resumen';

  @override
  String get navApplications => 'Aplicaciones';

  @override
  String get navAlertsLimits => 'Alertas y Límites';

  @override
  String get navReports => 'Informes';

  @override
  String get navFocusMode => 'Modo Enfoque';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navHelp => 'Ayuda';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get faqCategoryGeneral => 'Preguntas Generales';

  @override
  String get faqCategoryApplications => 'Gestión de Aplicaciones';

  @override
  String get faqCategoryReports => 'Análisis de Uso e Informes';

  @override
  String get faqCategoryAlerts => 'Alertas y Límites';

  @override
  String get faqCategoryFocusMode => 'Modo Enfoque y Temporizador Pomodoro';

  @override
  String get faqCategorySettings => 'Configuración y Personalización';

  @override
  String get faqCategoryTroubleshooting => 'Solución de Problemas';

  @override
  String get faqGeneralQ1 =>
      '¿Cómo rastrea esta aplicación el tiempo de pantalla?';

  @override
  String get faqGeneralA1 =>
      'La aplicación monitorea el uso de tu dispositivo en tiempo real, rastreando el tiempo dedicado a diferentes aplicaciones. Proporciona información completa sobre tus hábitos digitales, incluyendo tiempo total de pantalla, tiempo productivo y uso específico por aplicación.';

  @override
  String get faqGeneralQ2 => '¿Qué hace que una aplicación sea \'Productiva\'?';

  @override
  String get faqGeneralA2 =>
      'Puedes marcar manualmente las aplicaciones como productivas en la sección \'Aplicaciones\'. Las aplicaciones productivas contribuyen a tu Puntuación de Productividad, que calcula el porcentaje de tiempo de pantalla dedicado a aplicaciones relacionadas con el trabajo o beneficiosas.';

  @override
  String get faqGeneralQ3 =>
      '¿Qué tan preciso es el seguimiento del tiempo de pantalla?';

  @override
  String get faqGeneralA3 =>
      'La aplicación utiliza seguimiento a nivel del sistema para proporcionar una medición precisa del uso de tu dispositivo. Captura el tiempo en primer plano de cada aplicación con un impacto mínimo en la batería.';

  @override
  String get faqGeneralQ4 =>
      '¿Puedo personalizar la categorización de mis aplicaciones?';

  @override
  String get faqGeneralA4 =>
      '¡Por supuesto! Puedes crear categorías personalizadas, asignar aplicaciones a categorías específicas y modificar fácilmente estas asignaciones en la sección \'Aplicaciones\'. Esto ayuda a crear análisis de uso más significativos.';

  @override
  String get faqGeneralQ5 =>
      '¿Qué información puedo obtener de esta aplicación?';

  @override
  String get faqGeneralA5 =>
      'La aplicación ofrece información completa que incluye Puntuación de Productividad, patrones de uso por hora del día, uso detallado de aplicaciones, seguimiento de sesiones de enfoque y análisis visuales como gráficos y diagramas circulares para ayudarte a entender y mejorar tus hábitos digitales.';

  @override
  String get faqAppsQ1 =>
      '¿Cómo oculto aplicaciones específicas del seguimiento?';

  @override
  String get faqAppsA1 =>
      'En la sección \'Aplicaciones\', puedes alternar la visibilidad de las aplicaciones.';

  @override
  String get faqAppsQ2 => '¿Puedo buscar y filtrar mis aplicaciones?';

  @override
  String get faqAppsA2 =>
      'Sí, la sección de Aplicaciones incluye funcionalidad de búsqueda y opciones de filtrado. Puedes filtrar aplicaciones por categoría, estado de productividad, estado de seguimiento y visibilidad.';

  @override
  String get faqAppsQ3 =>
      '¿Qué opciones de edición están disponibles para las aplicaciones?';

  @override
  String get faqAppsA3 =>
      'Para cada aplicación, puedes editar: asignación de categoría, estado de productividad, seguimiento de uso, visibilidad en informes y establecer límites de tiempo diarios individuales.';

  @override
  String get faqAppsQ4 =>
      '¿Cómo se determinan las categorías de las aplicaciones?';

  @override
  String get faqAppsA4 =>
      'Las categorías iniciales son sugeridas por el sistema, pero tienes control total para crear, modificar y asignar categorías personalizadas según tu flujo de trabajo y preferencias.';

  @override
  String get faqReportsQ1 => '¿Qué tipos de informes están disponibles?';

  @override
  String get faqReportsA1 =>
      'Los informes incluyen: Tiempo total de pantalla, Tiempo productivo, Aplicaciones más usadas, Sesiones de enfoque, Gráfico de tiempo de pantalla diario, Gráfico circular de desglose por categoría, Uso detallado de aplicaciones, Tendencias de uso semanal y Análisis de patrones de uso por hora del día.';

  @override
  String get faqReportsQ2 =>
      '¿Qué tan detallados son los informes de uso de aplicaciones?';

  @override
  String get faqReportsA2 =>
      'Los informes detallados de uso de aplicaciones muestran: Nombre de la aplicación, Categoría, Tiempo total dedicado, Estado de productividad, y ofrecen una sección de \'Acciones\' con información más profunda como resumen de uso, límites diarios, tendencias de uso y métricas de productividad.';

  @override
  String get faqReportsQ3 =>
      '¿Puedo analizar mis tendencias de uso a lo largo del tiempo?';

  @override
  String get faqReportsA3 =>
      '¡Sí! La aplicación proporciona comparaciones semana a semana, mostrando gráficos de uso de semanas anteriores, uso diario promedio, sesiones más largas y totales semanales para ayudarte a rastrear tus hábitos digitales.';

  @override
  String get faqReportsQ4 => '¿Qué es el análisis de \'Patrón de Uso\'?';

  @override
  String get faqReportsA4 =>
      'El Patrón de Uso desglosa tu tiempo de pantalla en segmentos de mañana, tarde, noche y noche. Esto te ayuda a entender cuándo estás más activo en tu dispositivo e identificar áreas potenciales de mejora.';

  @override
  String get faqAlertsQ1 =>
      '¿Qué tan detallados son los límites de tiempo de pantalla?';

  @override
  String get faqAlertsA1 =>
      'Puedes establecer límites generales de tiempo de pantalla diario y límites individuales por aplicación. Los límites se pueden configurar en horas y minutos, con opciones para restablecer o ajustar según sea necesario.';

  @override
  String get faqAlertsQ2 => '¿Qué opciones de notificación están disponibles?';

  @override
  String get faqAlertsA2 =>
      'La aplicación ofrece múltiples tipos de notificaciones: Alertas del sistema cuando excedes el tiempo de pantalla, Alertas frecuentes a intervalos personalizables (1, 5, 15, 30 o 60 minutos), y opciones para modo enfoque, tiempo de pantalla y notificaciones específicas de aplicaciones.';

  @override
  String get faqAlertsQ3 => '¿Puedo personalizar las alertas de límites?';

  @override
  String get faqAlertsA3 =>
      'Sí, puedes personalizar la frecuencia de alertas, activar/desactivar tipos específicos de alertas y establecer diferentes límites para el tiempo de pantalla general y aplicaciones individuales.';

  @override
  String get faqFocusQ1 => '¿Qué tipos de Modos de Enfoque están disponibles?';

  @override
  String get faqFocusA1 =>
      'Los modos disponibles incluyen Trabajo Profundo (sesiones de enfoque más largas), Tareas Rápidas (ráfagas cortas de trabajo) y Modo Lectura. Cada modo te ayuda a estructurar tu trabajo y tiempos de descanso de manera efectiva.';

  @override
  String get faqFocusQ2 => '¿Qué tan flexible es el Temporizador Pomodoro?';

  @override
  String get faqFocusA2 =>
      'El temporizador es altamente personalizable. Puedes ajustar la duración del trabajo, la duración del descanso corto y la duración del descanso largo. Las opciones adicionales incluyen inicio automático para las siguientes sesiones y configuración de notificaciones.';

  @override
  String get faqFocusQ3 => '¿Qué muestra el historial del Modo Enfoque?';

  @override
  String get faqFocusA3 =>
      'El historial del Modo Enfoque rastrea las sesiones de enfoque diarias, mostrando el número de sesiones por día, gráfico de tendencias, duración promedio de sesión, tiempo total de enfoque y un gráfico circular de distribución del tiempo que desglosa sesiones de trabajo, descansos cortos y descansos largos.';

  @override
  String get faqFocusQ4 =>
      '¿Puedo rastrear el progreso de mis sesiones de enfoque?';

  @override
  String get faqFocusA4 =>
      'La aplicación cuenta con una interfaz de temporizador circular con botones de reproducir/pausar, reiniciar y configuración. Puedes rastrear y gestionar fácilmente tus sesiones de enfoque con controles intuitivos.';

  @override
  String get faqSettingsQ1 =>
      '¿Qué opciones de personalización están disponibles?';

  @override
  String get faqSettingsA1 =>
      'La personalización incluye selección de tema (Sistema, Claro, Oscuro), configuración de idioma, comportamiento de inicio, controles completos de notificaciones y opciones de gestión de datos como borrar datos o restablecer configuración.';

  @override
  String get faqSettingsQ2 =>
      '¿Cómo proporciono comentarios o informo problemas?';

  @override
  String get faqSettingsA2 =>
      'En la parte inferior de la sección de Configuración, encontrarás botones para Reportar un Error, Enviar Comentarios o Contactar Soporte. Estos te redirigirán a los canales de soporte apropiados.';

  @override
  String get faqSettingsQ3 => '¿Qué sucede cuando borro mis datos?';

  @override
  String get faqSettingsA3 =>
      'Borrar datos restablecerá todas tus estadísticas de uso, historial de sesiones de enfoque y configuración personalizada. Esto es útil para empezar de nuevo o solucionar problemas.';

  @override
  String get faqTroubleQ1 =>
      'Los datos no se muestran, error de que hive no se abre';

  @override
  String get faqTroubleA1 =>
      'El problema es conocido, la solución temporal es borrar los datos a través de configuración y si no funciona, ve a Documentos y elimina los siguientes archivos si existen - harman_screentime_app_usage_box.hive y harman_screentime_app_usage.lock, también se te sugiere actualizar la aplicación a la última versión.';

  @override
  String get faqTroubleQ2 =>
      'La aplicación se abre en cada inicio, ¿qué hacer?';

  @override
  String get faqTroubleA2 =>
      'Este es un problema conocido que ocurre en Windows 10, la solución temporal es habilitar Iniciar como Minimizado en la configuración para que se inicie minimizado.';

  @override
  String get usageAnalytics => 'Análisis de Uso';

  @override
  String get last7Days => 'Últimos 7 Días';

  @override
  String get lastMonth => 'Último Mes';

  @override
  String get last3Months => 'Últimos 3 Meses';

  @override
  String get lifetime => 'Todo el Tiempo';

  @override
  String get custom => 'Personalizado';

  @override
  String get loadingAnalyticsData => 'Cargando datos de análisis...';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get failedToInitialize =>
      'Error al inicializar análisis. Por favor reinicie la aplicación.';

  @override
  String unexpectedError(String error) {
    return 'Ocurrió un error inesperado: $error. Por favor intente más tarde.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Error al cargar datos de análisis: $error. Por favor verifique su conexión e intente de nuevo.';
  }

  @override
  String get customDialogTitle => 'Personalizado';

  @override
  String get dateRange => 'Rango de Fechas';

  @override
  String get specificDate => 'Fecha Específica';

  @override
  String get startDate => 'Fecha de Inicio: ';

  @override
  String get endDate => 'Fecha de Fin: ';

  @override
  String get date => 'Fecha: ';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get ok => 'Aceptar';

  @override
  String get invalidDateRange => 'Rango de Fechas Inválido';

  @override
  String get startDateBeforeEndDate =>
      'La fecha de inicio debe ser anterior o igual a la fecha de fin.';

  @override
  String get totalScreenTime => 'Tiempo Total de Pantalla';

  @override
  String get productiveTime => 'Tiempo Productivo';

  @override
  String get mostUsedApp => 'App Más Usada';

  @override
  String get focusSessions => 'Sesiones de Enfoque';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs período anterior';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs período anterior';
  }

  @override
  String iconLabel(String title) {
    return 'Icono de $title';
  }

  @override
  String get dailyScreenTime => 'Tiempo de Pantalla Diario';

  @override
  String get categoryBreakdown => 'Desglose por Categoría';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String sectionLabel(String title) {
    return 'Sección de $title';
  }

  @override
  String get detailedApplicationUsage => 'Uso Detallado de Aplicaciones';

  @override
  String get searchApplications => 'Buscar aplicaciones';

  @override
  String get nameHeader => 'Nombre';

  @override
  String get categoryHeader => 'Categoría';

  @override
  String get totalTimeHeader => 'Tiempo Total';

  @override
  String get productivityHeader => 'Productividad';

  @override
  String get actionsHeader => 'Acciones';

  @override
  String sortByOption(String option) {
    return 'Ordenar por: $option';
  }

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByCategory => 'Categoría';

  @override
  String get sortByUsage => 'Uso';

  @override
  String get productive => 'Productivo';

  @override
  String get nonProductive => 'No Productivo';

  @override
  String get noApplicationsMatch =>
      'Ninguna aplicación coincide con tus criterios de búsqueda';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get usageSummary => 'Resumen de Uso';

  @override
  String get usageOverPastWeek => 'Uso Durante la Semana Pasada';

  @override
  String get usagePatternByTimeOfDay => 'Patrón de Uso por Hora del Día';

  @override
  String get patternAnalysis => 'Análisis de Patrones';

  @override
  String get today => 'Hoy';

  @override
  String get dailyLimit => 'Límite Diario';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get usageTrend => 'Tendencia de Uso';

  @override
  String get productivity => 'Productividad';

  @override
  String get increasing => 'Aumentando';

  @override
  String get decreasing => 'Disminuyendo';

  @override
  String get stable => 'Estable';

  @override
  String get avgDailyUsage => 'Uso Diario Prom.';

  @override
  String get longestSession => 'Sesión Más Larga';

  @override
  String get weeklyTotal => 'Total Semanal';

  @override
  String get noHistoricalData => 'No hay datos históricos disponibles';

  @override
  String get morning => 'Mañana (6-12)';

  @override
  String get afternoon => 'Tarde (12-5)';

  @override
  String get evening => 'Noche (5-9)';

  @override
  String get night => 'Madrugada (9-6)';

  @override
  String get usageInsights => 'Información de Uso';

  @override
  String get limitStatus => 'Estado del Límite';

  @override
  String get close => 'Cerrar';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Usas principalmente $appName durante $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Tu uso ha aumentado significativamente ($percentage%) en comparación con el período anterior.';
  }

  @override
  String get trendingUpward =>
      'Tu uso está tendiendo al alza en comparación con el período anterior.';

  @override
  String significantDecrease(String percentage) {
    return 'Tu uso ha disminuido significativamente ($percentage%) en comparación con el período anterior.';
  }

  @override
  String get trendingDownward =>
      'Tu uso está tendiendo a la baja en comparación con el período anterior.';

  @override
  String get consistentUsage =>
      'Tu uso ha sido consistente en comparación con el período anterior.';

  @override
  String get markedAsProductive =>
      'Esta está marcada como una aplicación productiva en tu configuración.';

  @override
  String get markedAsNonProductive =>
      'Esta está marcada como una aplicación no productiva en tu configuración.';

  @override
  String mostActiveTime(String time) {
    return 'Tu hora más activa es alrededor de las $time.';
  }

  @override
  String get noLimitSet =>
      'No se ha establecido límite de uso para esta aplicación.';

  @override
  String get limitReached =>
      'Has alcanzado tu límite diario para esta aplicación.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Estás a punto de alcanzar tu límite diario con solo $remainingTime restante.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Has usado el $percent% de tu límite diario con $remainingTime restante.';
  }

  @override
  String remainingTime(String time) {
    return 'Te quedan $time de tu límite diario.';
  }

  @override
  String get todayChart => 'Hoy';

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
  String get alertsLimitsTitle => 'Alertas y Límites';

  @override
  String get notificationsSettings => 'Configuración de Notificaciones';

  @override
  String get overallScreenTimeLimit => 'Límite General de Tiempo de Pantalla';

  @override
  String get applicationLimits => 'Límites de Aplicaciones';

  @override
  String get popupAlerts => 'Alertas Emergentes';

  @override
  String get frequentAlerts => 'Alertas Frecuentes';

  @override
  String get soundAlerts => 'Alertas de Sonido';

  @override
  String get systemAlerts => 'Alertas del Sistema';

  @override
  String get dailyTotalLimit => 'Límite Diario Total: ';

  @override
  String get hours => 'Horas: ';

  @override
  String get minutes => 'Minutos: ';

  @override
  String get currentUsage => 'Uso Actual: ';

  @override
  String get tableName => 'Nombre';

  @override
  String get tableCategory => 'Categoría';

  @override
  String get tableDailyLimit => 'Límite Diario';

  @override
  String get tableCurrentUsage => 'Uso Actual';

  @override
  String get tableStatus => 'Estado';

  @override
  String get tableActions => 'Acciones';

  @override
  String get addLimit => 'Agregar Límite';

  @override
  String get noApplicationsToDisplay => 'No hay aplicaciones para mostrar';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusOff => 'Desactivado';

  @override
  String get durationNone => 'Ninguno';

  @override
  String get addApplicationLimit => 'Agregar Límite de Aplicación';

  @override
  String get selectApplication => 'Seleccionar Aplicación';

  @override
  String get selectApplicationPlaceholder => 'Selecciona una aplicación';

  @override
  String get enableLimit => 'Habilitar Límite: ';

  @override
  String editLimitTitle(String appName) {
    return 'Editar Límite: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Error al cargar datos: $error';
  }

  @override
  String get resetSettingsTitle => '¿Restablecer Configuración?';

  @override
  String get resetSettingsContent =>
      'Si restableces la configuración, no podrás recuperarla. ¿Deseas restablecerla?';

  @override
  String get resetAll => 'Restablecer Todo';

  @override
  String get refresh => 'Actualizar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Agregar';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get applicationsTitle => 'Aplicaciones';

  @override
  String get searchApplication => 'Buscar Aplicación';

  @override
  String get tracking => 'Seguimiento';

  @override
  String get hiddenVisible => 'Oculto/Visible';

  @override
  String get selectCategory => 'Seleccionar una Categoría';

  @override
  String get allCategories => 'Todas';

  @override
  String get tableScreenTime => 'Tiempo de Pantalla';

  @override
  String get tableTracking => 'Seguimiento';

  @override
  String get tableHidden => 'Oculto';

  @override
  String get tableEdit => 'Editar';

  @override
  String editAppTitle(String appName) {
    return 'Editar $appName';
  }

  @override
  String get categorySection => 'Categoría';

  @override
  String get customCategory => 'Personalizada';

  @override
  String get customCategoryPlaceholder =>
      'Ingresa nombre de categoría personalizada';

  @override
  String get uncategorized => 'Sin Categoría';

  @override
  String get isProductive => 'Es Productiva';

  @override
  String get trackUsage => 'Rastrear Uso';

  @override
  String get visibleInReports => 'Visible en Informes';

  @override
  String get timeLimitsSection => 'Límites de Tiempo';

  @override
  String get enableDailyLimit => 'Habilitar Límite Diario';

  @override
  String get setDailyTimeLimit => 'Establecer límite de tiempo diario:';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String errorLoadingData(String error) {
    return 'Error al cargar datos del resumen: $error';
  }

  @override
  String get focusModeTitle => 'Modo Enfoque';

  @override
  String get historySection => 'Historial';

  @override
  String get trendsSection => 'Tendencias';

  @override
  String get timeDistributionSection => 'Distribución del Tiempo';

  @override
  String get sessionHistorySection => 'Historial de Sesiones';

  @override
  String get workSession => 'Sesión de Trabajo';

  @override
  String get shortBreak => 'Descanso Corto';

  @override
  String get longBreak => 'Descanso Largo';

  @override
  String get dateHeader => 'Fecha';

  @override
  String get durationHeader => 'Duración';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get focusModeSettingsTitle => 'Configuración del Modo Enfoque';

  @override
  String get modeCustom => 'Personalizado';

  @override
  String get modeDeepWork => 'Trabajo Profundo (60 min)';

  @override
  String get modeQuickTasks => 'Tareas Rápidas (25 min)';

  @override
  String get modeReading => 'Lectura (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Duración del Trabajo: $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Descanso Corto: $minutes min';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Descanso Largo: $minutes min';
  }

  @override
  String get autoStartNextSession =>
      'Iniciar automáticamente la siguiente sesión';

  @override
  String get blockDistractions =>
      'Bloquear distracciones durante el modo enfoque';

  @override
  String get enableNotifications => 'Habilitar notificaciones';

  @override
  String get saved => 'Guardado';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Error al cargar datos del modo enfoque: $error';
  }

  @override
  String get overviewTitle => 'Resumen de Hoy';

  @override
  String get startFocusMode => 'Iniciar Modo Enfoque';

  @override
  String get loadingProductivityData =>
      'Cargando tus datos de productividad...';

  @override
  String get noActivityDataAvailable =>
      'Aún no hay datos de actividad disponibles';

  @override
  String get startUsingApplications =>
      'Comienza a usar tus aplicaciones para rastrear el tiempo de pantalla y la productividad.';

  @override
  String get refreshData => 'Actualizar Datos';

  @override
  String get topApplications => 'Aplicaciones Principales';

  @override
  String get noAppUsageDataAvailable =>
      'Aún no hay datos de uso de aplicaciones disponibles';

  @override
  String get noApplicationDataAvailable =>
      'No hay datos de aplicaciones disponibles';

  @override
  String get noCategoryDataAvailable =>
      'No hay datos de categorías disponibles';

  @override
  String get noApplicationLimitsSet =>
      'No se han establecido límites de aplicaciones';

  @override
  String get screenLabel => 'Tiempo de';

  @override
  String get timeLabel => 'Pantalla';

  @override
  String get productiveLabel => 'Puntuación';

  @override
  String get scoreLabel => 'Productiva';

  @override
  String get defaultNone => 'Ninguno';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Desconocido';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get generalSection => 'General';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get dataSection => 'Datos';

  @override
  String get versionSection => 'Versión';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription =>
      'Tema de color de la aplicación (El cambio requiere reinicio)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDescription => 'Idioma de la aplicación';

  @override
  String get startupBehaviourTitle => 'Comportamiento de Inicio';

  @override
  String get startupBehaviourDescription => 'Iniciar con el sistema operativo';

  @override
  String get launchMinimizedTitle => 'Iniciar Minimizado';

  @override
  String get launchMinimizedDescription =>
      'Iniciar la aplicación en la Bandeja del Sistema (Recomendado para Windows 10)';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsAllDescription =>
      'Todas las notificaciones de la aplicación';

  @override
  String get focusModeNotificationsTitle => 'Modo Enfoque';

  @override
  String get focusModeNotificationsDescription =>
      'Todas las notificaciones del modo enfoque';

  @override
  String get screenTimeNotificationsTitle => 'Tiempo de Pantalla';

  @override
  String get screenTimeNotificationsDescription =>
      'Todas las notificaciones de restricción de tiempo de pantalla';

  @override
  String get appScreenTimeNotificationsTitle =>
      'Tiempo de Pantalla por Aplicación';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Todas las notificaciones de restricción de tiempo de pantalla por aplicación';

  @override
  String get frequentAlertsTitle => 'Intervalo de Alertas Frecuentes';

  @override
  String get frequentAlertsDescription =>
      'Establecer intervalo para notificaciones frecuentes (minutos)';

  @override
  String get clearDataTitle => 'Borrar Datos';

  @override
  String get clearDataDescription =>
      'Borrar todo el historial y otros datos relacionados';

  @override
  String get resetSettingsTitle2 => 'Restablecer Configuración';

  @override
  String get resetSettingsDescription => 'Restablecer toda la configuración';

  @override
  String get versionTitle => 'Versión';

  @override
  String get versionDescription => 'Versión actual de la aplicación';

  @override
  String get contactButton => 'Contacto';

  @override
  String get reportBugButton => 'Reportar Error';

  @override
  String get submitFeedbackButton => 'Enviar Comentarios';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => '¿Borrar Datos?';

  @override
  String get clearDataDialogContent =>
      'Esto borrará todo el historial y datos relacionados. No podrás recuperarlos. ¿Deseas continuar?';

  @override
  String get clearDataButtonLabel => 'Borrar Datos';

  @override
  String get resetSettingsDialogTitle => '¿Restablecer Configuración?';

  @override
  String get resetSettingsDialogContent =>
      'Esto restablecerá toda la configuración a sus valores predeterminados. ¿Deseas continuar?';

  @override
  String get resetButtonLabel => 'Restablecer';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String couldNotLaunchUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get chart_focusTrends => 'Tendencias de Enfoque';

  @override
  String get chart_sessionCount => 'Cantidad de Sesiones';

  @override
  String get chart_avgDuration => 'Duración Prom.';

  @override
  String get chart_totalFocus => 'Enfoque Total';

  @override
  String get chart_yAxis_sessions => 'Sesiones';

  @override
  String get chart_yAxis_minutes => 'Minutos';

  @override
  String get chart_yAxis_value => 'Valor';

  @override
  String get chart_monthOverMonthChange => 'Cambio mes a mes: ';

  @override
  String get chart_customRange => 'Rango Personalizado';

  @override
  String get day_monday => 'Lunes';

  @override
  String get day_mondayShort => 'Lun';

  @override
  String get day_mondayAbbr => 'Lu';

  @override
  String get day_tuesday => 'Martes';

  @override
  String get day_tuesdayShort => 'Mar';

  @override
  String get day_tuesdayAbbr => 'Ma';

  @override
  String get day_wednesday => 'Miércoles';

  @override
  String get day_wednesdayShort => 'Mié';

  @override
  String get day_wednesdayAbbr => 'Mi';

  @override
  String get day_thursday => 'Jueves';

  @override
  String get day_thursdayShort => 'Jue';

  @override
  String get day_thursdayAbbr => 'Ju';

  @override
  String get day_friday => 'Viernes';

  @override
  String get day_fridayShort => 'Vie';

  @override
  String get day_fridayAbbr => 'Vi';

  @override
  String get day_saturday => 'Sábado';

  @override
  String get day_saturdayShort => 'Sáb';

  @override
  String get day_saturdayAbbr => 'Sá';

  @override
  String get day_sunday => 'Domingo';

  @override
  String get day_sundayShort => 'Dom';

  @override
  String get day_sundayAbbr => 'Do';

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
    return '$count horas';
  }

  @override
  String get month_january => 'Enero';

  @override
  String get month_januaryShort => 'Ene';

  @override
  String get month_february => 'Febrero';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'Marzo';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'Abril';

  @override
  String get month_aprilShort => 'Abr';

  @override
  String get month_may => 'Mayo';

  @override
  String get month_mayShort => 'May';

  @override
  String get month_june => 'Junio';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'Julio';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_augustShort => 'Ago';

  @override
  String get month_september => 'Septiembre';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Octubre';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'Noviembre';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Diciembre';

  @override
  String get month_decemberShort => 'Dic';

  @override
  String get categoryAll => 'Todas';

  @override
  String get categoryProductivity => 'Productividad';

  @override
  String get categoryDevelopment => 'Desarrollo';

  @override
  String get categorySocialMedia => 'Redes Sociales';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryGaming => 'Juegos';

  @override
  String get categoryCommunication => 'Comunicación';

  @override
  String get categoryWebBrowsing => 'Navegación Web';

  @override
  String get categoryCreative => 'Creatividad';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryUtility => 'Utilidades';

  @override
  String get categoryUncategorized => 'Sin Categoría';

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
  String get appAppleCalendar => 'Calendario';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Símbolo del Sistema';

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
  String get appCalculator => 'Calculadora';

  @override
  String get appNotes => 'Notas';

  @override
  String get appSystemPreferences => 'Preferencias del Sistema';

  @override
  String get appTaskManager => 'Administrador de Tareas';

  @override
  String get appFileExplorer => 'Explorador de Archivos';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Cargando la aplicación...';

  @override
  String get loadingData => 'Cargando datos...';

  @override
  String get reportsError => 'Error';

  @override
  String get reportsRetry => 'Reintentar';
}
