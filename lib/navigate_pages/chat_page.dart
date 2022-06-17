import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../widget/message.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, this.user, this.chatKey, this.user1, this.receive}) : super(key: key);
  final String? user, chatKey, user1;
  bool? receive;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final databaseRef = FirebaseDatabase.instance.reference();
  final textController = TextEditingController();
  List<MessageData> messageList = [];
  final ScrollController _scrollController = ScrollController();
  dynamic data;

  @override
  void initState() {
    if (mounted) {
      getDataFromFirebase();
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.user!),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    time: messageList[index].time!,
                    text: messageList[index].message!,
                    isCurrentUser: messageList[index].sender!,
                    seen: messageList[index].seen,
                    isConnected: messageList[index].receive,
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black12),
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.account_circle_rounded),
                        suffixIcon: Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  child: IconButton(
                    onPressed: () {
                      var nowTime = DateTime.now();
                      String time = DateFormat('kk:mm a').format(nowTime);
                      if (textController.text.isNotEmpty) {
                        databaseRef
                            .child('chatRoom')
                            .child(widget.chatKey!)
                            .child('Message')
                            .push()
                            .set({'content': textController.text, 'time': time, 'sender': widget.user1, 'seen': false, 'receive': false});
                      }
                      textController.clear();
                      getDataFromFirebase();
                      SchedulerBinding.instance?.addPostFrameCallback((_) {
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
                      });
                      setState(() {});
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  getDataFromFirebase() {
    databaseRef.child('chatRoom').child(widget.chatKey!).child('Message').onValue.listen((event) {
      data = event.snapshot.value;
      print("$data");
      if (data != null) {
        messageList.clear();
        data.forEach((key, value) {
          if (value['sender'] != widget.user1) {
            print("  Seen :: ${value['seen']}");
            print("Seen Value True");
            databaseRef.child('chatRoom').child(widget.chatKey!).child('Message').child(key).update({'seen': true});
            setState(() {});
          } else {
            print('else   ${value['seen']}');
          }
          messageList.add(MessageData(
              message: value['content'],
              sender: value['sender'] == widget.user1,
              time: value['time'],
              seen: value['seen'],
              receive: value['receive']));
          SchedulerBinding.instance?.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
          });
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }
}

class MessageData {
  String? time;
  String? message;
  bool? sender;
  bool seen = false;
  bool receive = false;

  MessageData({this.time, this.message, this.sender, required this.seen, required this.receive});
}
