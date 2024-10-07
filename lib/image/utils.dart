import 'dart:ui' as ui;
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';

Future<List<ui.Image>> cutImage(ui.Image image, List<Rect> cells) async {
  List<Future<ui.Image>> cutImageFutures = [];
  double minWidth = 50;
  double minHeight = 50;

  for (var cell in cells) {
    if (cell.width > minWidth && cell.height > minHeight) {
      cutImageFutures.add(_cutSingleImage(image, cell));
    }
  }

  List<ui.Image> cutImages = await Future.wait(cutImageFutures);
  return cutImages;
}

Future<ui.Image> _cutSingleImage(ui.Image image, Rect cell) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas canvas = Canvas(recorder);

  canvas.drawImageRect(
    image,
    cell,
    Rect.fromLTWH(0, 0, cell.width, cell.height),
    Paint(),
  );

  return await recorder.endRecording().toImage(
        cell.width.round(),
        cell.height.round(),
      );
}

Future<ui.Image> resizeImage(ui.Image image, double scale) async {
  final width = (image.width * scale).round();
  final height = (image.height * scale).round();

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  canvas.scale(scale);
  canvas.drawImage(image, Offset.zero, Paint());

  final ui.Image resizedImage =
      await recorder.endRecording().toImage(width, height);
  return resizedImage;
}

Future<void> saveImageToFile(ui.Image image, String filePath) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();
  final File file = File(filePath);
  await file.writeAsBytes(pngBytes);
}
