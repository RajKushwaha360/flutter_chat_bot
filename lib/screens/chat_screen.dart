import 'package:ai_chat/constants/api_constants.dart';
import 'package:ai_chat/constants/constants.dart';
import 'package:ai_chat/providers/chats_provider.dart';
import 'package:ai_chat/providers/model_provider.dart';
import 'package:ai_chat/screens/setting_screen.dart';
import 'package:ai_chat/services/api_services.dart';
import 'package:ai_chat/services/assets_manager.dart';
import 'package:ai_chat/widgets/chat_widget.dart';
import 'package:ai_chat/widgets/text_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isAiTyping = false;
  bool _isLoading = true;

  void getApiKey() async {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    final snapshot = await reference.child('api').get();

    if (snapshot.exists) {
      setApiKey(snapshot.value.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Could not fetch Api Key. Please try again.',
        ),
        action: SnackBarAction(
          label: 'Try Again',
          textColor: Colors.white,
          onPressed: (() {
            getApiKey();
          }),
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  TextEditingController textEditingController = TextEditingController();
  late FocusNode focusNode;
  late ScrollController _listScrollController;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    getApiKey();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiImage),
        ),
        title: const Text(
          'Chat Bot',
          style: TextStyle(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: _listScrollController,
                      itemBuilder: ((context, index) {
                        bool isLast = false;
                        if (index == chatProvider.getChatList.length - 1) {
                          isLast = true;
                          // print(chatProvider.getChatList[index].msg);
                        }
                        return ChatWidget(
                          msg: chatProvider.getChatList[index].msg,
                          chatIndex: chatProvider.getChatList[index].chatIndex,
                          isLast: isLast,
                        );
                      }),
                      itemCount: chatProvider.getChatList.length,
                    ),
                  ),
                  if (_isAiTyping) ...[
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                  Material(
                    color: cardColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 100,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              child: TextField(
                                focusNode: focusNode,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: null,
                                maxLength: 256,
                                buildCounter: null,
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                  counter: SizedBox(
                                    height: 0,
                                  ),
                                  hintText: 'How can I help you?',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.only(bottom: 10),
                          onPressed: () async {
                            if (textEditingController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please type your query'),
                                ),
                              );
                              return;
                            }

                            if (_isAiTyping) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: TextWidget(
                                  label: 'Please query one at a time.',
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }

                            await sendChatMessage(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider,
                            );
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendChatMessage({
    required ModelsProvider modelsProvider,
    required ChatProvider chatProvider,
  }) async {
    String temp = textEditingController.text;
    try {
      setState(
        () {
          _isAiTyping = true;
          textEditingController.clear();
          chatProvider.addUserMessage(msg: temp);
          focusNode.unfocus();
        },
      );

      bool isHarmful = await ApiService.validateMessage(msg: temp);

      if (isHarmful) {
        setState(
          () {
            chatProvider.addHarmfulMessage(msg: temp);
          },
        );

        throw Exception(
            "Please be careful. Your query violates OpenAI's usage policies.");
      }

      await chatProvider.sendMessageAndGetAnswers(
        msg: temp,
        modelId: modelsProvider.modelId,
        temperature: modelsProvider.getTemperature,
      );

      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEnd();
        _isAiTyping = false;
      });
    }
  }
}
