import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OcrService {
  Future<String> performOCR(String imagePath) async {
    return await FlutterTesseractOcr.extractText(imagePath,
        language: 'chi_tra+eng');
  }
}
