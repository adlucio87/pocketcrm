import 'package:flutter/material.dart';

/// Lightweight responsive utility for adapting layouts between
/// phone and tablet form factors.
class Responsive {
  Responsive._();

  /// Tablet breakpoint: shortest side >= 600dp (standard Material 3).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  /// Max content width on tablets to avoid over-stretched layouts.
  static double contentMaxWidth(BuildContext context) =>
      isTablet(context) ? 700.0 : double.infinity;

  /// Symmetric horizontal padding – wider on tablets.
  static EdgeInsets contentPadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: isTablet(context) ? 32.0 : 16.0);

  /// Constraints for bottom sheets – narrower on tablets.
  static BoxConstraints bottomSheetConstraints(BuildContext context) =>
      isTablet(context)
          ? const BoxConstraints(maxWidth: 500)
          : const BoxConstraints();
}
