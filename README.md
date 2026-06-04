# Dino

Dino is a cross-platform Flutter prototype for lightweight, on-device
adversarial image perturbation. It imports or captures an image,
modifies raw RGB pixels with deterministic low-amplitude perturbations, previews
the original and processed output, embeds a verifiable hidden mark, and exports
the protected image.

## Supported Development Targets

- Windows desktop: webcam capture, file import, processing preview, save/export,
  and watermark verification
- Android and iOS: camera capture, gallery import, processing preview,
  save/export, and watermark verification
- Flutter web: file import, processing preview, browser export, and watermark
  verification

## Folder Structure

```text
lib/
  core/
    image_processing/
      adversarial_steganography_engine.dart
      image_processing_isolate.dart
    platform/
      app_platform.dart
  features/
    protection/
      application/
        protection_controller.dart
      domain/
        protection_models.dart
      presentation/
        camera_capture_screen.dart
        home_screen.dart
        processing_screen.dart
        settings_screen.dart
  providers/
    app_providers.dart
  services/
    export/
      export_service_base.dart
      export_service_factory.dart
      export_service_io.dart
      export_service_stub.dart
      export_service_web.dart
    import/
      image_import_service.dart
  shared/
    widgets/
      protection_widgets.dart
  app/
    dino_app.dart
  main.dart
```

## Functional Flow

1. Home screen detects the platform and shows supported actions.
2. Desktop/web imports use `file_picker`.
3. Android/iOS gallery imports use the native file picker.
4. Android/iOS camera capture uses `image_picker` and returns directly into the
   processing pipeline.
5. `ProtectionController` sends image bytes to `compute()`, keeping the UI
   responsive.
6. The preview screen shows a before/after slider, an image-specific protection
   heatmap, original/processed previews, image-quality metrics, save, and
   reprocess.
7. Settings control seed, noise intensity, edge threshold, LSB depth,
   portrait-prior weighting, PNG/JPEG, and JPEG quality.

## Image Processing

The engine in `lib/core/image_processing` uses `package:image` to decode and
manipulate RGB pixels directly. It applies:

- LSB perturbation on RGB channels
- Seeded xorshift pseudo-random noise for reproducibility
- Semantic, edge, texture, and high-frequency region weighting
- RGB-channel-specific seeded patterns
- Portrait-feature weighting with lightweight image-profile detection
- DCT-inspired frequency patterns
- Distributed LSB Dino watermark and verification
- PSNR, approximate SSIM, touched-pixel ratio, MAE, size, and elapsed-time
  metrics

The processed output is designed to remain visually similar to the original
while increasing instability in some downstream AI feature extraction signals.
Resistance and disruption scores are heuristic estimates and do not guarantee
that an AI system will be blocked.

## Platform Notes

Android camera permission is in `android/app/src/main/AndroidManifest.xml`.
Gallery and export access use system pickers and scoped storage.

iOS usage descriptions are in `ios/Runner/Info.plist` for camera, photo-library
read, and photo-library add access.

Windows desktop builds that use plugins require Windows Developer Mode or
symlink privileges enabled by the OS.
