import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../features/protection/domain/protection_models.dart';
import 'export_service_base.dart';

ExportService createExportService() => const WebExportService();

class WebExportService implements ExportService {
  const WebExportService();

  @override
  Future<PreparedExport> prepareWorkingCopy({
    required Uint8List bytes,
    required ProcessingSettings settings,
  }) async {
    final fileName = _fileName(settings);

    return PreparedExport(
      path: fileName,
      fileName: fileName,
      isLocalFile: false,
    );
  }

  @override
  Future<ExportSaveResult> saveImage({
    required Uint8List bytes,
    required String workingPath,
    required String fileName,
    required ProcessingSettings settings,
  }) async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Export protected image',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [settings.exportFormat.extension],
      bytes: bytes,
    );

    if (path == null) {
      return const ExportSaveResult.cancelled();
    }

    return ExportSaveResult(
      saved: true,
      path: path,
      message: 'Export started.',
    );
  }

  String _fileName(ProcessingSettings settings) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return 'protected_${timestamp}_seed${settings.seed}.${settings.exportFormat.extension}';
  }
}
