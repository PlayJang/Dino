import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/protection/presentation/home_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/app_providers.dart';
import 'theme_controller.dart';

class DinoApp extends ConsumerWidget {
  const DinoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final themePreference = ref.watch(themeControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: _buildTheme(_lightScheme),
      darkTheme: _buildTheme(_darkScheme),
      themeMode: switch (themePreference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
      home: const HomeScreen(),
    );
  }

  ColorScheme get _lightScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1F6F4A),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDDF6DD),
    onPrimaryContainer: Color(0xFF07361F),
    secondary: Color(0xFF7A8F1C),
    onSecondary: Color(0xFF1C2200),
    secondaryContainer: Color(0xFFEAF2B5),
    onSecondaryContainer: Color(0xFF242B00),
    tertiary: Color(0xFF245E68),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFD4F3F0),
    onTertiaryContainer: Color(0xFF073A41),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFAFCF7),
    onSurface: Color(0xFF17221A),
    surfaceContainerHighest: Color(0xFFE8EEE2),
    onSurfaceVariant: Color(0xFF566159),
    outline: Color(0xFF747F75),
    outlineVariant: Color(0xFFC8D1C7),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF263128),
    onInverseSurface: Color(0xFFEFF7EC),
    inversePrimary: Color(0xFF9FE3AF),
  );

  ColorScheme get _darkScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9FE3AF),
    onPrimary: Color(0xFF00391D),
    primaryContainer: Color(0xFF0F4F2E),
    onPrimaryContainer: Color(0xFFDDF6DD),
    secondary: Color(0xFFD4E87A),
    onSecondary: Color(0xFF303800),
    secondaryContainer: Color(0xFF465100),
    onSecondaryContainer: Color(0xFFEAF2B5),
    tertiary: Color(0xFF8EDCE0),
    onTertiary: Color(0xFF00363D),
    tertiaryContainer: Color(0xFF134D56),
    onTertiaryContainer: Color(0xFFD4F3F0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF08140D),
    onSurface: Color(0xFFE4EFE3),
    surfaceContainerHighest: Color(0xFF243127),
    onSurfaceVariant: Color(0xFFC7D1C6),
    outline: Color(0xFF919B90),
    outlineVariant: Color(0xFF414D42),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE4EFE3),
    onInverseSurface: Color(0xFF17221A),
    inversePrimary: Color(0xFF1F6F4A),
  );

  ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 5,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.18),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
