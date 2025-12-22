import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final IconData? icon;
  final String? retryText;
  
  const ErrorDisplay({
    super.key, 
    required this.errorMessage, 
    required this.onRetry,
    this.icon = FluentIcons.error,
    this.retryText,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              errorMessage, 
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              semanticsLabel: '${l10n.reportsError}: $errorMessage',
            ),
          ),
          const SizedBox(height: 24),
          Button(
            onPressed: onRetry,
            child: Text(retryText ?? l10n.reportsRetry),
          ),
        ],
      ),
    );
  }
}