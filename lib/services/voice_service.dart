// services/voice_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isInitializing) return false;

    _isInitializing = true;
    try {
      _isInitialized = await _speech.initialize();
      return _isInitialized;
    } finally {
      _isInitializing = false;
    }
  }

  bool get isListening => _speech.isListening;
  bool get isInitialized => _isInitialized;

  void listen({
    required Function(String) onResult,
    required Function() onError,
  }) {
    if (!_isInitialized) return;

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      cancelOnError: true,
      partialResults: true,
    );
  }

  void stop() {
    if (_isInitialized) {
      _speech.stop();
    }
  }

  void cancel() {
    if (_isInitialized) {
      _speech.cancel();
    }
  }

  // Método para reiniciar si es necesario
  Future<void> reinitialize() async {
    if (_isInitialized) {
      _speech.cancel();
    }
    _isInitialized = false;
    await initialize();
  }
}
