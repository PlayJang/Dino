import 'dart:typed_data';

class CameraAvailability {
  const CameraAvailability.available({required this.label})
    : isAvailable = true,
      message = null;

  const CameraAvailability.unavailable(this.message)
    : isAvailable = false,
      label = null;

  final bool isAvailable;
  final String? label;
  final String? message;
}

class CapturedImageInput {
  const CapturedImageInput({required this.bytes, required this.sourceName});

  final Uint8List bytes;
  final String sourceName;
}

abstract class CameraCaptureService {
  Future<CameraAvailability> checkAvailability();

  Future<CapturedImageInput?> capturePhoto();
}
