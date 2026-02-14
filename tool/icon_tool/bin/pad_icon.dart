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

  const int canvasSize = 1024;
  const double contentRatio = 0.60;

  // Korrektur: In v4 heißt es numChannels, aber der Konstruktor braucht oft explizite Formate
  final Image canvas = Image(
    width: canvasSize, 
    height: canvasSize,
    numChannels: 4,
  );
  
  // Korrektur: ColorRgba8 ist korrekt, aber wir nutzen direkt das Color-Objekt
  fill(canvas, color: ColorRgba8(0, 0, 0, 0));

  final int maxContent = (canvasSize * contentRatio).round();
  
  // Korrektur: Interpolation wird jetzt über das Enum gesteuert
  final Image resized = copyResize(
    src, 
    width: maxContent, 
    height: maxContent, 
    interpolation: Interpolation.cubic,
    maintainAspect: true 
  );

  // Zentrieren
  final int dx = ((canvasSize - resized.width) ~/ 2);
  final int dy = ((canvasSize - resized.height) ~/ 2);

  // Korrektur: compositeImage Parameter heißen in v4 dstX und dstY
  compositeImage(canvas, resized, dstX: dx, dstY: dy);

  // Output speichern
  final outFile = File(outPath);
  outFile.createSync(recursive: true);
  outFile.writeAsBytesSync(encodePng(canvas));

  print('Erfolgreich: Foreground Icon erstellt unter $outPath');
}