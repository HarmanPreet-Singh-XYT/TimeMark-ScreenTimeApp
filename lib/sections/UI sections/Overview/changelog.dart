import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

class ChangelogModal {
  static const String _lastShownVersionKey = 'last_shown_changelog_version';

  /// Check if changelog should be shown and display it if needed
  static Future<void> showIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';
      final lastShownVersion = prefs.getString(_lastShownVersionKey);

      // OPTIMIZATION: Only proceed if this is a new version
      // This check happens BEFORE any API call
      if (lastShownVersion == null || lastShownVersion != currentVersion) {
        debugPrint(
            '📱 Changelog: New version detected - $currentVersion (last shown: $lastShownVersion)');
        debugPrint('🌐 Changelog: Fetching from GitHub API...');

        final releaseData = await _fetchReleaseData(currentVersion);

        if (releaseData != null && context.mounted) {
          debugPrint(
              '✅ Changelog: Found for version $currentVersion, displaying to user');
          await _showChangelogDialog(context, releaseData);
          // Mark this version as shown
          await prefs.setString(_lastShownVersionKey, currentVersion);
          debugPrint('💾 Changelog: Saved version $currentVersion as shown');
        } else {
          debugPrint(
              '⚠️ Changelog: No release found for version $currentVersion on GitHub');
        }
      } else {
        debugPrint(
            '✓ Changelog: Version $currentVersion already shown, skipping (no API call)');
      }
    } catch (e) {
      debugPrint('❌ Changelog Error: $e');
      // Silently fail - don't interrupt user experience
    }
  }

  /// Manually show changelog (for settings menu option)
  static Future<void> showManually(BuildContext context) async {
    try {
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';
      final releaseData = await _fetchReleaseData(currentVersion);

      if (releaseData != null && context.mounted) {
        await _showChangelogDialog(context, releaseData);
      } else if (context.mounted) {
        await _showErrorDialog(context);
      }
    } catch (e) {
      debugPrint('Error showing changelog manually: $e');
      if (context.mounted) {
        await _showErrorDialog(context);
      }
    }
  }

  // More efficient — single release fetch, no pagination issues
  static Future<Map<String, dynamic>?> _fetchReleaseData(String version) async {
    try {
      final tagName = version.startsWith('v') ? version : 'v$version';

      // Fetch the specific release by tag — no risk of missing it due to pagination
      final response = await http
          .get(Uri.parse('https://api.github.com/repos/HarmanPreet-Singh-XYT/'
              'Scolect-ScreenTimeApp/releases/tags/$tagName'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        return {
          'tag_name': release['tag_name'],
          'name': release['name'],
          'body': release['body'],
          'published_at': release['published_at'],
          'html_url': release['html_url'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching release data: $e');
      return null;
    }
  }

  /// Show the changelog dialog
  static Future<void> _showChangelogDialog(
    BuildContext context,
    Map<String, dynamic> releaseData,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FluentIcons.rocket,
                color: theme.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's New",
                    style: theme.typography.subtitle,
                  ),
                  Text(
                    releaseData['name'] ?? releaseData['tag_name'],
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.inactiveColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReleaseDate(context, releaseData['published_at']),
              const SizedBox(height: 16),
              _buildChangelogContent(context, releaseData['body']),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(l10n.continueButton ?? 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build release date widget
  static Widget _buildReleaseDate(BuildContext context, String? publishedAt) {
    if (publishedAt == null) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);
    final date = DateTime.parse(publishedAt);
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.calendar,
            size: 14,
            color: theme.accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Released on $formattedDate',
            style: TextStyle(
              fontSize: 12,
              color: theme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build changelog content with formatted text
  static Widget _buildChangelogContent(BuildContext context, String? body) {
    if (body == null || body.isEmpty) {
      return const Text('No changelog available for this version.');
    }

    final theme = FluentTheme.of(context);
    final lines = body.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Bullet points
      if (line.startsWith('-') || line.startsWith('•')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Headers
      else if (line.startsWith('#')) {
        final headerText = line.replaceAll('#', '').trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              headerText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.accentColor,
              ),
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Show error dialog when changelog can't be loaded
  static Future<void> _showErrorDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(
              FluentIcons.error_badge,
              color: Colors.warningPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Unable to Load Changelog'),
          ],
        ),
        content: const Text(
          'Could not retrieve the changelog for this version. '
          'Please check your internet connection or visit the GitHub releases page.',
        ),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  /// Reset the shown version (for testing purposes)
  static Future<void> resetShownVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastShownVersionKey);
  }

  /// Get the last shown version
  static Future<String?> getLastShownVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastShownVersionKey);
  }
}
