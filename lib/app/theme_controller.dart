import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreference { system, light, dark }

class ThemeController extends StateNotifier<AppThemePreference> {
  ThemeController() : super(AppThemePreference.system);

  void setTheme(AppThemePreference preference) {
    state = preference;
  }
}
