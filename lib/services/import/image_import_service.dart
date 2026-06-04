import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../core/platform/app_platform.dart';
import '../../features/protection/domain/protection_models.dart';

class PickedImageInput {
  const PickedImageInput({
    required this.bytes,
    required this.sourceName,
    required this.sourceKind,
  });

  final Uint8List bytes;
  final String sourceName;
  final SourceKind sourceKind;
}

class ImageImportService {
  const ImageImportService({required AppPlatform platform})
    : _platform = platform;

  final AppPlatform _platform;

  Future<PickedImageInput?> pickImage() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'bmp', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes ?? await file.xFile.readAsBytes();

    return PickedImageInput(
      bytes: bytes,
      sourceName: file.name,
      sourceKind: _platform.usesDesktopFilePicker
          ? SourceKind.file
          : SourceKind.gallery,
    );
  }
}
