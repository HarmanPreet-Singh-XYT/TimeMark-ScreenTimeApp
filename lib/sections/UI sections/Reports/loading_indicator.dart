import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final double? progressRingSize;
  final TextStyle? textStyle;
  
  const LoadingIndicator({
    super.key, 
    required this.message,
    this.progressRingSize = 24.0,
    this.textStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressRing(
            activeColor: FluentTheme.of(context).accentColor,
            strokeWidth: 4.0,
            value: progressRingSize,
          ),
          const SizedBox(height: 16),
          Text(
            message, 
            style: textStyle ?? const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
            semanticsLabel: message,
          ),
        ],
      ),
    );
  }
}

class AppLoadingIndicator extends LoadingIndicator {
  AppLoadingIndicator({
    super.key,
    required BuildContext context,
  }) : super(
    message: AppLocalizations.of(context)!.loadingApplication,
    progressRingSize: 32.0,
  );
}

class DataLoadingIndicator extends LoadingIndicator {
  DataLoadingIndicator({
    super.key,
    required BuildContext context,
  }) : super(
    message: AppLocalizations.of(context)!.loadingData,
    progressRingSize: 20.0,
  );
}