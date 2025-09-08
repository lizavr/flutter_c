import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../environment/env.dart';

class ChatGptClient {
  ChatGptClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      _apiKey = Env.apiKey;

  final http.Client _http;
  final String _apiKey;

  Future<String?> sendAudioBytes(Uint8List bytes) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint(
          'ChatGPT API key is missing. Put it in lib/environment/.env',
        );
        return null;
      }

      final uri = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..fields['model'] = 'gpt-4o-mini-transcribe'
        ..fields['prompt'] = 'convert bytes to text'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'audio.m4a',
            contentType: MediaType('audio', 'm4a'),
          ),
        );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final text = json['text'] as String?;
        return text;
      }
      debugPrint('Transcription error: ${resp.statusCode} ${resp.body}');
      return null;
    } catch (e) {
      debugPrint('Transcription request failed: $e');
      return null;
    }
  }
}
