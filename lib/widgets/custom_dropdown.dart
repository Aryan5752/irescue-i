// custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? errorText;
  final bool isExpanded;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final InputDecoration? decoration;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.isExpanded = true,
    this.isDense = false,
    this.contentPadding,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.decoration,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final defaultDecoration = InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      errorText: widget.errorText,
      prefixIcon: widget.prefix,
      suffixIcon: widget.suffix,
      contentPadding: widget.contentPadding,
      border: const OutlineInputBorder(),
    );
    
    final decoration = widget.decoration ?? defaultDecoration;
    
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    item.icon!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          style: item.textStyle ?? theme.textTheme.bodyMedium,
                        ),
                        if (item.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description!,
                            style: item.descriptionStyle ??
                                theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      isExpanded: widget.isExpanded,
      isDense: widget.isDense,
      decoration: decoration,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 2,
      style: theme.textTheme.bodyMedium,
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;
  final String? description;
  final Widget? icon;
  final TextStyle? textStyle;
  final TextStyle? descriptionStyle;
  final Color? color;

  const DropdownItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.textStyle,
    this.descriptionStyle,
    this.color,
  });
}