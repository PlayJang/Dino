import 'dart:convert';
import 'dart:io';

import 'locale_preference_store_base.dart';

LocalePreferenceStore createLocalePreferenceStore() {
  return const IoLocalePreferenceStore();
}

class IoLocalePreferenceStore implements LocalePreferenceStore {
  const IoLocalePreferenceStore();

  @override
  Future<String?> readLanguageCode() async {
    final file = _settingsFile;

    if (!await file.exists()) {
      return null;
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, Object?>) {
      return null;
    }

    final languageCode = decoded['languageCode'];
    return languageCode is String ? languageCode : null;
  }

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    final file = _settingsFile;
    final parent = file.parent;

    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    await file.writeAsString(
      jsonEncode(<String, Object?>{'languageCode': languageCode}),
      flush: true,
    );
  }

  File get _settingsFile {
    final root =
        Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.systemTemp.path;
    final separator = Platform.pathSeparator;
    final directory = root.endsWith(separator)
        ? '${root}Dino'
        : '$root${separator}Dino';

    return File('$directory${separator}settings.json');
  }
}
