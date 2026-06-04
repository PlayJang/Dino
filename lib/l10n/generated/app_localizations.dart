import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dino'**
  String get appTitle;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Protect images before you share'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dino adds a subtle hidden shield that makes AI copying and deepfake reuse harder.'**
  String get homeSubtitle;

  /// No description provided for @brandPromise.
  ///
  /// In en, this message translates to:
  /// **'Friendly protection for photos, art, screenshots, and everyday images.'**
  String get brandPromise;

  /// No description provided for @estimatedMetricsNote.
  ///
  /// In en, this message translates to:
  /// **'Scores are on-device estimates, not a guarantee that AI systems will be blocked.'**
  String get estimatedMetricsNote;

  /// No description provided for @dinoMascotLabel.
  ///
  /// In en, this message translates to:
  /// **'Dino privacy mascot'**
  String get dinoMascotLabel;

  /// No description provided for @localProcessing.
  ///
  /// In en, this message translates to:
  /// **'All processing stays on this device.'**
  String get localProcessing;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @verifyWatermark.
  ///
  /// In en, this message translates to:
  /// **'Verify Dino Mark'**
  String get verifyWatermark;

  /// No description provided for @recentProcessedImage.
  ///
  /// In en, this message translates to:
  /// **'Recent processed image'**
  String get recentProcessedImage;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @readyOnPlatform.
  ///
  /// In en, this message translates to:
  /// **'Ready on {platform}'**
  String readyOnPlatform(Object platform);

  /// No description provided for @latestOutputReady.
  ///
  /// In en, this message translates to:
  /// **'Latest output is ready'**
  String get latestOutputReady;

  /// No description provided for @noProcessedImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No processed images yet'**
  String get noProcessedImagesYet;

  /// No description provided for @quickProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get quickProtection;

  /// No description provided for @protectionMode.
  ///
  /// In en, this message translates to:
  /// **'Protection mode'**
  String get protectionMode;

  /// No description provided for @modeNatural.
  ///
  /// In en, this message translates to:
  /// **'Social Media Safe'**
  String get modeNatural;

  /// No description provided for @modeBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get modeBalanced;

  /// No description provided for @modeMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum Privacy'**
  String get modeMaximum;

  /// No description provided for @modeNaturalDescription.
  ///
  /// In en, this message translates to:
  /// **'Best for everyday sharing with the smallest visible change.'**
  String get modeNaturalDescription;

  /// No description provided for @modeBalancedDescription.
  ///
  /// In en, this message translates to:
  /// **'Recommended protection for most photos, art, and screenshots.'**
  String get modeBalancedDescription;

  /// No description provided for @modeMaximumDescription.
  ///
  /// In en, this message translates to:
  /// **'Strongest shield when privacy matters more than tiny quality changes.'**
  String get modeMaximumDescription;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'How Dino works'**
  String get onboardingTitle;

  /// No description provided for @onboardingStepChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo, artwork, screenshot, or webcam image.'**
  String get onboardingStepChoose;

  /// No description provided for @onboardingStepProtect.
  ///
  /// In en, this message translates to:
  /// **'Pick a protection mode. Balanced is recommended.'**
  String get onboardingStepProtect;

  /// No description provided for @onboardingStepExport.
  ///
  /// In en, this message translates to:
  /// **'Export a protected copy with a hidden Dino mark.'**
  String get onboardingStepExport;

  /// No description provided for @aiResistance.
  ///
  /// In en, this message translates to:
  /// **'AI resistance'**
  String get aiResistance;

  /// No description provided for @resistanceLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get resistanceLevelLow;

  /// No description provided for @resistanceLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get resistanceLevelMedium;

  /// No description provided for @resistanceLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get resistanceLevelHigh;

  /// No description provided for @resistanceLevelMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get resistanceLevelMaximum;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @recentOutputs.
  ///
  /// In en, this message translates to:
  /// **'Recent outputs'**
  String get recentOutputs;

  /// No description provided for @protectedImage.
  ///
  /// In en, this message translates to:
  /// **'Protected Image'**
  String get protectedImage;

  /// No description provided for @beforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before / after'**
  String get beforeAfter;

  /// No description provided for @protected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export {format}'**
  String exportFormat(Object format);

  /// No description provided for @reprocess.
  ///
  /// In en, this message translates to:
  /// **'Reprocess'**
  String get reprocess;

  /// No description provided for @qualityMetrics.
  ///
  /// In en, this message translates to:
  /// **'Quality metrics'**
  String get qualityMetrics;

  /// No description provided for @disruptionMetrics.
  ///
  /// In en, this message translates to:
  /// **'AI disruption metrics'**
  String get disruptionMetrics;

  /// No description provided for @featureDisruption.
  ///
  /// In en, this message translates to:
  /// **'Feature disruption'**
  String get featureDisruption;

  /// No description provided for @embeddingInstability.
  ///
  /// In en, this message translates to:
  /// **'Embedding instability'**
  String get embeddingInstability;

  /// No description provided for @styleDisruption.
  ///
  /// In en, this message translates to:
  /// **'Style disruption'**
  String get styleDisruption;

  /// No description provided for @semanticConfusion.
  ///
  /// In en, this message translates to:
  /// **'Semantic confusion'**
  String get semanticConfusion;

  /// No description provided for @reinterpretationResistance.
  ///
  /// In en, this message translates to:
  /// **'Reinterpretation resistance'**
  String get reinterpretationResistance;

  /// No description provided for @imageFidelity.
  ///
  /// In en, this message translates to:
  /// **'Image fidelity'**
  String get imageFidelity;

  /// No description provided for @resistanceScore.
  ///
  /// In en, this message translates to:
  /// **'Resistance score'**
  String get resistanceScore;

  /// No description provided for @imageType.
  ///
  /// In en, this message translates to:
  /// **'Image type'**
  String get imageType;

  /// No description provided for @textureComplexity.
  ///
  /// In en, this message translates to:
  /// **'Texture detail'**
  String get textureComplexity;

  /// No description provided for @semanticCoverage.
  ///
  /// In en, this message translates to:
  /// **'Important areas'**
  String get semanticCoverage;

  /// No description provided for @watermark.
  ///
  /// In en, this message translates to:
  /// **'Hidden Dino mark'**
  String get watermark;

  /// No description provided for @watermarkPresent.
  ///
  /// In en, this message translates to:
  /// **'Dino mark found'**
  String get watermarkPresent;

  /// No description provided for @watermarkMissing.
  ///
  /// In en, this message translates to:
  /// **'No Dino mark found'**
  String get watermarkMissing;

  /// No description provided for @watermarkConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get watermarkConfidence;

  /// No description provided for @watermarkFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get watermarkFingerprint;

  /// No description provided for @watermarkProtectedAt.
  ///
  /// In en, this message translates to:
  /// **'Protected at'**
  String get watermarkProtectedAt;

  /// No description provided for @watermarkMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get watermarkMode;

  /// No description provided for @watermarkHelp.
  ///
  /// In en, this message translates to:
  /// **'Dino hides a small signature in protected images so you can verify them later. Lossy compression may remove it.'**
  String get watermarkHelp;

  /// No description provided for @imageDetails.
  ///
  /// In en, this message translates to:
  /// **'Image details'**
  String get imageDetails;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoom;

  /// No description provided for @heatmapOverlay.
  ///
  /// In en, this message translates to:
  /// **'Heatmap overlay'**
  String get heatmapOverlay;

  /// No description provided for @heatmapHelp.
  ///
  /// In en, this message translates to:
  /// **'Warmer areas show where Dino applied more structured protection to this image.'**
  String get heatmapHelp;

  /// No description provided for @scanProtecting.
  ///
  /// In en, this message translates to:
  /// **'Building adversarial shield...'**
  String get scanProtecting;

  /// No description provided for @noImageProcessed.
  ///
  /// In en, this message translates to:
  /// **'No image processed'**
  String get noImageProcessed;

  /// No description provided for @captureOrImport.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload an image from the home screen.'**
  String get captureOrImport;

  /// No description provided for @deterministicSeed.
  ///
  /// In en, this message translates to:
  /// **'Deterministic seed'**
  String get deterministicSeed;

  /// No description provided for @seed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get seed;

  /// No description provided for @applySeed.
  ///
  /// In en, this message translates to:
  /// **'Apply seed'**
  String get applySeed;

  /// No description provided for @seedValidation.
  ///
  /// In en, this message translates to:
  /// **'Seed must be a whole number.'**
  String get seedValidation;

  /// No description provided for @protectionControls.
  ///
  /// In en, this message translates to:
  /// **'Simple controls'**
  String get protectionControls;

  /// No description provided for @protectionStrength.
  ///
  /// In en, this message translates to:
  /// **'AI Protection Power'**
  String get protectionStrength;

  /// No description provided for @edgeSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Protect Important Image Details'**
  String get edgeSensitivity;

  /// No description provided for @frequencyStrength.
  ///
  /// In en, this message translates to:
  /// **'Compression Shield'**
  String get frequencyStrength;

  /// No description provided for @faceWeighting.
  ///
  /// In en, this message translates to:
  /// **'Protect Face Features'**
  String get faceWeighting;

  /// No description provided for @rgbLsbDepth.
  ///
  /// In en, this message translates to:
  /// **'Hidden Mark Strength'**
  String get rgbLsbDepth;

  /// No description provided for @protectionStrengthHelp.
  ///
  /// In en, this message translates to:
  /// **'Higher protection makes AI copying harder, but may slightly change image quality.'**
  String get protectionStrengthHelp;

  /// No description provided for @edgeSensitivityHelp.
  ///
  /// In en, this message translates to:
  /// **'Dino pays extra attention to outlines, object edges, and brush strokes.'**
  String get edgeSensitivityHelp;

  /// No description provided for @frequencyStrengthHelp.
  ///
  /// In en, this message translates to:
  /// **'Helps the protection stay useful after resizing or light compression.'**
  String get frequencyStrengthHelp;

  /// No description provided for @faceWeightingHelp.
  ///
  /// In en, this message translates to:
  /// **'Adds extra care around eyes, mouth, hair, and face shape when people are present.'**
  String get faceWeightingHelp;

  /// No description provided for @lsbDepthHelp.
  ///
  /// In en, this message translates to:
  /// **'Controls how strongly Dino hides its invisible verification mark.'**
  String get lsbDepthHelp;

  /// No description provided for @oneBit.
  ///
  /// In en, this message translates to:
  /// **'1 bit'**
  String get oneBit;

  /// No description provided for @twoBits.
  ///
  /// In en, this message translates to:
  /// **'2 bits'**
  String get twoBits;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @jpegQuality.
  ///
  /// In en, this message translates to:
  /// **'JPEG quality'**
  String get jpegQuality;

  /// No description provided for @jpegQualityHelp.
  ///
  /// In en, this message translates to:
  /// **'Higher quality preserves more detail and gives the hidden mark a better chance of remaining readable.'**
  String get jpegQualityHelp;

  /// No description provided for @livePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get livePreview;

  /// No description provided for @livePreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Choose an image to preview setting changes.'**
  String get livePreviewEmpty;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @webcamCapture.
  ///
  /// In en, this message translates to:
  /// **'Camera Capture'**
  String get webcamCapture;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @checkingWebcam.
  ///
  /// In en, this message translates to:
  /// **'Checking camera...'**
  String get checkingWebcam;

  /// No description provided for @windowsWebcam.
  ///
  /// In en, this message translates to:
  /// **'Windows webcam'**
  String get windowsWebcam;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera capture is not available on this device.'**
  String get cameraUnavailable;

  /// No description provided for @sourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get sourceCamera;

  /// No description provided for @sourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get sourceGallery;

  /// No description provided for @sourceFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get sourceFile;

  /// No description provided for @stageIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stageIdle;

  /// No description provided for @stagePicking.
  ///
  /// In en, this message translates to:
  /// **'Opening image picker'**
  String get stagePicking;

  /// No description provided for @stageCapturing.
  ///
  /// In en, this message translates to:
  /// **'Opening camera'**
  String get stageCapturing;

  /// No description provided for @stageProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get stageProcessing;

  /// No description provided for @stageSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get stageSaving;

  /// No description provided for @metricTouched.
  ///
  /// In en, this message translates to:
  /// **'Touched'**
  String get metricTouched;

  /// No description provided for @metricPerturbation.
  ///
  /// In en, this message translates to:
  /// **'Perturbation'**
  String get metricPerturbation;

  /// No description provided for @metricFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get metricFrequency;

  /// No description provided for @metricTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get metricTime;

  /// No description provided for @metricSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get metricSize;

  /// No description provided for @profilePortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get profilePortrait;

  /// No description provided for @profileLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get profileLandscape;

  /// No description provided for @profileIllustration.
  ///
  /// In en, this message translates to:
  /// **'Illustration'**
  String get profileIllustration;

  /// No description provided for @profileLowDetail.
  ///
  /// In en, this message translates to:
  /// **'Low detail'**
  String get profileLowDetail;

  /// No description provided for @profileTextureHeavy.
  ///
  /// In en, this message translates to:
  /// **'Texture-heavy'**
  String get profileTextureHeavy;

  /// No description provided for @profileGeneral.
  ///
  /// In en, this message translates to:
  /// **'General image'**
  String get profileGeneral;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
