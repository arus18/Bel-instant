import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'conversation.dart';
import 'displayPictureAndName.dart';
import 'groupChats.dart';
import 'home.dart';
import 'refreshcontacts.dart';
import 'sendMsgs.dart';
import 'updateFunctions.dart';
import 'user.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Contacts extends StatefulWidget {
  final List<ForwardSnap> forwardMsgList;
  final String groupDisplayPicture;
  final String groupName;
  final bool newGroupInvite;
  final User user;
  final bool newBroadCast;
  final bool forward;
  final bool isGroupChat;
  final bool sendGroupInvite;
  final String displayPictureUrl;
  final String conversationID;
  final bool forwardSingleImage;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  const Contacts({
    Key? key,
    required this.user,
    this.newGroupInvite = false,
    required this.groupDisplayPicture,
    required this.groupName,
    this.newBroadCast = false,
    required this.forwardMsgList,
    required this.forward,
    this.isGroupChat = false,
    this.sendGroupInvite = false,
    required this.displayPictureUrl,
    required this.conversationID,
    this.forwardSingleImage = false,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ContactsState(
      user,
      groupDisplayPicture,
      groupName,
      newBroadCast,
      forwardMsgList,
      forward,
      isGroupChat,
      newGroupInvite: newGroupInvite,
    );
  }
}

class ContactsState extends State<Contacts> {
  final bool isGroupChat;
  final List<ForwardSnap> forwardMsgList;
  final String groupDisplayPicture;
  final String groupName;
  bool expand = true;
  final User user;
  bool refreshingContacts = false;
  late CollectionReference _dbContacts;
  Map<String, bool> _selectionList = Map<String, bool>();
  List<String> _contactIDList = [];
  ContactsState(this.user, this.groupDisplayPicture, this.groupName,
      this.newBroadcast, this.forwardMsgList, this.forward, this.isGroupChat,
      {required this.newGroupInvite});
  final bool newGroupInvite;
  final bool forward;
  final bool newBroadcast;
  final ref = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _dbContacts = ref
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc('${user.userID}')
        .collection('contacts');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 8,
      title: Text("Contacts", style: TextStyle(color: Colors.black)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30))),
      backgroundColor: Colors.yellow,
      actions: <Widget>[],
    );
    return Scaffold(
        bottomNavigationBar:
            Container(height: 50, child: Center(child: Text('Ad'))),
        persistentFooterButtons: <Widget>[
          (newGroupInvite || newBroadcast)
              ? Container(
                  height: 5,
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.all(2),
                  ),
                  child: Text('New group'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                InitializeDisplayPictureName(
                                  forNewGroup: true,
                                  user: user,
                                )));
                  },
                ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: EdgeInsets.all(2),
            ),
            child: Text('Invite'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return InviteContacts();
              }));
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: EdgeInsets.all(2),
            ),
            onPressed: () async {
              setState(() {
                refreshingContacts = true;
              });
              await refreshContacts(user);
              setState(() {
                refreshingContacts = false;
              });
            },
            child: Icon(Icons.refresh),
          ),
          newBroadcast
              ? TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.all(2),
                  ),
                  child: Text('Groups'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => GroupChats(
                                  user: user,
                                  forwardMsgList: forwardMsgList,
                                  forwardSingleImage: widget.forwardSingleImage,
                                  fileName: widget.fileName,
                                  fileSize: widget.fileSize,
                                  fileUrl: widget.fileUrl,
                                )));
                  },
                )
              : Container(
                  height: 5,
                )
        ],
        bottomSheet: refreshingContacts
            ? Container(
                color: Colors.yellow,
                child: Text('Updating contacts...'),
              )
            : (newGroupInvite || newBroadcast || widget.sendGroupInvite)
                ? Container(
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
                              _contactIDList.forEach((contactID) {
                                _selectionList[contactID] = true;
                              });
                            });
                          },
                          label: Text('Select all'),
                        ),
                        FloatingActionButton.extended(
                          heroTag: 'invite1',
                          backgroundColor: Colors.red,
                          onPressed: () async {
                            if (!widget.sendGroupInvite) {
                              Navigator.pop(context);
                            }
                            if (widget.sendGroupInvite) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomeState(
                                      widget.user,
                                    ),
                                  ),
                                  (Route<dynamic> route) => false);
                              for (int i = 0; i < _selectionList.length; i++) {
                                String contactID =
                                    _selectionList.keys.elementAt(i);
                                bool isSelected = _selectionList[contactID]!;
                                if (isSelected) {
                                  final contactSnapshot = await ref
                                      .collection('users')
                                      .doc(user.regionCode)
                                      .collection('users')
                                      .doc(user.userID)
                                      .collection('contacts')
                                      .doc(contactID)
                                      .get();
                                  final userID = contactSnapshot.id;
                                  final regionCode =
                                      contactSnapshot['regionCode'];
                                  final participantSnapshot = await ref
                                      .collection('conversations')
                                      .doc(widget.conversationID)
                                      .collection('participants')
                                      .doc(userID)
                                      .get();
                                  if (!participantSnapshot.exists) {
                                    _sendGroupInvite(
                                        userID,
                                        widget.displayPictureUrl,
                                        widget.conversationID,
                                        regionCode);
                                  }
                                }
                              }
                            }
                            if (newGroupInvite) {
                              _createNewGroupConversation(context);
                            } else if (newBroadcast) {
                              final conversationIDlist =
                                  await _createNewBroadcast();
                              forwardMsgList.forEach((forwardSnap) async {
                                final msgType = forwardSnap.msgType;
                                final msgID = forwardSnap.msgID;
                                final conversationID =
                                    forwardSnap.conversationID;

                                final msgSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('conversations')
                                    .doc(conversationID)
                                    .collection('msgs')
                                    .doc(msgID)
                                    .get();
                                if (msgType == 'text') {
                                  Map<String, dynamic> map = {
                                    'msgSnapshot': msgSnapshot,
                                    'conversationID': conversationIDlist,
                                  };
                                  forwardText(
                                    map,
                                    user,
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
                                        'userID': user.userID,
                                        'timestamp': timestamp,
                                        'fileSize': widget.fileSize,
                                        'name': user.userName
                                      }, SetOptions(merge: true)));
                                      setUnreadCount(
                                        conversationID,
                                        msgID,
                                        user.userID,
                                        timestamp,
                                        user,
                                      );
                                    });
                                  } else {
                                    forwardImage(
                                      map,
                                      user,
                                    );
                                  }
                                }
                                if (msgType == 'audio') {
                                  Map<String, dynamic> map = {
                                    'msgSnapshot': msgSnapshot,
                                    'conversationID': conversationIDlist,
                                  };
                                  forwardAudio(
                                    map,
                                    user,
                                  );
                                }
                              });
                            }
                          },
                          label: newBroadcast ? Text('Send') : Text('Invite'),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 50,
                  ),
        appBar: appBar,
        // ignore: unnecessary_null_comparison
        body: (_dbContacts != null
            ? (StreamBuilder<QuerySnapshot>(
                stream: _dbContacts.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text('Loading'),
                    );
                  }
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final contactSnapshot = snapshot.data!.docs[index];
                        if (contactSnapshot['contactName'] !=
                            null) //to avoid contact that is not in users contacts list to be added in database
                        {
                          return DBContactCard(
                            contactSnapshot: contactSnapshot,
                            contactState: this,
                            user: user,
                            newGroupInvite: newGroupInvite,
                            newBroadCast: newBroadcast,
                            sendGroupInvite: widget.sendGroupInvite,
                          );
                        }
                        return Container();
                      },
                    );
                  }
                  return Container();
                },
              ))
            : Center(
                child: LoadingBumpingLine.circle(
                backgroundColor: Colors.yellow,
              ))));
  }

  Future<List<String>> _createNewBroadcast() async {
    List<String> conversationIDs = [];
    for (int i = 0; i < _selectionList.length; i++) {
      String contactID = _selectionList.keys.elementAt(i);
      bool isSelected = _selectionList[contactID]!;
      bool isBlocked = false;
      if (isSelected) {
        final contactSnapshot = await ref
            .collection('users')
            .doc(user.regionCode)
            .collection('users')
            .doc(user.userID)
            .collection('contacts')
            .doc(contactID)
            .get();
        final userID = contactSnapshot.id;
        final profilePhotoUrl = contactSnapshot['displayPictureUrl'];
        final contactName = contactSnapshot['contactName'];
        final contactPhoneNumber = contactSnapshot['phoneNumber'];
        final regionCode = contactSnapshot['regionCode'];
        String conversationID = contactSnapshot['conversationID'];
        // ignore: unnecessary_null_comparison
        if (conversationID == null) {
          conversationID = await _createNewConversation(
            userID,
            contactName,
            profilePhotoUrl,
            contactPhoneNumber,
            user,
            regionCode,
          );
        } else {
          final conversationSnapshot = await ref
              .collection('users')
              .doc(user.regionCode)
              .collection('users')
              .doc(user.userID)
              .collection('conversations')
              .doc(conversationID)
              .get();
          isBlocked = conversationSnapshot['blocked'] ?? false;
        }
        if (!isBlocked) {
          conversationIDs.add(conversationID);
        }
      }
    }
    return conversationIDs;
  }

  _createNewGroupConversation(BuildContext context) async {
    final conversation = ref.collection('conversations').doc();
    String mediaUrl = '';
    if (groupDisplayPicture.isNotEmpty) {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + 'profilePic';
      final path =
          user.userID + '/' + conversation.id + '/profilePic/' + fileName;
      final task =
          await (storageRef.child(path).putFile(File(groupDisplayPicture)));
      mediaUrl = await task.ref.getDownloadURL();
    }

    ref
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations')
        .doc(conversation.id)
        .set({
      'conversationWith': groupName,
      'displayPictureUrl': mediaUrl,
      'groupChat': true,
      'lastReadMsgTimestamp': 0,
      'left': false,
      'timeDelayTimestamp': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    ref
        .collection('users')
        .doc(user.regionCode)
        .collection('users')
        .doc(user.userID)
        .collection('conversations')
        .doc(conversation.id)
        .collection('updates')
        .doc(conversation.id)
        .set({'timestamp': 0, 'unreadCount': 0});
    ref
        .collection('conversations')
        .doc(conversation.id)
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
        .doc(conversation.id)
        .collection('msgs')
        .doc()
        .set({
      'msgType': 'updateInfo',
      'info': '${user.userName} created $groupName',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    ref.collection('conversations').doc(conversation.id).set(
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
        SetOptions(merge: true));

    for (int i = 0; i < _selectionList.length; i++) {
      String contactID = _selectionList.keys.elementAt(i);
      bool isSelected = _selectionList[contactID]!;
      if (isSelected) {
        final contactSnapshot = await ref
            .collection('users')
            .doc(user.regionCode)
            .collection('users')
            .doc(user.userID)
            .collection('contacts')
            .doc(contactID)
            .get();
        final userID = contactSnapshot.id;
        final regionCode = contactSnapshot['regionCode'];
        _sendGroupInvite(userID, mediaUrl, conversation.id, regionCode);
      }
    }
  }

  _sendGroupInvite(String userID, String groupDisplayPicture,
      String groupConversationID, String regionCode) {
    ref
        .collection('users')
        .doc(regionCode)
        .collection('users')
        .doc(userID)
        .collection('conversations')
        .doc()
        .set({
      'msgType': 'groupInvite',
      'groupInvite': true,
      'groupDisplayPicture': groupDisplayPicture,
      'groupName': groupName,
      'invitorName': user.userName,
      'groupConversationID': groupConversationID,
      'invitorID': user.userID,
      'timeDelayTimestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

class DBContactCard extends StatefulWidget {
  final bool sendGroupInvite;
  final bool newBroadCast;
  final bool newGroupInvite;
  final User user;
  final DocumentSnapshot contactSnapshot;
  final ContactsState contactState;
  const DBContactCard(
      {Key? key,
      required this.contactState,
      required this.contactSnapshot,
      required this.user,
      required this.newGroupInvite,
      required this.newBroadCast,
      this.sendGroupInvite = false})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DBContactCardState(
        contactState, contactSnapshot, user, newGroupInvite, newBroadCast);
  }
}

class DBContactCardState extends State<DBContactCard> {
  bool loadingConversation = false;
  final bool newBroadCast;
  final bool newGroupInvite;
  final User user;
  final DocumentSnapshot contactSnapshot;
  final ContactsState contactState;
  DBContactCardState(this.contactState, this.contactSnapshot, this.user,
      this.newGroupInvite, this.newBroadCast);
  @override
  Widget build(BuildContext context) {
    final isSelected = contactState._selectionList[contactSnapshot.id] ?? false;
    final String profilePhotoUrl = contactSnapshot['displayPictureUrl'] ?? '';
    final contactName = contactSnapshot['contactName'] ?? '';
    final contactPhoneNumber = contactSnapshot['phoneNumber'] ?? '';
    final userID = contactSnapshot.id;
    final conversationID = contactSnapshot['conversationID'];
    final regionCode = contactSnapshot['regionCode'];
    final isBlocked = contactSnapshot['blocked'] ?? false;
    contactState._contactIDList.add(contactSnapshot.id);
    return ListTile(
      onTap: () async {
        if (newGroupInvite || newBroadCast || widget.sendGroupInvite) {
          setState(() {
            if (isSelected) {
              contactState._selectionList[contactSnapshot.id] = false;
            } else {
              contactState._selectionList[contactSnapshot.id] = true;
            }
          });
        } else {
          if (conversationID != null && !loadingConversation) {
            setState(() {
              loadingConversation = true;
            });
            final conversationSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.regionCode)
                .collection('users')
                .doc(user.userID)
                .collection('conversations')
                .doc(conversationID)
                .get();
            setlastReadMsgTimestamp(
              conversationID,
              user,
            );
            setUserLive(conversationID, user);
            setUnreadCountToZero(conversationID, user);
            setMsgsRead(
              conversationSnapshot['lastReadMsgTimestamp'],
              conversationID,
              user,
            );
            setState(() {
              loadingConversation = false;
            });
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return Conversation(
                conversationSnapshot['lastReadMsgTimestamp'],
                user: user,
                conversationID: conversationID,
                isGroupChat: false,
                isBlocked: isBlocked,
                conversationWith: contactName,
                phoneNumber: contactPhoneNumber,
                displayPictureUrl: profilePhotoUrl,
                userIDconversationWith: contactSnapshot.id,
              );
            }));
          } else {
            if (!loadingConversation) {
              setState(() {
                loadingConversation = true;
              });
              final conversationID = await _createNewConversation(
                  userID,
                  contactName,
                  profilePhotoUrl,
                  contactPhoneNumber,
                  user,
                  regionCode);
              setUserLive(conversationID, user);
              setState(() {
                loadingConversation = false;
              });
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Conversation(
                  0,
                  user: user,
                  conversationID: conversationID,
                  isGroupChat: false,
                  isBlocked: false,
                  conversationWith: contactName,
                  phoneNumber: contactName,
                  displayPictureUrl: profilePhotoUrl,
                  userIDconversationWith: contactSnapshot.id,
                );
              }));
            }
          }
        }
      },
      leading: profilePhotoUrl.isEmpty
          ? CircleAvatar()
          : CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(profilePhotoUrl),
            ),
      title: loadingConversation
          ? LoadingBumpingLine.circle(
              backgroundColor: Colors.yellow,
            )
          : Text(contactName, maxLines: 1),
      trailing: isSelected
          ? Icon(Icons.check)
          : Container(
              width: 5,
            ),
    );
  }
}

Future<String> _createNewConversation(
  String userID,
  String contactName,
  String profilePhotoUrl,
  String contactPhoneNumber,
  User user,
  String regionCode,
) async {
  final ref = FirebaseFirestore.instance;
  final conversation = ref.collection('conversations').doc();
  final userSnap = await ref.collection('userRegionCodes').doc(userID).get();
  final regionCode = userSnap['regionCode'];
  final fcmToken = userSnap['token'];
  ref
      .collection('conversations')
      .doc(conversation.id)
      .set({'timestamp': DateTime.now().millisecondsSinceEpoch});

  ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('contacts')
      .doc(userID)
      .set({'conversationID': conversation.id}, SetOptions(merge: true));

  ref
      .collection('users')
      .doc(regionCode)
      .collection('users')
      .doc(userID)
      .collection('contacts')
      .doc(user.userID)
      .set({'conversationID': conversation.id, 'regionCode': user.regionCode},
          SetOptions(merge: true));

  ref
      .collection('conversations')
      .doc(conversation.id)
      .collection('participants')
      .doc(userID)
      .set({
    'sendNotifications': true,
    'name': contactName,
    'phoneNumber': contactPhoneNumber,
    'displayPictureUrl': profilePhotoUrl,
    'token': fcmToken,
    'status': 'offline',
    'regionCode': regionCode,
  }, SetOptions(merge: true));
  ref
      .collection('conversations')
      .doc(conversation.id)
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
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('conversations')
      .doc(conversation.id)
      .set({
    'userIDconversationWith': userID,
    'conversationWith': contactName,
    'displayPictureUrl': profilePhotoUrl,
    'phoneNumber': contactPhoneNumber,
    'lastReadMsgTimestamp': 0,
    'timeDelayTimestamp': 0
  }, SetOptions(merge: true));
  ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('conversations')
      .doc(conversation.id)
      .collection('updates')
      .doc(conversation.id)
      .set({'timestamp': 0, 'unreadCount': 0});
  ref
      .collection('users')
      .doc(regionCode)
      .collection('users')
      .doc(userID)
      .collection('conversations')
      .doc(conversation.id)
      .set({
    'userIDconversationWith': user.userID,
    'conversationWith': user.userName,
    'displayPictureUrl': user.profilePhotUrl,
    'phoneNumber': user.phoneNumber,
    'lastReadMsgTimestamp': 0,
    'timeDelayTimestamp': 0
  }, SetOptions(merge: true));
  ref
      .collection('users')
      .doc(regionCode)
      .collection('users')
      .doc(userID)
      .collection('conversations')
      .doc(conversation.id)
      .collection('updates')
      .doc(conversation.id)
      .set({'timestamp': 0, 'unreadCount': 0});

  return conversation.id;
}

class InviteContacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InviteContactsState();
  }
}

class InviteContactsState extends State<InviteContacts> {
  bool loading = false;
  late List<Contact> _phoneContacts;
  Map<Contact, bool> selectionList = Map<Contact, bool>();
  Future<void> getContacts() async {
    try {
      final Iterable<Contact> contacts = await FlutterContacts.getContacts();
      setState(() {
        _phoneContacts = contacts.toList();
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      bottomSheet: Container(
        height: 50,
        color: Colors.yellow,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: 'invite',
              backgroundColor: Colors.red,
              onPressed: () {
                final List<String> recipents = [];
                selectionList.forEach((contact, isSelected) async {
                  if (isSelected) {
                    for (var number in contact.phones) {
                      recipents.add(number.number);
                    }
                    if (recipents.isNotEmpty) {
                      setState(() {
                        loading = true;
                      });
                      setState(() {
                        loading = false;
                      });
                    }
                  }
                });
              },
              label: loading
                  ? LoadingBumpingLine.circle(
                      backgroundColor: Colors.yellow,
                    )
                  : const Text('Invite'),
            )
          ],
        ),
      ),
      appBar: AppBar(),
      // ignore: unnecessary_null_comparison
      body: _phoneContacts != null
          ? ListView.builder(
              itemCount: _phoneContacts.length,
              itemBuilder: (BuildContext context, index) {
                final contact = _phoneContacts[index];
                final isSelected = selectionList[contact] ?? false;
                return ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectionList[contact] = false;
                      } else {
                        selectionList[contact] = true;
                      }
                    });
                  },
                  leading: (contact.photo != null && contact.photo!.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage:
                              MemoryImage(contact.photo ?? Uint8List(0)),
                        )
                      : CircleAvatar(
                          child: Text(contact.displayName),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                  title: Text(contact.displayName ?? ''),
                  trailing: (isSelected)
                      ? Icon(
                          Icons.check,
                          color: Colors.black,
                        )
                      : Container(height: 2, width: 2),
                );
              },
            )
          : Center(
              child: LoadingBumpingLine.circle(
              backgroundColor: Colors.yellow,
            )),
    );
  }
}

String numberToMonth(int i) {
  if (i == 1) {
    return 'January';
  }
  if (i == 2) {
    return 'February';
  }
  if (i == 3) {
    return 'March';
  }
  if (i == 4) {
    return 'April';
  }
  if (i == 5) {
    return 'May';
  }
  if (i == 6) {
    return 'June';
  }
  if (i == 7) {
    return 'July';
  }
  if (i == 8) {
    return 'August';
  }
  if (i == 9) {
    return 'September';
  }
  if (i == 10) {
    return 'October';
  }
  if (i == 11) {
    return 'November';
  }
  if (i == 12) {
    return 'December';
  }
  return '';
}
