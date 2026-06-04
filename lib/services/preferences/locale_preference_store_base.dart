abstract class LocalePreferenceStore {
  Future<String?> readLanguageCode();

  Future<void> writeLanguageCode(String languageCode);
}
