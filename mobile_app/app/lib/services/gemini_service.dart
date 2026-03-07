import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _modelName = 'gemini-2.5-flash';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  
  static const String _systemPrompt =
      'You are a helpful RAG assistant. Answer questions clearly and concisely. '
      'When the backend is connected, you will retrieve relevant context from a '
      'semantic database before answering. For now, answer from your own knowledge.';

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  
  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(userMessage),
      );
      return response.text ?? 'No response received.';
    } on GenerativeAIException catch (e) {
      return 'Gemini error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
