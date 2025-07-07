
// File: src/utils/responsive.dart
import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  /// Screen size breakpoints
  static const double smallScreenBreakpoint = 600;
  static const double mediumScreenBreakpoint = 900;
  static const double largeScreenBreakpoint = 1200;
  
  /// Check if current screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < smallScreenBreakpoint;
  }
  
  /// Check if current screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenBreakpoint && width < mediumScreenBreakpoint;
  }
  
  /// Check if current screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumScreenBreakpoint;
  }
  
  /// Get appropriate horizontal padding based on screen size
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
  }
  
  /// Get appropriate card width based on screen size
  static double getCardWidth(BuildContext context) {
    if (isSmallScreen(context)) {
      return MediaQuery.of(context).size.width * 0.9;
    } else if (isMediumScreen(context)) {
      return 500;
    } else {
      return 600;
    }
  }
  
  /// Get appropriate card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  /// Get appropriate button size based on screen size
  static double getButtonSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 44;
    } else {
      return 56;
    }
  }
  
  /// Get appropriate font size scaling based on screen size
  static double getFontScaling(BuildContext context) {
    if (isSmallScreen(context)) {
      return 0.9;
    } else if (isMediumScreen(context)) {
      return 1.0;
    } else {
      return 1.1;
    }
  }

  /// Private constructor to prevent instantiation
  ResponsiveUtils._();
}