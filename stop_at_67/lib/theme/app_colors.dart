import 'package:flutter/material.dart';

/// Centralized color palette for Stop at 67.
/// All screens and widgets must reference these tokens instead of inline hex literals.
abstract final class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────
  static const Color darkPrimary   = Color(0xFF07070F); // main scaffold bg (deep black-blue)
  static const Color darkSecondary = Color(0xFF180828); // gradient midpoint (rich purple)
  static const Color darkCard      = Color(0xFF1A1A2E); // cards, list tiles, dialogs
  static const Color darkElevated  = Color(0xFF2A2A3E); // secondary buttons, chips
  static const Color darkPurple    = Color(0xFF2D0A5E); // vivid purple glow center

  // ── Primary accent (orange) ──────────────────────────────────
  static const Color orange        = Color(0xFFFF6B35); // CTA buttons, borders, active states
  static const Color orangeLight   = Color(0xFFFF9B65); // avatar gradient end, hover

  // ── Gold accents ─────────────────────────────────────────────
  static const Color gold          = Color(0xFFFFD700); // coins, rank #1, daily reward, badges
  static const Color goldWarm      = Color(0xFFF5B841); // timer glow base
  static const Color goldDark      = Color(0xFFD89E2E); // gradient stop (reserved)

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = Colors.white;       // headings, values
  static const Color textSecondary = Color(0xFFBFC3D9);  // replaces white70
  static const Color textDisabled  = Color(0xFF6C728A);  // replaces white38 / white24 / white54
  static const Color textHint      = Color(0xFF3A3E52);  // very faint labels (white12)

  // ── Special ──────────────────────────────────────────────────
  static const Color cyan          = Color(0xFF00DDFF); // surge dialog accent
  static const Color transparent   = Colors.transparent;
}
