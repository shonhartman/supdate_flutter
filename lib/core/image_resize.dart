import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Resizes image bytes so the longest side is at most [maxWidth] (maintains aspect ratio).
/// Prefer JPEG output for smaller payload. Returns null if decode fails.
Uint8List? resizeImageForCurator(
  Uint8List bytes, {
  int maxWidth = 1024,
  int jpegQuality = 85,
}) {
  img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  if (decoded.width <= maxWidth && decoded.height <= maxWidth) {
    return img.encodeJpg(decoded, quality: jpegQuality);
  }

  img.Image resized;
  if (decoded.width >= decoded.height) {
    resized = img.copyResize(decoded, width: maxWidth);
  } else {
    resized = img.copyResize(decoded, height: maxWidth);
  }
  return img.encodeJpg(resized, quality: jpegQuality);
}
