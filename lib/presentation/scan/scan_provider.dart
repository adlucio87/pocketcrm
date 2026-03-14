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

@riverpod
class ScanNotifier extends _$ScanNotifier {
  @override
  ScanState build() => ScanState();

  Future<void> processImage(XFile imageFile) async {
    state = state.copyWith(status: ScanStatus.processing);

    try {
      // 1. ML Kit OCR
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();

      final rawText = recognized.text;
      if (rawText.trim().isEmpty) {
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'Nessun testo trovato. Riprova con una foto più nitida.',
        );
        return;
      }

      // 2. Parsing algoritmo
      final parsed = BusinessCardParser.parse(rawText);

      if (!parsed.hasMinimumData) {
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'Non riesco a leggere il biglietto. Riprova.',
        );
        return;
      }

      state = state.copyWith(
        status: ScanStatus.done,
        parsedData: parsed,
        rawText: rawText,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Errore durante la scansione: $e',
      );
    }
  }

  void reset() => state = ScanState();
}