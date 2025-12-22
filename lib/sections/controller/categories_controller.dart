import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class AppCategory {
  final String name; // Keep English name for internal identification
  final List<String> apps;

  const AppCategory({
    required this.name, 
    required this.apps,
  });

  // Get localized display name
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case "All":
        return l10n.categoryAll;
      case "Productivity":
        return l10n.categoryProductivity;
      case "Development":
        return l10n.categoryDevelopment;
      case "Social Media":
        return l10n.categorySocialMedia;
      case "Entertainment":
        return l10n.categoryEntertainment;
      case "Gaming":
        return l10n.categoryGaming;
      case "Communication":
        return l10n.categoryCommunication;
      case "Web Browsing":
        return l10n.categoryWebBrowsing;
      case "Creative":
        return l10n.categoryCreative;
      case "Education":
        return l10n.categoryEducation;
      case "Utility":
        return l10n.categoryUtility;
      case "Uncategorized":
        return l10n.categoryUncategorized;
      default:
        return name;
    }
  }

  // Method to check if an app belongs to this category
  // Now checks against localized app names too
  bool containsApp(String appName, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Check against English names
    bool matchesEnglish = apps.any(
      (app) => appName.toLowerCase().contains(app.toLowerCase())
    );
    
    if (matchesEnglish) return true;
    
    // Check against localized app names
    for (var app in apps) {
      String localizedAppName = _getLocalizedAppName(app, l10n);
      if (appName.toLowerCase().contains(localizedAppName.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }

  // Get localized app name
  static String _getLocalizedAppName(String appName, AppLocalizations l10n) {
    // Map English app names to their localized versions
    switch (appName) {
      // Productivity
      case "Microsoft Word":
        return l10n.appMicrosoftWord;
      case "Excel":
        return l10n.appExcel;
      case "PowerPoint":
        return l10n.appPowerPoint;
      case "Google Docs":
        return l10n.appGoogleDocs;
      case "Notion":
        return l10n.appNotion;
      case "Evernote":
        return l10n.appEvernote;
      case "Trello":
        return l10n.appTrello;
      case "Asana":
        return l10n.appAsana;
      case "Slack":
        return l10n.appSlack;
      case "Microsoft Teams":
        return l10n.appMicrosoftTeams;
      case "Zoom":
        return l10n.appZoom;
      case "Google Calendar":
        return l10n.appGoogleCalendar;
      case "Apple Calendar":
        return l10n.appAppleCalendar;
      
      // Development
      case "Visual Studio Code":
        return l10n.appVisualStudioCode;
      case "Terminal":
        return l10n.appTerminal;
      case "Command Prompt":
        return l10n.appCommandPrompt;
      
      // Web Browsing
      case "Chrome":
        return l10n.appChrome;
      case "Firefox":
        return l10n.appFirefox;
      case "Safari":
        return l10n.appSafari;
      case "Edge":
        return l10n.appEdge;
      case "Opera":
        return l10n.appOpera;
      case "Brave":
        return l10n.appBrave;
      
      // Entertainment
      case "Netflix":
        return l10n.appNetflix;
      case "YouTube":
        return l10n.appYouTube;
      case "Spotify":
        return l10n.appSpotify;
      case "Apple Music":
        return l10n.appAppleMusic;
      
      // Utility
      case "Calculator":
        return l10n.appCalculator;
      case "Notes":
        return l10n.appNotes;
      case "System Preferences":
        return l10n.appSystemPreferences;
      case "Task Manager":
        return l10n.appTaskManager;
      case "File Explorer":
        return l10n.appFileExplorer;
      case "Dropbox":
        return l10n.appDropbox;
      case "Google Drive":
        return l10n.appGoogleDrive;
      
      // Default: return original name if no translation
      default:
        return appName;
    }
  }
}

class AppCategories {
  static final List<AppCategory> categories = [
    const AppCategory(
      name: "All",
      apps: [],
    ),
    const AppCategory(
      name: "Productivity",
      apps: [
        "Microsoft Word", "Excel", "PowerPoint", "Google Docs", "Notion", 
        "Evernote", "Trello", "Asana", "Slack", "Microsoft Teams", 
        "Zoom", "Google Calendar", "Apple Calendar"
      ],
    ),
    const AppCategory(
      name: "Development",
      apps: [
        "Visual Studio Code", "IntelliJ IDEA", "PyCharm", "Xcode", 
        "Eclipse", "Android Studio", "Sublime Text", "GitHub Desktop", 
        "Terminal", "Command Prompt", "iTerm"
      ],
    ),
    const AppCategory(
      name: "Social Media",
      apps: [
        "Facebook", "Instagram", "Twitter", "LinkedIn", "TikTok", 
        "Snapchat", "Reddit", "WhatsApp", "Messenger"
      ],
    ),
    const AppCategory(
      name: "Entertainment",
      apps: [
        "Netflix", "YouTube", "Spotify", "Apple Music", "Amazon Prime Video", 
        "Hulu", "Disney+", "Twitch", "VLC Media Player", "Plex"
      ],
    ),
    const AppCategory(
      name: "Gaming",
      apps: [
        "Steam", "Epic Games Launcher", "Origin", "Uplay", 
        "Minecraft", "League of Legends", "World of Warcraft", 
        "Counter-Strike", "Valorant"
      ],
    ),
    const AppCategory(
      name: "Communication",
      apps: [
        "Zoom", "Skype", "Microsoft Teams", "Google Meet", "FaceTime", 
        "Telegram", "Signal", "Discord"
      ],
    ),
    const AppCategory(
      name: "Web Browsing",
      apps: [
        "Chrome", "Firefox", "Safari", "Edge", "Opera", 
        "Brave", "Vivaldi"
      ],
    ),
    const AppCategory(
      name: "Creative",
      apps: [
        "Adobe Photoshop", "Illustrator", "Premiere Pro", "Final Cut Pro", 
        "Blender", "Lightroom", "Figma", "Sketch", "InDesign"
      ],
    ),
    const AppCategory(
      name: "Education",
      apps: [
        "Coursera", "edX", "Udemy", "Khan Academy", "Duolingo", 
        "Grammarly", "Kindle", "Audible"
      ],
    ),
    const AppCategory(
      name: "Utility",
      apps: [
        "Calculator", "Notes", "Terminal", "System Preferences", 
        "Task Manager", "File Explorer", "Dropbox", "Google Drive"
      ],
    ),
  ];

  // Method to categorize an app (checks against both English and localized names)
  static String categorizeApp(String appName, [BuildContext? context]) {
    for (var category in categories) {
      if (context != null) {
        if (category.containsApp(appName, context)) {
          return category.name;
        }
      } else {
        // Fallback to English-only matching when context is not available
        if (category.apps.any((app) => appName.toLowerCase().contains(app.toLowerCase()))) {
          return category.name;
        }
      }
    }
    return "Uncategorized";
  }

  // Get localized category name
  static String getLocalizedCategoryName(String categoryName, BuildContext context) {
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => const AppCategory(name: "Uncategorized", apps: []),
    );
    return category.getLocalizedName(context);
  }

  // Method to get category color
  static Color getCategoryColor(String categoryName) {
    switch (categoryName) {
      case "Productivity":
        return Colors.blue;
      case "Development":
        return Colors.green;
      case "Social Media":
        return Colors.purple;
      case "Entertainment":
        return Colors.red;
      case "Gaming":
        return Colors.orange;
      case "Communication":
        return Colors.teal;
      case "Web Browsing":
        return Colors.grey;
      case "Creative":
        return Colors.yellow;
      case "Education":
        return Colors.successPrimaryColor;
      case "Utility":
        return Colors.warningPrimaryColor;
      default:
        return Colors.grey[500];
    }
  }

  // Get all category names for dropdown/filter
  static List<String> getCategoryNames() {
    return categories.map((cat) => cat.name).toList();
  }

  // Get localized category names for dropdown/filter
  static List<String> getLocalizedCategoryNames(BuildContext context) {
    return categories.map((cat) => cat.getLocalizedName(context)).toList();
  }
}

// Updated widget with localization
class AppCategoryWidget extends StatelessWidget {
  final String appName;

  const AppCategoryWidget({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    String categoryName = AppCategories.categorizeApp(appName, context);
    String localizedName = AppCategories.getLocalizedCategoryName(categoryName, context);
    Color categoryColor = AppCategories.getCategoryColor(categoryName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        localizedName,
        style: TextStyle(
          color: categoryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}