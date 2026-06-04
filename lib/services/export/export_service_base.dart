import 'dart:typed_data';

import '../../features/protection/domain/protection_models.dart';

class PreparedExport {
  const PreparedExport({
    required this.path,
    required this.fileName,
    required this.isLocalFile,
  });

  final String path;
  final String fileName;
  final bool isLocalFile;
}

class ExportSaveResult {
  const ExportSaveResult({required this.saved, this.path, this.message});

  const ExportSaveResult.cancelled()
    : saved = false,
      path = null,
      message = null;

  final bool saved;
  final String? path;
  final String? message;
}

abstract class ExportService {
  Future<PreparedExport> prepareWorkingCopy({
    required Uint8List bytes,
    required ProcessingSettings settings,
  });

  Future<ExportSaveResult> saveImage({
    required Uint8List bytes,
    required String workingPath,
    required String fileName,
    required ProcessingSettings settings,
  });
}
