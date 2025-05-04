import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:aastu_map/pages/chat/chat_message_model.dart';
import 'package:aastu_map/pages/chat/aastu_context_parser.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey; // You should store this securely
  
  // Chat history storage
  final List<Map<String, String>> _chatHistory = [];

  OpenAIService({required String apiKey}) : _apiKey = apiKey {
    print('[LOG OpenAIService] =========> Service initialized');
    _initialize();
  }

  Future<void> _initialize() async {
    await AastuContextParser.initialize();
    print('[LOG OpenAIService] =========> Context parser initialized');
  }

  Future<ChatMessage> getCompletionWithEnhancements(String userMessage) async {
    print('[LOG getCompletionWithEnhancements] =========> Processing user message: $userMessage');
    
    // Get the text response from the model
    final String textResponse = await getCompletion(userMessage);
    
    // Look for coordinates in the response - this is our priority for location detection
    final MapLocation? locationFromResponse = AastuContextParser.findLocation(textResponse);
    
    // Only look for links if no location was found - maps take priority
    List<LinkPreview>? links = null;
    if (locationFromResponse == null) {
      // Find relevant links for the response
      final foundLinks = AastuContextParser.findRelevantLinks(textResponse);
      
      // Only include links if they're actually relevant to the topic
      // and if the response is not a simple greeting or general message
      final lowerResponse = textResponse.toLowerCase();
      final bool isSimpleMessage = lowerResponse.contains('hello') || 
                                  lowerResponse.contains('welcome') || 
                                  lowerResponse.length < 100;
      
      // Check if the response contains content that justifies including a link
      final bool containsUsefulContent = lowerResponse.contains('information') || 
                                        lowerResponse.contains('resources') || 
                                        lowerResponse.contains('website') || 
                                        lowerResponse.contains('more details') ||
                                        lowerResponse.contains('you can find') ||
                                        lowerResponse.contains('you can visit') ||
                                        lowerResponse.contains('check out');
      
      links = (foundLinks.isNotEmpty && !isSimpleMessage && containsUsefulContent) ? foundLinks : null;
      
      print('[LOG getCompletionWithEnhancements] =========> Found links: ${foundLinks.length}, using: ${links?.length ?? 0}');
    } else {
      print('[LOG getCompletionWithEnhancements] =========> Location found, skipping link detection to prioritize map');
    }
    
    print('[LOG getCompletionWithEnhancements] =========> Found location: ${locationFromResponse?.title ?? 'None'}, links: ${links?.length ?? 0}');
    
    return ChatMessage.bot(
      textResponse,
      location: locationFromResponse,
      links: links,
    );
  }

  Future<String> getCompletion(String userMessage) async {
    print('[LOG getCompletion] =========> Processing user message: $userMessage');
    
    // Ensure context is loaded
    await AastuContextParser.initialize();
    final contextData = AastuContextParser.contextData;
    
    if (contextData == null) {
      print('[LOG getCompletion] =========> Context is not available');
      return "I'm sorry, but I'm having trouble accessing my knowledge base about AASTU.";
    }
    
    try {
      // Add the user message to chat history
      _chatHistory.add({'role': 'user', 'content': userMessage});
      
      // Keep only the last 10 messages to avoid token limits
      if (_chatHistory.length > 10) {
        _chatHistory.removeAt(0);
      }
      
      print('[LOG getCompletion] =========> Chat history size: ${_chatHistory.length}');
      print('[LOG getCompletion] =========> Sending request to OpenAI API');
      
      // Prepare messages with system prompt and chat history
      final messages = [
        {
          'role': 'system',
          'content': '''You are AASTU Assistant, a helpful AI assistant for Addis Ababa Science and Technology University.
          Use the following information about AASTU to answer questions:
          
          $contextData
          
          IMPORTANT: When responding to questions about physical locations on campus, ALWAYS include the exact coordinates in your response in the format: latitude, longitude (e.g., 8.8845, 38.8095). Always provide coordinates for any buildings, offices, or facilities mentioned in your response.
          
          Only answer questions related to AASTU. If asked about unrelated topics, politely decline and 
          suggest asking about university-related matters. Be friendly, helpful, and concise. If you don't know
          an answer about AASTU (Addis Ababa Science and Technology University), say so honestly rather than making up information but if question is related to AASTU and not mentioned above feel free to answer from your knowledge of AASTU, lastly consider user might have typo so answer understanding in context of some one could as about university.'''
        },
        ..._chatHistory,
      ];
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // Using the most economical model
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 250,
        }),
      );

      print('[LOG getCompletion] =========> Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[LOG getCompletion] =========> Request successful');
        final jsonResponse = jsonDecode(response.body);
        print('[LOG getCompletion] =========> Response decoded');
        final content = jsonResponse['choices'][0]['message']['content'].trim();
        
        // Add the bot response to chat history
        _chatHistory.add({'role': 'assistant', 'content': content});
        
        print('[LOG getCompletion] =========> Content extracted: ${content.substring(0, content.length > 30 ? 30 : content.length)}...');
        return content;
      } else {
        print('[LOG getCompletion] =========> API error response: ${response.body}');
        return "I'm having trouble connecting to my knowledge base. Please try again later.";
      }
    } catch (e) {
      print('[LOG getCompletion] =========> Exception caught: $e');
      return "I encountered an error. Please try again later.";
    }
  }
  
  // Clear chat history if needed
  void clearChatHistory() {
    _chatHistory.clear();
    print('[LOG OpenAIService] =========> Chat history cleared');
  }
} 