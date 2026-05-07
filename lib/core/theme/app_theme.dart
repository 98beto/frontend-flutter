import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBgDim = Color(0xFFE5DFC5);
  static const Color lightBg0 = Color(0xFFF3EAD3);
  static const Color lightBg1 = Color(0xFFEAE4CA);
  static const Color lightBg2 = Color(0xFFE5DFC5);
  static const Color lightBg3 = Color(0xFFDDD8BE);
  static const Color lightBg4 = Color(0xFFD8D3BA);
  static const Color lightBg5 = Color(0xFFB9C0AB);
  static const Color lightBgRed = Color(0xFFFADBD0);
  static const Color lightBgGreen = Color(0xFFE5E6C5);
  static const Color lightBgBlue = Color(0xFFE1E7DD);
  static const Color lightBgPurple = Color(0xFFF1DDD4);
  static const Color lightBgYellow = Color(0xFFF1E4C5);
  static const Color lightBgVisual = Color(0xFFE1E4BD);
  static const Color lightBase00 = Color(0xFFFFFBEF);
  static const Color lightTextStrong = Color(0xFF272E33);
  static const Color lightTextPrimary = Color(0xFF414B50);
  static const Color lightFg = Color(0xFF5C6A72);
  static const Color lightGrey = Color(0xFF939F91);
  static const Color lightGreyDim = Color(0xFF829181);
  static const Color lightBrand = Color(0xFF3A94C5);
  static const Color lightAccent = Color(0xFF35A77C);
  static const Color lightSuccess = Color(0xFF8DA101);
  static const Color lightWarning = Color(0xFFDFA000);
  static const Color lightDanger = Color(0xFFF85552);
  static const Color lightOrange = Color(0xFFF57D26);

  static const Color bgDim = Color(0xFF222327);
  static const Color bg0 = Color(0xFF2C2E34);
  static const Color bg1 = Color(0xFF33353F);
  static const Color bg2 = Color(0xFF363944);
  static const Color bg3 = Color(0xFF3B3E48);
  static const Color bg4 = Color(0xFF414550);

  static const Color bgRed = Color(0xFF55393D);
  static const Color bgGreen = Color(0xFF394634);
  static const Color bgBlue = Color(0xFF354157);
  static const Color bgPurple = Color(0xFF434055);
  static const Color bgYellow = Color(0xFF4E432F);
  static const Color black = Color(0xFF181819);

  static const Color red = Color(0xFFFC5D7C);
  static const Color green = Color(0xFF9ED072);
  static const Color blue = Color(0xFF76CCE0);
  static const Color purple = Color(0xFFB39DF3);
  static const Color yellow = Color(0xFFE7C664);
  static const Color orange = Color(0xFFF39660);

  static const Color filledRed = Color(0xFFFF6077);
  static const Color filledGreen = Color(0xFFA7DF78);
  static const Color filledBlue = Color(0xFF85D3F2);
  static const Color fg = Color(0xFFE2E2E3);
  static const Color grey = Color(0xFF7F8490);
  static const Color greyDim = Color(0xFF595F6F);

  static const Color brand = purple;
  static const Color muted = grey;
  static const Color accent = blue;
  static const Color soft = filledBlue;
  static const Color background = bgDim;
  static const Color panel = bg0;
  static const Color border = bg4;
  static const Color success = green;
  static const Color danger = red;
  static const Color warning = yellow;

  static final Color transparent = bgDim.withValues(alpha: 0);
  static final Color overlay = bgDim.withValues(alpha: 0.72);

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: purple,
      onPrimary: black,
      secondary: blue,
      onSecondary: black,
      error: red,
      onError: black,
      surface: bg0,
      onSurface: fg,
    );

    final baseTextTheme = Typography.whiteMountainView.apply(
      bodyColor: fg,
      displayColor: fg,
      fontFamily: 'Inter',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dialogTheme: DialogThemeData(backgroundColor: transparent),
      fontFamily: 'Inter',
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 15, color: fg),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: muted,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: greyDim,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bgDim,
        foregroundColor: fg,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      iconTheme: const IconThemeData(color: fg),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg1,
        hintStyle: const TextStyle(color: grey),
        labelStyle: const TextStyle(color: grey),
        prefixIconColor: grey,
        suffixIconColor: grey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: black,
          disabledBackgroundColor: bg3,
          disabledForegroundColor: grey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: bg1,
          disabledForegroundColor: grey,
          disabledBackgroundColor: bg1,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgBlue,
        selectedColor: bgPurple,
        disabledColor: bg2,
        labelStyle: const TextStyle(color: fg, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: fg),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return filledBlue;
          }
          return grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bgBlue;
          }
          return bg4;
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightBrand,
      onPrimary: lightBase00,
      secondary: lightAccent,
      onSecondary: lightTextStrong,
      error: lightDanger,
      onError: lightBase00,
      surface: lightBg0,
      onSurface: lightTextPrimary,
    );

    final baseTextTheme = Typography.blackMountainView.apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextStrong,
      fontFamily: 'Inter',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBgDim,
      canvasColor: lightBgDim,
      dialogTheme: const DialogThemeData(backgroundColor: lightBg0),
      fontFamily: 'Inter',
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: lightTextStrong,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: lightTextStrong,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextStrong,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightTextStrong,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 15,
          color: lightTextPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: lightFg,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: lightGrey,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: lightBgDim,
        foregroundColor: lightTextStrong,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightBg0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBg4),
        ),
      ),
      dividerColor: lightBg4,
      iconTheme: const IconThemeData(color: lightTextPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBg1,
        hintStyle: const TextStyle(color: lightGrey),
        labelStyle: const TextStyle(color: lightGrey),
        prefixIconColor: lightGrey,
        suffixIconColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightBg4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightBg4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightBrand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightDanger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBrand,
          foregroundColor: lightBase00,
          disabledBackgroundColor: lightBg3,
          disabledForegroundColor: lightGrey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          backgroundColor: lightBg1,
          disabledForegroundColor: lightGrey,
          disabledBackgroundColor: lightBg1,
          side: const BorderSide(color: lightBg4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightBrand,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightBgBlue,
        selectedColor: lightBgVisual,
        disabledColor: lightBg2,
        labelStyle: const TextStyle(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: lightBg4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: lightTextPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: lightBrand,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightBrand;
          }
          return lightGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightBgBlue;
          }
          return lightBg4;
        }),
      ),
    );
  }
}
