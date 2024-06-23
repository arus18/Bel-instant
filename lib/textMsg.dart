import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'conversation.dart';
import 'read.dart';
import 'sendMsgs.dart';
import 'textFullview.dart';
import 'user.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TextMsg extends StatefulWidget {
  final int timeMsgCreated;
  final String userNameWhoCreated;
  final bool isGroupChat;
  final ValueNotifier<bool> isEmojiKeyBoardVisible;
  final ItemScrollController scrollController;
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final String conversationID;
  final String msgID;
  final Color bgColor;
  final String fontStyle;
  final Color fontColor;
  final double fontSize;
  final String message;
  final String bgImageUrl;
  final bool isCustom;
  final int twentiethMsgTimestamp;
  TextMsg(
    this.user,
    this.conversationState,
    this.conversationID,
    this.msgID,
    this.userIDwhoCreatedMsg,
    this.streamcontroller,
    this.isGroupChat,
    this.userNameWhoCreated,
    this.timeMsgCreated, {
    required this.bgColor,
    required this.fontStyle,
    required this.fontColor,
    required this.fontSize,
    required this.message,
    required this.bgImageUrl,
    required this.isCustom,
    required this.isEmojiKeyBoardVisible,
    required this.scrollController,
    required this.twentiethMsgTimestamp,
  });
  @override
  State<StatefulWidget> createState() {
    return TextMsgState(
        user,
        conversationState,
        conversationID,
        msgID,
        userIDwhoCreatedMsg,
        streamcontroller,
        bgColor,
        fontStyle,
        fontColor,
        fontSize,
        message,
        bgImageUrl,
        isCustom);
  }
}

class TextMsgState extends State<TextMsg> {
  final msgController = TextEditingController();
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final String conversationID;
  final String msgID;
  final Color bgColor;
  final String fontStyle;
  final Color fontColor;
  final double fontSize;
  final String message;
  final String bgImageUrl;
  final bool isCustom;
  final _focusNode = FocusNode();
  late ForwardSnap _forwardSnap;
  bool _isSelected = false;
  TextMsgState(
      this.user,
      this.conversationState,
      this.conversationID,
      this.msgID,
      this.userIDwhoCreatedMsg,
      this.streamcontroller,
      this.bgColor,
      this.fontStyle,
      this.fontColor,
      this.fontSize,
      this.message,
      this.bgImageUrl,
      this.isCustom);

  @override
  void initState() {
    _forwardSnap = ForwardSnap(
        msgID,
        conversationID,
        'text',
        userIDwhoCreatedMsg,
        widget.timeMsgCreated,
        widget.twentiethMsgTimestamp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime msgCreated =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMsgCreated);
    final hour = msgCreated.hour;
    final minute = msgCreated.minute;
    String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () {
          if (conversationState.selectedMessages.isEmpty) {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return TextFullView(message);
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
          streamcontroller.add(
              ForwardSnap('', '', '', '', 0, widget.twentiethMsgTimestamp));
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
                                  'msgIDreplied': msgID,
                                  'msg': msgController.text,
                                };
                                final scrollCount =
                                    conversationState.scrollCount;
                                widget.scrollController
                                    .jumpTo(index: scrollCount);
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
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: (user.userID == userIDwhoCreatedMsg)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  (widget.isGroupChat && (user.userID != userIDwhoCreatedMsg))
                      ? Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Text(
                            widget.userNameWhoCreated,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                      : Container(),
                  (!isCustom
                      ? (Container(
                          constraints: BoxConstraints(maxWidth: width - 50),
                          child: Bubble(
                            radius: Radius.circular(10),
                            color: (user.userID != userIDwhoCreatedMsg)
                                ? Colors.yellow[100]
                                : Colors.yellow,
                            alignment: (userIDwhoCreatedMsg == user.userID)
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: Text(
                              message,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          )))
                      : Row(
                          mainAxisAlignment:
                              (userIDwhoCreatedMsg == user.userID)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: <Widget>[
                              Flexible(
                                  child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: width - 50),
                                      padding: EdgeInsets.all(5),
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: (fontSize == 0)
                                          ? AutoSizeText(
                                              message,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 5,
                                              style: GoogleFonts.getFont(
                                                  fontStyle,
                                                  color: fontColor),
                                            )
                                          : Text(message,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 5,
                                              style: GoogleFonts.getFont(
                                                  fontStyle,
                                                  fontSize: fontSize,
                                                  color: fontColor))))
                            ])),
                  Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Text(
                        '$hour:' + mins,
                        style: TextStyle(fontSize: 10),
                      )),
                  !widget.isGroupChat
                      ? Read(
                          userIDwhoCreatedThisMsg: userIDwhoCreatedMsg,
                          userID: user.userID,
                          conversationID: conversationID,
                          msgID: msgID)
                      : Container(),
                ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
