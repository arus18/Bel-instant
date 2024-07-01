import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'contacts.dart';
import 'conversation.dart';
import 'photoview.dart';
import 'profileView.dart';
import 'user.dart';
import 'updateFunctions.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:dart_date/dart_date.dart';
import 'sendMsgs.dart';

class HomeState extends StatefulWidget {
  final User user;

  HomeState(this.user);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeState> {
  //late AdmobBanner myBanner;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    //myBanner = buildBannerAd();
  }

  /*AdmobBanner buildBannerAd() {
    return AdmobBanner(
      adUnitId:
          'ca-app-pub-7282852941650188/8486998527', // Replace with your actual ad unit ID
      // ignore: sdk_version_constructor_tearoffs
      adSize: AdmobBannerSize.BANNER,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.loaded) {
          print('AdMob banner loaded.');
        }
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      actions: <Widget>[
        IconButton(
          onPressed: () {
            //print(widget.user.profilePhotUrl);
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ProfileView(
                user: widget.user,
              );
            }));
          },
          icon: Icon(Icons.person),
        ),
      ],
      elevation: 8,
      title: Text("Chats", style: TextStyle(color: Colors.black)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      backgroundColor: Colors.yellow,
    );

    return Scaffold(
      bottomNavigationBar: Container(
        height: 50,
        // Display AdMob banner here
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        backgroundColor: Colors.yellow,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return Contacts(
              user: widget.user,
              conversationID: '',
              displayPictureUrl: '',
              fileName: '',
              fileSize: 0,
              fileUrl: '',
              forward: false,
              forwardMsgList: [],
              groupDisplayPicture: '',
              groupName: '',
            );
          }));
        },
      ),
      appBar: appBar,
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.regionCode)
              .collection('users')
              .doc('${widget.user.userID}')
              .collection('conversations')
              .orderBy('timeDelayTimestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final conversationSnapshot = snapshot.data!.docs[index];
                  final String displayPictureUrl =
                      conversationSnapshot['displayPictureUrl'];
                  final conversationName =
                      conversationSnapshot['conversationWith'];
                  final phoneNumber = conversationSnapshot['phoneNumber'] ?? '';
                  final isGruopInvite =
                      conversationSnapshot['groupInvite'] ?? false;
                  final isGroupChat =
                      conversationSnapshot['groupChat'] ?? false;
                  final isBlocked = conversationSnapshot['blocked'] ?? false;
                  final userIDconversationWith =
                      conversationSnapshot['userIDconversationWith'];

                  if (isGruopInvite) {
                    return GroupInvite(
                      conversationSnapshot: conversationSnapshot,
                      user: widget.user,
                    );
                  }

                  return FutureBuilder<bool>(
                    future: conversationHasData(
                        conversationSnapshot.id, widget.user),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> hasData) {
                      if (hasData.connectionState == ConnectionState.done) {
                        return Container(
                          height: 75,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.yellow),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(5),
                          child: ListTile(
                            onTap: () {
                              setlastReadMsgTimestamp(
                                  conversationSnapshot.id, widget.user);
                              setUserLive(conversationSnapshot.id, widget.user);
                              setUnreadCountToZero(
                                  conversationSnapshot.id, widget.user);
                              setMsgsRead(
                                  conversationSnapshot['lastReadMsgTimestamp'],
                                  conversationSnapshot.id,
                                  widget.user);

                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return Conversation(
                                  conversationSnapshot['lastReadMsgTimestamp'],
                                  user: widget.user,
                                  conversationID: conversationSnapshot.id,
                                  isGroupChat: isGroupChat,
                                  isBlocked: isBlocked,
                                  phoneNumber: phoneNumber,
                                  displayPictureUrl: displayPictureUrl,
                                  conversationWith: conversationName,
                                  userIDconversationWith:
                                      userIDconversationWith,
                                );
                              }));
                            },
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ProfileImageView(displayPictureUrl,
                                      conversationName, phoneNumber);
                                }));
                              },
                              child: displayPictureUrl.isEmpty
                                  ? CircleAvatar()
                                  : CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              displayPictureUrl),
                                    ),
                            ),
                            title: Text(
                              conversationName,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Subtitle(
                              userID: widget.user.userID,
                              conversationID: conversationSnapshot.id,
                              isGroupChat: isGroupChat,
                            ),
                            trailing: Trailing(
                              conversationID: conversationSnapshot.id,
                              userID: widget.user.userID,
                              regionCode: widget.user.regionCode,
                            ),
                          ),
                        );
                      }
                      return Container(); // Placeholder widget until Future completes
                    },
                  );
                },
              );
            }
            return Container(); // Placeholder widget until StreamBuilder has data
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Subtitle extends StatelessWidget {
  final String userID;
  final String conversationID;
  final bool isGroupChat;
  const Subtitle(
      {Key? key,
      required this.userID,
      required this.conversationID,
      required this.isGroupChat})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasData) {
          final participants = snapshot.data!.docs;
          //print(participants.first.data().toString());
          String userStatus = '';
          final participant = participants
              .first; /*first(
            (snap) {
              return (snap.id != userID &&
                  (snap['status'] == 'typing' ||
                      snap['status'] == 'recording audio'));
            },
          )*/
          if (participant != null) {
            if (isGroupChat) {
              userStatus = '${participant['name']} is ' + participant['status'];
            } else {
              userStatus = participant['status'];
            }

            return FutureBuilder(
              future: hasInternetConnection(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data) {
                    return Text(
                      userStatus,
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    );
                  }
                }
                return Container();
              },
            );
          } else {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationID)
                    .collection('msgs')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final msgSnapShot = snapshot.data!.docs.last;
                    String lastMsg = '';
                    final msgType = msgSnapShot['msgType'];
                    if (msgType == 'updateInfo') {
                      lastMsg = msgSnapShot['info'];
                    }
                    if (msgType == 'text' || msgType == 'reply') {
                      lastMsg = msgSnapShot['msg'];
                    }
                    if (msgType == 'audio') {
                      lastMsg = 'Audio';
                    }
                    if (msgType == 'image') {
                      lastMsg = 'image';
                    }
                    if (msgType == 'deleted') {
                      lastMsg = 'deleted';
                    }
                    return Text(lastMsg);
                  }
                  return Container();
                });
          }
        }
        return Container();
      },
    );
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
}

class Trailing extends StatelessWidget {
  final String conversationID;
  final String userID;
  final String regionCode;
  const Trailing(
      {Key? key,
      required this.conversationID,
      required this.userID,
      required this.regionCode})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50,
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(regionCode)
                .collection('users')
                .doc(userID)
                .collection('conversations')
                .doc(conversationID)
                .collection('updates')
                .doc(conversationID)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasData) {
                final _timestamp = snapshot.data!['timestamp'] ?? 0;
                final _unreadCount = snapshot.data!['unreadCount'] ?? 0;
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        _timeStatus(_timestamp),
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      (_unreadCount != 0)
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.yellow, shape: BoxShape.circle),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                '$_unreadCount',
                                style: TextStyle(fontSize: 10),
                              ))
                          : Container()
                    ]);
              }
              return Container();
            }));
  }

  String _timeStatus(int timestamp) {
    if (timestamp == 0) {
      return '';
    }
    DateTime timeMsgCreated = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timeMsgCreated.isToday) {
      final hour = timeMsgCreated.hour;
      final minute = timeMsgCreated.minute;
      String mins = '$minute'.length < 2 ? '0$minute' : '$minute';
      return '$hour:' + mins;
    }
    if (timeMsgCreated.isYesterday) {
      return 'Yesterday';
    }
    if (timeMsgCreated.isThisYear) {
      final date = timeMsgCreated.day;
      final month = timeMsgCreated.month;
      return '$date/$month';
    } else {
      final date = timeMsgCreated.day;
      final month = timeMsgCreated.month;
      final year = timeMsgCreated.year;
      return '$date/$month/$year';
    }
  }
}

class GroupInvite extends StatefulWidget {
  final DocumentSnapshot conversationSnapshot;
  const GroupInvite(
      {Key? key, required this.conversationSnapshot, required this.user})
      : super(key: key);
  final User user;
  @override
  State<StatefulWidget> createState() {
    return GroupInviteState(conversationSnapshot, user);
  }
}

class GroupInviteState extends State<GroupInvite> {
  bool joiningGroup = false;
  bool deletingGroupInvite = false;
  final DocumentSnapshot conversationSnapshot;
  final User user;
  GroupInviteState(this.conversationSnapshot, this.user);
  @override
  Widget build(BuildContext context) {
    final String groupDisplayPicture =
        conversationSnapshot['groupDisplayPicture'] ?? '';
    final String invitorDisplayPicture =
        conversationSnapshot['invitorDisplayPicture'] ?? '';
    final groupName = conversationSnapshot['groupName'];
    final invitorName = conversationSnapshot['invitorName'];
    final groupConversationID = conversationSnapshot['groupConversationID'];
    final invitorID = conversationSnapshot['invitorID'];
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow),
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        margin: EdgeInsets.all(5),
        child: ListTile(
            leading: invitorDisplayPicture.isEmpty
                ? CircleAvatar()
                : CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(invitorDisplayPicture),
                  ),
            title: Text(
              invitorName + ' sent you an invite to join ' + groupName,
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                joiningGroup
                    ? LoadingBouncingLine.circle(
                        size: 20,
                      )
                    : TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Colors.blue, // Button background color
                        ),
                        child: Text('Join'),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.regionCode)
                              .collection('users')
                              .doc(user.userID)
                              .collection('conversations')
                              .doc(conversationSnapshot.id)
                              .delete();
                          _joinGroup(groupConversationID, groupName,
                              groupDisplayPicture, invitorID);
                        },
                      ),
                deletingGroupInvite
                    ? LoadingBouncingLine.circle(
                        size: 20,
                      )
                    : TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Colors.blue, // Button background color
                        ),
                        child: Text('Ignore'),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.regionCode)
                              .collection('users')
                              .doc(user.userID)
                              .collection('conversations')
                              .doc(conversationSnapshot.id)
                              .delete();
                        },
                      )
              ],
            )));
  }

  _joinGroup(String groupConversationID, String groupName,
      String groupDisplayPicture, String invitorID) async {
    setState(() {
      joiningGroup = true;
    });

    final ref = FirebaseFirestore.instance;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final msgID = ref
        .collection('conversations')
        .doc(groupConversationID)
        .collection('msgs')
        .doc()
        .id;
    ref
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations')
        .doc(groupConversationID)
        .set({
      'conversationWith': groupName,
      'displayPictureUrl': groupDisplayPicture,
      'unreadCount': 0,
      'groupChat': true,
      'lastReadMsgTimestamp': 0,
      'left': false,
      'timeDelayTimestamp': 0
    }, SetOptions(merge: true));
    ref
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations')
        .doc(groupConversationID)
        .collection('updates')
        .doc(groupConversationID)
        .set({'timestamp': 0, 'unreadCount': 0});
    ref
        .collection('conversations')
        .doc(groupConversationID)
        .collection('participants')
        .doc(user.userID)
        .set({
      'sendNotifications': true,
      'name': user.userName,
      'phoneNumber': user.phoneNumber,
      'displayPictureUrl': user.profilePhotUrl,
      'token': user.token,
      'status': 'offline',
      'regionCode': user.regionCode
    }, SetOptions(merge: true));
    ref
        .collection('conversations')
        .doc(groupConversationID)
        .collection('msgs')
        .doc(msgID)
        .set({
      'msgType': 'updateInfo',
      'info': '${user.userName} joined $groupName',
      'timestamp': timestamp
    }, SetOptions(merge: true));
    setUnreadCount(
        groupConversationID, msgID, user.userID, timestamp, widget.user,
        isUpdateInfo: true);
    setState(() {
      joiningGroup = false;
    });
    _updateDisplayPictureAndNameIfChangesOccured(
        groupConversationID, invitorID);
  }

  _updateDisplayPictureAndNameIfChangesOccured(
      String conversationID, String invitorUserID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('userRegionCodes')
        .doc(invitorUserID)
        .get();
    final conversationSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userSnapshot['regionCode'])
        .collection('users')
        .doc(invitorUserID)
        .collection('conversations')
        .doc(conversationID)
        .get();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations')
        .doc(conversationID)
        .set({
      'conversationWith': conversationSnapshot['conversationWith'],
      'displayPictureUrl': conversationSnapshot['displayPictureUrl']
    }, SetOptions(merge: true));
  }
}
