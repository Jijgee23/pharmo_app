import 'package:flutter/material.dart';
import 'package:pharmo_app/application/context/color/colors.dart';

final lightTheme = ThemeData(
  primaryColor: primary,
  hintColor: secondary,
  shadowColor: Colors.grey.shade300,
  // brightness: Brightness.light,
  scaffoldBackgroundColor: white,
  splashColor: Colors.grey.withAlpha(50),
  highlightColor: Colors.grey.withAlpha(50),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: secondary,
    onSecondary: black,
    error: Colors.red,
    onError: Colors.red,
    surface: white,
    onSurface: black,
  ),
  cardTheme: CardThemeData(
    color: white,
    elevation: 0,
    shadowColor: Colors.grey.shade300,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey.shade300),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors
        .white, // Material 3 дээр scroll хийхэд өнгө өөрчлөгдөхөөс сэргийлнэ
    elevation: 0, // Илүү цэвэрхэн харагдуулахын тулд 0 болгов
    scrolledUnderElevation:
        0.5, // Scroll хийх үед маш бүдэг сүүдэр эсвэл зураас гарна
    shadowColor: Colors.grey.withOpacity(0.2),
    centerTitle: false,
    iconTheme: const IconThemeData(
      color: Color(
          0xFF1A1A1A), // Цэвэр хар биш, гүн саарал (Deep Charcoal) нь илүү дээд зэрэглэлийн харагддаг
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: Color(0xFF1A1A1A),
      size: 24,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18, // 16 байсныг 18 болговол гарчиг илүү тод харагдана
      color: Color(0xFF1A1A1A),
      fontWeight: FontWeight.w700, // Bold-оос арай зөөлөн боловч тод
      letterSpacing: -0.5, // Текстүүд хоорондоо илүү нягт, цэгцтэй харагдана
      fontFamily: 'Inter', // Хэрэв та Inter эсвэл Roboto ашигладаг бол
    ),
    toolbarHeight: 64, // Бага зэрэг өндөр болгосноор "амьсгалах" зай ихэснэ
  ),

  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(
      color: black,
    ),
    focusedBorder: InputBorder.none,
    border: InputBorder.none,
    // labelStyle: TextStyle(color: primary),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(primary),
    overlayColor: WidgetStateProperty.all(primary),
    side: const BorderSide(color: primary, width: 1),
    fillColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  fontFamily: 'Sf-Pro-Text',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
  ),
  cardColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: white,
    selectedItemColor: white,
    unselectedIconTheme: IconThemeData(
      color: white..withAlpha(125),
    ),
  ),
);
