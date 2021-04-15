import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:interactive_message/conversation.dart';
import 'package:interactive_message/photoview.dart';
import 'package:interactive_message/read.dart';
import 'package:interactive_message/sendMsgs.dart';
import 'package:interactive_message/user.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SingleImagePreview extends StatefulWidget {
  
  final int timeMsgCreated;
  final String userNameWhoCreated;
  final bool isGroupChat;
  final ValueNotifier<bool> isEmojiKeyBoardVisble;
  final ItemScrollController scrollController;
  final int fileSize;
  final bool isGridView;
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final bool reply;
  final String conversationID;
  final String msgID;
  final String fileName;
  final String imgUrl;
  final int twentiethMsgTimestamp;
  const SingleImagePreview(
      
      this.user,
      this.conversationState,
      this.conversationID,
      this.msgID,
      this.userIDwhoCreatedMsg,
      this.streamcontroller,
      this.isGroupChat,
      this.userNameWhoCreated,
      this.timeMsgCreated,
      {Key key,
      this.fileName,
      this.imgUrl,
      this.reply: false,
      this.isGridView: false,
      this.fileSize,
      this.isEmojiKeyBoardVisble,
      this.scrollController,
      this.twentiethMsgTimestamp})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SingleImagePreviewState(
        msgID,
        userIDwhoCreatedMsg,
        fileName,
        imgUrl,
        conversationID,
        reply,
        user,
        conversationState,
        streamcontroller,
        isGridView);
  }
}

class SingleImagePreviewState extends State<SingleImagePreview> {
  final msgController = TextEditingController();
  final bool isGridView;
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final bool reply;
  final String conversationID;
  final String msgID;
  final String fileName;
  final String imgUrl;
  bool _initialized = false;
  bool _fileExists;
  String _path;
  bool _isSelected = false;
  ForwardSnap _forwardSnap;
  final _focusNode = FocusNode();
  SingleImagePreviewState(
      this.msgID,
      this.userIDwhoCreatedMsg,
      this.fileName,
      this.imgUrl,
      this.conversationID,
      this.reply,
      this.user,
      this.conversationState,
      this.streamcontroller,
      this.isGridView);
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _forwardSnap = ForwardSnap(
      
        msgID,
        conversationID,
        'image',
        userIDwhoCreatedMsg,
        widget.timeMsgCreated,
        widget.twentiethMsgTimestamp);
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final DateTime msgCreated =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMsgCreated);
    final hour = msgCreated.hour;
    final minute = msgCreated.minute;
    String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
    return SizedBox(
        width: width,
        child: Row(
            mainAxisAlignment: (userIDwhoCreatedMsg == user.userID)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              (GestureDetector(
                  onTap: () {
                    if (conversationState.selectedMessages.isEmpty &&
                        !widget.isGridView) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ImageView(
                          fileName,
                          imgUrl,
                          user,
                          fileSize: widget.fileSize,
                          conversationID: conversationID,
                          msgID: msgID,
                          userIDwhoCreatedMsg: userIDwhoCreatedMsg,
                          timestamp: widget.timeMsgCreated,
                          twentiethMsgTimestamp: widget.twentiethMsgTimestamp,
                        );
                      }));
                    }
                    if (!widget.isGridView && !widget.reply) {
                      final isSelected =
                          conversationState.selectedMessages[_forwardSnap] ??
                              false;

                      if (isSelected) {
                        streamcontroller.add(ForwardSnap(
                            '', '', '', '', 0, widget.twentiethMsgTimestamp));
                        conversationState.selectedMessages.remove(_forwardSnap);
                        setState(() {
                          _isSelected = false;
                        });
                        if (conversationState.selectedMessages.isEmpty) {
                          streamcontroller.add(ForwardSnap(
                              '', '', '', '', 0, widget.twentiethMsgTimestamp));
                        }
                      } else if (conversationState
                          .selectedMessages.isNotEmpty) {
                        streamcontroller.add(ForwardSnap(
                            '', '', '', '', 0, widget.twentiethMsgTimestamp));
                        conversationState.selectedMessages[_forwardSnap] = true;
                        setState(() {
                          _isSelected = true;
                        });
                      }
                    }
                  },
                  onLongPress: () {
                    if (!widget.isGridView && !widget.reply) {
                      streamcontroller.add(ForwardSnap(
                          '', '', '', '', 0, widget.twentiethMsgTimestamp));
                      conversationState.selectedMessages[_forwardSnap] = true;
                      setState(() {
                        _isSelected = true;
                      });
                    }
                  },
                  onDoubleTap: () {
                    if (!widget.isGridView && !widget.reply) {
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
                                            sendText(map, user,);
                                          },
                                          icon: Icon(Icons.send),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                          const Radius.circular(25.0),
                                        ))),
                                  ))),
                                ],
                              )),
                            );
                          });
                    }
                  },
                  child: Column(
                      crossAxisAlignment: (user.userID == userIDwhoCreatedMsg)
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        (widget.isGroupChat &&
                                !widget.isGridView &&
                                (user.userID != userIDwhoCreatedMsg) &&
                                !reply)
                            ? Container(
                                margin: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  widget.userNameWhoCreated,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))
                            : Container(),
                        Container(
                            color:
                                _isSelected ? Colors.lightGreen : Colors.white,
                            padding: EdgeInsets.all(3),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: width - 50),
                              width: (isGridView || reply)
                                  ? 100
                                  : 200, //half screen width
                              height: (isGridView || reply) ? 100 : 200,
                              child: _initialized
                                  ? _fileExists
                                      ? Image.file(
                                          File(_path),
                                          filterQuality: FilterQuality.low,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              LoadingBumpingLine.circle(
                                                backgroundColor: Colors.yellow,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error))
                                  : LoadingBumpingLine.circle(
                                      backgroundColor: Colors.yellow,
                                    ),
                            )),
                        (isGridView || widget.reply)
                            ? Container()
                            : Text(
                                '$hour:'+mins,
                                style: TextStyle(fontSize: 10),
                              ),
                        (widget.isGroupChat || isGridView || widget.reply)
                            ? Container()
                            : Read(
                                userIDwhoCreatedThisMsg: userIDwhoCreatedMsg,
                                userID: user.userID,
                                conversationID: conversationID,
                                msgID: msgID),
                      ])))
            ]));
  }

  _initialize() async {
    try {
      final dir = await getExternalStorageDirectory();
      _path = '${dir.path}/Belinstant/' + fileName;
      _fileExists = await File(_path).exists();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {}
  }
}
