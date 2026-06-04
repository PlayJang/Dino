import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../features/protection/domain/protection_models.dart';

class DinoWatermarkCodec {
  const DinoWatermarkCodec();

  static const _magic = 'DINO2';
  static const _message = 'Protected by Dino';
  static const _bitRepeats = 5;
  static const _maxPacketBytes = 512;

  DinoWatermarkMetadata buildMetadata({
    required ProcessingSettings settings,
    required int width,
    required int height,
    required int byteLength,
    required String protectedAtIso,
  }) {
    final fingerprint = _fingerprint(
      '${settings.seed}|$width|$height|$byteLength|$protectedAtIso|'
      '${settings.mode.name}',
    );

    return DinoWatermarkMetadata(
      message: _message,
      protectedAtIso: protectedAtIso,
      fingerprint: fingerprint,
      mode: settings.mode,
    );
  }

  void embed(img.Image image, DinoWatermarkMetadata metadata) {
    final payload = utf8.encode(
      jsonEncode({
        'message': metadata.message,
        'protectedAt': metadata.protectedAtIso,
        'fingerprint': metadata.fingerprint,
        'mode': metadata.mode.name,
      }),
    );
    final packet = _buildPacket(payload);
    final capacity = image.width * image.height * 3;
    final maxPacketBytes = _maxPacketBytesForCapacity(capacity);

    if (packet.length > maxPacketBytes) {
      return;
    }

    for (var byteIndex = 0; byteIndex < packet.length; byteIndex++) {
      final byte = packet[byteIndex];

      for (var bitOffset = 0; bitOffset < 8; bitOffset++) {
        final bit = (byte >> (7 - bitOffset)) & 1;
        final logicalBit = byteIndex * 8 + bitOffset;

        for (var repeat = 0; repeat < _bitRepeats; repeat++) {
          final repeatedBit = logicalBit * _bitRepeats + repeat;
          final carrier = _carrierFor(repeatedBit, capacity);
          _writeCarrierBit(image, carrier, bit);
        }
      }
    }
  }

  WatermarkVerificationResult verifyBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return const WatermarkVerificationResult(
        detected: false,
        confidence: 0,
        errorMessage: 'Unsupported image format.',
      );
    }

    return verifyImage(img.bakeOrientation(decoded));
  }

  WatermarkVerificationResult verifyImage(img.Image image) {
    final capacity = image.width * image.height * 3;
    final maxPacketBytes = _maxPacketBytesForCapacity(capacity);

    if (maxPacketBytes < _magic.length + 2) {
      return const WatermarkVerificationResult(detected: false, confidence: 0);
    }

    final header = _readPacketBytes(image, _magic.length + 2);
    final magicBytes = ascii.encode(_magic);
    final headerConfidence = _prefixConfidence(header, magicBytes);

    if (header.length < _magic.length + 2 || !_startsWith(header, magicBytes)) {
      return WatermarkVerificationResult(
        detected: false,
        confidence: headerConfidence,
      );
    }

    final payloadLength = (header[5] << 8) | header[6];
    final packetLength = _magic.length + 2 + payloadLength + 4;

    if (payloadLength <= 0 || packetLength > maxPacketBytes) {
      return WatermarkVerificationResult(
        detected: false,
        confidence: headerConfidence,
      );
    }

    final packet = _readPacketBytes(image, packetLength);
    final payloadStart = _magic.length + 2;
    final payloadEnd = payloadStart + payloadLength;
    final payload = packet.sublist(payloadStart, payloadEnd);
    final storedChecksum =
        (packet[payloadEnd] << 24) |
        (packet[payloadEnd + 1] << 16) |
        (packet[payloadEnd + 2] << 8) |
        packet[payloadEnd + 3];
    final actualChecksum = _checksum(payload);

    if (storedChecksum != actualChecksum) {
      return WatermarkVerificationResult(
        detected: false,
        confidence: headerConfidence * 0.84,
        errorMessage: 'Dino mark was found, but the data did not validate.',
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
      final modeName =
          decoded['mode'] as String? ?? ProtectionMode.balanced.name;
      final mode = ProtectionMode.values.firstWhere(
        (value) => value.name == modeName,
        orElse: () => ProtectionMode.balanced,
      );

      return WatermarkVerificationResult(
        detected: true,
        confidence: 1,
        metadata: DinoWatermarkMetadata(
          message: decoded['message'] as String? ?? _message,
          protectedAtIso: decoded['protectedAt'] as String? ?? '',
          fingerprint: decoded['fingerprint'] as String? ?? '',
          mode: mode,
        ),
      );
    } on Object {
      return WatermarkVerificationResult(
        detected: false,
        confidence: headerConfidence * 0.7,
        errorMessage: 'Dino mark was found, but the data was unreadable.',
      );
    }
  }

  static Uint8List _buildPacket(List<int> payload) {
    final packet = BytesBuilder(copy: false)
      ..add(ascii.encode(_magic))
      ..add([(payload.length >> 8) & 0xff, payload.length & 0xff])
      ..add(payload);
    final checksum = _checksum(payload);
    packet.add([
      (checksum >> 24) & 0xff,
      (checksum >> 16) & 0xff,
      (checksum >> 8) & 0xff,
      checksum & 0xff,
    ]);
    return packet.toBytes();
  }

  static int _maxPacketBytesForCapacity(int capacity) {
    final layoutBits = _layoutBitCount(capacity);
    return layoutBits ~/ (_bitRepeats * 8);
  }

  static int _layoutBitCount(int capacity) {
    return capacity < _maxPacketBytes * 8 * _bitRepeats
        ? capacity
        : _maxPacketBytes * 8 * _bitRepeats;
  }

  static int _carrierFor(int repeatedBit, int capacity) {
    final layoutBits = _layoutBitCount(capacity);
    return ((repeatedBit + 1) * capacity) ~/ (layoutBits + 1);
  }

  static void _writeCarrierBit(img.Image image, int carrier, int bit) {
    final pixelIndex = carrier ~/ 3;
    final channel = carrier % 3;
    final x = pixelIndex % image.width;
    final y = pixelIndex ~/ image.width;
    final pixel = image.getPixel(x, y);

    switch (channel) {
      case 0:
        pixel.r = (pixel.r.toInt() & ~1) | bit;
      case 1:
        pixel.g = (pixel.g.toInt() & ~1) | bit;
      case 2:
        pixel.b = (pixel.b.toInt() & ~1) | bit;
    }
  }

  static Uint8List _readPacketBytes(img.Image image, int byteCount) {
    final capacity = image.width * image.height * 3;
    final output = Uint8List(byteCount);

    for (var byteIndex = 0; byteIndex < byteCount; byteIndex++) {
      var byte = 0;

      for (var bitOffset = 0; bitOffset < 8; bitOffset++) {
        var votes = 0;
        final logicalBit = byteIndex * 8 + bitOffset;

        for (var repeat = 0; repeat < _bitRepeats; repeat++) {
          final repeatedBit = logicalBit * _bitRepeats + repeat;
          final carrier = _carrierFor(repeatedBit, capacity);
          votes += _readCarrierBit(image, carrier);
        }

        final bit = votes > _bitRepeats ~/ 2 ? 1 : 0;
        byte = (byte << 1) | bit;
      }

      output[byteIndex] = byte;
    }

    return output;
  }

  static int _readCarrierBit(img.Image image, int carrier) {
    final pixelIndex = carrier ~/ 3;
    final channel = carrier % 3;
    final x = pixelIndex % image.width;
    final y = pixelIndex ~/ image.width;
    final pixel = image.getPixel(x, y);

    return switch (channel) {
      0 => pixel.r.toInt() & 1,
      1 => pixel.g.toInt() & 1,
      2 => pixel.b.toInt() & 1,
      _ => 0,
    };
  }

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) {
      return false;
    }

    for (var index = 0; index < prefix.length; index++) {
      if (bytes[index] != prefix[index]) {
        return false;
      }
    }

    return true;
  }

  static double _prefixConfidence(Uint8List bytes, List<int> prefix) {
    if (bytes.isEmpty || prefix.isEmpty) {
      return 0;
    }

    var matchingBits = 0;
    final totalBits = prefix.length * 8;

    for (
      var index = 0;
      index < prefix.length && index < bytes.length;
      index++
    ) {
      final diff = bytes[index] ^ prefix[index];
      matchingBits += 8 - _bitCount(diff);
    }

    return matchingBits / totalBits;
  }

  static int _checksum(List<int> bytes) {
    var hash = 0x811c9dc5;

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }

    return hash;
  }

  static String _fingerprint(String value) {
    final bytes = utf8.encode(value);
    final hash = _checksum(bytes);
    final secondary = _checksum(bytes.reversed.toList(growable: false));
    return '${hash.toRadixString(16).padLeft(8, '0')}'
        '${secondary.toRadixString(16).padLeft(8, '0')}';
  }

  static int _bitCount(int value) {
    var count = 0;
    var current = value & 0xff;

    while (current != 0) {
      count += current & 1;
      current >>= 1;
    }

    return count;
  }
}
