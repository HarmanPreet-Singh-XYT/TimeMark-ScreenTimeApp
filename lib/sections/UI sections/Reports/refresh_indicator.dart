// analytics_proxy_widget.dart
import 'package:flutter/material.dart';
import 'loading_indicator.dart'; // Assuming you have this widget
import 'error_display.dart'; // Assuming you have this widget

class AnalyticsProxyWidget extends StatelessWidget {
  final Future<void> Function() onRefresh; // Function to refresh data
  final Widget header; // Header widget
  final bool isLoading; // Loading state
  final String? error; // Error message
  final List<Widget> analyticsContent; // Analytics content widgets
  final VoidCallback onRetry; // Function to retry loading data

  const AnalyticsProxyWidget({
    Key? key,
    required this.onRefresh,
    required this.header,
    required this.isLoading,
    this.error,
    required this.analyticsContent,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Enables pull-to-refresh
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header with period selector
              header,
              const SizedBox(height: 20),
              
              if (isLoading)
                const LoadingIndicator(message: 'Loading analytics data...')
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