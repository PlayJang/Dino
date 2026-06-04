import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_extensions.dart';
import '../../../providers/app_providers.dart';
import '../../../services/camera/camera_capture_service_base.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraAvailability? _availability;
  String? _errorMessage;
  bool _isChecking = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _checkCamera();
  }

  Future<void> _checkCamera() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final availability = await ref
          .read(cameraCaptureServiceProvider)
          .checkAvailability();

      if (!mounted) {
        return;
      }

      setState(() {
        _availability = availability;
        _isChecking = false;
        _errorMessage = availability.isAvailable ? null : availability.message;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _capture() async {
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final capture = await ref
          .read(cameraCaptureServiceProvider)
          .capturePhoto();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(capture);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCapturing = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isAvailable = _availability?.isAvailable ?? false;
    final status = _isChecking
        ? l10n.checkingWebcam
        : _errorMessage ?? _availability?.label ?? l10n.windowsWebcam;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.webcamCapture),
        leading: IconButton(
          tooltip: l10n.close,
          onPressed: _isCapturing ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? scheme.primaryContainer
                              : scheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isAvailable
                              ? Icons.photo_camera_outlined
                              : Icons.videocam_off_outlined,
                          color: isAvailable
                              ? scheme.onPrimaryContainer
                              : scheme.onErrorContainer,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 20),
                      if (_isChecking)
                        const CircularProgressIndicator()
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isCapturing ? null : _checkCamera,
                                icon: const Icon(Icons.refresh_outlined),
                                label: Text(l10n.retry),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: !isAvailable || _isCapturing
                                    ? null
                                    : _capture,
                                icon: _isCapturing
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_outlined),
                                label: Text(l10n.capture),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
