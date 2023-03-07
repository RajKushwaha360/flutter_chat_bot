import 'dart:async';

import 'package:ai_chat/models/chat_model.dart';
import 'package:ai_chat/services/api_services.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];

  int addedContext = ApiService.addedContext;
  String systemMsg = ApiService.systemMsg;

  List<ChatModel> get getChatList {
    return chatList;
  }

  void timerToRemove() {
    Timer timer = Timer(const Duration(seconds: 1), (() {
      chatList.removeWhere((element) => element.chatIndex == -1);
      notifyListeners();
    }));
  }

  void addHarmfulMessage({required String msg}) {
    chatList.removeLast();

    chatList.add(
      ChatModel(
        chatIndex: -1,
        msg: msg,
      ),
    );

    timerToRemove();

    notifyListeners();
  }

  void addUserMessage({required String msg}) {
    chatList.add(
      ChatModel(
        chatIndex: 1,
        msg: msg,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers({
    required String msg,
    required String modelId,
    required double temperature,
  }) async {
    List<Map<String, String>> messages = [];

    messages.add({
      "role": "system",
      "content": systemMsg
    });

    if (chatList.length - 2 * addedContext - 1 < 0) {
      for (int i = 0; i < chatList.length; i++) {
        if (i % 2 == 0) {
          messages.add({'role': 'user', 'content': chatList[i].msg});
        } else {
          messages.add({'role': 'assistant', 'content': chatList[i].msg});
        }
      }
    } else {
      for (int i = chatList.length - 2 * addedContext - 1;
          i < chatList.length;
          i++) {
        if (i % 2 == 0) {
          messages.add({'role': 'user', 'content': chatList[i].msg});
        } else {
          messages.add({'role': 'assistant', 'content': chatList[i].msg});
        }
      }
    }

    chatList.addAll(
      await ApiService.sendChatMessage(
        modelId: modelId,
        temperature: temperature,
        messageBody: messages,
      ),
    );

    notifyListeners();
  }
}
