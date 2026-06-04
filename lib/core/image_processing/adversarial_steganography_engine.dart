import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../features/protection/domain/protection_models.dart';
import 'dino_watermark_codec.dart';

class AdversarialSteganographyEngine {
  const AdversarialSteganographyEngine();

  AdversarialProcessResult process(AdversarialProcessRequest request) {
    final stopwatch = Stopwatch()..start();
    final decoded = img.decodeImage(request.bytes);

    if (decoded == null) {
      throw const FormatException(
        'The selected file is not a supported image.',
      );
    }

    final baked = img.bakeOrientation(decoded);
    final maxDimension = request.previewMaxDimension;
    final source = maxDimension == null
        ? baked
        : _resizeForPreview(baked, maxDimension);
    final output = img.Image.from(source);
    final width = source.width;
    final height = source.height;
    final pixelCount = width * height;
    final luminance = _buildLuminance(source);
    final structure = _buildStructureMaps(
      luminance: luminance,
      width: width,
      height: height,
      settings: request.settings,
    );
    final analysis = _analyzeImage(
      source: source,
      structure: structure,
      width: width,
      height: height,
    );
    final settings = request.settings;
    final modeGain = switch (settings.mode) {
      ProtectionMode.social => 0.84,
      ProtectionMode.balanced => 1.0,
      ProtectionMode.maximum => 1.12,
    };
    final protectionStrength = (settings.protectionStrength * modeGain)
        .clamp(0.0, 1.0)
        .toDouble();
    final frequencyStrength = settings.frequencyStrength
        .clamp(0.0, 1.0)
        .toDouble();
    final faceWeight = settings.faceWeight.clamp(0.0, 1.0).toDouble();
    final baseBits = settings.lsbBits.clamp(1, 2).toInt();
    final seed = _mixSeed(
      settings.seed,
      width,
      height,
      request.bytes.length,
      request.temporalFrame ?? 0,
    );
    final redNoise = _SeededNoise(seed ^ 0x9e3779b9);
    final greenNoise = _SeededNoise(seed ^ 0x85ebca6b);
    final blueNoise = _SeededNoise(seed ^ 0xc2b2ae35);
    final heatmapWidth = math.min(width, 640);
    final heatmapHeight = math.max(1, (height * heatmapWidth / width).round());
    final heatmapIntensity = Uint8List(heatmapWidth * heatmapHeight);

    var touchedPixels = 0;
    var absoluteErrorSum = 0.0;
    var squaredErrorSum = 0.0;
    var originalLumaSum = 0.0;
    var originalLumaSqSum = 0.0;
    var processedLumaSum = 0.0;
    var processedLumaSqSum = 0.0;
    var lumaCrossSum = 0.0;

    for (var y = 0; y < height; y++) {
      final rowOffset = y * width;

      for (var x = 0; x < width; x++) {
        final index = rowOffset + x;
        final edgeWeight = structure.edge[index];
        final highFrequency = structure.highFrequency[index];
        final textureWeight = structure.texture[index];
        final semanticWeight = structure.semantic[index];
        final horizonWeight = structure.horizontalContour[index];
        final facePrior = _faceRegionPrior(x, y, width, height) * faceWeight;
        final sceneWeight = _sceneAdaptiveWeight(
          profile: analysis.profile,
          edgeWeight: edgeWeight,
          highFrequency: highFrequency,
          textureWeight: textureWeight,
          semanticWeight: semanticWeight,
          horizonWeight: horizonWeight,
        );
        final faceScale = analysis.profile == ImageProfile.portrait
            ? 0.86
            : 0.34;
        final structuredWeight =
            (sceneWeight +
                    edgeWeight * 0.22 +
                    highFrequency * 0.20 +
                    textureWeight * 0.28 +
                    semanticWeight * 0.34 +
                    facePrior * faceScale)
                .clamp(0.0, 1.0)
                .toDouble();
        final channelBits = structuredWeight > 0.62 && protectionStrength > 0.52
            ? math.min(2, baseBits + 1).toInt()
            : baseBits;
        final pixel = output.getPixel(x, y);
        final originalR = pixel.r.toInt();
        final originalG = pixel.g.toInt();
        final originalB = pixel.b.toInt();
        final originalLuma = luminance[index].toDouble();
        final frequency = _frequencyPattern(
          x: x,
          y: y,
          seed: seed,
          edgeWeight: edgeWeight,
          highFrequency: highFrequency,
          facePrior: math.max(facePrior, semanticWeight * 0.55).toDouble(),
          strength: frequencyStrength * protectionStrength,
        );

        final r = _clamp8(
          _perturbChannel(
            originalR,
            channelBits,
            redNoise,
            structuredWeight,
            protectionStrength,
            channelScale: 1.08,
            frequencyDelta: frequency * 1.10,
          ),
        );
        final g = _clamp8(
          _perturbChannel(
            originalG,
            channelBits,
            greenNoise,
            structuredWeight,
            protectionStrength,
            channelScale: 0.72,
            frequencyDelta: frequency * -0.62,
          ),
        );
        final b = _clamp8(
          _perturbChannel(
            originalB,
            channelBits,
            blueNoise,
            structuredWeight,
            protectionStrength,
            channelScale: 1.22,
            frequencyDelta: frequency * 1.24,
          ),
        );

        pixel
          ..r = r
          ..g = g
          ..b = b;

        final rError = (r - originalR).abs();
        final gError = (g - originalG).abs();
        final bError = (b - originalB).abs();
        final heatmapX = x * heatmapWidth ~/ width;
        final heatmapY = y * heatmapHeight ~/ height;
        final heatmapIndex = heatmapY * heatmapWidth + heatmapX;
        final changeStrength = ((rError + gError + bError) / 18)
            .clamp(0.0, 1.0)
            .toDouble();
        final protectionActivity =
            (structuredWeight * 0.68 +
                    changeStrength * 0.22 +
                    frequencyStrength * protectionStrength * 0.10)
                .clamp(0.0, 1.0)
                .toDouble();
        final activityByte = (protectionActivity * 255).round();

        if (activityByte > heatmapIntensity[heatmapIndex]) {
          heatmapIntensity[heatmapIndex] = activityByte;
        }

        if (rError + gError + bError > 0) {
          touchedPixels++;
        }

        absoluteErrorSum += rError + gError + bError;
        squaredErrorSum +=
            (r - originalR) * (r - originalR) +
            (g - originalG) * (g - originalG) +
            (b - originalB) * (b - originalB);

        final processedLuma = _luminance(r, g, b);
        originalLumaSum += originalLuma;
        originalLumaSqSum += originalLuma * originalLuma;
        processedLumaSum += processedLuma;
        processedLumaSqSum += processedLuma * processedLuma;
        lumaCrossSum += originalLuma * processedLuma;
      }
    }

    final watermarkMetadata = const DinoWatermarkCodec().buildMetadata(
      settings: settings,
      width: width,
      height: height,
      byteLength: request.bytes.length,
      protectedAtIso:
          request.watermarkTimestampIso ?? '1970-01-01T00:00:00.000Z',
    );

    if (request.embedWatermark) {
      const DinoWatermarkCodec().embed(output, watermarkMetadata);
    }

    final encodedBytes = switch (settings.exportFormat) {
      ExportFormat.png => img.encodePng(output, level: 6),
      ExportFormat.jpeg => img.encodeJpg(
        output,
        quality: settings.jpegQuality.clamp(70, 100).toInt(),
      ),
    };

    stopwatch.stop();

    final totalChannels = pixelCount * 3;
    final meanAbsoluteError = absoluteErrorSum / totalChannels;
    final mse = squaredErrorSum / totalChannels;
    final psnr = _psnr(mse);
    final ssim = _ssim(
      samples: pixelCount,
      xSum: originalLumaSum,
      ySum: processedLumaSum,
      xSqSum: originalLumaSqSum,
      ySqSum: processedLumaSqSum,
      xySum: lumaCrossSum,
    );
    final touchedRatio = touchedPixels / pixelCount;
    final perturbationStrength = (meanAbsoluteError / 10)
        .clamp(0.0, 1.0)
        .toDouble();
    final featureDisruptionScore =
        (touchedRatio * 0.18 +
                perturbationStrength * 0.30 +
                protectionStrength * 0.16 +
                settings.edgeSensitivity * 0.11 +
                faceWeight * 0.16 +
                analysis.semanticCoverage * 0.08 +
                analysis.textureComplexity * 0.06 +
                frequencyStrength * 0.09)
            .clamp(0.0, 1.0)
            .toDouble();
    final embeddingInstabilityEstimate =
        (featureDisruptionScore * 0.46 +
                perturbationStrength * 0.24 +
                faceWeight * protectionStrength * 0.18 +
                frequencyStrength * 0.12)
            .clamp(0.0, 1.0)
            .toDouble();
    final styleDisruptionEstimate =
        (featureDisruptionScore * 0.28 +
                analysis.textureComplexity * protectionStrength * 0.30 +
                settings.edgeSensitivity * protectionStrength * 0.20 +
                frequencyStrength * protectionStrength * 0.22)
            .clamp(0.0, 1.0)
            .toDouble();
    final semanticConfusionEstimate =
        (featureDisruptionScore * 0.34 +
                analysis.semanticCoverage * protectionStrength * 0.26 +
                embeddingInstabilityEstimate * 0.22 +
                settings.edgeSensitivity * protectionStrength * 0.18)
            .clamp(0.0, 1.0)
            .toDouble();
    final reinterpretationResistanceEstimate =
        (embeddingInstabilityEstimate * 0.32 +
                styleDisruptionEstimate * 0.24 +
                semanticConfusionEstimate * 0.28 +
                frequencyStrength * protectionStrength * 0.16)
            .clamp(0.0, 1.0)
            .toDouble();
    final imageFidelityEstimate =
        (ssim * 0.54 +
                (psnr.isInfinite ? 1.0 : (psnr / 44).clamp(0.0, 1.0)) * 0.46)
            .clamp(0.0, 1.0)
            .toDouble();
    final aiResistanceScore =
        ((featureDisruptionScore * 0.22 +
                    embeddingInstabilityEstimate * 0.22 +
                    styleDisruptionEstimate * 0.16 +
                    semanticConfusionEstimate * 0.18 +
                    reinterpretationResistanceEstimate * 0.22) *
                (0.74 + imageFidelityEstimate * 0.26))
            .clamp(0.0, 1.0)
            .toDouble();
    final heatmapBytes = _encodeHeatmap(
      heatmapIntensity,
      width: heatmapWidth,
      height: heatmapHeight,
    );
    final metrics = ProcessingMetrics(
      width: width,
      height: height,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      psnr: psnr,
      ssim: ssim,
      touchedPixelsRatio: touchedRatio,
      meanAbsoluteError: meanAbsoluteError,
      perturbationStrength: perturbationStrength,
      frequencyStrength: frequencyStrength,
      featureDisruptionScore: featureDisruptionScore,
      embeddingInstabilityEstimate: embeddingInstabilityEstimate,
      styleDisruptionEstimate: styleDisruptionEstimate,
      semanticConfusionEstimate: semanticConfusionEstimate,
      reinterpretationResistanceEstimate: reinterpretationResistanceEstimate,
      imageFidelityEstimate: imageFidelityEstimate,
      aiResistanceScore: aiResistanceScore,
      imageProfile: analysis.profile,
      textureComplexity: analysis.textureComplexity,
      semanticCoverage: analysis.semanticCoverage,
      watermarkFingerprint: watermarkMetadata.fingerprint,
    );

    return AdversarialProcessResult(
      bytes: Uint8List.fromList(encodedBytes),
      heatmapBytes: heatmapBytes,
      metrics: metrics,
    );
  }

  static Uint8List _encodeHeatmap(
    Uint8List intensity, {
    required int width,
    required int height,
  }) {
    final heatmap = img.Image(width: width, height: height, numChannels: 4);

    for (var y = 0; y < height; y++) {
      final rowOffset = y * width;

      for (var x = 0; x < width; x++) {
        final value = intensity[rowOffset + x] / 255;
        final red = (255 * _smoothStep(0.34, 1.0, value)).round();
        final green = (230 * (1 - (value - 0.52).abs() * 1.6).clamp(0.0, 1.0))
            .round();
        final blue = (245 * (1 - _smoothStep(0.12, 0.72, value))).round();
        final alpha = (value * 188).round().clamp(0, 188).toInt();
        heatmap.setPixelRgba(x, y, red, green, blue, alpha);
      }
    }

    return Uint8List.fromList(img.encodePng(heatmap, level: 4));
  }

  static img.Image _resizeForPreview(img.Image source, int maxDimension) {
    final longestSide = math.max(source.width, source.height);

    if (longestSide <= maxDimension) {
      return source;
    }

    final scale = maxDimension / longestSide;
    return img.copyResize(
      source,
      width: (source.width * scale).round().clamp(1, maxDimension).toInt(),
      height: (source.height * scale).round().clamp(1, maxDimension).toInt(),
      interpolation: img.Interpolation.linear,
    );
  }

  static Uint8List _buildLuminance(img.Image source) {
    final width = source.width;
    final height = source.height;
    final luminance = Uint8List(width * height);

    for (var y = 0; y < height; y++) {
      final rowOffset = y * width;

      for (var x = 0; x < width; x++) {
        final pixel = source.getPixel(x, y);
        luminance[rowOffset + x] = _luminance(
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        ).round().clamp(0, 255).toInt();
      }
    }

    return luminance;
  }

  static _StructureMaps _buildStructureMaps({
    required Uint8List luminance,
    required int width,
    required int height,
    required ProcessingSettings settings,
  }) {
    final edge = Float32List(width * height);
    final highFrequency = Float32List(width * height);
    final texture = Float32List(width * height);
    final semantic = Float32List(width * height);
    final horizontalContour = Float32List(width * height);
    final sensitivity = settings.edgeSensitivity.clamp(0.0, 1.0).toDouble();
    final threshold = _lerpDouble(0.34, 0.06, sensitivity);

    for (var y = 0; y < height; y++) {
      final rowOffset = y * width;
      final yUp = y == 0 ? y : y - 1;
      final yDown = y == height - 1 ? y : y + 1;
      final upOffset = yUp * width;
      final downOffset = yDown * width;

      for (var x = 0; x < width; x++) {
        final index = rowOffset + x;
        final xLeft = x == 0 ? x : x - 1;
        final xRight = x == width - 1 ? x : x + 1;
        final topLeft = luminance[upOffset + xLeft];
        final top = luminance[upOffset + x];
        final topRight = luminance[upOffset + xRight];
        final left = luminance[rowOffset + xLeft];
        final center = luminance[index];
        final right = luminance[rowOffset + xRight];
        final bottomLeft = luminance[downOffset + xLeft];
        final bottom = luminance[downOffset + x];
        final bottomRight = luminance[downOffset + xRight];
        final gx =
            -topLeft -
            2 * left -
            bottomLeft +
            topRight +
            2 * right +
            bottomRight;
        final gy =
            -topLeft -
            2 * top -
            topRight +
            bottomLeft +
            2 * bottom +
            bottomRight;
        final gradient = (math.sqrt(gx * gx + gy * gy) / 1140)
            .clamp(0.0, 1.0)
            .toDouble();
        final horizontal = (gy.abs() / 1140).clamp(0.0, 1.0).toDouble();
        final laplacian =
            ((4 * center - left - right - top - bottom).abs() / 1020)
                .clamp(0.0, 1.0)
                .toDouble();

        final edgeValue = _smoothStep(threshold, 1.0, gradient);
        final highFrequencyValue = math
            .max(laplacian, _smoothStep(threshold * 0.72, 1.0, gradient))
            .toDouble();
        final textureValue = (laplacian * 0.62 + highFrequencyValue * 0.38)
            .clamp(0.0, 1.0)
            .toDouble();
        final horizontalValue = _smoothStep(threshold * 0.64, 1.0, horizontal);
        final semanticValue = math
            .max(
              edgeValue,
              math.max(textureValue * 0.88, horizontalValue * 0.74),
            )
            .toDouble();

        edge[index] = edgeValue;
        highFrequency[index] = highFrequencyValue;
        texture[index] = textureValue;
        horizontalContour[index] = horizontalValue;
        semantic[index] = semanticValue;
      }
    }

    return _StructureMaps(
      edge: edge,
      highFrequency: highFrequency,
      texture: texture,
      semantic: semantic,
      horizontalContour: horizontalContour,
    );
  }

  static _ImageAnalysis _analyzeImage({
    required img.Image source,
    required _StructureMaps structure,
    required int width,
    required int height,
  }) {
    final pixelCount = width * height;
    var edgeSum = 0.0;
    var textureSum = 0.0;
    var horizontalSum = 0.0;
    var faceSum = 0.0;
    var semanticPixels = 0;
    var centralSamples = 0;
    var skinLikeSamples = 0;

    for (var y = 0; y < height; y++) {
      final rowOffset = y * width;

      for (var x = 0; x < width; x++) {
        final index = rowOffset + x;
        final semanticValue = structure.semantic[index];
        edgeSum += structure.edge[index];
        textureSum += structure.texture[index];
        horizontalSum += structure.horizontalContour[index];
        faceSum += _faceRegionPrior(x, y, width, height);
        final nx = (x + 0.5) / width;
        final ny = (y + 0.5) / height;
        final centralX = (nx - 0.5) / 0.32;
        final centralY = (ny - 0.48) / 0.40;

        if (semanticValue > 0.25) {
          semanticPixels++;
        }

        if (centralX * centralX + centralY * centralY < 1) {
          centralSamples++;
          final pixel = source.getPixel(x, y);

          if (_isSkinLike(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt())) {
            skinLikeSamples++;
          }
        }
      }
    }

    final colorBucketCount = _sampleColorBucketCount(source);
    final edgeDensity = edgeSum / pixelCount;
    final textureComplexity = textureSum / pixelCount;
    final semanticCoverage = semanticPixels / pixelCount;
    final horizontalStrength = horizontalSum / pixelCount;
    final faceCoverage = faceSum / pixelCount;
    final portraitEvidence = centralSamples == 0
        ? 0.0
        : skinLikeSamples / centralSamples;
    final isWideLandscape = width > height * 1.16;
    final lowPalette = colorBucketCount < 96;
    final profile = switch ((
      portraitEvidence,
      isWideLandscape,
      horizontalStrength,
      textureComplexity,
      edgeDensity,
      lowPalette,
      semanticCoverage,
    )) {
      (_, true, > 0.08, _, _, _, _) => ImageProfile.landscape,
      (> 0.22, _, _, _, _, _, _) => ImageProfile.portrait,
      (_, _, _, > 0.18, _, _, _) => ImageProfile.textureHeavy,
      (_, _, _, _, > 0.10, true, _) => ImageProfile.illustration,
      (_, _, _, < 0.045, < 0.045, _, < 0.06) => ImageProfile.lowDetail,
      _ => ImageProfile.general,
    };

    return _ImageAnalysis(
      profile: profile,
      edgeDensity: edgeDensity,
      textureComplexity: textureComplexity,
      semanticCoverage: semanticCoverage,
      horizontalStrength: horizontalStrength,
      faceCoverage: faceCoverage,
    );
  }

  static int _sampleColorBucketCount(img.Image source) {
    final buckets = <int>{};
    final pixelCount = source.width * source.height;
    final step = math.max(1, pixelCount ~/ 4096);

    for (var index = 0; index < pixelCount; index += step) {
      final x = index % source.width;
      final y = index ~/ source.width;
      final pixel = source.getPixel(x, y);
      final r = pixel.r.toInt() >> 4;
      final g = pixel.g.toInt() >> 4;
      final b = pixel.b.toInt() >> 4;
      buckets.add((r << 8) | (g << 4) | b);
    }

    return buckets.length;
  }

  static bool _isSkinLike(int r, int g, int b) {
    final maxChannel = math.max(r, math.max(g, b));
    final minChannel = math.min(r, math.min(g, b));
    return r > 85 &&
        g > 35 &&
        b > 20 &&
        maxChannel - minChannel > 14 &&
        r > g &&
        r > b &&
        (r - g).abs() > 8;
  }

  static double _sceneAdaptiveWeight({
    required ImageProfile profile,
    required double edgeWeight,
    required double highFrequency,
    required double textureWeight,
    required double semanticWeight,
    required double horizonWeight,
  }) {
    return switch (profile) {
      ImageProfile.portrait =>
        semanticWeight * 0.20 + textureWeight * 0.10 + edgeWeight * 0.12,
      ImageProfile.landscape =>
        horizonWeight * 0.30 + edgeWeight * 0.22 + textureWeight * 0.20,
      ImageProfile.illustration =>
        edgeWeight * 0.30 + semanticWeight * 0.24 + highFrequency * 0.12,
      ImageProfile.lowDetail =>
        semanticWeight * 0.18 + edgeWeight * 0.16 + textureWeight * 0.10,
      ImageProfile.textureHeavy =>
        textureWeight * 0.34 + highFrequency * 0.24 + edgeWeight * 0.14,
      ImageProfile.general =>
        semanticWeight * 0.24 + edgeWeight * 0.20 + textureWeight * 0.18,
    };
  }

  static int _perturbChannel(
    int channel,
    int bitCount,
    _SeededNoise noise,
    double structuredWeight,
    double protectionStrength, {
    required double channelScale,
    required double frequencyDelta,
  }) {
    var value = _injectLeastSignificantBits(
      channel,
      bitCount,
      noise.nextUint32(),
    );

    if (structuredWeight > 0.035) {
      final probability = (0.16 + structuredWeight * 0.74)
          .clamp(0.0, 0.92)
          .toDouble();

      if (noise.nextUnit() < probability) {
        final amplitude =
            (protectionStrength * channelScale * (1.0 + structuredWeight * 4.2))
                .round()
                .clamp(1, 6)
                .toInt();
        value += noise.nextSigned(amplitude);
      }
    }

    return (value + frequencyDelta.round()).toInt();
  }

  static double _frequencyPattern({
    required int x,
    required int y,
    required int seed,
    required double edgeWeight,
    required double highFrequency,
    required double facePrior,
    required double strength,
  }) {
    if (strength <= 0) {
      return 0;
    }

    final blockX = x >> 3;
    final blockY = y >> 3;
    final localX = x & 7;
    final localY = y & 7;
    final hash = _blockHash(blockX, blockY, seed);
    final sign = hash.isEven ? 1.0 : -1.0;
    final phase = ((hash >> 9) & 7) * math.pi / 8;
    final u = localX + 0.5;
    final v = localY + 0.5;
    final basisA =
        math.cos((2 * u + 1) * math.pi / 8 + phase) *
        math.cos((3 * v + 1) * math.pi / 8);
    final basisB =
        math.cos((3 * u + 1) * math.pi / 8) *
        math.cos((2 * v + 1) * math.pi / 8 + phase * 0.5);
    final featureBoost =
        (0.72 + edgeWeight * 0.32 + highFrequency * 0.24 + facePrior * 0.34)
            .clamp(0.65, 1.46)
            .toDouble();

    return (basisA * 0.58 + basisB * 0.42) *
        sign *
        strength *
        featureBoost *
        2.35;
  }

  static int _mixSeed(
    int seed,
    int width,
    int height,
    int byteLength,
    int temporalFrame,
  ) {
    var value = seed & 0xffffffff;
    value ^= (width * 0x45d9f3b) & 0xffffffff;
    value ^= (height * 0x119de1f3) & 0xffffffff;
    value ^= (byteLength * 0x27d4eb2d) & 0xffffffff;
    value ^= (temporalFrame * 0x165667b1) & 0xffffffff;
    return value == 0 ? 0x6d2b79f5 : value;
  }

  static int _blockHash(int blockX, int blockY, int seed) {
    var value = seed & 0xffffffff;
    value ^= (blockX * 0x9e3779b9) & 0xffffffff;
    value ^= (blockY * 0x85ebca6b) & 0xffffffff;
    value ^= value >> 16;
    value = (value * 0x7feb352d) & 0xffffffff;
    value ^= value >> 15;
    return value & 0xffffffff;
  }

  static int _injectLeastSignificantBits(
    int channel,
    int bitCount,
    int randomBits,
  ) {
    final mask = (1 << bitCount) - 1;
    return (channel & ~mask) | (randomBits & mask);
  }

  static double _faceRegionPrior(int x, int y, int width, int height) {
    if (width < 2 || height < 2) {
      return 0;
    }

    final nx = (x + 0.5) / width;
    final ny = (y + 0.5) / height;
    final faceX = (nx - 0.5) / 0.29;
    final faceY = (ny - 0.47) / 0.38;
    final ellipse = faceX * faceX + faceY * faceY;
    final faceCore = ellipse < 1 ? (1 - ellipse) * 0.18 : 0.0;
    final contour = ellipse > 0.66 && ellipse < 1.13
        ? (1 - ((ellipse - 0.9).abs() / 0.24)).clamp(0.0, 1.0) * 0.62
        : 0.0;
    final leftEye = _gaussian2d(nx, ny, 0.39, 0.38, 0.045, 0.025) * 0.96;
    final rightEye = _gaussian2d(nx, ny, 0.61, 0.38, 0.045, 0.025) * 0.96;
    final leftBrow = _gaussian2d(nx, ny, 0.39, 0.33, 0.06, 0.018) * 0.72;
    final rightBrow = _gaussian2d(nx, ny, 0.61, 0.33, 0.06, 0.018) * 0.72;
    final noseBridge = _gaussian2d(nx, ny, 0.5, 0.41, 0.028, 0.075) * 0.74;
    final nose = _gaussian2d(nx, ny, 0.5, 0.49, 0.038, 0.08) * 0.72;
    final mouth = _gaussian2d(nx, ny, 0.5, 0.62, 0.095, 0.032) * 0.82;
    final leftMouthEdge = _gaussian2d(nx, ny, 0.41, 0.62, 0.025, 0.034) * 0.74;
    final rightMouthEdge = _gaussian2d(nx, ny, 0.59, 0.62, 0.025, 0.034) * 0.74;
    final jaw = _gaussian2d(nx, ny, 0.5, 0.72, 0.22, 0.036) * 0.62;
    final hairBoundary = _gaussian2d(nx, ny, 0.5, 0.24, 0.24, 0.05) * 0.58;

    return (faceCore +
            contour +
            leftEye +
            rightEye +
            leftBrow +
            rightBrow +
            noseBridge +
            nose +
            mouth +
            leftMouthEdge +
            rightMouthEdge +
            jaw +
            hairBoundary)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _gaussian2d(
    double x,
    double y,
    double cx,
    double cy,
    double sx,
    double sy,
  ) {
    final dx = (x - cx) / sx;
    final dy = (y - cy) / sy;
    return math.exp(-0.5 * (dx * dx + dy * dy));
  }

  static double _luminance(int r, int g, int b) {
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  static int _clamp8(int value) => value.clamp(0, 255).toInt();

  static double _smoothStep(double edge0, double edge1, double value) {
    if (edge0 == edge1) {
      return value >= edge1 ? 1 : 0;
    }

    final t = ((value - edge0) / (edge1 - edge0)).clamp(0.0, 1.0).toDouble();
    return t * t * (3 - 2 * t);
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static double _psnr(double mse) {
    if (mse <= 0) {
      return double.infinity;
    }

    return 10 * math.log((255 * 255) / mse) / math.ln10;
  }

  static double _ssim({
    required int samples,
    required double xSum,
    required double ySum,
    required double xSqSum,
    required double ySqSum,
    required double xySum,
  }) {
    final count = samples.toDouble();
    final meanX = xSum / count;
    final meanY = ySum / count;
    final varianceX = xSqSum / count - meanX * meanX;
    final varianceY = ySqSum / count - meanY * meanY;
    final covariance = xySum / count - meanX * meanY;
    const c1 = 6.5025;
    const c2 = 58.5225;
    final numerator = (2 * meanX * meanY + c1) * (2 * covariance + c2);
    final denominator =
        (meanX * meanX + meanY * meanY + c1) * (varianceX + varianceY + c2);

    if (denominator == 0) {
      return 1;
    }

    return (numerator / denominator).clamp(0.0, 1.0).toDouble();
  }
}

class _StructureMaps {
  const _StructureMaps({
    required this.edge,
    required this.highFrequency,
    required this.texture,
    required this.semantic,
    required this.horizontalContour,
  });

  final Float32List edge;
  final Float32List highFrequency;
  final Float32List texture;
  final Float32List semantic;
  final Float32List horizontalContour;
}

class _ImageAnalysis {
  const _ImageAnalysis({
    required this.profile,
    required this.edgeDensity,
    required this.textureComplexity,
    required this.semanticCoverage,
    required this.horizontalStrength,
    required this.faceCoverage,
  });

  final ImageProfile profile;
  final double edgeDensity;
  final double textureComplexity;
  final double semanticCoverage;
  final double horizontalStrength;
  final double faceCoverage;
}

class _SeededNoise {
  _SeededNoise(int seed) : _state = seed & 0xffffffff;

  int _state;

  int nextUint32() {
    var x = _state;
    x ^= (x << 13) & 0xffffffff;
    x ^= x >> 17;
    x ^= (x << 5) & 0xffffffff;
    _state = x & 0xffffffff;
    return _state;
  }

  double nextUnit() => nextUint32() / 0xffffffff;

  int nextSigned(int amplitude) {
    if (amplitude <= 0) {
      return 0;
    }

    return (nextUint32() % (amplitude * 2 + 1)) - amplitude;
  }
}
