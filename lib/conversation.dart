import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:interactive_message/audioPlayer.dart';
import 'package:interactive_message/contacts.dart';
import 'package:interactive_message/conversationDetails.dart';
import 'package:interactive_message/imagePreview.dart';
import 'package:interactive_message/photoview.dart';
import 'package:interactive_message/read.dart';
import 'package:interactive_message/readByList.dart';
import 'package:interactive_message/reply.dart';
import 'package:interactive_message/textMsg.dart';
import 'package:interactive_message/textinput.dart';
import 'package:interactive_message/updateFunctions.dart';
import 'package:interactive_message/user.dart';
import 'package:interactive_message/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dart_date/dart_date.dart';

class ForwardSnap {
  final String msgID;
  final String conversationID;
  final String msgType;
  final String userIDWhocreatedMsg;
  final int timestamp;
  final int twentiethMsgTimestamp;

  ForwardSnap(
    this.msgID,
    this.conversationID,
    this.msgType,
    this.userIDWhocreatedMsg,
    this.timestamp,
    this.twentiethMsgTimestamp,
  );
}

class ForwardMessageButton extends StatefulWidget {
  final bool isBlocked;
  final bool isGroupChat;
  final ConversationState conversationState;
  final User user;
  final Stream<ForwardSnap> stream;
  const ForwardMessageButton(
    this.isBlocked, {
    Key key,
    this.stream,
    this.user,
    this.conversationState,
    this.isGroupChat,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ForwardMessageButtonState(
        stream, user, conversationState, isGroupChat);
  }
}

class ForwardMessageButtonState extends State<ForwardMessageButton> {
  final bool isGroupChat;
  final ConversationState conversationState;
  final User user;
  final Stream<ForwardSnap> stream;
  final List<ForwardSnap> deletedMsgsTempList = List<ForwardSnap>();
  ForwardMessageButtonState(
      this.stream, this.user, this.conversationState, this.isGroupChat);
  @override
  void initState() {
    super.initState();
    stream.listen((data) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return conversationState.selectedMessages.isEmpty
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
                Text('+ ${conversationState.selectedMessages.length}'),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    final _forwardSnap =
                        conversationState.selectedMessages.keys.first;
                    final msgID = _forwardSnap.msgID;
                    final conversationID = _forwardSnap.conversationID;
                    final userIDwhoCreatedMsg =
                        _forwardSnap.userIDWhocreatedMsg;

                    if (conversationState.selectedMessages.length == 1 &&
                        user.userID == userIDwhoCreatedMsg) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ReadBy(
                          user: user,
                          conversationID: conversationID,
                          msgID: msgID,
                        );
                      }));
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward),
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      final msgsToForward =
                          conversationState.selectedMessages.keys.toList();
                      return Contacts(
                        user: user,
                        newBroadCast: true,
                        forwardMsgList: msgsToForward,
                        forward: true,
                      );
                    }));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    String conversationID = conversationState
                        .selectedMessages.keys.first.conversationID;
                    List<ForwardSnap> selectedMsgs = List<ForwardSnap>.from(
                        conversationState.selectedMessages.keys);
                    selectedMsgs.forEach((forwardSnap) {
                      String msgID = forwardSnap.msgID;
                      String userIDwhoCreatedMsg =
                          forwardSnap.userIDWhocreatedMsg;

                      if (user.userID == userIDwhoCreatedMsg) {
                        deletedMsgsTempList.add(forwardSnap);
                        FirebaseFirestore.instance
                            .collection('conversations')
                            .doc(conversationID)
                            .collection('msgs')
                            .doc(msgID)
                            .set({
                          'msgType': 'deleted',
                        }, SetOptions(merge: true));
                      }
                    });
                    deletedMsgsTempList.forEach((forwardSnap) {
                      conversationState.selectedMessages.remove(forwardSnap);
                    });
                    setState(() {});
                  },
                )
              ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Conversation extends StatefulWidget {
  final int lastReadMsgTimestamp;
  final String userIDconversationWith;
  final String conversationWith;
  final String displayPictureUrl;
  final String phoneNumber;
  final User user;
  final bool isGroupChat;
  final String conversationID;
  final bool isBlocked;
  const Conversation(
    this.lastReadMsgTimestamp, {
    Key key,
    this.user,
    this.isGroupChat,
    this.conversationID,
    this.isBlocked,
    this.conversationWith,
    this.displayPictureUrl,
    this.phoneNumber,
    this.userIDconversationWith,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ConversationState(
      lastReadMsgTimestamp,
      conversationID,
      isGroupChat,
      user,
      isBlocked,
      conversationWith,
      displayPictureUrl,
      phoneNumber,
      userIDconversationWith,
    );
  }
}

class ConversationState extends State<Conversation>
    with WidgetsBindingObserver {
  int _visibleMaxIndex = 1;
  int minIndex;
  int scrollCount = 0;
  int lastReadMsgTimestamp;
  bool hasMsgs = true;
  final _streamController = StreamController<ForwardSnap>();
  List<StreamBuilder> _uploadTasks = List<StreamBuilder>();
  ValueNotifier<bool> _isEmojiKeyboardVisible = ValueNotifier(false);
  ValueNotifier<bool> _newUploadAdded = ValueNotifier(false);
  final String userIDconversationWith;
  final String conversationWith;
  final String displayPictureUrl;
  final String phoneNumber;
  String msgID;
  final User user;
  final bool isGroupChat;
  final String conversationID;
  CollectionReference _participants;
  CollectionReference _conversations;
  List<StorageUploadTask> uploadProgress = List<StorageUploadTask>();
  Map<ForwardSnap, bool> selectedMessages = Map<ForwardSnap, bool>();
  final ItemScrollController _controller = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  int initialScrollIndex = 10;
  final bool isBlocked;
  ConversationState(
    this.lastReadMsgTimestamp,
    this.conversationID,
    this.isGroupChat,
    this.user,
    this.isBlocked,
    this.conversationWith,
    this.displayPictureUrl,
    this.phoneNumber,
    this.userIDconversationWith,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _participants = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('participants');
    _conversations = FirebaseFirestore.instance
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations');
    _positionsListener.itemPositions.addListener(() {
      try {
        final positions = _positionsListener.itemPositions.value;
        minIndex = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
                position.itemTrailingEdge < min.itemTrailingEdge
                    ? position
                    : min)
            .index;
        final index = positions
            .where((ItemPosition position) => position.itemLeadingEdge < 1)
            .reduce((ItemPosition max, ItemPosition position) =>
                position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
            .index;
        final lastIndex = (index + 1);
        if (lastIndex > _visibleMaxIndex) {
          _visibleMaxIndex = lastIndex;
        }
      } catch (e) {}
    });
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .where('timestamp', isGreaterThanOrEqualTo: lastReadMsgTimestamp)
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      try {
        scrollCount = snapshot.docs.length;
        final positions = _positionsListener.itemPositions.value;
        final lastIndex = positions.last.index + 1;
        if (scrollCount - lastIndex == 1) {
          _controller.jumpTo(index: scrollCount);
        }
      } catch (e) {}
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .doc(user.userID)
          .set({'status': 'online'}, SetOptions(merge: true));
    }
    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .doc(user.userID)
          .set({'status': 'live'}, SetOptions(merge: true));
      setMsgsRead(lastReadMsgTimestamp, conversationID, user);
    }
  }

  Widget _userStatus() {
    if (_participants != null) {
      return StreamBuilder(
        stream: _participants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.hasData) {
            final participants = snapshot.data.docs;
            String userStatus = '';
            if (isGroupChat) {
              final participant = participants.firstWhere((snap) {
                return (snap.id != user.userID &&
                    snap.data()['status'] == 'typing');
              }, orElse: () {
                return null;
              });
              if (participant != null) {
                userStatus = '${participant.data()['name']} is ' +
                    participant.data()['status'];
              }
            } else {
              final participant = participants.firstWhere((snap) {
                return snap.id != user.userID;
              }, orElse: () {
                return null;
              });
              if (participant != null) {
                String status = participant.data()['status'] ?? '';
                if (status == 'online' || status == 'live') {
                  userStatus = 'online';
                }
                if (status == 'offline') {
                  final lastseen = participant.data()['lastseen'];
                  if (lastseen != null) {
                    userStatus = 'last seen ' + _timeStatus(lastseen);
                  }
                }
                if (status == 'typing') {
                  userStatus = 'typing...';
                }
                if (status == 'recording audio') {
                  userStatus = 'recording audio';
                }
              }
            }
            return FutureBuilder(
              future: hasInternetConnection(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data) {
                    return Text(
                      userStatus,
                      style: TextStyle(fontSize: 10),
                    );
                  }
                }
                return Container();
              },
            );
          }
          return Container();
        },
      );
    }
    return Container();
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: false,
      leading: Container(
          margin: EdgeInsets.all(3),
          child: displayPictureUrl.isEmpty
              ? CircleAvatar()
              : CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(displayPictureUrl),
                )),
      title: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ConversationDetails(
                user: user,
                conversationID: conversationID,
                userIDconversationWith: userIDconversationWith,
                displayPictureUrl: displayPictureUrl,
                name: conversationWith,
                phoneNumber: phoneNumber,
                isGroupChat: isGroupChat,
              );
            }));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[Text(conversationWith), _userStatus()],
          )),
      elevation: 8,
      actions: <Widget>[
        ForwardMessageButton(
          isBlocked,
          stream: _streamController.stream,
          user: user,
          conversationState: this,
          isGroupChat: isGroupChat,
        ),
        ValueListenableBuilder<Iterable<ItemPosition>>(
          valueListenable: _positionsListener.itemPositions,
          builder: (context, positions, child) {
            return (minIndex == 0 && hasMsgs && (scrollCount != 0))
                ? IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      selectedMessages.clear();
                      final snapshot = await FirebaseFirestore.instance
                          .collection('conversations')
                          .doc(conversationID)
                          .collection('msgs')
                          .where('timestamp',
                              isLessThanOrEqualTo: lastReadMsgTimestamp)
                          .orderBy('timestamp', descending: true)
                          .limit(50)
                          .get();
                      if (snapshot.docs.isNotEmpty) {
                        setState(() {
                          final msg = snapshot.docs.last;
                          lastReadMsgTimestamp = msg.data()['timestamp'];
                          initialScrollIndex = snapshot.docs.length;
                          _visibleMaxIndex += snapshot.docs.length;
                        });
                      }
                      if (snapshot.docs.length <= 1) {
                        setState(() {
                          hasMsgs = false;
                        });
                      }
                    },
                  )
                : Container();
          },
        )
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30))),
      backgroundColor: Colors.yellow,
    );
    return WillPopScope(
        onWillPop: (() async {
          FirebaseFirestore.instance
              .collection('conversations')
              .doc(conversationID)
              .collection('participants')
              .doc(user.userID)
              .set({'status': 'online'}, SetOptions(merge: true));

          return true;
        }),
        child: Scaffold(
            bottomNavigationBar:
                Container(height: 50, child: Center(child: Text('Ad'))),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: (Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  (ValueListenableBuilder<bool>(
                    valueListenable: _newUploadAdded,
                    builder: (context, isNewUploadAdded, child) {
                      if (isNewUploadAdded) {
                        final task = uploadProgress.last;
                        final stream = StreamBuilder<StorageTaskEvent>(
                          stream: task.events,
                          builder: (_, snapshot) {
                            var event = snapshot?.data?.snapshot;
                            double progressPercent = event != null
                                ? (event.bytesTransferred /
                                        event.totalByteCount) *
                                    100
                                : 0;
                            if (task.isInProgress) {
                              return Text(
                                '$progressPercent%',
                              );
                            }

                            return Container();
                          },
                        );
                        _uploadTasks.add(stream);
                      }
                      return SizedBox(
                          height: 50,
                          child: Stack(
                            children: _uploadTasks,
                          ));
                    },
                  )),
                  ValueListenableBuilder<Iterable<ItemPosition>>(
                    valueListenable: _positionsListener.itemPositions,
                    builder: (context, positions, child) {
                      return (scrollCount > _visibleMaxIndex)
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.yellow, shape: BoxShape.circle),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                '+${scrollCount - _visibleMaxIndex}',
                                style: TextStyle(fontSize: 20),
                              ))
                          : Container();
                    },
                  )
                ])),
            resizeToAvoidBottomInset: true,
            appBar: appBar,
            backgroundColor: Colors.white,
            body: (Container(
                child: Column(children: <Widget>[
              Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationID)
                    .collection('msgs')
                    .where('timestamp',
                        isGreaterThanOrEqualTo: lastReadMsgTimestamp)
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Text('Loading'),
                    );
                  } else {
                    if (snapshot.hasData) {
                      scrollCount = snapshot.data.docs.length;
                      return ScrollablePositionedList.builder(
                        initialScrollIndex: (initialScrollIndex > scrollCount)
                            ? 0
                            : initialScrollIndex,
                        itemScrollController: _controller,
                        itemPositionsListener: _positionsListener,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          index = (index < 0) ? 0 : index;
                          final msgSnapShot = snapshot.data.docs[index];
                          final msgType = msgSnapShot.data()['msgType'];
                          final isCustom =
                              msgSnapShot.data()['isCustom'] ?? false;
                          final userIDwhoCreatedMsg =
                              msgSnapShot.data()['userID'];
                          final fileSize = msgSnapShot.data()['fileSize'];
                          final userNameWhoCreated = msgSnapShot.data()['name'];
                          final timeMsgCreated =
                              msgSnapShot.data()['timestamp'];
                          final int twentiethMsgTimestamp =
                              msgSnapShot.data()['twentiethMsgTimestamp'];
                          if (msgType == 'updateInfo' ||
                              msgType == 'dateInfo') {
                            final userID = msgSnapShot.data()['userID'];

                            if (userID != null) {
                              String info = '';
                              if (userID == user.userID) {
                                info =
                                    'You ${msgSnapShot.data()['info']} $conversationWith';
                              } else {
                                info =
                                    '$conversationWith ${msgSnapShot.data()['info']} you';
                              }
                              return Bubble(
                                margin: BubbleEdges.all(3),
                                padding: BubbleEdges.all(4),
                                alignment: Alignment.center,
                                color: Colors.yellow,
                                child: Text(info),
                              );
                            }
                            return Bubble(
                              margin: BubbleEdges.all(3),
                              padding: BubbleEdges.all(4),
                              alignment: Alignment.center,
                              color: Colors.yellow,
                              child: Text(msgSnapShot.data()['info']),
                            );
                          }
                          if (msgType == 'deleted') {
                            return Bubble(
                              child: Text(
                                'deleted',
                                style: TextStyle(fontSize: 16),
                              ),
                              color: Colors.lightGreen[100],
                              alignment: (userIDwhoCreatedMsg == user.userID)
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                            );
                          }

                          if (msgType == 'reply') {
                            return Reply(
                              user,
                              this,
                              _streamController,
                              isGroupChat,
                              userNameWhoCreated,
                              timeMsgCreated,
                              controller: _controller,
                              conversationID: conversationID,
                              msgSnapshot: msgSnapShot,
                              twentiethMsgTimestamp: twentiethMsgTimestamp,
                            );
                          }
                          if (msgType == 'text') {
                            if (isCustom) {
                              final bgColor = ColorsUtility.getColorForString(
                                  msgSnapShot.data()['bgColor'],
                                  msgSnapShot.data()['bgColorID']);
                              final fontStyle = msgSnapShot.data()['fontStyle'];
                              final fontColor = ColorsUtility.getColorForString(
                                  msgSnapShot.data()['fontColor'],
                                  msgSnapShot.data()['fontColorID']);
                              final fontSize = msgSnapShot.data()['fontSize'];
                              final message = msgSnapShot.data()['msg'];
                              final String bgImageUrl =
                                  msgSnapShot.data()['bgImageUrl'];
                              return TextMsg(
                                user,
                                this,
                                conversationID,
                                msgSnapShot.id,
                                userIDwhoCreatedMsg,
                                _streamController,
                                isGroupChat,
                                userNameWhoCreated,
                                timeMsgCreated,
                                bgColor: bgColor,
                                fontStyle: fontStyle,
                                fontColor: fontColor,
                                fontSize: fontSize,
                                message: message,
                                bgImageUrl:
                                    bgImageUrl.isNotEmpty ? bgImageUrl : null,
                                isCustom: true,
                                scrollController: _controller,
                                isEmojiKeyBoardVisible: _isEmojiKeyboardVisible,
                                twentiethMsgTimestamp: twentiethMsgTimestamp,
                              );
                            }
                            return TextMsg(
                              user,
                              this,
                              conversationID,
                              msgSnapShot.id,
                              userIDwhoCreatedMsg,
                              _streamController,
                              isGroupChat,
                              userNameWhoCreated,
                              timeMsgCreated,
                              message: msgSnapShot.data()['msg'],
                              isCustom: false,
                              bgImageUrl: null,
                              scrollController: _controller,
                              isEmojiKeyBoardVisible: _isEmojiKeyboardVisible,
                              twentiethMsgTimestamp: twentiethMsgTimestamp,
                            );
                          }
                          final Map<String, dynamic> urlList =
                              msgSnapShot.data()['urls'];

                          if (urlList != null && urlList.length >= 4) {
                            final fileSizeMap = msgSnapShot.data()['fileSize'];
                            return ImageGridView(
                              urlList: urlList,
                              msgID: msgSnapShot.id,
                              userIDwhoCreatedMsg: userIDwhoCreatedMsg,
                              fileSizeMap: fileSizeMap,
                              userNameWhoCreated: userNameWhoCreated,
                              timeMsgCreated: timeMsgCreated,
                              user: user,
                              conversationState: this,
                              conversationID: conversationID,
                              isGroupChat: isGroupChat,
                              scrollController: _controller,
                              streamController: _streamController,
                              twentiethMsgTimestamp: twentiethMsgTimestamp,
                            );
                          }
                          if (msgType == 'image') {
                            final url = msgSnapShot.data()['url'];
                            final fileName = msgSnapShot.data()['fileName'];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SingleImagePreview(
                                  user,
                                  this,
                                  conversationID,
                                  msgSnapShot.id,
                                  userIDwhoCreatedMsg,
                                  _streamController,
                                  isGroupChat,
                                  userNameWhoCreated,
                                  timeMsgCreated,
                                  fileName: fileName,
                                  imgUrl: url,
                                  fileSize: fileSize,
                                  scrollController: _controller,
                                  isEmojiKeyBoardVisble:
                                      _isEmojiKeyboardVisible,
                                  twentiethMsgTimestamp: twentiethMsgTimestamp,
                                )
                              ],
                            );
                          }

                          if (msgType == 'audio') {
                            final duration = msgSnapShot.data()['duration'];
                            return AudioPlayerForConversation(
                              user,
                              this,
                              conversationID,
                              msgSnapShot.id,
                              userIDwhoCreatedMsg,
                              _streamController,
                              timeMsgCreated,
                              isGroupChat,
                              userNameWhoCreated,
                              duration,
                              url: msgSnapShot.data()['url'],
                              fileSize: fileSize,
                              scrollController: _controller,
                              twentiethMsgTimestamp: twentiethMsgTimestamp,
                            );
                          }
                          return Container();
                        },
                      );
                    }
                    return Container();
                  }
                },
              )),
              StreamBuilder(
                stream: _conversations.doc(conversationID).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final _isBlocked = snapshot.data.data()['blocked'] ?? false;
                    return _isBlocked
                        ? Container(
                            child: Text("You're blocked"),
                          )
                        : TextInput(
                            user,
                            this,
                            context: context,
                            conversationID: conversationID,
                            isGroupChat: isGroupChat,
                            isEmojiKeyBoardVisible: _isEmojiKeyboardVisible,
                            scrollController: _controller,
                            newUploadAdded: _newUploadAdded,
                          );
                  }
                  return Container();
                },
              ),
            ])))));
  }

  String _timeStatus(int timestamp) {
    DateTime timeMsgCreated = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timeMsgCreated.isToday) {
      final hour = timeMsgCreated.hour;
      final minute = timeMsgCreated.minute;
      String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
      return 'today at $hour:' + mins;
    }
    if (timeMsgCreated.isYesterday) {
      final hour = timeMsgCreated.hour;
      final minute = timeMsgCreated.minute;
      String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
      return 'yesterday at $hour:' + mins;
    }
    if (timeMsgCreated.isThisYear) {
      final date = timeMsgCreated.day;
      final month = timeMsgCreated.month;
      final hour = timeMsgCreated.hour;
      final minute = timeMsgCreated.minute;
      String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
      return '$date/$month at $hour:' + mins;
    } else {
      final date = timeMsgCreated.day;
      final month = timeMsgCreated.month;
      final year = timeMsgCreated.year;
      return '$date/$month/$year';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ImageGridView extends StatefulWidget {
  final Map<String, dynamic> urlList;
  final String msgID;
  final String userIDwhoCreatedMsg;
  final Map<String, dynamic> fileSizeMap;
  final String userNameWhoCreated;
  final int timeMsgCreated;
  final User user;
  final ConversationState conversationState;
  final String conversationID;
  final bool isGroupChat;
  final ItemScrollController scrollController;
  final StreamController<ForwardSnap> streamController;
  final int twentiethMsgTimestamp;
  const ImageGridView(
      {Key key,
      this.urlList,
      this.msgID,
      this.userIDwhoCreatedMsg,
      this.fileSizeMap,
      this.userNameWhoCreated,
      this.timeMsgCreated,
      this.user,
      this.conversationState,
      this.conversationID,
      this.isGroupChat,
      this.scrollController,
      this.streamController,
      this.twentiethMsgTimestamp})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ImageGridViewState();
  }
}

class ImageGridViewState extends State<ImageGridView> {
  ForwardSnap _forwardSnap;
  bool _isSelected = false;
  @override
  void initState() {
    super.initState();
    _forwardSnap = ForwardSnap(
        widget.msgID,
        widget.conversationID,
        'image',
        widget.userIDwhoCreatedMsg,
        widget.timeMsgCreated,
        widget.twentiethMsgTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime msgCreated =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMsgCreated);
    final hour = msgCreated.hour;
    final minute = msgCreated.minute;
    String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
    final width = MediaQuery.of(context).size.width;
    return Container(
        color: _isSelected ? Colors.lightGreen : Colors.white,
        width: width,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                (widget.userIDwhoCreatedMsg == widget.user.userID)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    if (widget.conversationState.selectedMessages.isEmpty) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return MultipleImageView(
                          widget.user,
                          mediaList: widget.urlList,
                          fileSizeMap: widget.fileSizeMap,
                        );
                      }));
                    }
                    final isSelected = widget
                            .conversationState.selectedMessages[_forwardSnap] ??
                        false;
                    if (isSelected) {
                      widget.streamController.add(ForwardSnap(
                          '', '', '', '', 0, widget.twentiethMsgTimestamp));
                      widget.conversationState.selectedMessages
                          .remove(_forwardSnap);
                      setState(() {
                        _isSelected = false;
                      });
                      if (widget.conversationState.selectedMessages.isEmpty) {
                        widget.streamController.add(ForwardSnap(
                            '', '', '', '', 0, widget.twentiethMsgTimestamp));
                      }
                    } else if (widget
                        .conversationState.selectedMessages.isNotEmpty) {
                      widget.streamController.add(ForwardSnap(
                          '', '', '', '', 0, widget.twentiethMsgTimestamp));
                      widget.conversationState.selectedMessages[_forwardSnap] =
                          true;
                      setState(() {
                        _isSelected = true;
                      });
                    }
                  },
                  onLongPress: () {
                    widget.streamController.add(ForwardSnap(
                        '', '', '', '', 0, widget.twentiethMsgTimestamp));
                    widget.conversationState.selectedMessages[_forwardSnap] =
                        true;
                    setState(() {
                      _isSelected = true;
                    });
                  },
                  child: Column(
                      crossAxisAlignment:
                          (widget.user.userID == widget.userIDwhoCreatedMsg)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: <Widget>[
                        (widget.isGroupChat &&
                                (widget.user.userID !=
                                    widget.userIDwhoCreatedMsg))
                            ? Container(
                                margin: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  widget.userNameWhoCreated,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))
                            : Container(),
                        Container(
                            height: 212,
                            width: 212,
                            child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  GridView.builder(
                                    itemCount: 4,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemBuilder: (BuildContext context, index) {
                                      final url =
                                          widget.urlList.keys.elementAt(index);
                                      final fileName = widget.urlList[url];
                                      return SingleImagePreview(
                                        widget.user,
                                        widget.conversationState,
                                        widget.conversationID,
                                        widget.msgID,
                                        '',
                                        null,
                                        widget.isGroupChat,
                                        widget.userNameWhoCreated,
                                        widget.timeMsgCreated,
                                        fileName: fileName,
                                        imgUrl: url,
                                        isGridView: true,
                                        fileSize: widget.fileSizeMap[fileName],
                                        scrollController:
                                            widget.scrollController,
                                      );
                                    },
                                  ),
                                  Container(
                                      height: 200,
                                      width: 200,
                                      child: (Text(
                                        (widget.urlList.length > 4)
                                            ? '+ ${widget.urlList.length - 4}'
                                            : '',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      )))
                                ])),
                        Text(
                          '$hour:' + mins,
                          style: TextStyle(fontSize: 10),
                        ),
                        !widget.isGroupChat
                            ? Read(
                                userIDwhoCreatedThisMsg:
                                    widget.userIDwhoCreatedMsg,
                                userID: widget.user.userID,
                                conversationID: widget.conversationID,
                                msgID: widget.msgID)
                            : Container()
                      ]))
            ]));
  }
}
