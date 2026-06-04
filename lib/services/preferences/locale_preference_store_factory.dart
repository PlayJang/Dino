import 'locale_preference_store_base.dart';
import 'locale_preference_store_stub.dart'
    if (dart.library.io) 'locale_preference_store_io.dart'
    as platform_store;

LocalePreferenceStore createLocalePreferenceStore() {
  return platform_store.createLocalePreferenceStore();
}
