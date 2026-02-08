import 'dart:io';
import 'package:image/image.dart';

void main(List<String> args) {
  final srcPath = 'assets/icon/app_icon.png';
  final outPath = 'assets/icon/app_icon_fg.png';

  if (!File(srcPath).existsSync()) {
    print('Source icon not found: $srcPath');
    exit(2);
  }

  final bytes = File(srcPath).readAsBytesSync();
  Image? src = decodeImage(bytes);
  if (src == null) {
    print('Failed to decode image');
    exit(3);
  }

  const int canvasSize = 1024; // target foreground size
  const double contentRatio = 0.60; // logo occupies 60% of canvas

  final Image canvas = Image(width: canvasSize, height: canvasSize);
  // transparent background
  fill(canvas, color: getColor(0, 0, 0, 0));

  // compute target size preserving aspect ratio
  final int maxContent = (canvasSize * contentRatio).round();
  int targetW = src.width;
  int targetH = src.height;
  if (targetW > maxContent || targetH > maxContent) {
    final double scale = (maxContent / (targetW > targetH ? targetW : targetH));
    targetW = (targetW * scale).round();
    targetH = (targetH * scale).round();
  }

  final Image resized = copyResize(src, width: targetW, height: targetH, interpolation: Interpolation.cubic);

  // center
  final int dx = ((canvasSize - resized.width) / 2).round();
  final int dy = ((canvasSize - resized.height) / 2).round();

  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final int px = resized.getPixel(x, y);
      canvas.setPixel(x + dx, y + dy, px);
    }
  }

  // ensure output dir exists
  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  outFile.writeAsBytesSync(encodePng(canvas));

  print('Wrote padded foreground icon to $outPath');
}
