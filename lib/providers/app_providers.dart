import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../app/locale_controller.dart';
import '../app/theme_controller.dart';
import '../core/platform/app_platform.dart';
import '../features/protection/application/protection_controller.dart';
import '../services/camera/camera_capture_service_base.dart';
import '../services/camera/camera_capture_service_factory.dart';
import '../services/export/export_service_base.dart';
import '../services/export/export_service_factory.dart';
import '../services/import/image_import_service.dart';
import '../services/preferences/locale_preference_store_base.dart';
import '../services/preferences/locale_preference_store_factory.dart';

final appPlatformProvider = Provider<AppPlatform>((ref) {
  return AppPlatform.current();
});

final imageImportServiceProvider = Provider<ImageImportService>((ref) {
  return ImageImportService(platform: ref.watch(appPlatformProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return createExportService();
});

final cameraCaptureServiceProvider = Provider<CameraCaptureService>((ref) {
  return createCameraCaptureService(ref.watch(appPlatformProvider));
});

final localePreferenceStoreProvider = Provider<LocalePreferenceStore>((ref) {
  return createLocalePreferenceStore();
});

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(ref.watch(localePreferenceStoreProvider));
    });

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemePreference>((ref) {
      return ThemeController();
    });

final protectionControllerProvider =
    StateNotifierProvider<ProtectionController, ProtectionState>((ref) {
      return ProtectionController(
        imageImportService: ref.watch(imageImportServiceProvider),
        exportService: ref.watch(exportServiceProvider),
      );
    });
