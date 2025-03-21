import 'package:fluent_ui/fluent_ui.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final double? progressRingSize;
  final TextStyle? textStyle;
  
  const LoadingIndicator({
    Key? key, 
    required this.message,
    this.progressRingSize = 24.0,
    this.textStyle,
  }) : super(key: key);
  
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
  AppLoadingIndicator({
    Key? key,
    String message = 'Loading application...',
  }) : super(
    key: key,
    message: message,
    progressRingSize: 32.0,
  );
}

class DataLoadingIndicator extends LoadingIndicator {
  DataLoadingIndicator({
    Key? key,
    String message = 'Loading data...',
  }) : super(
    key: key,
    message: message,
    progressRingSize: 20.0,
  );
}