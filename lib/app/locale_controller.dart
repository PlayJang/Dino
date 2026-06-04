import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences/locale_preference_store_base.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._store) : super(const Locale('en')) {
    _load();
  }

  final LocalePreferenceStore _store;

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) {
      return;
    }

    state = Locale(locale.languageCode);
    try {
      await _store.writeLanguageCode(locale.languageCode);
    } on Object {
      // Locale switching should keep working even if preference persistence fails.
    }
  }

  Future<void> _load() async {
    final languageCode = await _safeReadLanguageCode();

    if (languageCode == null || !_isSupported(languageCode)) {
      return;
    }

    state = Locale(languageCode);
  }

  Future<String?> _safeReadLanguageCode() async {
    try {
      return await _store.readLanguageCode();
    } on Object {
      return null;
    }
  }

  bool _isSupported(String languageCode) {
    return languageCode == 'en' || languageCode == 'ko';
  }
}
