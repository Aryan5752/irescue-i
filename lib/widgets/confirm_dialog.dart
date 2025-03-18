// confirm_dialog.dart
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? icon;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            if (onCancel != null) {
              onCancel!();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: cancelColor,
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? (isDestructive ? Colors.red : null),
            foregroundColor: isDestructive ? Colors.white : null,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  // Show dialog and return result
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? icon,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: icon,
        isDestructive: isDestructive,
      ),
    );
  }
}