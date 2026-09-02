import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../buttons/app_icon_button.dart';

/// Search input component with built-in native debouncing and clear action.
///
/// Designed for CRM list filtering (Leads, Deals, Accounts, Contacts) without
/// pulling in any third-party reactive or utility libraries.
class AppSearchField extends StatefulWidget {
  /// Custom placeholder hint text. Defaults to 'Search...'.
  final String hint;

  /// External text editing controller. If omitted, an internal one is managed.
  final TextEditingController? controller;

  /// Focus node to manage search focus.
  final FocusNode? focusNode;

  /// Callback fired after [debounceDuration] when search query changes.
  final ValueChanged<String>? onChanged;

  /// Callback fired immediately when user taps keyboard search action.
  final ValueChanged<String>? onSubmitted;

  /// Callback fired when the search query is cleared via clear button.
  final VoidCallback? onClear;

  /// Debounce delay before invoking [onChanged]. Defaults to 300ms.
  final Duration debounceDuration;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether the field should automatically receive focus.
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      if (widget.controller != null) {
        if (_ownsController) {
          _controller.dispose();
          _ownsController = false;
        }
        _controller = widget.controller!;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _hasText = _controller.text.isNotEmpty;
      _controller.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_handleTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged?.call(_controller.text);
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: textTheme.bodyLarge?.copyWith(
        color: widget.enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: widget.enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        suffixIcon: _hasText && widget.enabled
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: AppIconButton(
                  icon: Icons.close_rounded,
                  size: 32,
                  iconSize: 18,
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                ),
              )
            : null,
        contentPadding: AppSpacing.inputPadding,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.allPill,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allPill,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allPill,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
