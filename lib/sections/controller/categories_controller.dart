import 'package:fluent_ui/fluent_ui.dart';
class AppCategory {
  final String name;
  final List<String> apps;

  const AppCategory({
    required this.name, 
    required this.apps,
  });

  // Method to check if an app belongs to this category
  bool containsApp(String appName) {
    return apps.any(
      (app) => appName.toLowerCase().contains(app.toLowerCase())
    );
  }
}

class AppCategories {
  static final List<AppCategory> categories = [
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
        "Snapchat", "Discord", "Reddit", "WhatsApp", "Messenger"
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
        "Steam", "Epic Games Launcher", "Origin", "Uplay", "Discord", 
        "Minecraft", "League of Legends", "World of Warcraft", 
        "Counter-Strike", "Valorant"
      ],
    ),
    const AppCategory(
      name: "Communication",
      apps: [
        "Zoom", "Skype", "Microsoft Teams", "Google Meet", "FaceTime", 
        "Telegram", "Signal", "Discord Voice"
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

  // Method to categorize an app
  static String categorizeApp(String appName) {
    for (var category in categories) {
      if (category.containsApp(appName)) {
        return category.name;
      }
    }
    return "Uncategorized";
  }

  // Method to get category color (optional, for UI purposes)
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
}

// Example usage in a widget
class AppCategoryWidget extends StatelessWidget {
  final String appName;

  const AppCategoryWidget({Key? key, required this.appName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String category = AppCategories.categorizeApp(appName);
    Color categoryColor = AppCategories.getCategoryColor(category);

    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: categoryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}