import 'package:flutter/material.dart';

/// Carries the app's light/dark preference down the tree.
///
/// Built the same way `flutter_animated_login` builds its own
/// `AnimatedLoginScope`: an [InheritedNotifier] over a [ChangeNotifier], so
/// any widget that reads it rebuilds when the value changes.
class ThemeModeScope extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  /// Wraps [child] so it can reach [mode].
  const ThemeModeScope({
    super.key,
    required ValueNotifier<ThemeMode> mode,
    required super.child,
  }) : super(notifier: mode);

  /// The nearest enclosing theme-mode notifier.
  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    assert(scope != null, 'No ThemeModeScope above this widget.');
    return scope!.notifier!;
  }
}

/// An app-bar button that flips the whole app between light and dark.
///
/// Every demo shows one, because an [AnimatedLoginTheme] has to look right in
/// both.
class ThemeModeButton extends StatelessWidget {
  /// Creates the toggle.
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = ThemeModeScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => mode.value = isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
