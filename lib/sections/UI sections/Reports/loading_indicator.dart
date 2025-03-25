import 'package:fluent_ui/fluent_ui.dart';

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

// For specific loading states, you might want to use these factory constructors:
class AppLoadingIndicator extends LoadingIndicator {
  const AppLoadingIndicator({
    super.key,
    super.message = 'Loading application...',
  }) : super(
    progressRingSize: 32.0,
  );
}

class DataLoadingIndicator extends LoadingIndicator {
  const DataLoadingIndicator({
    super.key,
    super.message = 'Loading data...',
  }) : super(
    progressRingSize: 20.0,
  );
}