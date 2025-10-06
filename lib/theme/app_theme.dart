import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان التطبيق الرئيسية
  static const Color primary = Color(0xFF00543C);
  static const Color secondary = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color text = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // نمط الظل الموحد
  static const BoxShadow shadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  // نمط النص الموحد — سنستخدم GoogleFonts للحصول على خط Cairo دون ملفات محلية
  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: text,
      );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: text,
      );

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: text,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        color: textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        color: textSecondary,
      );

  // الأنماط الموحدة للأزرار
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );

  static final ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primary,
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: const BorderSide(color: primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // نمط البطاقات الموحد
  static final cardTheme = CardThemeData(
    color: card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: text.withOpacity(0.1)),
    ),
  );

  // نمط حقول الإدخال الموحد
  static final InputDecorationTheme inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: card,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: text.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: text.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: error),
    ),
  );

  // ثيم التطبيق الرئيسي
  static final ThemeData theme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
    ),
    textTheme: TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButton),
    cardTheme: cardTheme,
    inputDecorationTheme: inputTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: card,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: text),
      titleTextStyle: titleLarge,
    ),
  );
}
