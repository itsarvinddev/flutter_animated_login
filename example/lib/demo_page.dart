import 'package:flutter/material.dart';

import 'theme_mode_scope.dart';

/// One line in a demo's result panel.
@immutable
class DemoEvent {
  /// Records [message]; [ok] decides which icon it gets.
  const DemoEvent(this.message, {this.ok = true});

  /// What happened, in the user's words.
  final String message;

  /// Whether it was a success.
  final bool ok;
}

/// Collects what a demo's fake backend was asked to do.
///
/// Demos write here instead of calling `print`, so the payload a callback
/// received is visible in the running app — which is the whole point of a
/// demo.
class DemoEventLog extends ChangeNotifier {
  final List<DemoEvent> _events = <DemoEvent>[];
  bool _disposed = false;

  /// Every event, newest first.
  List<DemoEvent> get events => List<DemoEvent>.unmodifiable(_events);

  /// Records something that worked.
  void success(String message) => _add(DemoEvent(message));

  /// Records something that failed.
  void failure(String message) => _add(DemoEvent(message, ok: false));

  /// Forgets every event.
  void clear() {
    _events.clear();
    _safeNotify();
  }

  void _add(DemoEvent event) {
    _events.insert(0, event);
    _safeNotify();
  }

  // A request can still be in flight when the user pops the route, so guard
  // the notification the same way the package guards its own.
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// The frame every demo shares.
///
/// An app bar with the light/dark toggle, the login flow itself, an optional
/// [footer] for demo-specific controls, and the result panel that replaces
/// `print`.
class DemoPage extends StatelessWidget {
  /// Creates the frame around [child].
  const DemoPage({
    super.key,
    required this.title,
    required this.log,
    required this.child,
    this.footer,
  });

  /// Shown in the app bar.
  final String title;

  /// Where this demo reports its results.
  final DemoEventLog log;

  /// The login flow being demonstrated.
  final Widget child;

  /// Demo-specific controls, rendered between [child] and the result panel.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const <Widget>[ThemeModeButton()],
      ),
      // The login widget is told not to build its own Scaffold — see
      // PageConfig.useScaffold — so it sits inside this one without nesting
      // two ScaffoldMessengers.
      body: Column(
        children: <Widget>[
          Expanded(child: child),
          if (footer != null) footer!,
          DemoResultPanel(log: log),
        ],
      ),
    );
  }
}

/// Shows what the fake backend did, newest first.
class DemoResultPanel extends StatelessWidget {
  /// Creates a panel bound to [log].
  const DemoResultPanel({super.key, required this.log});

  /// The log to render.
  final DemoEventLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: log,
      builder: (context, _) {
        final events = log.events;
        return Material(
          color: theme.colorScheme.surfaceContainerHighest,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Result',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      if (events.isNotEmpty)
                        TextButton(
                          onPressed: log.clear,
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 132),
                    child:
                        events.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Submit the form — what the fake backend '
                                'received shows up here.',
                                style: theme.textTheme.bodySmall,
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 8),
                              itemCount: events.length,
                              itemBuilder:
                                  (context, index) =>
                                      _EventTile(event: events[index]),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final DemoEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        event.ok ? theme.colorScheme.primary : theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            event.ok ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              event.message,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
