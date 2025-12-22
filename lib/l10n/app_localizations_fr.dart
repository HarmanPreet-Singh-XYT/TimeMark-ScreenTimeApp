// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appWindowTitle =>
      'TimeMark - Suivi du Temps d\'Écran et de l\'Utilisation des Applications';

  @override
  String get appName => 'TimeMark';

  @override
  String get appTitle => 'Temps d\'Écran Productif';

  @override
  String get sidebarTitle => 'Temps d\'Écran';

  @override
  String get sidebarSubtitle => 'Open Source';

  @override
  String get trayShowWindow => 'Afficher la Fenêtre';

  @override
  String get trayStartFocusMode => 'Démarrer le Mode Concentration';

  @override
  String get trayStopFocusMode => 'Arrêter le Mode Concentration';

  @override
  String get trayReports => 'Rapports';

  @override
  String get trayAlertsLimits => 'Alertes et Limites';

  @override
  String get trayApplications => 'Applications';

  @override
  String get trayDisableNotifications => 'Désactiver les Notifications';

  @override
  String get trayEnableNotifications => 'Activer les Notifications';

  @override
  String get trayVersionPrefix => 'Version : ';

  @override
  String trayVersion(String version) {
    return 'Version : $version';
  }

  @override
  String get trayExit => 'Quitter';

  @override
  String get navOverview => 'Aperçu';

  @override
  String get navApplications => 'Applications';

  @override
  String get navAlertsLimits => 'Alertes et Limites';

  @override
  String get navReports => 'Rapports';

  @override
  String get navFocusMode => 'Mode Concentration';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navHelp => 'Aide';

  @override
  String get helpTitle => 'Aide';

  @override
  String get faqCategoryGeneral => 'Questions Générales';

  @override
  String get faqCategoryApplications => 'Gestion des Applications';

  @override
  String get faqCategoryReports => 'Analyses et Rapports d\'Utilisation';

  @override
  String get faqCategoryAlerts => 'Alertes et Limites';

  @override
  String get faqCategoryFocusMode => 'Mode Concentration et Minuteur Pomodoro';

  @override
  String get faqCategorySettings => 'Paramètres et Personnalisation';

  @override
  String get faqCategoryTroubleshooting => 'Dépannage';

  @override
  String get faqGeneralQ1 =>
      'Comment cette application suit-elle le temps d\'écran ?';

  @override
  String get faqGeneralA1 =>
      'L\'application surveille l\'utilisation de votre appareil en temps réel, en suivant le temps passé sur différentes applications. Elle fournit des informations complètes sur vos habitudes numériques, y compris le temps d\'écran total, le temps productif et l\'utilisation spécifique des applications.';

  @override
  String get faqGeneralQ2 =>
      'Qu\'est-ce qui rend une application \'Productive\' ?';

  @override
  String get faqGeneralA2 =>
      'Vous pouvez marquer manuellement les applications comme productives dans la section \'Applications\'. Les applications productives contribuent à votre Score de Productivité, qui calcule le pourcentage de temps d\'écran consacré aux applications liées au travail ou bénéfiques.';

  @override
  String get faqGeneralQ3 =>
      'Quelle est la précision du suivi du temps d\'écran ?';

  @override
  String get faqGeneralA3 =>
      'L\'application utilise un suivi au niveau du système pour fournir une mesure précise de l\'utilisation de votre appareil. Elle capture le temps au premier plan pour chaque application avec un impact minimal sur la batterie.';

  @override
  String get faqGeneralQ4 =>
      'Puis-je personnaliser la catégorisation de mes applications ?';

  @override
  String get faqGeneralA4 =>
      'Absolument ! Vous pouvez créer des catégories personnalisées, attribuer des applications à des catégories spécifiques et modifier facilement ces attributions dans la section \'Applications\'. Cela aide à créer des analyses d\'utilisation plus significatives.';

  @override
  String get faqGeneralQ5 =>
      'Quelles informations puis-je obtenir de cette application ?';

  @override
  String get faqGeneralA5 =>
      'L\'application offre des informations complètes, notamment le Score de Productivité, les modèles d\'utilisation par moment de la journée, l\'utilisation détaillée des applications, le suivi des sessions de concentration, et des analyses visuelles comme des graphiques et des diagrammes circulaires pour vous aider à comprendre et améliorer vos habitudes numériques.';

  @override
  String get faqAppsQ1 =>
      'Comment masquer des applications spécifiques du suivi ?';

  @override
  String get faqAppsA1 =>
      'Dans la section \'Applications\', vous pouvez basculer la visibilité des applications.';

  @override
  String get faqAppsQ2 => 'Puis-je rechercher et filtrer mes applications ?';

  @override
  String get faqAppsA2 =>
      'Oui, la section Applications comprend une fonctionnalité de recherche et des options de filtrage. Vous pouvez filtrer les applications par catégorie, statut de productivité, statut de suivi et visibilité.';

  @override
  String get faqAppsQ3 =>
      'Quelles options d\'édition sont disponibles pour les applications ?';

  @override
  String get faqAppsA3 =>
      'Pour chaque application, vous pouvez modifier : l\'attribution de catégorie, le statut de productivité, le suivi d\'utilisation, la visibilité dans les rapports et définir des limites de temps quotidiennes individuelles.';

  @override
  String get faqAppsQ4 =>
      'Comment les catégories d\'applications sont-elles déterminées ?';

  @override
  String get faqAppsA4 =>
      'Les catégories initiales sont suggérées par le système, mais vous avez un contrôle total pour créer, modifier et attribuer des catégories personnalisées selon votre flux de travail et vos préférences.';

  @override
  String get faqReportsQ1 => 'Quels types de rapports sont disponibles ?';

  @override
  String get faqReportsA1 =>
      'Les rapports incluent : Temps d\'écran total, Temps productif, Applications les plus utilisées, Sessions de concentration, Graphique du temps d\'écran quotidien, Diagramme circulaire de répartition par catégorie, Utilisation détaillée des applications, Tendances d\'utilisation hebdomadaires et Analyse des modèles d\'utilisation par moment de la journée.';

  @override
  String get faqReportsQ2 =>
      'Quelle est la précision des rapports d\'utilisation des applications ?';

  @override
  String get faqReportsA2 =>
      'Les rapports d\'utilisation détaillés des applications montrent : Nom de l\'application, Catégorie, Temps total passé, Statut de productivité, et offrent une section \'Actions\' avec des informations plus approfondies comme le résumé d\'utilisation, les limites quotidiennes, les tendances d\'utilisation et les métriques de productivité.';

  @override
  String get faqReportsQ3 =>
      'Puis-je analyser mes tendances d\'utilisation au fil du temps ?';

  @override
  String get faqReportsA3 =>
      'Oui ! L\'application fournit des comparaisons semaine après semaine, montrant des graphiques d\'utilisation sur les semaines passées, l\'utilisation quotidienne moyenne, les sessions les plus longues et les totaux hebdomadaires pour vous aider à suivre vos habitudes numériques.';

  @override
  String get faqReportsQ4 =>
      'Qu\'est-ce que l\'analyse du \'Modèle d\'Utilisation\' ?';

  @override
  String get faqReportsA4 =>
      'Le Modèle d\'Utilisation décompose votre temps d\'écran en segments matin, après-midi, soir et nuit. Cela vous aide à comprendre quand vous êtes le plus actif sur votre appareil et à identifier les domaines potentiels d\'amélioration.';

  @override
  String get faqAlertsQ1 =>
      'Quelle est la granularité des limites de temps d\'écran ?';

  @override
  String get faqAlertsA1 =>
      'Vous pouvez définir des limites globales de temps d\'écran quotidien et des limites individuelles par application. Les limites peuvent être configurées en heures et minutes, avec des options pour réinitialiser ou ajuster selon les besoins.';

  @override
  String get faqAlertsQ2 =>
      'Quelles options de notification sont disponibles ?';

  @override
  String get faqAlertsA2 =>
      'L\'application offre plusieurs types de notifications : Alertes système lorsque vous dépassez le temps d\'écran, Alertes fréquentes à intervalles personnalisables (1, 5, 15, 30 ou 60 minutes), et des bascules pour le mode concentration, le temps d\'écran et les notifications spécifiques aux applications.';

  @override
  String get faqAlertsQ3 => 'Puis-je personnaliser les alertes de limite ?';

  @override
  String get faqAlertsA3 =>
      'Oui, vous pouvez personnaliser la fréquence des alertes, activer/désactiver des types spécifiques d\'alertes et définir différentes limites pour le temps d\'écran global et les applications individuelles.';

  @override
  String get faqFocusQ1 =>
      'Quels types de Modes Concentration sont disponibles ?';

  @override
  String get faqFocusA1 =>
      'Les modes disponibles incluent Travail Approfondi (sessions de concentration plus longues), Tâches Rapides (courtes périodes de travail) et Mode Lecture. Chaque mode vous aide à structurer efficacement votre travail et vos temps de pause.';

  @override
  String get faqFocusQ2 => 'Quelle est la flexibilité du Minuteur Pomodoro ?';

  @override
  String get faqFocusA2 =>
      'Le minuteur est hautement personnalisable. Vous pouvez ajuster la durée de travail, la durée de la pause courte et la durée de la pause longue. Des options supplémentaires incluent le démarrage automatique des sessions suivantes et les paramètres de notification.';

  @override
  String get faqFocusQ3 => 'Que montre l\'historique du Mode Concentration ?';

  @override
  String get faqFocusA3 =>
      'L\'historique du Mode Concentration suit les sessions de concentration quotidiennes, montrant le nombre de sessions par jour, le graphique des tendances, la durée moyenne des sessions, le temps total de concentration et un diagramme circulaire de distribution du temps décomposant les sessions de travail, les pauses courtes et les pauses longues.';

  @override
  String get faqFocusQ4 =>
      'Puis-je suivre la progression de mes sessions de concentration ?';

  @override
  String get faqFocusA4 =>
      'L\'application dispose d\'une interface de minuteur circulaire avec des boutons lecture/pause, recharger et paramètres. Vous pouvez facilement suivre et gérer vos sessions de concentration avec des contrôles intuitifs.';

  @override
  String get faqSettingsQ1 =>
      'Quelles options de personnalisation sont disponibles ?';

  @override
  String get faqSettingsA1 =>
      'La personnalisation comprend la sélection du thème (Système, Clair, Sombre), les paramètres de langue, le comportement au démarrage, des contrôles de notification complets et des options de gestion des données comme effacer les données ou réinitialiser les paramètres.';

  @override
  String get faqSettingsQ2 =>
      'Comment puis-je donner mon avis ou signaler des problèmes ?';

  @override
  String get faqSettingsA2 =>
      'En bas de la section Paramètres, vous trouverez des boutons pour Signaler un Bug, Soumettre un Commentaire ou Contacter le Support. Ceux-ci vous redirigeront vers les canaux de support appropriés.';

  @override
  String get faqSettingsQ3 =>
      'Que se passe-t-il lorsque j\'efface mes données ?';

  @override
  String get faqSettingsA3 =>
      'Effacer les données réinitialisera toutes vos statistiques d\'utilisation, l\'historique des sessions de concentration et les paramètres personnalisés. C\'est utile pour repartir de zéro ou pour le dépannage.';

  @override
  String get faqTroubleQ1 =>
      'Les données ne s\'affichent pas, erreur d\'ouverture de hive';

  @override
  String get faqTroubleA1 =>
      'Le problème est connu, la solution temporaire est d\'effacer les données via les paramètres et si cela ne fonctionne pas, allez dans Documents et supprimez les fichiers suivants s\'ils existent - harman_screentime_app_usage_box.hive et harman_screentime_app_usage.lock, il est également suggéré de mettre à jour l\'application vers la dernière version.';

  @override
  String get faqTroubleQ2 =>
      'L\'application s\'ouvre à chaque démarrage, que faire ?';

  @override
  String get faqTroubleA2 =>
      'C\'est un problème connu qui se produit sur Windows 10, la solution temporaire est d\'activer Lancer en Minimisé dans les paramètres pour qu\'elle se lance en minimisé.';

  @override
  String get usageAnalytics => 'Analyses d\'Utilisation';

  @override
  String get last7Days => '7 Derniers Jours';

  @override
  String get lastMonth => 'Dernier Mois';

  @override
  String get last3Months => '3 Derniers Mois';

  @override
  String get lifetime => 'Depuis le Début';

  @override
  String get custom => 'Personnalisé';

  @override
  String get loadingAnalyticsData => 'Chargement des données d\'analyse...';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get failedToInitialize =>
      'Échec de l\'initialisation des analyses. Veuillez redémarrer l\'application.';

  @override
  String unexpectedError(String error) {
    return 'Une erreur inattendue s\'est produite : $error. Veuillez réessayer plus tard.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Erreur lors du chargement des données d\'analyse : $error. Veuillez vérifier votre connexion et réessayer.';
  }

  @override
  String get customDialogTitle => 'Personnalisé';

  @override
  String get dateRange => 'Plage de Dates';

  @override
  String get specificDate => 'Date Spécifique';

  @override
  String get startDate => 'Date de Début : ';

  @override
  String get endDate => 'Date de Fin : ';

  @override
  String get date => 'Date : ';

  @override
  String get cancel => 'Annuler';

  @override
  String get apply => 'Appliquer';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Plage de Dates Invalide';

  @override
  String get startDateBeforeEndDate =>
      'La date de début doit être antérieure ou égale à la date de fin.';

  @override
  String get totalScreenTime => 'Temps d\'Écran Total';

  @override
  String get productiveTime => 'Temps Productif';

  @override
  String get mostUsedApp => 'Application la Plus Utilisée';

  @override
  String get focusSessions => 'Sessions de Concentration';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs période précédente';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs période précédente';
  }

  @override
  String iconLabel(String title) {
    return 'Icône $title';
  }

  @override
  String get dailyScreenTime => 'Temps d\'Écran Quotidien';

  @override
  String get categoryBreakdown => 'Répartition par Catégorie';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String sectionLabel(String title) {
    return 'Section $title';
  }

  @override
  String get detailedApplicationUsage =>
      'Utilisation Détaillée des Applications';

  @override
  String get searchApplications => 'Rechercher des applications';

  @override
  String get nameHeader => 'Nom';

  @override
  String get categoryHeader => 'Catégorie';

  @override
  String get totalTimeHeader => 'Temps Total';

  @override
  String get productivityHeader => 'Productivité';

  @override
  String get actionsHeader => 'Actions';

  @override
  String sortByOption(String option) {
    return 'Trier par : $option';
  }

  @override
  String get sortByName => 'Nom';

  @override
  String get sortByCategory => 'Catégorie';

  @override
  String get sortByUsage => 'Utilisation';

  @override
  String get productive => 'Productif';

  @override
  String get nonProductive => 'Non-Productif';

  @override
  String get noApplicationsMatch =>
      'Aucune application ne correspond à vos critères de recherche';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get usageSummary => 'Résumé d\'Utilisation';

  @override
  String get usageOverPastWeek => 'Utilisation de la Semaine Passée';

  @override
  String get usagePatternByTimeOfDay =>
      'Modèle d\'Utilisation par Moment de la Journée';

  @override
  String get patternAnalysis => 'Analyse des Modèles';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get dailyLimit => 'Limite Quotidienne';

  @override
  String get noLimit => 'Aucune limite';

  @override
  String get usageTrend => 'Tendance d\'Utilisation';

  @override
  String get productivity => 'Productivité';

  @override
  String get increasing => 'En Hausse';

  @override
  String get decreasing => 'En Baisse';

  @override
  String get stable => 'Stable';

  @override
  String get avgDailyUsage => 'Utilisation Quotidienne Moy.';

  @override
  String get longestSession => 'Session la Plus Longue';

  @override
  String get weeklyTotal => 'Total Hebdomadaire';

  @override
  String get noHistoricalData => 'Aucune donnée historique disponible';

  @override
  String get morning => 'Matin (6h-12h)';

  @override
  String get afternoon => 'Après-midi (12h-17h)';

  @override
  String get evening => 'Soir (17h-21h)';

  @override
  String get night => 'Nuit (21h-6h)';

  @override
  String get usageInsights => 'Aperçus d\'Utilisation';

  @override
  String get limitStatus => 'Statut de la Limite';

  @override
  String get close => 'Fermer';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Vous utilisez principalement $appName pendant $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Votre utilisation a augmenté de manière significative ($percentage%) par rapport à la période précédente.';
  }

  @override
  String get trendingUpward =>
      'Votre utilisation est en hausse par rapport à la période précédente.';

  @override
  String significantDecrease(String percentage) {
    return 'Votre utilisation a diminué de manière significative ($percentage%) par rapport à la période précédente.';
  }

  @override
  String get trendingDownward =>
      'Votre utilisation est en baisse par rapport à la période précédente.';

  @override
  String get consistentUsage =>
      'Votre utilisation est restée constante par rapport à la période précédente.';

  @override
  String get markedAsProductive =>
      'Cette application est marquée comme productive dans vos paramètres.';

  @override
  String get markedAsNonProductive =>
      'Cette application est marquée comme non-productive dans vos paramètres.';

  @override
  String mostActiveTime(String time) {
    return 'Votre moment le plus actif est autour de $time.';
  }

  @override
  String get noLimitSet =>
      'Aucune limite d\'utilisation n\'a été définie pour cette application.';

  @override
  String get limitReached =>
      'Vous avez atteint votre limite quotidienne pour cette application.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Vous êtes sur le point d\'atteindre votre limite quotidienne avec seulement $remainingTime restant.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Vous avez utilisé $percent% de votre limite quotidienne avec $remainingTime restant.';
  }

  @override
  String remainingTime(String time) {
    return 'Il vous reste $time sur votre limite quotidienne.';
  }

  @override
  String get todayChart => 'Aujourd\'hui';

  @override
  String hourPeriodAM(int hour) {
    return '${hour}h';
  }

  @override
  String hourPeriodPM(int hour) {
    return '${hour}h';
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
  String get alertsLimitsTitle => 'Alertes et Limites';

  @override
  String get notificationsSettings => 'Paramètres de Notifications';

  @override
  String get overallScreenTimeLimit => 'Limite Globale de Temps d\'Écran';

  @override
  String get applicationLimits => 'Limites des Applications';

  @override
  String get popupAlerts => 'Alertes Pop-up';

  @override
  String get frequentAlerts => 'Alertes Fréquentes';

  @override
  String get soundAlerts => 'Alertes Sonores';

  @override
  String get systemAlerts => 'Alertes Système';

  @override
  String get dailyTotalLimit => 'Limite Quotidienne Totale : ';

  @override
  String get hours => 'Heures : ';

  @override
  String get minutes => 'Minutes : ';

  @override
  String get currentUsage => 'Utilisation Actuelle : ';

  @override
  String get tableName => 'Nom';

  @override
  String get tableCategory => 'Catégorie';

  @override
  String get tableDailyLimit => 'Limite Quotidienne';

  @override
  String get tableCurrentUsage => 'Utilisation Actuelle';

  @override
  String get tableStatus => 'Statut';

  @override
  String get tableActions => 'Actions';

  @override
  String get addLimit => 'Ajouter une Limite';

  @override
  String get noApplicationsToDisplay => 'Aucune application à afficher';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusOff => 'Désactivé';

  @override
  String get durationNone => 'Aucune';

  @override
  String get addApplicationLimit => 'Ajouter une Limite d\'Application';

  @override
  String get selectApplication => 'Sélectionner une Application';

  @override
  String get selectApplicationPlaceholder => 'Sélectionnez une application';

  @override
  String get enableLimit => 'Activer la Limite : ';

  @override
  String editLimitTitle(String appName) {
    return 'Modifier la Limite : $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Échec du chargement des données : $error';
  }

  @override
  String get resetSettingsTitle => 'Réinitialiser les Paramètres ?';

  @override
  String get resetSettingsContent =>
      'Si vous réinitialisez les paramètres, vous ne pourrez pas les récupérer. Voulez-vous les réinitialiser ?';

  @override
  String get resetAll => 'Tout Réinitialiser';

  @override
  String get refresh => 'Actualiser';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get applicationsTitle => 'Applications';

  @override
  String get searchApplication => 'Rechercher une Application';

  @override
  String get tracking => 'Suivi';

  @override
  String get hiddenVisible => 'Masqué/Visible';

  @override
  String get selectCategory => 'Sélectionner une Catégorie';

  @override
  String get allCategories => 'Toutes';

  @override
  String get tableScreenTime => 'Temps d\'Écran';

  @override
  String get tableTracking => 'Suivi';

  @override
  String get tableHidden => 'Masqué';

  @override
  String get tableEdit => 'Modifier';

  @override
  String editAppTitle(String appName) {
    return 'Modifier $appName';
  }

  @override
  String get categorySection => 'Catégorie';

  @override
  String get customCategory => 'Personnalisée';

  @override
  String get customCategoryPlaceholder =>
      'Entrez le nom de la catégorie personnalisée';

  @override
  String get uncategorized => 'Non catégorisé';

  @override
  String get isProductive => 'Est Productif';

  @override
  String get trackUsage => 'Suivre l\'Utilisation';

  @override
  String get visibleInReports => 'Visible dans les Rapports';

  @override
  String get timeLimitsSection => 'Limites de Temps';

  @override
  String get enableDailyLimit => 'Activer la Limite Quotidienne';

  @override
  String get setDailyTimeLimit => 'Définir la limite de temps quotidienne :';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String errorLoadingData(String error) {
    return 'Erreur lors du chargement des données d\'aperçu : $error';
  }

  @override
  String get focusModeTitle => 'Mode Concentration';

  @override
  String get historySection => 'Historique';

  @override
  String get trendsSection => 'Tendances';

  @override
  String get timeDistributionSection => 'Répartition du Temps';

  @override
  String get sessionHistorySection => 'Historique des Sessions';

  @override
  String get workSession => 'Session de Travail';

  @override
  String get shortBreak => 'Pause Courte';

  @override
  String get longBreak => 'Pause Longue';

  @override
  String get dateHeader => 'Date';

  @override
  String get durationHeader => 'Durée';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get focusModeSettingsTitle => 'Paramètres du Mode Concentration';

  @override
  String get modeCustom => 'Personnalisé';

  @override
  String get modeDeepWork => 'Travail Approfondi (60 min)';

  @override
  String get modeQuickTasks => 'Tâches Rapides (25 min)';

  @override
  String get modeReading => 'Lecture (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Durée de Travail : $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Pause Courte : $minutes min';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Pause Longue : $minutes min';
  }

  @override
  String get autoStartNextSession =>
      'Démarrer automatiquement la session suivante';

  @override
  String get blockDistractions =>
      'Bloquer les distractions pendant le mode concentration';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get saved => 'Enregistré';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Erreur lors du chargement des données du mode concentration : $error';
  }

  @override
  String get overviewTitle => 'Aperçu d\'Aujourd\'hui';

  @override
  String get startFocusMode => 'Démarrer le Mode Concentration';

  @override
  String get loadingProductivityData =>
      'Chargement de vos données de productivité...';

  @override
  String get noActivityDataAvailable => 'Aucune donnée d\'activité disponible';

  @override
  String get startUsingApplications =>
      'Commencez à utiliser vos applications pour suivre le temps d\'écran et la productivité.';

  @override
  String get refreshData => 'Actualiser les Données';

  @override
  String get topApplications => 'Applications Principales';

  @override
  String get noAppUsageDataAvailable =>
      'Aucune donnée d\'utilisation d\'application disponible';

  @override
  String get noApplicationDataAvailable =>
      'Aucune donnée d\'application disponible';

  @override
  String get noCategoryDataAvailable => 'Aucune donnée de catégorie disponible';

  @override
  String get noApplicationLimitsSet => 'Aucune limite d\'application définie';

  @override
  String get screenLabel => 'Temps';

  @override
  String get timeLabel => 'd\'Écran';

  @override
  String get productiveLabel => 'Score';

  @override
  String get scoreLabel => 'Productif';

  @override
  String get defaultNone => 'Aucun';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Inconnu';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get generalSection => 'Général';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get dataSection => 'Données';

  @override
  String get versionSection => 'Version';

  @override
  String get themeTitle => 'Thème';

  @override
  String get themeDescription =>
      'Thème de couleur de l\'application (Redémarrage Requis)';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageDescription => 'Langue de l\'application';

  @override
  String get startupBehaviourTitle => 'Comportement au Démarrage';

  @override
  String get startupBehaviourDescription => 'Lancer au démarrage du système';

  @override
  String get launchMinimizedTitle => 'Lancer en Minimisé';

  @override
  String get launchMinimizedDescription =>
      'Démarrer l\'application dans la barre système (Recommandé pour Windows 10)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllDescription =>
      'Toutes les notifications de l\'application';

  @override
  String get focusModeNotificationsTitle => 'Mode Concentration';

  @override
  String get focusModeNotificationsDescription =>
      'Toutes les notifications du mode concentration';

  @override
  String get screenTimeNotificationsTitle => 'Temps d\'Écran';

  @override
  String get screenTimeNotificationsDescription =>
      'Toutes les notifications de restriction du temps d\'écran';

  @override
  String get appScreenTimeNotificationsTitle =>
      'Temps d\'Écran des Applications';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Toutes les notifications de restriction du temps d\'écran des applications';

  @override
  String get frequentAlertsTitle => 'Intervalle des Alertes Fréquentes';

  @override
  String get frequentAlertsDescription =>
      'Définir l\'intervalle pour les notifications fréquentes (minutes)';

  @override
  String get clearDataTitle => 'Effacer les Données';

  @override
  String get clearDataDescription =>
      'Effacer tout l\'historique et les données associées';

  @override
  String get resetSettingsTitle2 => 'Réinitialiser les Paramètres';

  @override
  String get resetSettingsDescription => 'Réinitialiser tous les paramètres';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionDescription => 'Version actuelle de l\'application';

  @override
  String get contactButton => 'Contact';

  @override
  String get reportBugButton => 'Signaler un Bug';

  @override
  String get submitFeedbackButton => 'Soumettre un Commentaire';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Effacer les Données ?';

  @override
  String get clearDataDialogContent =>
      'Cela effacera tout l\'historique et les données associées. Vous ne pourrez pas les récupérer. Voulez-vous continuer ?';

  @override
  String get clearDataButtonLabel => 'Effacer les Données';

  @override
  String get resetSettingsDialogTitle => 'Réinitialiser les Paramètres ?';

  @override
  String get resetSettingsDialogContent =>
      'Cela réinitialisera tous les paramètres à leurs valeurs par défaut. Voulez-vous continuer ?';

  @override
  String get resetButtonLabel => 'Réinitialiser';

  @override
  String get cancelButton => 'Annuler';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get chart_focusTrends => 'Tendances de Concentration';

  @override
  String get chart_sessionCount => 'Nombre de Sessions';

  @override
  String get chart_avgDuration => 'Durée Moyenne';

  @override
  String get chart_totalFocus => 'Concentration Totale';

  @override
  String get chart_yAxis_sessions => 'Sessions';

  @override
  String get chart_yAxis_minutes => 'Minutes';

  @override
  String get chart_yAxis_value => 'Valeur';

  @override
  String get chart_monthOverMonthChange => 'Variation mensuelle : ';

  @override
  String get chart_customRange => 'Plage Personnalisée';

  @override
  String get day_monday => 'Lundi';

  @override
  String get day_mondayShort => 'Lun';

  @override
  String get day_mondayAbbr => 'Lu';

  @override
  String get day_tuesday => 'Mardi';

  @override
  String get day_tuesdayShort => 'Mar';

  @override
  String get day_tuesdayAbbr => 'Ma';

  @override
  String get day_wednesday => 'Mercredi';

  @override
  String get day_wednesdayShort => 'Mer';

  @override
  String get day_wednesdayAbbr => 'Me';

  @override
  String get day_thursday => 'Jeudi';

  @override
  String get day_thursdayShort => 'Jeu';

  @override
  String get day_thursdayAbbr => 'Je';

  @override
  String get day_friday => 'Vendredi';

  @override
  String get day_fridayShort => 'Ven';

  @override
  String get day_fridayAbbr => 'Ve';

  @override
  String get day_saturday => 'Samedi';

  @override
  String get day_saturdayShort => 'Sam';

  @override
  String get day_saturdayAbbr => 'Sa';

  @override
  String get day_sunday => 'Dimanche';

  @override
  String get day_sundayShort => 'Dim';

  @override
  String get day_sundayAbbr => 'Di';

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
    return '$date : ${hours}h ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count heures';
  }

  @override
  String get month_january => 'Janvier';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'Février';

  @override
  String get month_februaryShort => 'Fév';

  @override
  String get month_march => 'Mars';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'Avril';

  @override
  String get month_aprilShort => 'Avr';

  @override
  String get month_may => 'Mai';

  @override
  String get month_mayShort => 'Mai';

  @override
  String get month_june => 'Juin';

  @override
  String get month_juneShort => 'Juin';

  @override
  String get month_july => 'Juillet';

  @override
  String get month_julyShort => 'Juil';

  @override
  String get month_august => 'Août';

  @override
  String get month_augustShort => 'Août';

  @override
  String get month_september => 'Septembre';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Octobre';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'Novembre';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Décembre';

  @override
  String get month_decemberShort => 'Déc';

  @override
  String get categoryAll => 'Toutes';

  @override
  String get categoryProductivity => 'Productivité';

  @override
  String get categoryDevelopment => 'Développement';

  @override
  String get categorySocialMedia => 'Réseaux Sociaux';

  @override
  String get categoryEntertainment => 'Divertissement';

  @override
  String get categoryGaming => 'Jeux';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryWebBrowsing => 'Navigation Web';

  @override
  String get categoryCreative => 'Créatif';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryUtility => 'Utilitaire';

  @override
  String get categoryUncategorized => 'Non catégorisé';

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
  String get appGoogleCalendar => 'Google Agenda';

  @override
  String get appAppleCalendar => 'Calendrier';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Invite de Commandes';

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
  String get appCalculator => 'Calculatrice';

  @override
  String get appNotes => 'Notes';

  @override
  String get appSystemPreferences => 'Préférences Système';

  @override
  String get appTaskManager => 'Gestionnaire des Tâches';

  @override
  String get appFileExplorer => 'Explorateur de Fichiers';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';
}
