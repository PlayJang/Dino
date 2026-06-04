import 'dart:typed_data';

enum ExportFormat {
  png,
  jpeg;

  String get label => switch (this) {
    ExportFormat.png => 'PNG',
    ExportFormat.jpeg => 'JPEG',
  };

  String get extension => switch (this) {
    ExportFormat.png => 'png',
    ExportFormat.jpeg => 'jpg',
  };
}

enum SourceKind {
  camera,
  gallery,
  file;

  String get label => switch (this) {
    SourceKind.camera => 'Camera',
    SourceKind.gallery => 'Gallery',
    SourceKind.file => 'File',
  };
}

enum ProcessingStage {
  idle,
  picking,
  capturing,
  processing,
  saving;

  String get label => switch (this) {
    ProcessingStage.idle => 'Ready',
    ProcessingStage.picking => 'Opening gallery',
    ProcessingStage.capturing => 'Opening camera',
    ProcessingStage.processing => 'Processing',
    ProcessingStage.saving => 'Saving',
  };
}

enum ProtectionMode { social, balanced, maximum }

enum ImageProfile {
  portrait,
  landscape,
  illustration,
  lowDetail,
  textureHeavy,
  general,
}

class ProcessingSettings {
  const ProcessingSettings({
    required this.mode,
    required this.seed,
    required this.lsbBits,
    required this.protectionStrength,
    required this.edgeSensitivity,
    required this.frequencyStrength,
    required this.faceWeight,
    required this.exportFormat,
    required this.jpegQuality,
  });

  const ProcessingSettings.defaults()
    : mode = ProtectionMode.balanced,
      seed = 133742,
      lsbBits = 1,
      protectionStrength = 0.58,
      edgeSensitivity = 0.62,
      frequencyStrength = 0.34,
      faceWeight = 0.68,
      exportFormat = ExportFormat.png,
      jpegQuality = 94;

  factory ProcessingSettings.preset(
    ProtectionMode mode, {
    int seed = 133742,
    ExportFormat exportFormat = ExportFormat.png,
    int jpegQuality = 94,
  }) {
    return switch (mode) {
      ProtectionMode.social => ProcessingSettings(
        mode: mode,
        seed: seed,
        lsbBits: 1,
        protectionStrength: 0.34,
        edgeSensitivity: 0.42,
        frequencyStrength: 0.18,
        faceWeight: 0.44,
        exportFormat: exportFormat,
        jpegQuality: jpegQuality,
      ),
      ProtectionMode.balanced => ProcessingSettings(
        mode: mode,
        seed: seed,
        lsbBits: 1,
        protectionStrength: 0.58,
        edgeSensitivity: 0.62,
        frequencyStrength: 0.34,
        faceWeight: 0.68,
        exportFormat: exportFormat,
        jpegQuality: jpegQuality,
      ),
      ProtectionMode.maximum => ProcessingSettings(
        mode: mode,
        seed: seed,
        lsbBits: 2,
        protectionStrength: 0.86,
        edgeSensitivity: 0.86,
        frequencyStrength: 0.72,
        faceWeight: 0.94,
        exportFormat: exportFormat,
        jpegQuality: jpegQuality,
      ),
    };
  }

  final ProtectionMode mode;
  final int seed;
  final int lsbBits;
  final double protectionStrength;
  final double edgeSensitivity;
  final double frequencyStrength;
  final double faceWeight;
  final ExportFormat exportFormat;
  final int jpegQuality;

  ProcessingSettings copyWith({
    ProtectionMode? mode,
    int? seed,
    int? lsbBits,
    double? protectionStrength,
    double? edgeSensitivity,
    double? frequencyStrength,
    double? faceWeight,
    ExportFormat? exportFormat,
    int? jpegQuality,
  }) {
    return ProcessingSettings(
      mode: mode ?? this.mode,
      seed: seed ?? this.seed,
      lsbBits: lsbBits ?? this.lsbBits,
      protectionStrength: protectionStrength ?? this.protectionStrength,
      edgeSensitivity: edgeSensitivity ?? this.edgeSensitivity,
      frequencyStrength: frequencyStrength ?? this.frequencyStrength,
      faceWeight: faceWeight ?? this.faceWeight,
      exportFormat: exportFormat ?? this.exportFormat,
      jpegQuality: jpegQuality ?? this.jpegQuality,
    );
  }
}

class ProcessingMetrics {
  const ProcessingMetrics({
    required this.width,
    required this.height,
    required this.elapsedMilliseconds,
    required this.psnr,
    required this.ssim,
    required this.touchedPixelsRatio,
    required this.meanAbsoluteError,
    required this.perturbationStrength,
    required this.frequencyStrength,
    required this.featureDisruptionScore,
    required this.embeddingInstabilityEstimate,
    required this.styleDisruptionEstimate,
    required this.semanticConfusionEstimate,
    required this.reinterpretationResistanceEstimate,
    required this.imageFidelityEstimate,
    required this.aiResistanceScore,
    required this.imageProfile,
    required this.textureComplexity,
    required this.semanticCoverage,
    required this.watermarkFingerprint,
  });

  final int width;
  final int height;
  final int elapsedMilliseconds;
  final double psnr;
  final double ssim;
  final double touchedPixelsRatio;
  final double meanAbsoluteError;
  final double perturbationStrength;
  final double frequencyStrength;
  final double featureDisruptionScore;
  final double embeddingInstabilityEstimate;
  final double styleDisruptionEstimate;
  final double semanticConfusionEstimate;
  final double reinterpretationResistanceEstimate;
  final double imageFidelityEstimate;
  final double aiResistanceScore;
  final ImageProfile imageProfile;
  final double textureComplexity;
  final double semanticCoverage;
  final String watermarkFingerprint;
}

class AdversarialProcessRequest {
  const AdversarialProcessRequest({
    required this.bytes,
    required this.settings,
    this.previewMaxDimension,
    this.temporalFrame,
    this.watermarkTimestampIso,
    this.embedWatermark = true,
  });

  final Uint8List bytes;
  final ProcessingSettings settings;
  final int? previewMaxDimension;
  final int? temporalFrame;
  final String? watermarkTimestampIso;
  final bool embedWatermark;
}

class AdversarialProcessResult {
  const AdversarialProcessResult({
    required this.bytes,
    required this.heatmapBytes,
    required this.metrics,
  });

  final Uint8List bytes;
  final Uint8List heatmapBytes;
  final ProcessingMetrics metrics;
}

class ProtectedImageRecord {
  const ProtectedImageRecord({
    required this.sourceKind,
    required this.sourceName,
    required this.originalBytes,
    required this.processedBytes,
    required this.heatmapBytes,
    required this.outputPath,
    required this.outputName,
    required this.hasLocalOutputFile,
    required this.settings,
    required this.metrics,
    required this.createdAt,
    this.savedAt,
  });

  final SourceKind sourceKind;
  final String sourceName;
  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final Uint8List heatmapBytes;
  final String outputPath;
  final String outputName;
  final bool hasLocalOutputFile;
  final ProcessingSettings settings;
  final ProcessingMetrics metrics;
  final DateTime createdAt;
  final DateTime? savedAt;

  bool get isSaved => savedAt != null;

  ProtectedImageRecord copyWith({
    String? outputPath,
    String? outputName,
    bool? hasLocalOutputFile,
    ProcessingMetrics? metrics,
    DateTime? savedAt,
  }) {
    return ProtectedImageRecord(
      sourceKind: sourceKind,
      sourceName: sourceName,
      originalBytes: originalBytes,
      processedBytes: processedBytes,
      heatmapBytes: heatmapBytes,
      outputPath: outputPath ?? this.outputPath,
      outputName: outputName ?? this.outputName,
      hasLocalOutputFile: hasLocalOutputFile ?? this.hasLocalOutputFile,
      settings: settings,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

class DinoWatermarkMetadata {
  const DinoWatermarkMetadata({
    required this.message,
    required this.protectedAtIso,
    required this.fingerprint,
    required this.mode,
  });

  final String message;
  final String protectedAtIso;
  final String fingerprint;
  final ProtectionMode mode;
}

class WatermarkVerificationResult {
  const WatermarkVerificationResult({
    required this.detected,
    required this.confidence,
    this.metadata,
    this.errorMessage,
  });

  final bool detected;
  final double confidence;
  final DinoWatermarkMetadata? metadata;
  final String? errorMessage;
}
