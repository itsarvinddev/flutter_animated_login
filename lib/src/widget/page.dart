import 'package:flutter/material.dart';

import '../utils/gradient_box.dart';
import '../utils/page_config.dart';
import '../utils/theme.dart';

/// Builds a screen's contents, given the space available to it.
typedef PageBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

/// The page every screen in the flow is drawn on: a gradient background and a
/// centred, scrollable card.
class PageWidget extends StatelessWidget {
  /// Creates a page showing what [builder] returns.
  const PageWidget({super.key, this.builder, this.config = const PageConfig()});

  /// Builds the card's contents.
  final PageBuilder? builder;

  /// How the page looks and behaves.
  final PageConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginTheme = AnimatedLoginTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final maxWidth =
            config.cardConstraints?.maxWidth ?? loginTheme.maxCardWidth ?? 600;

        Widget card = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints:
              config.cardConstraints ?? BoxConstraints(maxWidth: maxWidth),
          margin: config.cardMargin ?? EdgeInsets.all(isMobile ? 20 : 40),
          decoration:
              config.cardDecoration ??
              BoxDecoration(
                borderRadius:
                    loginTheme.cardRadius ??
                    const BorderRadius.all(Radius.circular(20)),
                color: loginTheme.cardColor ?? theme.colorScheme.surface,
                boxShadow:
                    isMobile
                        ? null
                        : loginTheme.cardShadow ??
                            <BoxShadow>[
                              // Before 1.0.0 this was opaque black at a 100px
                              // blur, which painted a dark halo over the gradient.
                              BoxShadow(
                                color: theme.shadowColor.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 48,
                                spreadRadius: -8,
                                offset: const Offset(0, 16),
                              ),
                            ],
              ),
          // The card paints its own background, so anything inside that
          // draws ink — a CheckboxListTile for consent, a custom signup field
          // — needs a Material between it and that DecoratedBox. Without one
          // Flutter reports "ListTile background color or ink splashes may be
          // invisible" on every build, and the splashes really are hidden.
          child: Material(
            type: MaterialType.transparency,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding:
                  config.cardPadding ??
                  loginTheme.cardPadding ??
                  EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: isMobile ? 20 : 40,
                  ),
              child: builder?.call(context, constraints),
            ),
          ),
        );

        if (config.pageHeader != null || config.pageFooter != null) {
          card = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (config.pageHeader != null) config.pageHeader!,
              Flexible(child: card),
              if (config.pageFooter != null) config.pageFooter!,
            ],
          );
        }

        // Deliberately NOT SliverFillRemaining(hasScrollBody: false): that
        // sizes the child from getMaxIntrinsicHeight and then lays it out with
        // a *tight* constraint, so any subtree whose intrinsic height
        // under-reports — a Wrap of provider buttons, a CheckboxListTile, a
        // subtitle that wraps — overflows and clips instead of scrolling.
        //
        // ConstrainedBox(minHeight:) inside a SingleChildScrollView centres
        // content that fits and lets taller content grow and scroll, without
        // consulting intrinsics at all.
        Widget content = SingleChildScrollView(
          keyboardDismissBehavior: config.keyboardDismissBehavior,
          physics: config.scrollPhysics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: card),
          ),
        );

        if (config.useSafeArea) content = SafeArea(child: content);

        final body = Stack(
          children: [
            config.background ??
                AnimatedOpacity(
                  opacity: isMobile ? 0.0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: GradientBox(
                    colors:
                        config.colors ??
                        <Color>[
                          loginTheme.backgroundGradientStart ??
                              theme.colorScheme.primary,
                          loginTheme.backgroundGradientEnd ??
                              theme.colorScheme.secondary,
                        ],
                    begin: config.begin,
                    end: config.end,
                  ),
                ),
            content,
          ],
        );

        // Nesting a Scaffold inside the caller's own Scaffold paints a second
        // background and shadows their ScaffoldMessenger. Opt out with
        // PageConfig(useScaffold: false).
        if (!config.useScaffold) return body;

        return Scaffold(
          backgroundColor: config.scaffoldBackgroundColor,
          body: body,
        );
      },
    );
  }
}
