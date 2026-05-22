import 'package:flutter/material.dart';

/// Shared responsive breakpoints and grid delegates used by the
/// Categories / Providers / Favorites / Search screens, so a 10" tablet gets
/// a proper multi-column layout instead of a stretched 2-column mobile grid.
class AppBreakpoints {
  AppBreakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// Maximum width the centered content column may grow to on large screens.
  /// Keeps cards from stretching edge-to-edge on very wide tablets / desktop.
  static const double maxContent = 1400;
}

bool isTabletWidth(double w) => w >= AppBreakpoints.tablet;

/// Grid delegate for the Categories grid.
///
/// - Mobile (<600): keep the original 2-column layout.
/// - Tablet+: use `maxCrossAxisExtent` so the column count grows with width
///   (3 cols at 10", 4 cols at wider). `mainAxisExtent` gives the cards a
///   compact fixed height (~130 px) — no more huge empty boxes.
SliverGridDelegate categoryGridDelegate(double w) {
  if (isTabletWidth(w)) {
    return const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 320,
      mainAxisExtent: 130,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
    );
  }
  return const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.05,
  );
}

/// Grid delegate for the provider lists (Providers, Category Providers,
/// Favorites, Search).
///
/// - Mobile (<600): keep the original 2-column / 0.72 aspect.
/// - Tablet+: cap each cell at ~380 px wide and ~310 px tall via
///   `mainAxisExtent`, so cards don't stretch into oversized rectangles
///   with huge empty white areas under the text.
SliverGridDelegate providerGridDelegate(double w) {
  if (isTabletWidth(w)) {
    return const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 380,
      mainAxisExtent: 310,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
    );
  }
  return const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.72,
  );
}
