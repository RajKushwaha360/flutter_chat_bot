import 'dart:convert';
import 'dart:io';

import 'package:ai_chat/constants/api_constants.dart';
import 'package:ai_chat/models/chat_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //Model name to send in your api request
  static String modelName = 'gpt-3.5-turbo';

  //Below variable will show how many previous chat(query and reply) to add with
  //next query, so that the language model can get context of previous questions
  //and answers
  //
  //For eg. for value 2, the last two questions and answers will be sent along with next query,
  //which helps model understand contexts from last questions
  static int addedContext = 2;

  //The system message helps set the behavior of the bot.
  static String systemMsg =
      'You are Jarvis, a friendly chat bot with a bit of sense of humor who gives short and to the point answers.';

  //this variable represent what is maximum limit of token it can respond with.
  //Approximately 100 token will be 75 words.
  static int maxTokens = 100;

  //validate if the text input isn't containing any harmful text
  static Future<bool> validateMessage({required String msg}) async {
    try {
      Uri uri = Uri.parse('$BASE_URL/moderations');
      var response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'input': msg}),
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }

      bool isHarmful = false;

      if (jsonResponse['results'].length > 0) {
        isHarmful = jsonResponse['results'][0]['flagged'];
      }

      return isHarmful;
    } catch (error) {
      // print('error $error');
      rethrow;
    }
  }

  // send msg to chatgpt api
  static Future<List<ChatModel>> sendChatMessage({
    required String modelId,
    required double temperature,
    required List<Map<String, String>> messageBody,
  }) async {
    try {
      Uri uri = Uri.parse('$BASE_URL/chat/completions');
      var response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": modelName,
          "messages": messageBody,
          "temperature": temperature,
          "max_tokens": maxTokens
        }),
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }

      List<ChatModel> chatList = [];

      if (jsonResponse['choices'].length > 0) {
        chatList = List.generate(
          jsonResponse['choices'].length,
          (index) => ChatModel(
            msg: jsonResponse['choices'][index]['message']['content'],
            chatIndex: 0,
          ),
        );
      }

      return chatList;
    } catch (error) {
      // print('error $error');
      rethrow;
    }
  }
}
