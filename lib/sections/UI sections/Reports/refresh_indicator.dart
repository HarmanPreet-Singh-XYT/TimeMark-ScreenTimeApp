import 'package:flutter/material.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'loading_indicator.dart';
import 'error_display.dart';

class AnalyticsProxyWidget extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget header;
  final bool isLoading;
  final String? error;
  final List<Widget> analyticsContent;
  final VoidCallback onRetry;

  const AnalyticsProxyWidget({
    super.key,
    required this.onRefresh,
    required this.header,
    required this.isLoading,
    this.error,
    required this.analyticsContent,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              header,
              const SizedBox(height: 20),
              
              if (isLoading)
                LoadingIndicator(message: l10n.loadingAnalyticsData)
              else if (error != null)
                ErrorDisplay(
                  errorMessage: error!,
                  onRetry: onRetry,
                )
              else
                ...analyticsContent,
            ],
          ),
        ),
      ),
    );
  }
}