import 'dart:async';
import 'dart:io';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:interactive_message/conversation.dart';
import 'package:interactive_message/read.dart';
import 'package:interactive_message/sendMsgs.dart';
import 'package:interactive_message/user.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AudioPlayerForPreview extends StatefulWidget {
  final int duration;
  final String url;
  const AudioPlayerForPreview(this.duration, {Key key, this.url})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AudioPlayerForPreviewState(duration, url);
  }
}

class AudioPlayerForPreviewState extends State<AudioPlayerForPreview> {
  final int duration;
  final String url;
  AudioPlayer _audioPlayer = AudioPlayer();
  double _progress = 0.0;
  bool _playing = false;
  AudioPlayerForPreviewState(this.duration, this.url);
  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      if (state == AudioPlayerState.COMPLETED) {
        setState(() {
          _playing = false;
          _progress = 0.0;
        });
      }
    });

    _audioPlayer.onAudioPositionChanged.listen(
      (Duration d) {
        if (mounted) {
          setState(() {
            _progress = (d.inMilliseconds / duration).toDouble();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 5,
          ),
          height: 50,
          width: 50,
          decoration:
              BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
          child: Center(
            child: IconButton(
              onPressed: () {
                _play();
              },
              icon: (!_playing) ? Icon(Icons.play_arrow) : Icon(Icons.stop),
            ),
          ),
        ),
        Expanded(
            child: LinearProgressIndicator(
          value: _progress,
        )),
      ],
    );
  }

  _play() async {
    if (!_playing) {
      try {
        await _audioPlayer.play(url, isLocal: true);
      } catch (e) {}

      setState(() {
        _playing = true;
      });
    } else {
      await _audioPlayer.stop();
      setState(() {
        _playing = false;
        _progress = 0.0;
      });
    }
  }
}

class AudioPlayerForConversation extends StatefulWidget {
  
  final int timeMsgCreated;
  final String userNameCreatedMsg;
  final bool isGroupChat;
  final ItemScrollController scrollController;
  final int fileSize;
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final String conversationID;
  final String msgID;
  final int duration;
  final String url;
  final bool reply;
  final int twentiethMsgTimestamp;
  final String userIDwhoCreatedRepliedMsg;
  const AudioPlayerForConversation(
    
    this.user,
    this.conversationState,
    this.conversationID,
    this.msgID,
    this.userIDwhoCreatedMsg,
    this.streamcontroller,
    this.timeMsgCreated,
    this.isGroupChat,
    this.userNameCreatedMsg,
    this.duration, {
    Key key,
    this.url,
    this.fileSize,
    this.scrollController,
    this.reply: false,
    this.twentiethMsgTimestamp,
    this.userIDwhoCreatedRepliedMsg,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AudioPlayerForConversationState(msgID, userIDwhoCreatedMsg, duration,
        url, conversationID, user, conversationState, streamcontroller);
  }
}

class AudioPlayerForConversationState
    extends State<AudioPlayerForConversation> {
  final msgController = TextEditingController();
  final String userIDwhoCreatedMsg;
  final StreamController<ForwardSnap> streamcontroller;
  final ConversationState conversationState;
  final User user;
  final String conversationID;
  final String msgID;
  final int duration;
  File _audioFile;
  final String url;
  AudioPlayer _audioPlayer = AudioPlayer();
  double _progress = 0.0;
  bool _playing = false;
  ForwardSnap _forwardSnap;
  bool _isSelected = false;
  final _focusNode = FocusNode();
  AudioPlayerForConversationState(
      this.msgID,
      this.userIDwhoCreatedMsg,
      this.duration,
      this.url,
      this.conversationID,
      this.user,
      this.conversationState,
      this.streamcontroller);
  @override
  void initState() {
    super.initState();
    _forwardSnap = ForwardSnap(
        msgID,
        conversationID,
        'audio',
        widget.userIDwhoCreatedMsg,
        widget.timeMsgCreated,
        widget.twentiethMsgTimestamp);
    try {
      _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
        if (state == AudioPlayerState.COMPLETED) {
          setState(() {
            _playing = false;
            _progress = 0.0;
          });
        }
      });
    } catch (e) {}
    try {
      _audioPlayer.onAudioPositionChanged.listen(
        (Duration d) {
          if (mounted) {
            setState(() {
              _progress = (d.inMilliseconds / duration).toDouble();
            });
          }
        },
      );
    } catch (e) {}
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime msgCreated =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMsgCreated);
    final hour = msgCreated.hour;
    final minute = msgCreated.minute;
    String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
    return Align(
        alignment: (userIDwhoCreatedMsg == user.userID)
            ? Alignment.topRight
            : Alignment.topLeft,
        child: (GestureDetector(
            onTap: () {
              if (!widget.reply) {
                final isSelected =
                    conversationState.selectedMessages[_forwardSnap] ?? false;
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
                } else if (conversationState.selectedMessages.isNotEmpty) {
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
              if (!widget.reply) {
                streamcontroller.add(ForwardSnap(
                    '', '', '', '', 0, widget.twentiethMsgTimestamp));
                conversationState.selectedMessages[_forwardSnap] = true;
                setState(() {
                  _isSelected = true;
                });
              }
            },
            onDoubleTap: () {
              if (!widget.reply) {
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
                                      borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ))),
                            ))),
                          ],
                        )),
                      );
                    });
              }
            },
            child: Container(
                color: _isSelected ? Colors.lightGreen : Colors.white,
                child: Column(
                    crossAxisAlignment: (user.userID == userIDwhoCreatedMsg)
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      (widget.isGroupChat &&
                              (user.userID != userIDwhoCreatedMsg) &&
                              !widget.reply)
                          ? Container(
                              margin: EdgeInsets.only(bottom: 3),
                              child: Text(
                                widget.userNameCreatedMsg,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                          : Container(),
                      Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Text('${duration / 1000} sec')),
                      widget.reply
                          ? Bubble(
                              radius: Radius.circular(10),
                              color: (user.userID !=
                                      widget.userIDwhoCreatedRepliedMsg)
                                  ? Colors.yellow[100]
                                  : Colors.yellow,
                              child: Container(
                                  width: width(),
                                  child: Row(
                                    mainAxisAlignment:
                                        (userIDwhoCreatedMsg == user.userID)
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 5,
                                        ),
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: (user.userID ==
                                                    widget
                                                        .userIDwhoCreatedRepliedMsg)
                                                ? Colors.yellow[100]
                                                : Colors.yellow,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: (_audioFile == null)
                                              ? LoadingDoubleFlipping.circle(
                                                  backgroundColor:
                                                      Colors.yellow,
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    _play();
                                                  },
                                                  icon: (!_playing)
                                                      ? Icon(Icons.play_arrow)
                                                      : Icon(Icons.stop),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                          child: LinearProgressIndicator(
                                        value: _progress,
                                      ))
                                    ],
                                  )))
                          : Bubble(
                              radius: Radius.circular(10),
                              color: (user.userID != userIDwhoCreatedMsg)
                                  ? Colors.yellow[100]
                                  : Colors.yellow,
                              child: Container(
                                  width: width(),
                                  child: Row(
                                    mainAxisAlignment:
                                        (userIDwhoCreatedMsg == user.userID)
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 5,
                                        ),
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: (user.userID ==
                                                    userIDwhoCreatedMsg)
                                                ? Colors.yellow[100]
                                                : Colors.yellow,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: (_audioFile == null)
                                              ? LoadingDoubleFlipping.circle(
                                                  backgroundColor:
                                                      Colors.yellow,
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    _play();
                                                  },
                                                  icon: (!_playing)
                                                      ? Icon(Icons.play_arrow)
                                                      : Icon(Icons.stop),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                          child: LinearProgressIndicator(
                                        value: _progress,
                                      ))
                                    ],
                                  ))),
                      !widget.reply
                          ? Text('$hour:' + mins,
                              style: TextStyle(fontSize: 10))
                          : Container(),
                      (!widget.isGroupChat && !widget.reply)
                          ? Read(
                              userIDwhoCreatedThisMsg: userIDwhoCreatedMsg,
                              userID: user.userID,
                              conversationID: conversationID,
                              msgID: msgID)
                          : Container(),
                    ])))));
  }

  double width() {
    final width = MediaQuery.of(context).size.width;
    final audioPlayerWidth = (60 / 100) * width;
    return audioPlayerWidth;
  }

  _play() async {
    if (!_playing) {
      try {
        await _audioPlayer.play(_audioFile.path, isLocal: true);
      } catch (e) {}

      setState(() {
        _playing = true;
      });
    } else {
      await _audioPlayer.stop();
      setState(() {
        _playing = false;
        _progress = 0.0;
      });
    }
  }

  _initialize() async {
    try {
      _audioFile = await DefaultCacheManager().getSingleFile(url);
    } catch (e) {}
    if (mounted) {
      setState(() {});
    }
  }
}
