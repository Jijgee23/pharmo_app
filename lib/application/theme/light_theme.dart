// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Teal-based modern M3 light theme
final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Sf-Pro-Text',

  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    // Primary — teal 600
    primary: Color(0xFF00897B),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFB2DFDB),
    onPrimaryContainer: Color(0xFF004D40),

    // Secondary — teal 400
    secondary: Color(0xFF26A69A),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE0F2F1),
    onSecondaryContainer: Color(0xFF00695C),

    // Tertiary — warm accent
    tertiary: Color(0xFF0097A7),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE0F7FA),
    onTertiaryContainer: Color(0xFF006064),

    // Surfaces
    surface: Colors.white,
    onSurface: Color(0xFF1A2B2B),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF5F9F9),
    surfaceContainer: Color(0xFFEFF5F4),
    surfaceContainerHigh: Color(0xFFE9F0F0),
    surfaceContainerHighest: Color(0xFFE0EDED),
    onSurfaceVariant: Color(0xFF4A6361),

    // Outline
    outline: Color(0xFFD0DCDB),
    outlineVariant: Color(0xFFEBF2F1),

    // Error
    error: Color(0xFFE53935),
    onError: Colors.white,
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFB71C1C),

    // Inverse
    inverseSurface: Color(0xFF1A2B2B),
    onInverseSurface: Color(0xFFF0F6F5),
    inversePrimary: Color(0xFF80CBC4),

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  ),

  scaffoldBackgroundColor: const Color(0xFFF5F9F9),
  splashColor: const Color(0xff00897b1a),
  highlightColor: Colors.transparent,

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    foregroundColor: const Color(0xFF1A2B2B),
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: const Color(0xff00897b14),
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    iconTheme: const IconThemeData(color: Color(0xFF1A2B2B), size: 22),
    actionsIconTheme: const IconThemeData(color: Color(0xFF1A2B2B), size: 22),
    titleTextStyle: const TextStyle(
      fontSize: 17,
      color: Color(0xFF1A2B2B),
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    toolbarHeight: 60,
  ),

  // Cards
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shadowColor: const Color(0xff00897b18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFEBF2F1), width: 1),
    ),
    margin: EdgeInsets.zero,
  ),

  // ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00897B),
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),

  // OutlinedButton
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF00897B),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      side: const BorderSide(color: Color(0xFF00897B), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

  // TextButton
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF00897B),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),

  // IconButton
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: const Color(0xFF1A2B2B),
      highlightColor: const Color(0xff00897b14),
    ),
  ),

  // InputDecoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    hintStyle: const TextStyle(color: Color(0xFFAABBBA), fontSize: 14),
    labelStyle: const TextStyle(color: Color(0xFF4A6361), fontSize: 14),
    floatingLabelStyle:
        const TextStyle(color: Color(0xFF00897B), fontSize: 13, fontWeight: FontWeight.w500),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD0DCDB), width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD0DCDB), width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.2),
    ),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFF00897B);
      return Colors.transparent;
    }),
    checkColor: WidgetStatePropertyAll(Colors.white),
    side: const BorderSide(color: Color(0xFF00897B), width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),

  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF0F6F5),
    selectedColor: const Color(0xFF00897B),
    labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF1A2B2B)),
    secondaryLabelStyle:
        const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(color: Color(0xFFD0DCDB)),
    ),
    showCheckmark: false,
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: Color(0xFFEBF2F1),
    thickness: 1,
    space: 1,
  ),

  // ListTile
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A2B2B)),
    subtitleTextStyle: TextStyle(fontSize: 12, color: Color(0xFF6B8280)),
    iconColor: Color(0xFF4A6361),
  ),

  // BottomNavigationBar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF00897B),
    unselectedItemColor: Color(0xFFAABBBA),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 10),
  ),

  // Dialog
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    elevation: 4,
    shadowColor: const Color(0xff00897b20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle:
        const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B)),
    contentTextStyle: const TextStyle(fontSize: 14, color: Color(0xFF4A6361), height: 1.5),
  ),

  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1A2B2B),
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
  ),

  // BottomSheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    modalElevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  // PopupMenu
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
    elevation: 8,
    shadowColor: const Color(0xff00000018),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 13, color: Color(0xFF1A2B2B)),
  ),

  // Typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 57, fontWeight: FontWeight.w700, color: Color(0xFF1A2B2B), letterSpacing: -1),
    displayMedium: TextStyle(
        fontSize: 45, fontWeight: FontWeight.w700, color: Color(0xFF1A2B2B), letterSpacing: -0.5),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B)),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B)),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B)),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B)),
    titleLarge: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A2B2B), letterSpacing: -0.3),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A2B2B)),
    titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A2B2B)),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1A2B2B), height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF1A2B2B), height: 1.5),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B8280), height: 1.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A2B2B)),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A6361)),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF6B8280)),
  ),

  // Shadow & surface
  shadowColor: const Color(0xff00897b14),
  primaryColor: const Color(0xFF00897B),
  hintColor: const Color(0xFFAABBBA),
  cardColor: Colors.white,
);
