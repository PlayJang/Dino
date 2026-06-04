import 'package:flutter/foundation.dart';

enum PlatformFamily { android, ios, windows, macos, linux, web, unknown }

class AppPlatform {
  const AppPlatform(this.family);

  factory AppPlatform.current() {
    if (kIsWeb) {
      return const AppPlatform(PlatformFamily.web);
    }

    return AppPlatform(switch (defaultTargetPlatform) {
      TargetPlatform.android => PlatformFamily.android,
      TargetPlatform.iOS => PlatformFamily.ios,
      TargetPlatform.windows => PlatformFamily.windows,
      TargetPlatform.macOS => PlatformFamily.macos,
      TargetPlatform.linux => PlatformFamily.linux,
      TargetPlatform.fuchsia => PlatformFamily.unknown,
    });
  }

  final PlatformFamily family;

  bool get isWeb => family == PlatformFamily.web;

  bool get isMobile =>
      family == PlatformFamily.android || family == PlatformFamily.ios;

  bool get isDesktop =>
      family == PlatformFamily.windows ||
      family == PlatformFamily.macos ||
      family == PlatformFamily.linux;

  bool get supportsCameraCapture =>
      family == PlatformFamily.windows || isMobile;

  bool get usesDesktopFilePicker => isDesktop || isWeb;

  String get importButtonLabel =>
      usesDesktopFilePicker ? 'Upload Image' : 'Import Image';

  String get platformLabel => switch (family) {
    PlatformFamily.android => 'Android',
    PlatformFamily.ios => 'iOS',
    PlatformFamily.windows => 'Windows',
    PlatformFamily.macos => 'macOS',
    PlatformFamily.linux => 'Linux',
    PlatformFamily.web => 'Web',
    PlatformFamily.unknown => 'Device',
  };
}
