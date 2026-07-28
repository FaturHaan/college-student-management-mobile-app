import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final file = File('kalender-kampus-semester-3-dan-4.pdf');
  final bytes = await file.readAsBytes();
  final document = PdfDocument(inputBytes: bytes);
  String text = PdfTextExtractor(document).extractText();
  print(text);
}
