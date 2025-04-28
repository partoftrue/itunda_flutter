import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Basic color constants
const Color kPrimaryColor = Color(0xFF0064FF);
const Color kSecondaryColor = Color(0xFF4EA1FF);
const Color kLightBackground = Color(0xFFF9FAFB);
const Color kDarkBackground = Color(0xFF181C23);

class AppTheme {
  static const Color primaryColor = kPrimaryColor;
  static const Color secondaryColor = kSecondaryColor;
  
  // Basic light theme
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      background: kLightBackground,
    ),
    scaffoldBackgroundColor: kLightBackground,
    textTheme: GoogleFonts.notoSansTextTheme(),
    useMaterial3: true,
  );

  // Basic dark theme
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      background: kDarkBackground,
    ),
    scaffoldBackgroundColor: kDarkBackground,
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
  );
}
