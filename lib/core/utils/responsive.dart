import 'package:flutter/material.dart';

/// A responsive utility that scales dimensions based on the device screen size.
///
/// All designs are based on a standard 375 x 812 canvas (iPhone 13 mini).
/// On larger or smaller devices, values are proportionally scaled so layouts
/// stay visually consistent without hardcoded pixel values.
class Responsive {
  // Design baseline dimensions (iPhone 13 mini / standard mobile mockup)
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  /// Horizontal scale factor (based on screen width vs design width).
  static double sw(BuildContext context) => MediaQuery.of(context).size.width / _designWidth;

  /// Vertical scale factor (based on screen height vs design height).
  static double sh(BuildContext context) => MediaQuery.of(context).size.height / _designHeight;

  /// Screen width in logical pixels.
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  /// Screen height in logical pixels.
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  /// Scale a horizontal dimension (paddings, widths, horizontal spacing).
  /// Clamped between 0.85x and 1.3x to avoid extreme shrinking/stretching.
  static double w(BuildContext context, double value) => value * sw(context).clamp(0.85, 1.3);

  /// Scale a vertical dimension (spacings, heights, vertical padding).
  /// Clamped between 0.8x and 1.3x so small phones shrink spacing gracefully.
  static double h(BuildContext context, double value) => value * sh(context).clamp(0.8, 1.3);

  /// Scale a font size. Clamped tighter (0.85x – 1.15x) so text stays readable
  /// without becoming comically large on tablets.
  static double sp(BuildContext context, double value) => value * sw(context).clamp(0.85, 1.15);

  /// Scale a radius value based on horizontal scale factor.
  static double r(BuildContext context, double value) => value * sw(context).clamp(0.85, 1.3);

  /// True when the screen height is under 700 logical pixels (small phones).
  static bool isSmallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;

  /// True when the screen height is over 900 logical pixels (large phones / tablets).
  static bool isLargeScreen(BuildContext context) => MediaQuery.of(context).size.height > 900;
}
