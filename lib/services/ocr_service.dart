import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  TextRecognizer? _textRecognizer;

  OCRService() {
    // Only initialize text recognizer on mobile platforms
    if (!kIsWeb) {
      _textRecognizer = TextRecognizer();
    }
  }

  Future<String> extractText(String imagePath) async {
    // Check if running on web
    if (kIsWeb) {
      return 'OCR is not available on web. Please use the mobile app (iOS/Android) for receipt scanning functionality.';
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer!.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      print('Error extracting text: $e');
      return 'Error: Could not extract text from image. Please try again.';
    }
  }

  Future<Map<String, dynamic>> parseReceiptData(String text) async {
    final lines = text.split('\n');
    
    // Look for total amount with keywords
    final totalKeywords = ['total', 'bill amount', 'amount', 'grand total', 'net total'];
    double total = 0.0;
    
    // First, try to find amount near total keywords
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      
      for (final keyword in totalKeywords) {
        if (line.contains(keyword)) {
          // Look for amount in this line or next line
          final amountRegex = RegExp(r'(\d{1,6}\.\d{2})');
          
          // Check current line
          final matchCurrent = amountRegex.firstMatch(lines[i]);
          if (matchCurrent != null) {
            final amount = double.tryParse(matchCurrent.group(1) ?? '');
            if (amount != null && amount > 0 && amount < 1000000) {
              total = amount;
              break;
            }
          }
          
          // Check next line if current line doesn't have amount
          if (i + 1 < lines.length && total == 0.0) {
            final matchNext = amountRegex.firstMatch(lines[i + 1]);
            if (matchNext != null) {
              final amount = double.tryParse(matchNext.group(1) ?? '');
              if (amount != null && amount > 0 && amount < 1000000) {
                total = amount;
                break;
              }
            }
          }
        }
      }
      
      if (total > 0) break;
    }
    
    // If still no total found, look for reasonable amounts (with decimal points)
    if (total == 0.0) {
      final amountRegex = RegExp(r'(\d{1,6}\.\d{2})');
      final amounts = <double>[];
      
      for (final line in lines) {
        final matches = amountRegex.allMatches(line);
        for (final match in matches) {
          final amount = double.tryParse(match.group(1) ?? '');
          if (amount != null && amount > 0 && amount < 10000) {
            amounts.add(amount);
          }
        }
      }
      
      // Pick the largest reasonable amount
      if (amounts.isNotEmpty) {
        total = amounts.reduce((a, b) => a > b ? a : b);
      }
    }
    
    // Try to find merchant name (usually first line or line with merchant keywords)
    String merchant = 'Unknown Merchant';
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.length > 5 && !line.contains(RegExp(r'\d{5,}'))) {
        merchant = line;
        break;
      }
    }
    
    return {
      'merchant': merchant,
      'amount': total,
      'rawText': text,
      'date': DateTime.now().toString(),
    };
  }

  void dispose() {
    _textRecognizer?.close();
  }
}
