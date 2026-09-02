import 'package:flutter/material.dart';

/// Standard border-radius tokens for ClientSphere CRM.
///
/// Standardizes corner roundness across interactive inputs, cards, dialogs,
/// bottom sheets, and status indicators.
abstract final class AppRadius {
  // --- Raw Dimensional Tokens ---
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double pill = 999.0;

  // --- Radius Objects ---
  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusPill = Radius.circular(pill);

  // --- BorderRadius Shortcuts ---
  static const BorderRadius allXs = BorderRadius.all(radiusXs);
  static const BorderRadius allSm = BorderRadius.all(radiusSm);
  static const BorderRadius allMd = BorderRadius.all(radiusMd);
  static const BorderRadius allLg = BorderRadius.all(radiusLg);
  static const BorderRadius allXl = BorderRadius.all(radiusXl);
  static const BorderRadius allPill = BorderRadius.all(radiusPill);

  // --- Sheet & Modal Specific Corners ---
  static const BorderRadius topLg = BorderRadius.only(
    topLeft: radiusLg,
    topRight: radiusLg,
  );
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: radiusXl,
    topRight: radiusXl,
  );

  // --- Shape Outlines for Material Components ---
  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(
    borderRadius: allSm,
  );
  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: allMd,
  );
  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(
    borderRadius: allLg,
  );
  static const RoundedRectangleBorder shapePill = RoundedRectangleBorder(
    borderRadius: allPill,
  );
}
