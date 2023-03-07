import 'package:ai_chat/constants/constants.dart';
import 'package:ai_chat/services/assets_manager.dart';
import 'package:ai_chat/widgets/text_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  ChatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      required this.isLast});

  final String msg;
  final int chatIndex;
  final bool isLast;
  bool isShown = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? cardColor : scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  chatIndex == 0
                      ? AssetsManager.botImage
                      : AssetsManager.userImage,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 8,
                  height: 0,
                ),
                Expanded(
                  child: chatIndex != 0 // is from user
                      ? chatIndex == 1 // is not harmful
                          ? TextWidget(label: msg)
                          : TextWidget(
                              label: msg,
                              color: Colors.red,
                            )
                      : isLast
                          ? StatefulBuilder(builder: ((context, setState) {
                              return isShown
                                  ? Text(
                                    msg.trim(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  )
                                  : DefaultTextStyle(
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                      child: AnimatedTextKit(
                                        onFinished: () {
                                          // _animationCount = 0;
                                          setState(
                                            () {
                                              isShown = true;
                                            },
                                          );
                                        },
                                        isRepeatingAnimation: false,
                                        repeatForever: false,
                                        displayFullTextOnTap: true,
                                        totalRepeatCount: 1,
                                        animatedTexts: [
                                          TyperAnimatedText(
                                            msg.trim(),
                                          ),
                                        ],
                                      ),
                                    );
                            }))
                          : Text(
                              msg.trim(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
