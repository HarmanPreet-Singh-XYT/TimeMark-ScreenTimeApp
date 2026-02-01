// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appWindowTitle =>
      'TimeMark - Lacak Waktu Layar & Penggunaan Aplikasi';

  @override
  String get appName => 'TimeMark';

  @override
  String get appTitle => 'Waktu Layar Produktif';

  @override
  String get sidebarTitle => 'Waktu Layar';

  @override
  String get sidebarSubtitle => 'Sumber Terbuka';

  @override
  String get trayShowWindow => 'Tampilkan Jendela';

  @override
  String get trayStartFocusMode => 'Mulai Mode Fokus';

  @override
  String get trayStopFocusMode => 'Hentikan Mode Fokus';

  @override
  String get trayReports => 'Laporan';

  @override
  String get trayAlertsLimits => 'Peringatan & Batasan';

  @override
  String get trayApplications => 'Aplikasi';

  @override
  String get trayDisableNotifications => 'Nonaktifkan Notifikasi';

  @override
  String get trayEnableNotifications => 'Aktifkan Notifikasi';

  @override
  String get trayVersionPrefix => 'Versi: ';

  @override
  String trayVersion(String version) {
    return 'Versi: $version';
  }

  @override
  String get trayExit => 'Keluar';

  @override
  String get navOverview => 'Ringkasan';

  @override
  String get navApplications => 'Aplikasi';

  @override
  String get navAlertsLimits => 'Peringatan & Batasan';

  @override
  String get navReports => 'Laporan';

  @override
  String get navFocusMode => 'Mode Fokus';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get navHelp => 'Bantuan';

  @override
  String get helpTitle => 'Bantuan';

  @override
  String get faqCategoryGeneral => 'Pertanyaan Umum';

  @override
  String get faqCategoryApplications => 'Manajemen Aplikasi';

  @override
  String get faqCategoryReports => 'Analitik Penggunaan & Laporan';

  @override
  String get faqCategoryAlerts => 'Peringatan & Batasan';

  @override
  String get faqCategoryFocusMode => 'Mode Fokus & Timer Pomodoro';

  @override
  String get faqCategorySettings => 'Pengaturan & Kustomisasi';

  @override
  String get faqCategoryTroubleshooting => 'Pemecahan Masalah';

  @override
  String get faqGeneralQ1 => 'Bagaimana aplikasi ini melacak waktu layar?';

  @override
  String get faqGeneralA1 =>
      'Aplikasi memantau penggunaan perangkat Anda secara real-time, melacak waktu yang dihabiskan pada berbagai aplikasi. Ini memberikan wawasan komprehensif tentang kebiasaan digital Anda, termasuk total waktu layar, waktu produktif, dan penggunaan aplikasi spesifik.';

  @override
  String get faqGeneralQ2 => 'Apa yang membuat aplikasi \'Produktif\'?';

  @override
  String get faqGeneralA2 =>
      'Anda dapat menandai aplikasi sebagai produktif secara manual di bagian \'Aplikasi\'. Aplikasi produktif berkontribusi pada Skor Produktif Anda, yang menghitung persentase waktu layar yang dihabiskan untuk aplikasi terkait pekerjaan atau bermanfaat.';

  @override
  String get faqGeneralQ3 => 'Seberapa akurat pelacakan waktu layar?';

  @override
  String get faqGeneralA3 =>
      'Aplikasi menggunakan pelacakan tingkat sistem untuk memberikan pengukuran yang tepat dari penggunaan perangkat Anda. Ini menangkap waktu foreground untuk setiap aplikasi dengan dampak baterai minimal.';

  @override
  String get faqGeneralQ4 =>
      'Bisakah saya menyesuaikan kategorisasi aplikasi saya?';

  @override
  String get faqGeneralA4 =>
      'Tentu saja! Anda dapat membuat kategori khusus, menetapkan aplikasi ke kategori tertentu, dan dengan mudah memodifikasi penetapan ini di bagian \'Aplikasi\'. Ini membantu menciptakan analitik penggunaan yang lebih bermakna.';

  @override
  String get faqGeneralQ5 =>
      'Wawasan apa yang bisa saya dapatkan dari aplikasi ini?';

  @override
  String get faqGeneralA5 =>
      'Aplikasi menawarkan wawasan komprehensif termasuk Skor Produktif, pola penggunaan berdasarkan waktu, penggunaan aplikasi terperinci, pelacakan sesi fokus, dan analitik visual seperti grafik dan diagram lingkaran untuk membantu Anda memahami dan meningkatkan kebiasaan digital Anda.';

  @override
  String get faqAppsQ1 =>
      'Bagaimana cara menyembunyikan aplikasi tertentu dari pelacakan?';

  @override
  String get faqAppsA1 =>
      'Di bagian \'Aplikasi\', Anda dapat mengaktifkan/menonaktifkan visibilitas aplikasi.';

  @override
  String get faqAppsQ2 => 'Bisakah saya mencari dan memfilter aplikasi saya?';

  @override
  String get faqAppsA2 =>
      'Ya, bagian Aplikasi mencakup fungsi pencarian dan opsi filter. Anda dapat memfilter aplikasi berdasarkan kategori, status produktivitas, status pelacakan, dan visibilitas.';

  @override
  String get faqAppsQ3 => 'Opsi pengeditan apa yang tersedia untuk aplikasi?';

  @override
  String get faqAppsA3 =>
      'Untuk setiap aplikasi, Anda dapat mengedit: penetapan kategori, status produktivitas, pelacakan penggunaan, visibilitas dalam laporan, dan menetapkan batasan waktu harian individual.';

  @override
  String get faqAppsQ4 => 'Bagaimana kategori aplikasi ditentukan?';

  @override
  String get faqAppsA4 =>
      'Kategori awal disarankan oleh sistem, tetapi Anda memiliki kontrol penuh untuk membuat, memodifikasi, dan menetapkan kategori khusus berdasarkan alur kerja dan preferensi Anda.';

  @override
  String get faqReportsQ1 => 'Jenis laporan apa yang tersedia?';

  @override
  String get faqReportsA1 =>
      'Laporan mencakup: Total waktu layar, Waktu produktif, Aplikasi paling sering digunakan, Sesi fokus, Grafik waktu layar harian, Diagram lingkaran pembagian kategori, Penggunaan aplikasi terperinci, Tren penggunaan mingguan, dan Analisis pola penggunaan berdasarkan waktu.';

  @override
  String get faqReportsQ2 => 'Seberapa detail laporan penggunaan aplikasi?';

  @override
  String get faqReportsA2 =>
      'Laporan penggunaan aplikasi terperinci menunjukkan: Nama aplikasi, Kategori, Total waktu yang dihabiskan, Status produktivitas, dan menawarkan bagian \'Tindakan\' dengan wawasan lebih dalam seperti ringkasan penggunaan, batasan harian, tren penggunaan, dan metrik produktivitas.';

  @override
  String get faqReportsQ3 =>
      'Bisakah saya menganalisis tren penggunaan saya dari waktu ke waktu?';

  @override
  String get faqReportsA3 =>
      'Ya! Aplikasi menyediakan perbandingan minggu-ke-minggu, menampilkan grafik penggunaan selama beberapa minggu terakhir, penggunaan harian rata-rata, sesi terpanjang, dan total mingguan untuk membantu Anda melacak kebiasaan digital Anda.';

  @override
  String get faqReportsQ4 => 'Apa itu analisis \'Pola Penggunaan\'?';

  @override
  String get faqReportsA4 =>
      'Pola Penggunaan memecah waktu layar Anda menjadi segmen pagi, siang, sore, dan malam. Ini membantu Anda memahami kapan Anda paling aktif di perangkat dan mengidentifikasi area potensial untuk perbaikan.';

  @override
  String get faqAlertsQ1 => 'Seberapa detail batasan waktu layar?';

  @override
  String get faqAlertsA1 =>
      'Anda dapat menetapkan batasan waktu layar harian keseluruhan dan batasan aplikasi individual. Batasan dapat dikonfigurasi dalam jam dan menit, dengan opsi untuk mengatur ulang atau menyesuaikan sesuai kebutuhan.';

  @override
  String get faqAlertsQ2 => 'Opsi notifikasi apa yang tersedia?';

  @override
  String get faqAlertsA2 =>
      'Aplikasi menawarkan beberapa jenis notifikasi: Peringatan sistem saat Anda melebihi waktu layar, Peringatan sering pada interval yang dapat disesuaikan (1, 5, 15, 30, atau 60 menit), dan tombol untuk mode fokus, waktu layar, dan notifikasi khusus aplikasi.';

  @override
  String get faqAlertsQ3 => 'Bisakah saya menyesuaikan peringatan batasan?';

  @override
  String get faqAlertsA3 =>
      'Ya, Anda dapat menyesuaikan frekuensi peringatan, mengaktifkan/menonaktifkan jenis peringatan tertentu, dan menetapkan batasan berbeda untuk waktu layar keseluruhan dan aplikasi individual.';

  @override
  String get faqFocusQ1 => 'Jenis Mode Fokus apa yang tersedia?';

  @override
  String get faqFocusA1 =>
      'Mode yang tersedia termasuk Deep Work (sesi fokus lebih lama), Quick Tasks (pekerjaan singkat), dan Mode Membaca. Setiap mode membantu Anda menyusun waktu kerja dan istirahat secara efektif.';

  @override
  String get faqFocusQ2 => 'Seberapa fleksibel Timer Pomodoro?';

  @override
  String get faqFocusA2 =>
      'Timer sangat dapat disesuaikan. Anda dapat menyesuaikan durasi kerja, lama istirahat pendek, dan durasi istirahat panjang. Opsi tambahan termasuk mulai otomatis untuk sesi berikutnya dan pengaturan notifikasi.';

  @override
  String get faqFocusQ3 => 'Apa yang ditampilkan riwayat Mode Fokus?';

  @override
  String get faqFocusA3 =>
      'Riwayat Mode Fokus melacak sesi fokus harian, menampilkan jumlah sesi per hari, grafik tren, durasi sesi rata-rata, total waktu fokus, dan diagram lingkaran distribusi waktu yang memecah sesi kerja, istirahat pendek, dan istirahat panjang.';

  @override
  String get faqFocusQ4 => 'Bisakah saya melacak kemajuan sesi fokus saya?';

  @override
  String get faqFocusA4 =>
      'Aplikasi menampilkan UI timer melingkar dengan tombol putar/jeda, muat ulang, dan pengaturan. Anda dapat dengan mudah melacak dan mengelola sesi fokus Anda dengan kontrol intuitif.';

  @override
  String get faqSettingsQ1 => 'Opsi kustomisasi apa yang tersedia?';

  @override
  String get faqSettingsA1 =>
      'Kustomisasi mencakup pemilihan tema (Sistem, Terang, Gelap), pengaturan bahasa, perilaku startup, kontrol notifikasi komprehensif, dan opsi manajemen data seperti menghapus data atau mengatur ulang pengaturan.';

  @override
  String get faqSettingsQ2 =>
      'Bagaimana cara memberikan umpan balik atau melaporkan masalah?';

  @override
  String get faqSettingsA2 =>
      'Di bagian bawah bagian Pengaturan, Anda akan menemukan tombol untuk Laporkan Bug, Kirim Umpan Balik, atau Hubungi Dukungan. Ini akan mengarahkan Anda ke saluran dukungan yang sesuai.';

  @override
  String get faqSettingsQ3 =>
      'Apa yang terjadi ketika saya menghapus data saya?';

  @override
  String get faqSettingsA3 =>
      'Menghapus data akan mengatur ulang semua statistik penggunaan Anda, riwayat sesi fokus, dan pengaturan khusus. Ini berguna untuk memulai dari awal atau pemecahan masalah.';

  @override
  String get faqTroubleQ1 => 'Data tidak muncul, kesalahan hive tidak terbuka';

  @override
  String get faqTroubleA1 =>
      'Masalah ini diketahui, perbaikan sementara adalah menghapus data melalui pengaturan dan jika tidak berhasil maka pergi ke Dokumen dan hapus file berikut jika ada - harman_screentime_app_usage_box.hive dan harman_screentime_app_usage.lock, Anda juga disarankan untuk memperbarui aplikasi ke versi terbaru.';

  @override
  String get faqTroubleQ2 =>
      'Aplikasi terbuka setiap startup, apa yang harus dilakukan?';

  @override
  String get faqTroubleA2 =>
      'Ini adalah masalah yang diketahui yang terjadi pada Windows 10, perbaikan sementara adalah mengaktifkan Luncurkan sebagai Diminimalkan di pengaturan sehingga diluncurkan sebagai Diminimalkan.';

  @override
  String get usageAnalytics => 'Analitik Penggunaan';

  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get lastMonth => 'Bulan Lalu';

  @override
  String get last3Months => '3 Bulan Terakhir';

  @override
  String get lifetime => 'Selamanya';

  @override
  String get custom => 'Kustom';

  @override
  String get loadingAnalyticsData => 'Memuat data analitik...';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get failedToInitialize =>
      'Gagal menginisialisasi analitik. Silakan mulai ulang aplikasi.';

  @override
  String unexpectedError(String error) {
    return 'Terjadi kesalahan tak terduga: $error. Silakan coba lagi nanti.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Kesalahan memuat data analitik: $error. Silakan periksa koneksi Anda dan coba lagi.';
  }

  @override
  String get customDialogTitle => 'Kustom';

  @override
  String get dateRange => 'Rentang Tanggal';

  @override
  String get specificDate => 'Tanggal Spesifik';

  @override
  String get startDate => 'Tanggal Mulai: ';

  @override
  String get endDate => 'Tanggal Akhir: ';

  @override
  String get date => 'Tanggal: ';

  @override
  String get cancel => 'Batal';

  @override
  String get apply => 'Terapkan';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Rentang Tanggal Tidak Valid';

  @override
  String get startDateBeforeEndDate =>
      'Tanggal mulai harus sebelum atau sama dengan tanggal akhir.';

  @override
  String get totalScreenTime => 'Total Waktu Layar';

  @override
  String get productiveTime => 'Waktu Produktif';

  @override
  String get mostUsedApp => 'Aplikasi Paling Sering Digunakan';

  @override
  String get focusSessions => 'Sesi Fokus';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs periode sebelumnya';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs periode sebelumnya';
  }

  @override
  String iconLabel(String title) {
    return 'Ikon $title';
  }

  @override
  String get dailyScreenTime => 'Waktu Layar Harian';

  @override
  String get categoryBreakdown => 'Pembagian Kategori';

  @override
  String get noDataAvailable => 'Tidak ada data tersedia';

  @override
  String sectionLabel(String title) {
    return 'Bagian $title';
  }

  @override
  String get detailedApplicationUsage => 'Penggunaan Aplikasi Terperinci';

  @override
  String get searchApplications => 'Cari aplikasi';

  @override
  String get nameHeader => 'Nama';

  @override
  String get categoryHeader => 'Kategori';

  @override
  String get totalTimeHeader => 'Total Waktu';

  @override
  String get productivityHeader => 'Produktivitas';

  @override
  String get actionsHeader => 'Tindakan';

  @override
  String sortByOption(String option) {
    return 'Urutkan berdasarkan: $option';
  }

  @override
  String get sortByName => 'Nama';

  @override
  String get sortByCategory => 'Kategori';

  @override
  String get sortByUsage => 'Penggunaan';

  @override
  String get productive => 'Produktif';

  @override
  String get nonProductive => 'Non-Produktif';

  @override
  String get noApplicationsMatch =>
      'Tidak ada aplikasi yang cocok dengan kriteria pencarian Anda';

  @override
  String get viewDetails => 'Lihat detail';

  @override
  String get usageSummary => 'Ringkasan Penggunaan';

  @override
  String get usageOverPastWeek => 'Penggunaan Selama Seminggu Terakhir';

  @override
  String get usagePatternByTimeOfDay => 'Pola Penggunaan Berdasarkan Waktu';

  @override
  String get patternAnalysis => 'Analisis Pola';

  @override
  String get today => 'Hari Ini';

  @override
  String get dailyLimit => 'Batasan Harian';

  @override
  String get noLimit => 'Tidak ada batasan';

  @override
  String get usageTrend => 'Tren Penggunaan';

  @override
  String get productivity => 'Produktivitas';

  @override
  String get increasing => 'Meningkat';

  @override
  String get decreasing => 'Menurun';

  @override
  String get stable => 'Stabil';

  @override
  String get avgDailyUsage => 'Rata-rata Penggunaan Harian';

  @override
  String get longestSession => 'Sesi Terpanjang';

  @override
  String get weeklyTotal => 'Total Mingguan';

  @override
  String get noHistoricalData => 'Tidak ada data historis tersedia';

  @override
  String get morning => 'Pagi (6-12)';

  @override
  String get afternoon => 'Siang (12-5)';

  @override
  String get evening => 'Sore (5-9)';

  @override
  String get night => 'Malam (9-6)';

  @override
  String get usageInsights => 'Wawasan Penggunaan';

  @override
  String get limitStatus => 'Status Batasan';

  @override
  String get close => 'Tutup';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Anda terutama menggunakan $appName selama $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Penggunaan Anda telah meningkat secara signifikan ($percentage%) dibandingkan periode sebelumnya.';
  }

  @override
  String get trendingUpward =>
      'Penggunaan Anda cenderung meningkat dibandingkan periode sebelumnya.';

  @override
  String significantDecrease(String percentage) {
    return 'Penggunaan Anda telah menurun secara signifikan ($percentage%) dibandingkan periode sebelumnya.';
  }

  @override
  String get trendingDownward =>
      'Penggunaan Anda cenderung menurun dibandingkan periode sebelumnya.';

  @override
  String get consistentUsage =>
      'Penggunaan Anda telah konsisten dibandingkan periode sebelumnya.';

  @override
  String get markedAsProductive =>
      'Ini ditandai sebagai aplikasi produktif dalam pengaturan Anda.';

  @override
  String get markedAsNonProductive =>
      'Ini ditandai sebagai aplikasi non-produktif dalam pengaturan Anda.';

  @override
  String mostActiveTime(String time) {
    return 'Waktu paling aktif Anda adalah sekitar $time.';
  }

  @override
  String get noLimitSet =>
      'Tidak ada batasan penggunaan yang ditetapkan untuk aplikasi ini.';

  @override
  String get limitReached =>
      'Anda telah mencapai batasan harian untuk aplikasi ini.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Anda hampir mencapai batasan harian dengan hanya $remainingTime tersisa.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Anda telah menggunakan $percent% dari batasan harian dengan $remainingTime tersisa.';
  }

  @override
  String remainingTime(String time) {
    return 'Anda memiliki $time tersisa dari batasan harian Anda.';
  }

  @override
  String get todayChart => 'Hari Ini';

  @override
  String hourPeriodAM(int hour) {
    return '$hour Pagi';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour Sore';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get alertsLimitsTitle => 'Peringatan & Batasan';

  @override
  String get notificationsSettings => 'Pengaturan Notifikasi';

  @override
  String get overallScreenTimeLimit => 'Batasan Waktu Layar Keseluruhan';

  @override
  String get applicationLimits => 'Batasan Aplikasi';

  @override
  String get popupAlerts => 'Peringatan Pop-up';

  @override
  String get frequentAlerts => 'Peringatan Sering';

  @override
  String get soundAlerts => 'Peringatan Suara';

  @override
  String get systemAlerts => 'Peringatan Sistem';

  @override
  String get dailyTotalLimit => 'Batasan Total Harian: ';

  @override
  String get hours => 'Jam: ';

  @override
  String get minutes => 'Menit: ';

  @override
  String get currentUsage => 'Penggunaan Saat Ini: ';

  @override
  String get tableName => 'Nama';

  @override
  String get tableCategory => 'Kategori';

  @override
  String get tableDailyLimit => 'Batasan Harian';

  @override
  String get tableCurrentUsage => 'Penggunaan Saat Ini';

  @override
  String get tableStatus => 'Status';

  @override
  String get tableActions => 'Tindakan';

  @override
  String get addLimit => 'Tambah Batasan';

  @override
  String get noApplicationsToDisplay => 'Tidak ada aplikasi untuk ditampilkan';

  @override
  String get statusActive => 'Aktif';

  @override
  String get statusOff => 'Mati';

  @override
  String get durationNone => 'Tidak ada';

  @override
  String get addApplicationLimit => 'Tambah Batasan Aplikasi';

  @override
  String get selectApplication => 'Pilih Aplikasi';

  @override
  String get selectApplicationPlaceholder => 'Pilih sebuah aplikasi';

  @override
  String get enableLimit => 'Aktifkan Batasan: ';

  @override
  String editLimitTitle(String appName) {
    return 'Edit Batasan: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String get resetSettingsTitle => 'Atur Ulang Pengaturan?';

  @override
  String get resetSettingsContent =>
      'Jika Anda mengatur ulang pengaturan, Anda tidak akan dapat memulihkannya. Apakah Anda ingin mengatur ulang?';

  @override
  String get resetAll => 'Atur Ulang Semua';

  @override
  String get refresh => 'Segarkan';

  @override
  String get save => 'Simpan';

  @override
  String get add => 'Tambah';

  @override
  String get error => 'Kesalahan';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get applicationsTitle => 'Aplikasi';

  @override
  String get searchApplication => 'Cari Aplikasi';

  @override
  String get tracking => 'Pelacakan';

  @override
  String get hiddenVisible => 'Tersembunyi/Terlihat';

  @override
  String get selectCategory => 'Pilih Kategori';

  @override
  String get allCategories => 'Semua';

  @override
  String get tableScreenTime => 'Waktu Layar';

  @override
  String get tableTracking => 'Pelacakan';

  @override
  String get tableHidden => 'Tersembunyi';

  @override
  String get tableEdit => 'Edit';

  @override
  String editAppTitle(String appName) {
    return 'Edit $appName';
  }

  @override
  String get categorySection => 'Kategori';

  @override
  String get customCategory => 'Kustom';

  @override
  String get customCategoryPlaceholder => 'Masukkan nama kategori kustom';

  @override
  String get uncategorized => 'Tidak Dikategorikan';

  @override
  String get isProductive => 'Produktif';

  @override
  String get trackUsage => 'Lacak Penggunaan';

  @override
  String get visibleInReports => 'Terlihat dalam Laporan';

  @override
  String get timeLimitsSection => 'Batasan Waktu';

  @override
  String get enableDailyLimit => 'Aktifkan Batasan Harian';

  @override
  String get setDailyTimeLimit => 'Atur batasan waktu harian:';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String errorLoadingData(String error) {
    return 'Kesalahan memuat data ringkasan: $error';
  }

  @override
  String get focusModeTitle => 'Mode Fokus';

  @override
  String get historySection => 'Riwayat';

  @override
  String get trendsSection => 'Tren';

  @override
  String get timeDistributionSection => 'Distribusi Waktu';

  @override
  String get sessionHistorySection => 'Riwayat Sesi';

  @override
  String get workSession => 'Sesi Kerja';

  @override
  String get shortBreak => 'Istirahat Pendek';

  @override
  String get longBreak => 'Istirahat Panjang';

  @override
  String get dateHeader => 'Tanggal';

  @override
  String get durationHeader => 'Durasi';

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sunday => 'Minggu';

  @override
  String get focusModeSettingsTitle => 'Pengaturan Mode Fokus';

  @override
  String get modeCustom => 'Kustom';

  @override
  String get modeDeepWork => 'Deep Work (60 menit)';

  @override
  String get modeQuickTasks => 'Tugas Cepat (25 menit)';

  @override
  String get modeReading => 'Membaca (45 menit)';

  @override
  String workDurationLabel(int minutes) {
    return 'Durasi Kerja: $minutes menit';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Istirahat Pendek: $minutes menit';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Istirahat Panjang: $minutes menit';
  }

  @override
  String get autoStartNextSession => 'Mulai otomatis sesi berikutnya';

  @override
  String get blockDistractions => 'Blokir gangguan selama mode fokus';

  @override
  String get enableNotifications => 'Aktifkan notifikasi';

  @override
  String get saved => 'Tersimpan';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Kesalahan memuat data mode fokus: $error';
  }

  @override
  String get overviewTitle => 'Ringkasan Hari Ini';

  @override
  String get startFocusMode => 'Mulai Mode Fokus';

  @override
  String get loadingProductivityData => 'Memuat data produktivitas Anda...';

  @override
  String get noActivityDataAvailable => 'Belum ada data aktivitas tersedia';

  @override
  String get startUsingApplications =>
      'Mulai gunakan aplikasi Anda untuk melacak waktu layar dan produktivitas.';

  @override
  String get refreshData => 'Segarkan Data';

  @override
  String get topApplications => 'Aplikasi Teratas';

  @override
  String get noAppUsageDataAvailable =>
      'Belum ada data penggunaan aplikasi tersedia';

  @override
  String get noApplicationDataAvailable => 'Tidak ada data aplikasi tersedia';

  @override
  String get noCategoryDataAvailable => 'Tidak ada data kategori tersedia';

  @override
  String get noApplicationLimitsSet =>
      'Tidak ada batasan aplikasi yang ditetapkan';

  @override
  String get screenLabel => 'Layar';

  @override
  String get timeLabel => 'Waktu';

  @override
  String get productiveLabel => 'Produktif';

  @override
  String get scoreLabel => 'Skor';

  @override
  String get defaultNone => 'Tidak ada';

  @override
  String get defaultTime => '0j 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Tidak dikenal';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get generalSection => 'Umum';

  @override
  String get notificationsSection => 'Notifikasi';

  @override
  String get dataSection => 'Data';

  @override
  String get versionSection => 'Versi';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription =>
      'Tema warna aplikasi (Perubahan Memerlukan Mulai Ulang)';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageDescription => 'Bahasa aplikasi';

  @override
  String get startupBehaviourTitle => 'Perilaku Startup';

  @override
  String get startupBehaviourDescription => 'Luncurkan saat startup OS';

  @override
  String get launchMinimizedTitle => 'Luncurkan sebagai Diminimalkan';

  @override
  String get launchMinimizedDescription =>
      'Mulai aplikasi di System Tray (Direkomendasikan untuk Windows 10)';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get notificationsAllDescription => 'Semua notifikasi aplikasi';

  @override
  String get focusModeNotificationsTitle => 'Mode Fokus';

  @override
  String get focusModeNotificationsDescription =>
      'Semua Notifikasi untuk mode fokus';

  @override
  String get screenTimeNotificationsTitle => 'Waktu Layar';

  @override
  String get screenTimeNotificationsDescription =>
      'Semua Notifikasi untuk pembatasan waktu layar';

  @override
  String get appScreenTimeNotificationsTitle => 'Waktu Layar Aplikasi';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Semua Notifikasi untuk pembatasan waktu layar aplikasi';

  @override
  String get frequentAlertsTitle => 'Interval Peringatan Sering';

  @override
  String get frequentAlertsDescription =>
      'Atur interval untuk notifikasi sering (menit)';

  @override
  String get clearDataTitle => 'Hapus Data';

  @override
  String get clearDataDescription =>
      'Hapus semua riwayat dan data terkait lainnya';

  @override
  String get resetSettingsTitle2 => 'Atur Ulang Pengaturan';

  @override
  String get resetSettingsDescription => 'Atur ulang semua pengaturan';

  @override
  String get versionTitle => 'Versi';

  @override
  String get versionDescription => 'Versi aplikasi saat ini';

  @override
  String get contactButton => 'Kontak';

  @override
  String get reportBugButton => 'Laporkan Bug';

  @override
  String get submitFeedbackButton => 'Kirim Umpan Balik';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Hapus Data?';

  @override
  String get clearDataDialogContent =>
      'Ini akan menghapus semua riwayat dan data terkait. Anda tidak akan dapat memulihkannya. Apakah Anda ingin melanjutkan?';

  @override
  String get clearDataButtonLabel => 'Hapus Data';

  @override
  String get resetSettingsDialogTitle => 'Atur Ulang Pengaturan?';

  @override
  String get resetSettingsDialogContent =>
      'Ini akan mengatur ulang semua pengaturan ke nilai default. Apakah Anda ingin melanjutkan?';

  @override
  String get resetButtonLabel => 'Atur Ulang';

  @override
  String get cancelButton => 'Batal';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Tidak dapat membuka $url';
  }

  @override
  String errorMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get chart_focusTrends => 'Tren Fokus';

  @override
  String get chart_sessionCount => 'Jumlah Sesi';

  @override
  String get chart_avgDuration => 'Rata-rata Durasi';

  @override
  String get chart_totalFocus => 'Total Fokus';

  @override
  String get chart_yAxis_sessions => 'Sesi';

  @override
  String get chart_yAxis_minutes => 'Menit';

  @override
  String get chart_yAxis_value => 'Nilai';

  @override
  String get chart_monthOverMonthChange => 'Perubahan bulan ke bulan: ';

  @override
  String get chart_customRange => 'Rentang Kustom';

  @override
  String get day_monday => 'Senin';

  @override
  String get day_mondayShort => 'Sen';

  @override
  String get day_mondayAbbr => 'Sn';

  @override
  String get day_tuesday => 'Selasa';

  @override
  String get day_tuesdayShort => 'Sel';

  @override
  String get day_tuesdayAbbr => 'Sl';

  @override
  String get day_wednesday => 'Rabu';

  @override
  String get day_wednesdayShort => 'Rab';

  @override
  String get day_wednesdayAbbr => 'Rb';

  @override
  String get day_thursday => 'Kamis';

  @override
  String get day_thursdayShort => 'Kam';

  @override
  String get day_thursdayAbbr => 'Km';

  @override
  String get day_friday => 'Jumat';

  @override
  String get day_fridayShort => 'Jum';

  @override
  String get day_fridayAbbr => 'Jm';

  @override
  String get day_saturday => 'Sabtu';

  @override
  String get day_saturdayShort => 'Sab';

  @override
  String get day_saturdayAbbr => 'Sb';

  @override
  String get day_sunday => 'Minggu';

  @override
  String get day_sundayShort => 'Min';

  @override
  String get day_sundayAbbr => 'Mg';

  @override
  String time_hours(int count) {
    return '${count}j';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count menit';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: ${hours}j ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count jam';
  }

  @override
  String get month_january => 'Januari';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'Februari';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'Maret';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'April';

  @override
  String get month_aprilShort => 'Apr';

  @override
  String get month_may => 'Mei';

  @override
  String get month_mayShort => 'Mei';

  @override
  String get month_june => 'Juni';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'Juli';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'Agustus';

  @override
  String get month_augustShort => 'Agu';

  @override
  String get month_september => 'September';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Oktober';

  @override
  String get month_octoberShort => 'Okt';

  @override
  String get month_november => 'November';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Desember';

  @override
  String get month_decemberShort => 'Des';

  @override
  String get categoryAll => 'Semua';

  @override
  String get categoryProductivity => 'Produktivitas';

  @override
  String get categoryDevelopment => 'Pengembangan';

  @override
  String get categorySocialMedia => 'Media Sosial';

  @override
  String get categoryEntertainment => 'Hiburan';

  @override
  String get categoryGaming => 'Permainan';

  @override
  String get categoryCommunication => 'Komunikasi';

  @override
  String get categoryWebBrowsing => 'Penjelajahan Web';

  @override
  String get categoryCreative => 'Kreatif';

  @override
  String get categoryEducation => 'Pendidikan';

  @override
  String get categoryUtility => 'Utilitas';

  @override
  String get categoryUncategorized => 'Tidak Dikategorikan';

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
  String get appAppleCalendar => 'Kalender';

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
  String get appCalculator => 'Kalkulator';

  @override
  String get appNotes => 'Catatan';

  @override
  String get appSystemPreferences => 'Preferensi Sistem';

  @override
  String get appTaskManager => 'Task Manager';

  @override
  String get appFileExplorer => 'File Explorer';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Memuat aplikasi...';

  @override
  String get loadingData => 'Memuat data...';

  @override
  String get reportsError => 'Kesalahan';

  @override
  String get reportsRetry => 'Coba Lagi';

  @override
  String get backupRestoreSection => 'Cadangan & Pemulihan';

  @override
  String get backupRestoreTitle => 'Cadangan & Pemulihan';

  @override
  String get exportDataTitle => 'Ekspor Data';

  @override
  String get exportDataDescription => 'Buat cadangan semua data Anda';

  @override
  String get importDataTitle => 'Impor Data';

  @override
  String get importDataDescription => 'Pulihkan dari file cadangan';

  @override
  String get exportButton => 'Ekspor';

  @override
  String get importButton => 'Impor';

  @override
  String get closeButton => 'Tutup';

  @override
  String get noButton => 'Tidak';

  @override
  String get shareButton => 'Bagikan';

  @override
  String get exportStarting => 'Memulai ekspor...';

  @override
  String get exportSuccessful =>
      'Ekspor berhasil! File disimpan di Dokumen/TimeMark-Backups';

  @override
  String get exportFailed => 'Ekspor gagal';

  @override
  String get exportComplete => 'Ekspor Selesai';

  @override
  String get shareBackupQuestion =>
      'Apakah Anda ingin membagikan file cadangan?';

  @override
  String get importStarting => 'Memulai impor...';

  @override
  String get importSuccessful => 'Impor berhasil!';

  @override
  String get importFailed => 'Impor gagal';

  @override
  String get importOptionsTitle => 'Opsi Impor';

  @override
  String get importOptionsQuestion => 'Bagaimana Anda ingin mengimpor data?';

  @override
  String get replaceModeTitle => 'Ganti';

  @override
  String get replaceModeDescription => 'Ganti semua data yang ada';

  @override
  String get mergeModeTitle => 'Gabung';

  @override
  String get mergeModeDescription => 'Gabungkan dengan data yang ada';

  @override
  String get appendModeTitle => 'Tambah';

  @override
  String get appendModeDescription => 'Hanya tambahkan catatan baru';

  @override
  String get warningTitle => '⚠️ Peringatan';

  @override
  String get replaceWarningMessage =>
      'Ini akan mengganti SEMUA data Anda yang ada. Apakah Anda yakin ingin melanjutkan?';

  @override
  String get replaceAllButton => 'Ganti Semua';

  @override
  String get fileLabel => 'File';

  @override
  String get sizeLabel => 'Ukuran';

  @override
  String get recordsLabel => 'Catatan';

  @override
  String get usageRecordsLabel => 'Catatan penggunaan';

  @override
  String get focusSessionsLabel => 'Sesi fokus';

  @override
  String get appMetadataLabel => 'Metadata aplikasi';

  @override
  String get updatedLabel => 'Diperbarui';

  @override
  String get skippedLabel => 'Dilewati';

  @override
  String get faqSettingsQ4 =>
      'Bagaimana cara memulihkan atau mengekspor data saya?';

  @override
  String get faqSettingsA4 =>
      'Anda dapat pergi ke pengaturan, dan di sana Anda akan menemukan bagian Cadangan & Pemulihan. Anda dapat mengekspor atau mengimpor data dari sini, perhatikan bahwa file data yang diekspor disimpan di Dokumen pada Folder TimeMark-Backups dan hanya file ini yang dapat digunakan untuk memulihkan data, bukan file lain.';

  @override
  String get faqGeneralQ6 =>
      'Bagaimana cara mengubah bahasa dan bahasa apa yang tersedia, juga bagaimana jika saya menemukan terjemahan yang salah?';

  @override
  String get faqGeneralA6 =>
      'Bahasa dapat diubah melalui bagian Pengaturan Umum, semua bahasa yang tersedia tercantum di sana, Anda dapat meminta terjemahan dengan mengklik Kontak dan mengirim permintaan Anda dengan bahasa yang diberikan. Ketahuilah bahwa terjemahan bisa salah karena dihasilkan oleh AI dari bahasa Inggris dan jika Anda ingin melaporkan maka Anda dapat melaporkan melalui laporkan bug, atau kontak, atau jika Anda seorang pengembang maka buka issue di Github. Kontribusi mengenai bahasa juga diterima!';

  @override
  String get faqGeneralQ7 =>
      'Bagaimana jika saya menemukan terjemahan yang salah?';

  @override
  String get faqGeneralA7 =>
      'Terjemahan bisa salah karena dihasilkan oleh AI dari bahasa Inggris dan jika Anda ingin melaporkan maka Anda dapat melaporkan melalui laporkan bug, atau kontak, atau jika Anda seorang pengembang maka buka issue di Github. Kontribusi mengenai bahasa juga diterima!';

  @override
  String get activityTrackingSection => 'Pelacakan Aktivitas';

  @override
  String get idleDetectionTitle => 'Deteksi Idle';

  @override
  String get idleDetectionDescription => 'Berhenti melacak saat tidak aktif';

  @override
  String get idleTimeoutTitle => 'Batas Waktu Idle';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Waktu sebelum dianggap idle ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Fitur lanjutan dapat meningkatkan penggunaan sumber daya. Aktifkan hanya jika diperlukan.';

  @override
  String get monitorAudioTitle => 'Pantau Audio Sistem';

  @override
  String get monitorAudioDescription =>
      'Deteksi aktivitas dari pemutaran audio';

  @override
  String get audioSensitivityTitle => 'Sensitivitas Audio';

  @override
  String audioSensitivityDescription(String value) {
    return 'Ambang batas deteksi ($value)';
  }

  @override
  String get monitorControllersTitle => 'Pantau Kontroler Game';

  @override
  String get monitorControllersDescription => 'Deteksi kontroler Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Pantau Perangkat HID';

  @override
  String get monitorHIDDescription =>
      'Deteksi roda kemudi, tablet, perangkat khusus';

  @override
  String get setIdleTimeoutTitle => 'Atur Batas Waktu Idle';

  @override
  String get idleTimeoutDialogDescription =>
      'Pilih berapa lama menunggu sebelum menganggap Anda idle:';

  @override
  String get seconds30 => '30 detik';

  @override
  String get minute1 => '1 menit';

  @override
  String get minutes2 => '2 menit';

  @override
  String get minutes5 => '5 menit';

  @override
  String get minutes10 => '10 menit';

  @override
  String get customOption => 'Kustom';

  @override
  String get customDurationTitle => 'Durasi Kustom';

  @override
  String get minutesLabel => 'Menit';

  @override
  String get secondsLabel => 'Detik';

  @override
  String get minAbbreviation => 'mnt';

  @override
  String get secAbbreviation => 'dtk';

  @override
  String totalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String minimumError(String value) {
    return 'Minimum adalah $value';
  }

  @override
  String maximumError(String value) {
    return 'Maksimum adalah $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Rentang: $min - $max';
  }

  @override
  String get saveButton => 'Simpan';

  @override
  String timeFormatSeconds(int seconds) {
    return '${seconds}dtk';
  }

  @override
  String get timeFormatMinute => '1 mnt';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes mnt ${seconds}dtk';
  }
}
