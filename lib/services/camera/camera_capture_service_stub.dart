import '../../core/platform/app_platform.dart';
import 'camera_capture_service_base.dart';

CameraCaptureService createCameraCaptureService(AppPlatform platform) {
  return const UnsupportedCameraCaptureService();
}

class UnsupportedCameraCaptureService implements CameraCaptureService {
  const UnsupportedCameraCaptureService();

  @override
  Future<CameraAvailability> checkAvailability() async {
    return const CameraAvailability.unavailable(
      'Camera capture is not available on this device.',
    );
  }

  @override
  Future<CapturedImageInput?> capturePhoto() async {
    throw StateError('Camera capture is not available on this platform.');
  }
}
