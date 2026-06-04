import '../../core/platform/app_platform.dart';
import 'camera_capture_service_base.dart';
import 'camera_capture_service_stub.dart'
    if (dart.library.io) 'camera_capture_service_io.dart'
    as platform_camera;

CameraCaptureService createCameraCaptureService(AppPlatform platform) {
  return platform_camera.createCameraCaptureService(platform);
}
