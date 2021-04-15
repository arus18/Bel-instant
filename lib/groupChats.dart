import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:interactive_message/conversation.dart';
import 'package:interactive_message/sendMsgs.dart';
import 'package:interactive_message/user.dart';
import 'package:loading_animations/loading_animations.dart';

class GroupChats extends StatefulWidget {
  final User user;
  final List<ForwardSnap> forwardMsgList;
  final bool forwardSingleImage;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  const GroupChats(
      {Key key,
      this.user,
      this.forwardMsgList,
      this.forwardSingleImage,
      this.fileName,
      this.fileUrl,
      this.fileSize})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return GroupChatsState();
  }
}

class GroupChatsState extends State<GroupChats> {
  bool initialized = false;
  QuerySnapshot conversations;
  Map<String, bool> selectionList = Map<String, bool>();
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    conversations = await (FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.regionCode)
        .collection('users')
        .doc(widget.user.userID)
        .collection('conversations')
        .get());
    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Scaffold(
            appBar: AppBar(
              title: Text('Groups'),
            ),
            bottomNavigationBar:
                Container(height: 50, child: Center(child: Text('Ad'))),
            bottomSheet: Container(
                height: 50,
                color: Colors.yellow,
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton.extended(
                        heroTag: "selectall1",
                        backgroundColor: Colors.red,
                        onPressed: () {
                          setState(() {
                            conversations.docs.forEach((conversation) {
                              final isGroupChat =
                                  conversation.data()['groupChat'] ?? false;
                              if (isGroupChat) {
                                selectionList[conversation.id] = true;
                              }
                            });
                          });
                        },
                        label: Text('Select all'),
                      ),
                      FloatingActionButton.extended(
                        heroTag: "send",
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          Navigator.pop(context);
                          final conversationIDlist = List<String>();
                          selectionList.forEach((conversationID, isSelected) {
                            if (isSelected) {
                              conversationIDlist.add(conversationID);
                            }
                          });
                          widget.forwardMsgList.forEach((forwardSnap) async {
                            final msgType = forwardSnap.msgType;
                            final msgID = forwardSnap.msgID;
                            final conversationID = forwardSnap.conversationID;

                            final msgSnapshot = await FirebaseFirestore.instance
                                .collection('conversations')
                                .doc(conversationID)
                                .collection('msgs')
                                .doc(msgID)
                                .get();
                            if (msgType == 'text') {
                              Map<String, dynamic> map = {
                                'msgSnapshot': msgSnapshot,
                                'conversationID': conversationIDlist,
                                'userID': widget.user.userID
                              };
                              forwardText(
                                map,
                                widget.user,
                              );
                            }
                            if (msgType == 'image') {
                              Map<String, dynamic> map = {
                                'msgSnapshot': msgSnapshot,
                                'conversationID': conversationIDlist,
                              };
                              if (widget.forwardSingleImage) {
                                conversationIDlist
                                    .forEach((conversationID) async {
                                  final msgs = FirebaseFirestore.instance
                                      .collection('conversations')
                                      .doc(conversationID)
                                      .collection('msgs');
                                  final msgID = msgs.doc().id;
                                  final timestamp =
                                      DateTime.now().millisecondsSinceEpoch;
                                  await (msgs.doc(msgID).set({
                                    'msgType': 'image',
                                    'url': widget.fileUrl,
                                    'fileName': widget.fileName,
                                    'userID': widget.user.userID,
                                    'timestamp': timestamp,
                                    'fileSize': widget.fileSize,
                                    'name': widget.user.userName
                                  }, SetOptions(merge: true)));
                                  setUnreadCount(
                                    conversationID,
                                    msgID,
                                    widget.user.userID,
                                    timestamp,
                                    widget.user,
                                  );
                                });
                              } else {
                                forwardImage(
                                  map,
                                  widget.user,
                                );
                              }
                            }
                            if (msgType == 'audio') {
                              Map<String, dynamic> map = {
                                'msgSnapshot': msgSnapshot,
                                'conversationID': conversationIDlist,
                                'userID': widget.user.userID
                              };
                              forwardAudio(
                                map,
                                widget.user,
                              );
                            }
                          });
                        },
                        label: Text('Send'),
                      )
                    ])),
            body: ListView.builder(
              itemCount: conversations.docs.length,
              itemBuilder: (BuildContext context, index) {
                final conversation = conversations.docs[index];
                final isSelected = selectionList[conversation.id] ?? false;
                final isGroupChat = conversation.data()['groupChat'] ?? false;
                if (isGroupChat) {
                  final String displayPictureUrl =
                      conversation.data()['displayPictureUrl'];
                  final String name = conversation.data()['conversationWith'];
                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectionList[conversation.id] = false;
                        } else {
                          selectionList[conversation.id] = true;
                        }
                      });
                    },
                    leading: displayPictureUrl.isEmpty
                        ? CircleAvatar()
                        : CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(displayPictureUrl),
                          ),
                    title: Text(name),
                    trailing: isSelected
                        ? Icon(Icons.check)
                        : Container(
                            width: 5,
                          ),
                  );
                }
                return Container();
              },
            ))
        : Center(
            child: LoadingBumpingLine.circle(
            backgroundColor: Colors.yellow,
          ));
  }
}
