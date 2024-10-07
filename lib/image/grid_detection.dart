import 'dart:ui';
import 'package:image/image.dart' as img;

class GridDetection {
  Future<List<Rect>> detectGrid(img.Image image) async {
    // 將圖像轉換為灰階
    img.Image grayscale = img.grayscale(image);

    // 檢測水平和垂直線
    List<int> horizontalLines = _detectLines(grayscale, true);
    List<int> verticalLines = _detectLines(grayscale, false);

    List<Rect> gridCells = [];
    for (int i = 0; i < horizontalLines.length - 1; i++) {
      for (int j = 0; j < verticalLines.length - 1; j++) {
        Rect cell = Rect.fromLTRB(
          verticalLines[j].toDouble(),
          horizontalLines[i].toDouble(),
          verticalLines[j + 1].toDouble(),
          horizontalLines[i + 1].toDouble(),
        );
        gridCells.add(cell);
      }
    }

    return gridCells;
  }

  List<int> _detectLines(img.Image image, bool horizontal) {
    int threshold = 200; // 設定亮度閾值
    int minLineGap = 20; // 設定最小線間距
    List<int> lines = [];

    for (int i = 0; i < (horizontal ? image.height : image.width); i++) {
      int darkPixels = 0;
      for (int j = 0; j < (horizontal ? image.width : image.height); j++) {
        img.Pixel pixel =
            horizontal ? image.getPixel(j, i) : image.getPixel(i, j);
        if (img.getLuminance(pixel) < threshold) {
          darkPixels++;
        }
      }

      // 如果黑色像素超過一半，則視為一條線
      if (darkPixels > (horizontal ? image.width : image.height) * 0.5) {
        if (lines.isEmpty || i - lines.last >= minLineGap) {
          lines.add(i);
        }
      }
    }

    // 確保至少有兩條線
    if (lines.isEmpty) {
      lines = [0, horizontal ? image.height : image.width];
    } else if (lines.length == 1) {
      lines.insert(0, 0);
    }

    return lines;
  }
}
