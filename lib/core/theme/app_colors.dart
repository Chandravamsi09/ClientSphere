import 'package:flutter/material.dart';

/// Semantic and palette color tokens for the ClientSphere CRM application.
///
/// Provides a unified color foundation supporting both Light and Dark themes,
/// along with enterprise CRM status and pipeline stage identifiers.
abstract final class AppColors {
  // --- Primary Brand Colors (Enterprise Trust Blue) ---
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color primaryContainerLight = Color(0xFFDBEAFE);
  static const Color onPrimaryContainerLight = Color(0xFF1E3A8A);
  static const Color primaryContainerDark = Color(0xFF1E3A8A);
  static const Color onPrimaryContainerDark = Color(0xFFDBEAFE);

  // --- Secondary Accent Colors (Teal / Precision Accent) ---
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF042F2E);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color secondaryContainerLight = Color(0xFFCCFBF1);
  static const Color onSecondaryContainerLight = Color(0xFF115E59);
  static const Color secondaryContainerDark = Color(0xFF134E4A);
  static const Color onSecondaryContainerDark = Color(0xFF99F6E4);

  // --- Light Theme Neutral & Surface Tokens ---
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // --- Dark Theme Neutral & Surface Tokens ---
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF0F172A);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderSubtle = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // --- CRM Semantic & Operational Status Tokens ---
  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainerLight = Color(0xFFDCFCE7);
  static const Color onSuccessContainerLight = Color(0xFF14532D);
  static const Color successContainerDark = Color(0xFF14532D);
  static const Color onSuccessContainerDark = Color(0xFFBBF7D0);

  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainerLight = Color(0xFFFEF3C7);
  static const Color onSuccessWarningLight = Color(0xFF78350F);
  static const Color warningContainerDark = Color(0xFF78350F);
  static const Color onWarningContainerDark = Color(0xFFFDE68A);

  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFEE2E2);
  static const Color onErrorContainerLight = Color(0xFF7F1D1D);
  static const Color errorContainerDark = Color(0xFF7F1D1D);
  static const Color onErrorContainerDark = Color(0xFFFECACA);

  static const Color info = Color(0xFF2563EB);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainerLight = Color(0xFFEFF6FF);
  static const Color onInfoContainerLight = Color(0xFF1E3A8A);
  static const Color infoContainerDark = Color(0xFF1E3A8A);
  static const Color onInfoContainerDark = Color(0xFFBFDBFE);

  // --- CRM Deal Pipeline Stage Colors ---
  static const Color stageLead = Color(0xFF6366F1);
  static const Color stageQualified = Color(0xFF0284C7);
  static const Color stageProposal = Color(0xFFD97706);
  static const Color stageNegotiation = Color(0xFF9333EA);
  static const Color stageWon = Color(0xFF16A34A);
  static const Color stageLost = Color(0xFFDC2626);
}
