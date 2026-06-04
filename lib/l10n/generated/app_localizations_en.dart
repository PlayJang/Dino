// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dino';

  @override
  String get homeHeadline => 'Protect images before you share';

  @override
  String get homeSubtitle =>
      'Dino adds a subtle hidden shield that makes AI copying and deepfake reuse harder.';

  @override
  String get brandPromise =>
      'Friendly protection for photos, art, screenshots, and everyday images.';

  @override
  String get estimatedMetricsNote =>
      'Scores are on-device estimates, not a guarantee that AI systems will be blocked.';

  @override
  String get dinoMascotLabel => 'Dino privacy mascot';

  @override
  String get localProcessing => 'All processing stays on this device.';

  @override
  String get capturePhoto => 'Capture Photo';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get verifyWatermark => 'Verify Dino Mark';

  @override
  String get recentProcessedImage => 'Recent processed image';

  @override
  String get open => 'Open';

  @override
  String readyOnPlatform(Object platform) {
    return 'Ready on $platform';
  }

  @override
  String get latestOutputReady => 'Latest output is ready';

  @override
  String get noProcessedImagesYet => 'No processed images yet';

  @override
  String get quickProtection => 'Protection';

  @override
  String get protectionMode => 'Protection mode';

  @override
  String get modeNatural => 'Social Media Safe';

  @override
  String get modeBalanced => 'Balanced';

  @override
  String get modeMaximum => 'Maximum Privacy';

  @override
  String get modeNaturalDescription =>
      'Best for everyday sharing with the smallest visible change.';

  @override
  String get modeBalancedDescription =>
      'Recommended protection for most photos, art, and screenshots.';

  @override
  String get modeMaximumDescription =>
      'Strongest shield when privacy matters more than tiny quality changes.';

  @override
  String get recommended => 'Recommended';

  @override
  String get onboardingTitle => 'How Dino works';

  @override
  String get onboardingStepChoose =>
      'Choose a photo, artwork, screenshot, or webcam image.';

  @override
  String get onboardingStepProtect =>
      'Pick a protection mode. Balanced is recommended.';

  @override
  String get onboardingStepExport =>
      'Export a protected copy with a hidden Dino mark.';

  @override
  String get aiResistance => 'AI resistance';

  @override
  String get resistanceLevelLow => 'Low';

  @override
  String get resistanceLevelMedium => 'Medium';

  @override
  String get resistanceLevelHigh => 'High';

  @override
  String get resistanceLevelMaximum => 'Maximum';

  @override
  String get settings => 'Settings';

  @override
  String get recentOutputs => 'Recent outputs';

  @override
  String get protectedImage => 'Protected Image';

  @override
  String get beforeAfter => 'Before / after';

  @override
  String get protected => 'Protected';

  @override
  String get original => 'Original';

  @override
  String get ready => 'Ready';

  @override
  String get saved => 'Saved';

  @override
  String exportFormat(Object format) {
    return 'Export $format';
  }

  @override
  String get reprocess => 'Reprocess';

  @override
  String get qualityMetrics => 'Quality metrics';

  @override
  String get disruptionMetrics => 'AI disruption metrics';

  @override
  String get featureDisruption => 'Feature disruption';

  @override
  String get embeddingInstability => 'Embedding instability';

  @override
  String get styleDisruption => 'Style disruption';

  @override
  String get semanticConfusion => 'Semantic confusion';

  @override
  String get reinterpretationResistance => 'Reinterpretation resistance';

  @override
  String get imageFidelity => 'Image fidelity';

  @override
  String get resistanceScore => 'Resistance score';

  @override
  String get imageType => 'Image type';

  @override
  String get textureComplexity => 'Texture detail';

  @override
  String get semanticCoverage => 'Important areas';

  @override
  String get watermark => 'Hidden Dino mark';

  @override
  String get watermarkPresent => 'Dino mark found';

  @override
  String get watermarkMissing => 'No Dino mark found';

  @override
  String get watermarkConfidence => 'Confidence';

  @override
  String get watermarkFingerprint => 'Fingerprint';

  @override
  String get watermarkProtectedAt => 'Protected at';

  @override
  String get watermarkMode => 'Mode';

  @override
  String get watermarkHelp =>
      'Dino hides a small signature in protected images so you can verify them later. Lossy compression may remove it.';

  @override
  String get imageDetails => 'Image details';

  @override
  String get zoom => 'Zoom';

  @override
  String get heatmapOverlay => 'Heatmap overlay';

  @override
  String get heatmapHelp =>
      'Warmer areas show where Dino applied more structured protection to this image.';

  @override
  String get scanProtecting => 'Building adversarial shield...';

  @override
  String get noImageProcessed => 'No image processed';

  @override
  String get captureOrImport =>
      'Capture or upload an image from the home screen.';

  @override
  String get deterministicSeed => 'Deterministic seed';

  @override
  String get seed => 'Seed';

  @override
  String get applySeed => 'Apply seed';

  @override
  String get seedValidation => 'Seed must be a whole number.';

  @override
  String get protectionControls => 'Simple controls';

  @override
  String get protectionStrength => 'AI Protection Power';

  @override
  String get edgeSensitivity => 'Protect Important Image Details';

  @override
  String get frequencyStrength => 'Compression Shield';

  @override
  String get faceWeighting => 'Protect Face Features';

  @override
  String get rgbLsbDepth => 'Hidden Mark Strength';

  @override
  String get protectionStrengthHelp =>
      'Higher protection makes AI copying harder, but may slightly change image quality.';

  @override
  String get edgeSensitivityHelp =>
      'Dino pays extra attention to outlines, object edges, and brush strokes.';

  @override
  String get frequencyStrengthHelp =>
      'Helps the protection stay useful after resizing or light compression.';

  @override
  String get faceWeightingHelp =>
      'Adds extra care around eyes, mouth, hair, and face shape when people are present.';

  @override
  String get lsbDepthHelp =>
      'Controls how strongly Dino hides its invisible verification mark.';

  @override
  String get oneBit => '1 bit';

  @override
  String get twoBits => '2 bits';

  @override
  String get export => 'Export';

  @override
  String get format => 'Format';

  @override
  String get jpegQuality => 'JPEG quality';

  @override
  String get jpegQualityHelp =>
      'Higher quality preserves more detail and gives the hidden mark a better chance of remaining readable.';

  @override
  String get livePreview => 'Live preview';

  @override
  String get livePreviewEmpty => 'Choose an image to preview setting changes.';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get korean => 'Korean';

  @override
  String get webcamCapture => 'Camera Capture';

  @override
  String get close => 'Close';

  @override
  String get checkingWebcam => 'Checking camera...';

  @override
  String get windowsWebcam => 'Windows webcam';

  @override
  String get retry => 'Retry';

  @override
  String get capture => 'Capture';

  @override
  String get cameraUnavailable =>
      'Camera capture is not available on this device.';

  @override
  String get sourceCamera => 'Camera';

  @override
  String get sourceGallery => 'Gallery';

  @override
  String get sourceFile => 'File';

  @override
  String get stageIdle => 'Ready';

  @override
  String get stagePicking => 'Opening image picker';

  @override
  String get stageCapturing => 'Opening camera';

  @override
  String get stageProcessing => 'Processing';

  @override
  String get stageSaving => 'Saving';

  @override
  String get metricTouched => 'Touched';

  @override
  String get metricPerturbation => 'Perturbation';

  @override
  String get metricFrequency => 'Frequency';

  @override
  String get metricTime => 'Time';

  @override
  String get metricSize => 'Size';

  @override
  String get profilePortrait => 'Portrait';

  @override
  String get profileLandscape => 'Landscape';

  @override
  String get profileIllustration => 'Illustration';

  @override
  String get profileLowDetail => 'Low detail';

  @override
  String get profileTextureHeavy => 'Texture-heavy';

  @override
  String get profileGeneral => 'General image';
}
