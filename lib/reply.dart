import 'dart:async';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'audioPlayer.dart';
import 'conversation.dart';
import 'imagePreview.dart';
import 'read.dart';
import 'sendMsgs.dart';
import 'textFullview.dart';
import 'user.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Reply extends StatefulWidget {
  final int timeMsgCreated;
  final String userWhoCreated;
  final bool isGroupChat;
  final ValueNotifier<bool> isEmojiKeyBoardVisible;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final ItemScrollController controller;
  final String conversationID;
  final DocumentSnapshot msgSnapshot;
  final int twentiethMsgTimestamp;
  const Reply(
    this.user,
    this.conversationState,
    this.streamcontroller,
    this.isGroupChat,
    this.userWhoCreated,
    this.timeMsgCreated, {
    Key? key,
    required this.controller,
    required this.conversationID,
    required this.msgSnapshot,
    required this.isEmojiKeyBoardVisible,
    required this.twentiethMsgTimestamp,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ReplyState(msgSnapshot, conversationID, controller, user,
        conversationState, streamcontroller);
  }
}

class ReplyState extends State<Reply> {
  final msgController = TextEditingController();
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  late Widget _repliedMessage;
  final ItemScrollController controller;
  final String conversationID;
  final DocumentSnapshot msgSnapshot;
  bool _isSelected = false;
  late ForwardSnap _forwardSnap;
  final _focusNode = FocusNode();
  late String userNamewhoCreatedRepliedMsg;
  ReplyState(this.msgSnapshot, this.conversationID, this.controller, this.user,
      this.conversationState, this.streamcontroller);

  @override
  void initState() {
    _forwardSnap = ForwardSnap(
        msgSnapshot.id,
        conversationID,
        'text',
        msgSnapshot['userID'],
        widget.timeMsgCreated,
        widget.twentiethMsgTimestamp);
    _repliedMessageBuilder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //add to stream for forward
    final width = MediaQuery.of(context).size.width;
    final DateTime msgCreated =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMsgCreated);
    final hour = msgCreated.hour;
    final minute = msgCreated.minute;
    String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
    return (GestureDetector(
      onTap: () {
        if (conversationState.selectedMessages.isEmpty) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return TextFullView(msgSnapshot['msg']);
          }));
        }
        final isSelected =
            conversationState.selectedMessages[_forwardSnap] ?? false;
        if (isSelected) {
          streamcontroller.add(
              ForwardSnap('', '', '', '', 0, widget.twentiethMsgTimestamp));
          conversationState.selectedMessages.remove(_forwardSnap);
          setState(() {
            _isSelected = false;
          });
          if (conversationState.selectedMessages.isEmpty) {
            streamcontroller.add(
                ForwardSnap('', '', '', '', 0, widget.twentiethMsgTimestamp));
          }
        } else if (conversationState.selectedMessages.isNotEmpty) {
          streamcontroller.add(
              ForwardSnap('', '', '', '', 0, widget.twentiethMsgTimestamp));
          conversationState.selectedMessages[_forwardSnap] = true;
          setState(() {
            _isSelected = true;
          });
        }
      },
      onLongPress: () {
        streamcontroller
            .add(ForwardSnap('', '', '', '', 0, widget.twentiethMsgTimestamp));
        conversationState.selectedMessages[_forwardSnap] = true;
        setState(() {
          _isSelected = true;
        });
      },
      onDoubleTap: () {
        _focusNode.requestFocus();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                        child: (TextField(
                      focusNode: _focusNode,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      controller: msgController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Map<String, dynamic> map = {
                                'reply': true,
                                'conversationID': conversationID,
                                'msgIDreplied': msgSnapshot.id,
                                'msg': msgController.text,
                              };
                              final scrollCount = conversationState.scrollCount;
                              controller.jumpTo(index: scrollCount);
                              sendText(
                                map,
                                user,
                              );
                            },
                            icon: Icon(Icons.send),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ))),
                    ))),
                  ],
                )),
              );
            });
      },
      child: Container(
        color: _isSelected ? Colors.lightGreen : Colors.white,
        padding: EdgeInsets.all(3),
        child: Align(
            alignment: (msgSnapshot['userID'] == user.userID)
                ? Alignment.topRight
                : Alignment.topLeft,
            child: Column(
              crossAxisAlignment: (user.userID == msgSnapshot['userID'])
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                (widget.isGroupChat &&
                        (user.userID != msgSnapshot['userID']) &&
                        userNamewhoCreatedRepliedMsg != null)
                    ? Container(
                        margin: EdgeInsets.only(bottom: 3),
                        child: Text(
                          userNamewhoCreatedRepliedMsg,
                        ))
                    : Container(),
                Container(
                        constraints: BoxConstraints(maxWidth: width - 50),
                        child: _repliedMessage) ??
                    Container(),
                (widget.isGroupChat && (user.userID != msgSnapshot['userID']))
                    ? Container(
                        margin: EdgeInsets.only(bottom: 3),
                        child: Text(
                          widget.userWhoCreated,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                    : Container(),
                Container(
                    constraints: BoxConstraints(maxWidth: width - 50),
                    child: Bubble(
                      color: (user.userID != msgSnapshot['userID'])
                          ? Colors.yellow[100]
                          : Colors.yellow,
                      child: Text(
                        msgSnapshot['msg'],
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                Text(
                  '$hour:' + mins,
                  style: TextStyle(fontSize: 10),
                ),
                !widget.isGroupChat
                    ? Read(
                        userIDwhoCreatedThisMsg: msgSnapshot['userID'],
                        userID: user.userID,
                        conversationID: conversationID,
                        msgID: msgSnapshot.id)
                    : Container(),
              ],
            )),
      ),
    ));
  }

  double width() {
    final width = MediaQuery.of(context).size.width;
    final audioPlayerWidth = (60 / 100) * width;
    return audioPlayerWidth;
  }

  _repliedMessageBuilder() async {
    final msgs = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs');
    final repliedMsgSnapshot =
        await msgs.doc(msgSnapshot['msgIDreplied']).get();
    String msgType = repliedMsgSnapshot['msgType'];
    final fileSize = repliedMsgSnapshot['fileSize'];
    userNamewhoCreatedRepliedMsg = repliedMsgSnapshot['name'];
    if (msgType == 'reply') {
      msgType = repliedMsgSnapshot['typeOfReplyMsg'];
    }
    if (msgType == 'text') {
      _repliedMessage = GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return TextFullView(repliedMsgSnapshot['msg']);
            }));
          },
          child: Bubble(
            color: (user.userID != repliedMsgSnapshot['userID'])
                ? Colors.yellow[100]
                : Colors.yellow,
            child: Text(
              repliedMsgSnapshot['msg'],
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ));
      if (mounted) {
        setState(() {});
      }
      return;
    }
    if (msgType == 'image') {
      final url = repliedMsgSnapshot['url'];
      final fileName = repliedMsgSnapshot['fileName'];
      _repliedMessage = SingleImagePreview(
        user,
        conversationState,
        conversationID,
        repliedMsgSnapshot.id,
        msgSnapshot['userID'],
        streamcontroller,
        widget.isGroupChat,
        widget.userWhoCreated,
        widget.timeMsgCreated,
        fileName: fileName,
        imgUrl: url,
        reply: true,
        fileSize: fileSize,
        isEmojiKeyBoardVisble: ValueNotifier<bool>(false),
        scrollController: ItemScrollController(),
        twentiethMsgTimestamp: 0,
      );
      if (mounted) {
        setState(() {});
      }

      return;
    }
    if (msgType == 'audio') {
      _repliedMessage = AudioPlayerForConversation(
        user,
        conversationState,
        conversationID,
        repliedMsgSnapshot.id,
        msgSnapshot['userID'],
        streamcontroller,
        widget.timeMsgCreated,
        widget.isGroupChat,
        widget.userWhoCreated,
        repliedMsgSnapshot['duration'],
        url: repliedMsgSnapshot['url'],
        reply: true,
        userIDwhoCreatedRepliedMsg: repliedMsgSnapshot['userID'],
        fileSize: 0,
        scrollController: ItemScrollController(),
        twentiethMsgTimestamp: 0,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
  }
}
