import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../features/protection/domain/protection_models.dart';
import 'export_service_base.dart';

ExportService createExportService() => const IoExportService();

class IoExportService implements ExportService {
  const IoExportService();

  @override
  Future<PreparedExport> prepareWorkingCopy({
    required Uint8List bytes,
    required ProcessingSettings settings,
  }) async {
    final directory = Directory(
      _joinPath(Directory.systemTemp.path, 'dino_protected_images'),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileName = _fileName(settings);
    final file = File(_joinPath(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);

    return PreparedExport(
      path: file.path,
      fileName: fileName,
      isLocalFile: true,
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
    );

    if (path == null) {
      return const ExportSaveResult.cancelled();
    }

    final normalizedPath = _ensureExtension(path, settings.exportFormat);
    final output = File(normalizedPath);
    await output.writeAsBytes(bytes, flush: true);

    return ExportSaveResult(
      saved: true,
      path: output.path,
      message: 'Exported to ${output.path}',
    );
  }

  String _fileName(ProcessingSettings settings) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return 'protected_${timestamp}_seed${settings.seed}.${settings.exportFormat.extension}';
  }

  String _ensureExtension(String path, ExportFormat format) {
    final extension = '.${format.extension}'.toLowerCase();

    if (path.toLowerCase().endsWith(extension)) {
      return path;
    }

    return '$path$extension';
  }

  String _joinPath(String left, String right) {
    final separator = Platform.pathSeparator;

    if (left.endsWith(separator)) {
      return '$left$right';
    }

    return '$left$separator$right';
  }
}
