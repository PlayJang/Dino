import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steganography_application/app/dino_app.dart';
import 'package:steganography_application/providers/app_providers.dart';
import 'package:steganography_application/services/preferences/locale_preference_store_base.dart';

void main() {
  testWidgets('home screen renders the protection workflow in English', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await _pumpApp(tester);

      expect(find.text('Dino'), findsOneWidget);
      expect(find.text('Capture Photo'), findsOneWidget);
      expect(find.text('Upload Image'), findsOneWidget);
      expect(find.text('All processing stays on this device.'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent processed image'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Recent processed image'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('No processed images yet'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('No processed images yet'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Korean locale renders Korean labels', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    try {
      await _pumpApp(tester, languageCode: 'ko');

      expect(find.text('디노'), findsOneWidget);
      expect(find.text('사진 촬영'), findsOneWidget);
      expect(find.text('이미지 업로드'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('settings controls switch language and show reset', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final store = _FakeLocalePreferenceStore();

    try {
      await _pumpApp(tester, store: store);

      await tester.tap(find.byIcon(Icons.tune_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('Reset'), findsOneWidget);
      await tester.tap(find.text('Korean'));
      await tester.pumpAndSettle();

      expect(store.languageCode, 'ko');
      expect(find.text('초기화'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('AI 보호력'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('AI 보호력'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  String? languageCode,
  _FakeLocalePreferenceStore? store,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localePreferenceStoreProvider.overrideWithValue(
          store ?? _FakeLocalePreferenceStore(languageCode),
        ),
      ],
      child: const DinoApp(),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeLocalePreferenceStore implements LocalePreferenceStore {
  _FakeLocalePreferenceStore([this.languageCode]);

  String? languageCode;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
  }
}
