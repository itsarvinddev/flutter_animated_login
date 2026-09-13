import 'package:flutter/material.dart';

/// The gradient painted behind the card on wide windows.
class GradientBox extends StatelessWidget {
  /// Creates a gradient background.
  const GradientBox({
    super.key,
    this.colors = const <Color>[],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.stops,
  });

  /// Where the gradient starts.
  final AlignmentGeometry begin;

  /// Where the gradient ends.
  final AlignmentGeometry end;

  /// The colours to blend. Any number; they are spaced evenly unless [stops]
  /// says otherwise.
  final List<Color> colors;

  /// Where each colour sits along the gradient. Must be the same length as
  /// [colors] when given.
  final List<double>? stops;

  @override
  Widget build(BuildContext context) {
    assert(
      stops == null || stops!.length == colors.length,
      'GradientBox.stops must have the same length as colors '
      '(${stops?.length} != ${colors.length}).',
    );
    if (colors.isEmpty) return const SizedBox.expand();
    // A gradient needs two stops; repeat a lone colour rather than throwing.
    final effective =
        colors.length == 1 ? <Color>[colors.first, colors.first] : colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effective,
          begin: begin,
          end: end,
          // Left null so LinearGradient spaces the colours evenly. Before
          // 1.0.0 this was hardcoded to [0, 1], which threw for any list that
          // was not exactly two colours long.
          stops: stops,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
