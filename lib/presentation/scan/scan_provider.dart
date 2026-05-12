import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/services/business_card_parser.dart';

part 'scan_provider.freezed.dart';
part 'scan_provider.g.dart';

enum ScanStatus { idle, processing, done, error }

@freezed
class ScanState with _$ScanState {
  factory ScanState({
    @Default(ScanStatus.idle) ScanStatus status,
    BusinessCardData? parsedData,
    String? rawText,
    String? errorMessage,
  }) = _ScanState;
}

@Riverpod(keepAlive: true)
class ScanNotifier extends _$ScanNotifier {
  @override
  ScanState build() {
    if (kDebugMode) print('SCAN: ScanNotifier build() called (isNew: true)');
    ref.keepAlive();
    return ScanState();
  }

  Future<void> processImage(XFile imageFile) async {
    state = state.copyWith(status: ScanStatus.processing);
    if (kDebugMode) print('SCAN: Starting processImage for ${imageFile.path}');

    try {
      // 1. ML Kit OCR
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();

      final rawText = recognized.text;
      if (kDebugMode) {
        print('SCAN: OCR Raw Text length: ${rawText.length}');
        print('SCAN: OCR Raw Text: \n$rawText');
      }

      if (rawText.trim().isEmpty) {
        if (kDebugMode) print('SCAN: Error - Raw text is empty');
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'No text found. Try again with a clearer photo.',
        );
        return;
      }

      // 2. Parsing algoritmo
      final parsed = BusinessCardParser.parse(rawText);

      if (kDebugMode) {
        print('SCAN: Parsing complete. Confidence: ${parsed.confidence}');
        print('SCAN: Parsed Data: $parsed');
      }

      if (!parsed.hasMinimumData) {
        if (kDebugMode) print('SCAN: Error - Not enough data found');
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'Unable to read the card. Please try again.',
        );
        return;
      }

      state = state.copyWith(
        status: ScanStatus.done,
        parsedData: parsed,
        rawText: rawText,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('SCAN: Catch error: $e');
        print('SCAN: Stack trace: $stack');
      }
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Error during scan: $e',
      );
    }
  }

  void reset() => state = ScanState();
}