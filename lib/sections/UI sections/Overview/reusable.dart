import 'package:fluent_ui/fluent_ui.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 32, color: theme.inactiveColor.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: theme.inactiveColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
