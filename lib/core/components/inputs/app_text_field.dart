import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Production-ready form text field for the ClientSphere CRM.
///
/// Features support for required asterisks, helper/error messages, prefix/suffix
/// slots, password visibility toggle, accessible semantics, and Material 3
/// styling.
class AppTextField extends StatefulWidget {
  /// Optional label displayed above the field.
  final String? label;

  /// Placeholder hint text displayed inside the field when empty.
  final String? hint;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Validation error text displayed below the field.
  final String? errorText;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Initial text value when a controller is not provided.
  final String? initialValue;

  /// Focus node for managing focus state.
  final FocusNode? focusNode;

  /// Keyboard type (e.g. email, phone, number, multiline).
  final TextInputType keyboardType;

  /// Action key on keyboard (e.g. next, done, search).
  final TextInputAction? textInputAction;

  /// Whether the input should be obscured (passwords/PINs).
  final bool obscureText;

  /// Whether to show an interactive eye icon to toggle password visibility.
  final bool enablePasswordToggle;

  /// Whether the input is editable.
  final bool enabled;

  /// Whether the field is read-only (focusable, but non-editable).
  final bool readOnly;

  /// Whether to autofocus this field on display.
  final bool autofocus;

  /// Maximum number of lines. Defaults to 1.
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Optional leading icon or widget.
  final Widget? prefixIcon;

  /// Optional trailing icon or widget.
  final Widget? suffixIcon;

  /// Whether this field is mandatory in a form (displays an indicator asterisk).
  final bool isRequired;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the keyboard action button is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the input is tapped.
  final VoidCallback? onTap;

  /// Optional form field validator function.
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (widget.enablePasswordToggle) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
        onPressed: widget.enabled ? _togglePasswordVisibility : null,
      );
    }

    final fieldWidget = TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      style: textTheme.bodyLarge?.copyWith(
        color: widget.enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffixIcon,
        contentPadding: AppSpacing.inputPadding,
      ),
    );

    if (widget.label == null) {
      return fieldWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              widget.label!,
              style: textTheme.labelLarge?.copyWith(
                color: widget.enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
            if (widget.isRequired) ...[
              AppSpacing.gapW4,
              Text(
                '*',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        AppSpacing.gapH8,
        fieldWidget,
      ],
    );
  }
}
