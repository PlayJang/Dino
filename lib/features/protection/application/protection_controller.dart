import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/image_processing/image_processing_isolate.dart';
import '../../../services/export/export_service_base.dart';
import '../../../services/import/image_import_service.dart';
import '../domain/protection_models.dart';

class ProtectionState {
  const ProtectionState({
    required this.settings,
    required this.stage,
    required this.history,
    this.activeRecord,
    this.errorMessage,
    this.statusMessage,
  });

  const ProtectionState.initial()
    : settings = const ProcessingSettings.defaults(),
      stage = ProcessingStage.idle,
      history = const <ProtectedImageRecord>[],
      activeRecord = null,
      errorMessage = null,
      statusMessage = null;

  static const _unset = Object();

  final ProcessingSettings settings;
  final ProcessingStage stage;
  final ProtectedImageRecord? activeRecord;
  final List<ProtectedImageRecord> history;
  final String? errorMessage;
  final String? statusMessage;

  bool get isBusy => stage != ProcessingStage.idle;
  bool get isProcessing => stage == ProcessingStage.processing;

  ProtectionState copyWith({
    ProcessingSettings? settings,
    ProcessingStage? stage,
    List<ProtectedImageRecord>? history,
    Object? activeRecord = _unset,
    Object? errorMessage = _unset,
    Object? statusMessage = _unset,
  }) {
    return ProtectionState(
      settings: settings ?? this.settings,
      stage: stage ?? this.stage,
      history: history ?? this.history,
      activeRecord: identical(activeRecord, _unset)
          ? this.activeRecord
          : activeRecord as ProtectedImageRecord?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      statusMessage: identical(statusMessage, _unset)
          ? this.statusMessage
          : statusMessage as String?,
    );
  }
}

class ProtectionController extends StateNotifier<ProtectionState> {
  ProtectionController({
    required ImageImportService imageImportService,
    required ExportService exportService,
  }) : _imageImportService = imageImportService,
       _exportService = exportService,
       super(const ProtectionState.initial());

  final ImageImportService _imageImportService;
  final ExportService _exportService;

  void setProtectionMode(ProtectionMode mode) {
    final current = state.settings;
    state = state.copyWith(
      settings: ProcessingSettings.preset(
        mode,
        seed: current.seed,
        exportFormat: current.exportFormat,
        jpegQuality: current.jpegQuality,
      ),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setSeed(int seed) {
    state = state.copyWith(
      settings: state.settings.copyWith(seed: seed),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setLsbBits(int bits) {
    state = state.copyWith(
      settings: state.settings.copyWith(lsbBits: bits),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setProtectionStrength(double strength) {
    state = state.copyWith(
      settings: state.settings.copyWith(protectionStrength: strength),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setEdgeSensitivity(double sensitivity) {
    state = state.copyWith(
      settings: state.settings.copyWith(edgeSensitivity: sensitivity),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setFrequencyStrength(double strength) {
    state = state.copyWith(
      settings: state.settings.copyWith(frequencyStrength: strength),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setFaceWeight(double weight) {
    state = state.copyWith(
      settings: state.settings.copyWith(faceWeight: weight),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setExportFormat(ExportFormat format) {
    state = state.copyWith(
      settings: state.settings.copyWith(exportFormat: format),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void setJpegQuality(int quality) {
    state = state.copyWith(
      settings: state.settings.copyWith(jpegQuality: quality),
      errorMessage: null,
      statusMessage: null,
    );
  }

  void resetSettings() {
    state = state.copyWith(
      settings: const ProcessingSettings.defaults(),
      errorMessage: null,
      statusMessage: 'Settings reset.',
    );
  }

  void setCameraOpening() {
    state = state.copyWith(
      stage: ProcessingStage.capturing,
      errorMessage: null,
      statusMessage: 'Opening camera...',
    );
  }

  void cancelPendingAction() {
    if (state.stage == ProcessingStage.capturing ||
        state.stage == ProcessingStage.picking) {
      state = state.copyWith(
        stage: ProcessingStage.idle,
        statusMessage: null,
        errorMessage: null,
      );
    }
  }

  Future<ProtectedImageRecord?> pickAndProcessImage() async {
    state = state.copyWith(
      stage: ProcessingStage.picking,
      errorMessage: null,
      statusMessage: 'Opening image picker...',
    );

    try {
      final input = await _imageImportService.pickImage();

      if (input == null) {
        state = state.copyWith(
          stage: ProcessingStage.idle,
          statusMessage: null,
        );
        return null;
      }

      return processBytes(
        bytes: input.bytes,
        sourceKind: input.sourceKind,
        sourceName: input.sourceName,
      );
    } on Object catch (error) {
      state = state.copyWith(
        stage: ProcessingStage.idle,
        errorMessage: _friendlyError(error),
        statusMessage: null,
      );
      return null;
    }
  }

  Future<ProtectedImageRecord?> reprocessActiveImage() async {
    final active = state.activeRecord;

    if (active == null) {
      state = state.copyWith(
        errorMessage: 'Choose or capture an image before reprocessing.',
        statusMessage: null,
      );
      return null;
    }

    return processBytes(
      bytes: active.originalBytes,
      sourceKind: active.sourceKind,
      sourceName: active.sourceName,
    );
  }

  Future<ProtectedImageRecord?> processBytes({
    required Uint8List bytes,
    required SourceKind sourceKind,
    required String sourceName,
  }) async {
    state = state.copyWith(
      stage: ProcessingStage.processing,
      errorMessage: null,
      statusMessage: 'Processing $sourceName...',
    );

    try {
      final settings = state.settings;
      final result = await processImageOnWorker(
        AdversarialProcessRequest(
          bytes: bytes,
          settings: settings,
          temporalFrame: sourceKind == SourceKind.camera
              ? DateTime.now().millisecondsSinceEpoch
              : null,
          watermarkTimestampIso: DateTime.now().toUtc().toIso8601String(),
        ),
      );
      final export = await _exportService.prepareWorkingCopy(
        bytes: result.bytes,
        settings: settings,
      );
      final record = ProtectedImageRecord(
        sourceKind: sourceKind,
        sourceName: sourceName,
        originalBytes: bytes,
        processedBytes: result.bytes,
        heatmapBytes: result.heatmapBytes,
        outputPath: export.path,
        outputName: export.fileName,
        hasLocalOutputFile: export.isLocalFile,
        settings: settings,
        metrics: result.metrics,
        createdAt: DateTime.now(),
      );
      final history = _upsertRecord(record, state.history);

      state = state.copyWith(
        stage: ProcessingStage.idle,
        activeRecord: record,
        history: history,
        errorMessage: null,
        statusMessage: 'Processing complete.',
      );

      return record;
    } on Object catch (error) {
      state = state.copyWith(
        stage: ProcessingStage.idle,
        errorMessage: _friendlyError(error),
        statusMessage: null,
      );
      return null;
    }
  }

  Future<void> saveActiveImage() async {
    final active = state.activeRecord;

    if (active == null) {
      state = state.copyWith(
        errorMessage: 'Process an image before saving.',
        statusMessage: null,
      );
      return;
    }

    state = state.copyWith(
      stage: ProcessingStage.saving,
      errorMessage: null,
      statusMessage: 'Saving image...',
    );

    try {
      final result = await _exportService.saveImage(
        bytes: active.processedBytes,
        workingPath: active.outputPath,
        fileName: active.outputName,
        settings: active.settings,
      );

      if (!result.saved) {
        state = state.copyWith(
          stage: ProcessingStage.idle,
          statusMessage: null,
        );
        return;
      }

      final updated = active.copyWith(savedAt: DateTime.now());
      state = state.copyWith(
        stage: ProcessingStage.idle,
        activeRecord: updated,
        history: _replaceRecord(updated, state.history),
        errorMessage: null,
        statusMessage: result.message ?? 'Image saved.',
      );
    } on Object catch (error) {
      state = state.copyWith(
        stage: ProcessingStage.idle,
        errorMessage: _friendlyError(error),
        statusMessage: null,
      );
    }
  }

  void selectRecord(ProtectedImageRecord record) {
    state = state.copyWith(
      activeRecord: record,
      errorMessage: null,
      statusMessage: 'Loaded ${record.sourceName}.',
    );
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, statusMessage: null);
  }

  List<ProtectedImageRecord> _upsertRecord(
    ProtectedImageRecord record,
    List<ProtectedImageRecord> history,
  ) {
    return <ProtectedImageRecord>[
      record,
      ...history.where((item) => item.outputPath != record.outputPath),
    ].take(8).toList(growable: false);
  }

  List<ProtectedImageRecord> _replaceRecord(
    ProtectedImageRecord record,
    List<ProtectedImageRecord> history,
  ) {
    return history
        .map((item) => item.outputPath == record.outputPath ? record : item)
        .toList(growable: false);
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }

    if (message.startsWith('FormatException: ')) {
      return message.substring('FormatException: '.length);
    }

    return message;
  }
}
