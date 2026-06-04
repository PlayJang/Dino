import 'dart:typed_data';

import '../../features/protection/domain/protection_models.dart';
import 'export_service_base.dart';

ExportService createExportService() => const UnsupportedExportService();

class UnsupportedExportService implements ExportService {
  const UnsupportedExportService();

  @override
  Future<PreparedExport> prepareWorkingCopy({
    required Uint8List bytes,
    required ProcessingSettings settings,
  }) {
    throw UnsupportedError('Image export is not supported on this platform.');
  }

  @override
  Future<ExportSaveResult> saveImage({
    required Uint8List bytes,
    required String workingPath,
    required String fileName,
    required ProcessingSettings settings,
  }) {
    throw UnsupportedError('Image export is not supported on this platform.');
  }
}
