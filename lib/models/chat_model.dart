class ChatModel{
  final String msg;
  final int chatIndex;
  // 0 for bot,
  // 1 for user and
  // -1 if message contains hate speech etc

  ChatModel({required this.msg, required this.chatIndex});

  factory ChatModel.fromJsom(Map<String,dynamic> json) => ChatModel(
    msg: json['msg'],
    chatIndex: json['chatIndex'],
  );

}