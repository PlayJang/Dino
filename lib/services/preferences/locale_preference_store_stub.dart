import 'locale_preference_store_base.dart';

LocalePreferenceStore createLocalePreferenceStore() {
  return InMemoryLocalePreferenceStore();
}

class InMemoryLocalePreferenceStore implements LocalePreferenceStore {
  String? _languageCode;

  @override
  Future<String?> readLanguageCode() async => _languageCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    _languageCode = languageCode;
  }
}
