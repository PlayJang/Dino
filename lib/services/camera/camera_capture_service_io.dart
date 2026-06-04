import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../core/platform/app_platform.dart';
import 'camera_capture_service_base.dart';
import 'camera_capture_service_stub.dart';

CameraCaptureService createCameraCaptureService(AppPlatform platform) {
  if (platform.family == PlatformFamily.windows) {
    return const WindowsCameraCaptureService();
  }

  if (platform.isMobile) {
    return MobileCameraCaptureService();
  }

  return const UnsupportedCameraCaptureService();
}

class MobileCameraCaptureService implements CameraCaptureService {
  MobileCameraCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CameraAvailability> checkAvailability() async {
    return const CameraAvailability.available(label: 'Device camera');
  }

  @override
  Future<CapturedImageInput?> capturePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      requestFullMetadata: false,
    );

    if (image == null) {
      return null;
    }

    final bytes = await image.readAsBytes();

    if (bytes.isEmpty) {
      throw StateError('The camera returned an empty image.');
    }

    final sourceName = image.name.isEmpty
        ? 'camera_${DateTime.now().toUtc().millisecondsSinceEpoch}.jpg'
        : image.name;
    return CapturedImageInput(bytes: bytes, sourceName: sourceName);
  }
}

class WindowsCameraCaptureService implements CameraCaptureService {
  const WindowsCameraCaptureService();

  @override
  Future<CameraAvailability> checkAvailability() async {
    final result = await _runPowerShell(_cameraProbeScript);

    if (result.exitCode != 0) {
      return CameraAvailability.unavailable(_messageFromProcess(result));
    }

    final label = _okPayload(result.stdout).trim();
    return CameraAvailability.available(
      label: label.isEmpty ? 'Windows webcam' : label,
    );
  }

  @override
  Future<CapturedImageInput?> capturePhoto() async {
    final fileName = _captureFileName();
    final path = _joinPath(_workingDirectory.path, fileName);
    final result = await _runPowerShell(
      _cameraCaptureScript.replaceFirst('{{OUTPUT_PATH}}', _psString(path)),
    );

    if (result.exitCode != 0) {
      throw StateError(_messageFromProcess(result));
    }

    final file = File(path);

    if (!await file.exists()) {
      throw StateError('The webcam did not return an image.');
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw StateError('The webcam returned an empty image.');
    }

    return CapturedImageInput(bytes: bytes, sourceName: fileName);
  }

  Directory get _workingDirectory {
    final directory = Directory(
      _joinPath(Directory.systemTemp.path, 'dino_camera'),
    );

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    return directory;
  }

  Future<ProcessResult> _runPowerShell(String script) {
    return Process.run(
      'powershell.exe',
      <String>[
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-EncodedCommand',
        _encodePowerShell(script),
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
  }

  String _captureFileName() {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return 'webcam_$timestamp.jpg';
  }

  String _encodePowerShell(String script) {
    final bytes = <int>[];

    for (final codeUnit in script.codeUnits) {
      bytes
        ..add(codeUnit & 0xff)
        ..add(codeUnit >> 8);
    }

    return base64.encode(bytes);
  }

  String _psString(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  String _messageFromProcess(ProcessResult result) {
    final stderr = result.stderr.toString().trim();
    final stdout = result.stdout.toString().trim();
    final message = stdout.contains('ERROR|')
        ? stdout
        : stderr.isNotEmpty
        ? stderr
        : stdout;

    if (message.isEmpty) {
      return 'Windows webcam capture failed.';
    }

    return message
        .replaceFirst(RegExp(r'^ERROR\|\s*'), '')
        .replaceAll(RegExp(r'#< CLIXML.*', dotAll: true), '')
        .replaceAll(RegExp(r'\s+At line:.*', dotAll: true), '')
        .trim();
  }

  String _okPayload(Object output) {
    final lines = output
        .toString()
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      if (line.startsWith('OK|')) {
        return line.substring(3);
      }
    }

    return '';
  }

  String _joinPath(String left, String right) {
    final separator = Platform.pathSeparator;

    if (left.endsWith(separator)) {
      return '$left$right';
    }

    return '$left$separator$right';
  }
}

const _winRtSetup = r'''
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime
[Windows.Media.Capture.MediaCapture,Windows.Media.Capture,ContentType=WindowsRuntime] | Out-Null
[Windows.Media.Capture.MediaCaptureInitializationSettings,Windows.Media.Capture,ContentType=WindowsRuntime] | Out-Null
[Windows.Media.Capture.StreamingCaptureMode,Windows.Media.Capture,ContentType=WindowsRuntime] | Out-Null
[Windows.Media.MediaProperties.ImageEncodingProperties,Windows.Media.MediaProperties,ContentType=WindowsRuntime] | Out-Null
[Windows.Devices.Enumeration.DeviceInformation,Windows.Devices.Enumeration,ContentType=WindowsRuntime] | Out-Null
[Windows.Devices.Enumeration.DeviceInformationCollection,Windows.Devices.Enumeration,ContentType=WindowsRuntime] | Out-Null
[Windows.Devices.Enumeration.DeviceClass,Windows.Devices.Enumeration,ContentType=WindowsRuntime] | Out-Null
[Windows.Storage.StorageFolder,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
[Windows.Storage.CreationCollisionOption,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
  $_.Name -eq 'AsTask' -and
  $_.GetParameters().Count -eq 1 -and
  $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]
$asTaskAction = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
  $_.Name -eq 'AsTask' -and
  $_.GetParameters().Count -eq 1 -and
  $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'
})[0]
function AwaitOperation($operation, [Type]$resultType) {
  $task = $asTaskGeneric.MakeGenericMethod($resultType).Invoke($null, @($operation))
  $task.Wait()
  return $task.Result
}
function AwaitAction($operation) {
  $task = $asTaskAction.Invoke($null, @($operation))
  $task.Wait()
}
function GetVideoDevices() {
  return AwaitOperation ([Windows.Devices.Enumeration.DeviceInformation]::FindAllAsync([Windows.Devices.Enumeration.DeviceClass]::VideoCapture)) ([Windows.Devices.Enumeration.DeviceInformationCollection])
}
''';

const _cameraProbeScript =
    '''
try {
$_winRtSetup
\$devices = GetVideoDevices
if (\$devices.Count -lt 1) {
  Write-Output 'ERROR|No webcam was detected.'
  exit 2
}
Write-Output ("OK|" + \$devices[0].Name)
exit 0
} catch {
  Write-Output ("ERROR|" + \$_.Exception.Message)
  exit 1
}
''';

const _cameraCaptureScript =
    '''
try {
$_winRtSetup
\$outputPath = {{OUTPUT_PATH}}
if ([string]::IsNullOrWhiteSpace(\$outputPath)) {
  throw 'Missing output path.'
}
\$devices = GetVideoDevices
if (\$devices.Count -lt 1) {
  Write-Output 'ERROR|No webcam was detected.'
  exit 2
}
\$folder = AwaitOperation ([Windows.Storage.StorageFolder]::GetFolderFromPathAsync((Split-Path -Parent \$outputPath))) ([Windows.Storage.StorageFolder])
\$file = AwaitOperation (\$folder.CreateFileAsync((Split-Path -Leaf \$outputPath), [Windows.Storage.CreationCollisionOption]::ReplaceExisting)) ([Windows.Storage.StorageFile])
\$settings = [Windows.Media.Capture.MediaCaptureInitializationSettings]::new()
\$settings.StreamingCaptureMode = [Windows.Media.Capture.StreamingCaptureMode]::Video
\$settings.VideoDeviceId = \$devices[0].Id
\$capture = [Windows.Media.Capture.MediaCapture]::new()
AwaitAction (\$capture.InitializeAsync(\$settings))
AwaitAction (\$capture.CapturePhotoToStorageFileAsync([Windows.Media.MediaProperties.ImageEncodingProperties]::CreateJpeg(), \$file))
if (\$capture -is [System.IDisposable]) {
  \$capture.Dispose()
}
Write-Output ("OK|" + \$outputPath)
exit 0
} catch {
  if (\$capture -is [System.IDisposable]) {
    \$capture.Dispose()
  }
  Write-Output ("ERROR|" + \$_.Exception.Message)
  exit 1
}
''';
