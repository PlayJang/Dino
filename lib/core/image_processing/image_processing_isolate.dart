import 'package:flutter/foundation.dart';

import '../../features/protection/domain/protection_models.dart';
import 'adversarial_steganography_engine.dart';
import 'dino_watermark_codec.dart';

Future<AdversarialProcessResult> processImageOnWorker(
  AdversarialProcessRequest request,
) {
  return compute(_processImageEntryPoint, request);
}

AdversarialProcessResult _processImageEntryPoint(
  AdversarialProcessRequest request,
) {
  return const AdversarialSteganographyEngine().process(request);
}

Future<WatermarkVerificationResult> verifyDinoWatermarkOnWorker(
  Uint8List bytes,
) {
  return compute(_verifyDinoWatermarkEntryPoint, bytes);
}

WatermarkVerificationResult _verifyDinoWatermarkEntryPoint(Uint8List bytes) {
  return const DinoWatermarkCodec().verifyBytes(bytes);
}
