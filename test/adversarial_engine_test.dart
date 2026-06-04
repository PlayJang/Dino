import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:steganography_application/core/image_processing/dino_watermark_codec.dart';
import 'package:image/image.dart' as img;
import 'package:steganography_application/core/image_processing/adversarial_steganography_engine.dart';
import 'package:steganography_application/features/protection/domain/protection_models.dart';

void main() {
  const engine = AdversarialSteganographyEngine();

  test('same seed produces identical output', () {
    final bytes = _portraitFixture();
    const settings = ProcessingSettings.defaults();

    final first = engine.process(
      AdversarialProcessRequest(bytes: bytes, settings: settings),
    );
    final second = engine.process(
      AdversarialProcessRequest(bytes: bytes, settings: settings),
    );

    expect(first.bytes, equals(second.bytes));
    expect(first.heatmapBytes, equals(second.heatmapBytes));
  });

  test('processing returns an image-specific heatmap', () {
    final result = engine.process(
      AdversarialProcessRequest(
        bytes: _portraitFixture(),
        settings: const ProcessingSettings.defaults(),
      ),
    );
    final heatmap = img.decodeImage(result.heatmapBytes);

    expect(heatmap, isNotNull);
    expect(heatmap!.width, 64);
    expect(heatmap.height, 64);
    expect(result.heatmapBytes, isNotEmpty);
  });

  test('different seed changes output', () {
    final bytes = _portraitFixture();
    const settings = ProcessingSettings.defaults();

    final first = engine.process(
      AdversarialProcessRequest(bytes: bytes, settings: settings),
    );
    final second = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: settings.copyWith(seed: settings.seed + 17),
      ),
    );

    expect(second.bytes, isNot(equals(first.bytes)));
  });

  test('higher protection strength increases perturbation metrics', () {
    final bytes = _portraitFixture();
    const defaults = ProcessingSettings.defaults();

    final low = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: defaults.copyWith(
          protectionStrength: 0.12,
          edgeSensitivity: 0.2,
          frequencyStrength: 0.05,
          faceWeight: 0.1,
        ),
      ),
    );
    final high = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: defaults.copyWith(
          protectionStrength: 0.92,
          edgeSensitivity: 0.9,
          frequencyStrength: 0.75,
          faceWeight: 1,
        ),
      ),
    );

    expect(
      high.metrics.meanAbsoluteError,
      greaterThan(low.metrics.meanAbsoluteError),
    );
    expect(
      high.metrics.perturbationStrength,
      greaterThan(low.metrics.perturbationStrength),
    );
  });

  test('face weighting emphasizes portrait feature regions', () {
    final bytes = _portraitFixture();
    const defaults = ProcessingSettings.defaults();
    final result = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: defaults.copyWith(
          protectionStrength: 0.72,
          edgeSensitivity: 0.2,
          frequencyStrength: 0,
          faceWeight: 1,
        ),
      ),
    );
    final original = img.decodeImage(bytes)!;
    final processed = img.decodeImage(result.bytes)!;
    final centerError = _regionError(original, processed, 22, 20, 42, 45);
    final cornerError = _regionError(original, processed, 0, 0, 14, 14);

    expect(centerError, greaterThan(cornerError * 1.35));
  });

  test('frequency strength changes output while preserving visual quality', () {
    final bytes = _portraitFixture();
    const defaults = ProcessingSettings.defaults();
    final noFrequency = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: defaults.copyWith(frequencyStrength: 0),
      ),
    );
    final withFrequency = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: defaults.copyWith(frequencyStrength: 0.82),
      ),
    );

    expect(withFrequency.bytes, isNot(equals(noFrequency.bytes)));
    expect(withFrequency.metrics.psnr, greaterThan(30));
  });

  test('maximum protection mode increases AI resistance estimate', () {
    final bytes = _portraitFixture();
    final natural = ProcessingSettings.preset(ProtectionMode.social);
    final maximum = ProcessingSettings.preset(ProtectionMode.maximum);

    final naturalResult = engine.process(
      AdversarialProcessRequest(bytes: bytes, settings: natural),
    );
    final maximumResult = engine.process(
      AdversarialProcessRequest(bytes: bytes, settings: maximum),
    );

    expect(
      maximumResult.metrics.aiResistanceScore,
      greaterThan(naturalResult.metrics.aiResistanceScore),
    );
    expect(
      maximumResult.metrics.embeddingInstabilityEstimate,
      greaterThan(naturalResult.metrics.embeddingInstabilityEstimate),
    );
    expect(
      maximumResult.metrics.semanticConfusionEstimate,
      greaterThan(naturalResult.metrics.semanticConfusionEstimate),
    );
    expect(
      maximumResult.metrics.reinterpretationResistanceEstimate,
      greaterThan(naturalResult.metrics.reinterpretationResistanceEstimate),
    );
  });

  test('protected PNG carries a verifiable Dino watermark', () {
    final bytes = _portraitFixture();
    const settings = ProcessingSettings.defaults();

    final result = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: settings,
        watermarkTimestampIso: '2026-05-28T00:00:00.000Z',
      ),
    );
    final verification = const DinoWatermarkCodec().verifyBytes(result.bytes);

    expect(verification.detected, isTrue);
    expect(verification.metadata?.message, 'Protected by Dino');
    expect(verification.metadata?.mode, ProtectionMode.balanced);
  });

  test('unprotected input does not verify as a Dino image', () {
    final verification = const DinoWatermarkCodec().verifyBytes(
      _portraitFixture(),
    );

    expect(verification.detected, isFalse);
  });

  test('landscape-like images use scene-aware protection profile', () {
    final bytes = _landscapeFixture();
    final result = engine.process(
      AdversarialProcessRequest(
        bytes: bytes,
        settings: const ProcessingSettings.defaults(),
      ),
    );

    expect(result.metrics.imageProfile, ImageProfile.landscape);
    expect(result.metrics.semanticCoverage, greaterThan(0));
  });
}

Uint8List _portraitFixture() {
  final image = img.Image(width: 64, height: 64);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgb(x, y, 190, 211, 221);
      final nx = (x - 32) / 18;
      final ny = (y - 31) / 24;

      if (nx * nx + ny * ny < 1) {
        image.setPixelRgb(x, y, 226, 182, 154);
      }

      if (((x - 25) * (x - 25) < 9 && (y - 25) * (y - 25) < 4) ||
          ((x - 39) * (x - 39) < 9 && (y - 25) * (y - 25) < 4)) {
        image.setPixelRgb(x, y, 42, 45, 53);
      }

      if ((x - 32).abs() < 3 && y > 28 && y < 38) {
        image.setPixelRgb(x, y, 172, 120, 102);
      }

      if ((x - 32).abs() < 9 && (y - 42).abs() < 2) {
        image.setPixelRgb(x, y, 132, 54, 68);
      }

      if ((x - 32).abs() < 18 && y > 10 && y < 18) {
        image.setPixelRgb(x, y, 54, 64, 74);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _landscapeFixture() {
  final image = img.Image(width: 96, height: 48);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (y < 22) {
        image.setPixelRgb(x, y, 128, 186, 218);
      } else {
        image.setPixelRgb(x, y, 78 + (x % 11), 132 + (y % 17), 72);
      }

      if ((y - 23).abs() < 2) {
        image.setPixelRgb(x, y, 52, 84, 74);
      }

      if ((x - 68).abs() + (y - 18).abs() < 10) {
        image.setPixelRgb(x, y, 76, 92, 104);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

double _regionError(
  img.Image original,
  img.Image processed,
  int left,
  int top,
  int right,
  int bottom,
) {
  var sum = 0.0;
  var count = 0;

  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      final a = original.getPixel(x, y);
      final b = processed.getPixel(x, y);
      sum +=
          (a.r.toInt() - b.r.toInt()).abs() +
          (a.g.toInt() - b.g.toInt()).abs() +
          (a.b.toInt() - b.b.toInt()).abs();
      count += 3;
    }
  }

  return sum / count;
}
