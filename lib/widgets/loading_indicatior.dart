// loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;
  final Color? backgroundColor;
  final Color? progressColor;
  final double size;
  final double strokeWidth;
  final bool withScaffold;
  final Widget? child;

  const LoadingIndicator({
    super.key,
    this.message,
    this.overlay = false,
    this.backgroundColor,
    this.progressColor,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.withScaffold = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: progressColor != null
                ? AlwaysStoppedAnimation<Color>(progressColor!)
                : null,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    // With scaffold for full page loading
    if (withScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: loadingWidget,
        ),
      );
    }

    // Overlay loading on top of content
    if (overlay && child != null) {
      return Stack(
        children: [
          child!,
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: loadingWidget,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Simple centered loading indicator
    return Center(
      child: loadingWidget,
    );
  }

  // Factory for inline loading
  factory LoadingIndicator.inline({
    String? message,
    Color? progressColor,
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return LoadingIndicator(
      message: message,
      progressColor: progressColor,
      size: size,
      strokeWidth: strokeWidth,
    );
  }

  // Factory for overlay loading
  factory LoadingIndicator.overlay({
    required Widget child,
    String? message,
    Color? backgroundColor = Colors.black54,
    Color? progressColor,
  }) {
    return LoadingIndicator(
      message: message,
      overlay: true,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      child: child,
    );
  }

  // Factory for full page loading
  factory LoadingIndicator.fullPage({
    String? message,
    Color? backgroundColor,
    Color? progressColor,
  }) {
    return LoadingIndicator(
      message: message,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      withScaffold: true,
    );
  }
}