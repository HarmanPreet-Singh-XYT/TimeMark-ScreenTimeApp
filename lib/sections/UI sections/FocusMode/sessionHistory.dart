import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class SessionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SessionHistory({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.dateHeader,
                    style: FluentTheme.of(context).typography.caption?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: FluentTheme.of(context)
                              .typography
                              .caption
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.durationHeader,
                    textAlign: TextAlign.right,
                    style: FluentTheme.of(context).typography.caption?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: FluentTheme.of(context)
                              .typography
                              .caption
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Session list
          Expanded(
            child: data.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.history,
                          size: 32,
                          color:
                              FluentTheme.of(context).inactiveBackgroundColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No sessions yet',
                          style: FluentTheme.of(context)
                              .typography
                              .caption
                              ?.copyWith(
                                color: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final session = data[index];
                      return _SessionRow(
                        date: session["date"] ?? '',
                        duration: session["duration"] ?? '',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatefulWidget {
  final String date;
  final String duration;

  const _SessionRow({
    required this.date,
    required this.duration,
  });

  @override
  State<_SessionRow> createState() => _SessionRowState();
}

class _SessionRowState extends State<_SessionRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? FluentTheme.of(context).accentColor.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C50).withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                widget.date,
                style: FluentTheme.of(context).typography.body?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                widget.duration,
                textAlign: TextAlign.right,
                style: FluentTheme.of(context).typography.body?.copyWith(
                      color: FluentTheme.of(context)
                          .typography
                          .body
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
