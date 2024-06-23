import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'contacts.dart';
import 'home.dart';
import 'user.dart';
import 'sendMsgs.dart';
import 'package:loading_animations/loading_animations.dart';

class ConversationDetails extends StatefulWidget {
  final User user;
  final String conversationID;
  final String displayPictureUrl;
  final String name;
  final String phoneNumber;
  final bool isGroupChat;
  final String userIDconversationWith;

  const ConversationDetails({
    Key? key,
    required this.user,
    required this.conversationID,
    required this.displayPictureUrl,
    required this.name,
    required this.phoneNumber,
    required this.isGroupChat,
    required this.userIDconversationWith,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ConversationDetailsState();
  }
}

class ConversationDetailsState extends State<ConversationDetails> {
  late QuerySnapshot _participants;
  bool _sendNotifications = false;
  late bool _isBlocked;
  bool _noInternetConnection = false;
  bool _uploading = false;
  bool _editName = false;
  bool _editNameInProgress = false;
  late String _imagePath;
  final _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<bool> _hasInternetConnection() async {
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

  _initialize() async {
    final hasInternetConnection = await _hasInternetConnection();
    if (hasInternetConnection) {
      DocumentSnapshot regionCodeSnapshot;
      regionCodeSnapshot = await (FirebaseFirestore.instance
          .collection('userRegionCodes')
          .doc(widget.userIDconversationWith)
          .get());
      if (!widget.isGroupChat) {
        final conversationSnapshot = await (FirebaseFirestore.instance
            .collection('users')
            .doc(regionCodeSnapshot['regionCode'])
            .collection('users')
            .doc(widget.userIDconversationWith)
            .collection('conversations')
            .doc(widget.conversationID)
            .get());
        _isBlocked = conversationSnapshot['blocked'] ?? false;
      }
      _participants = await (FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationID)
          .collection('participants')
          .get());

      final _participant = await (FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationID)
          .collection('participants')
          .doc(widget.user.userID)
          .get());
      _sendNotifications = _participant['sendNotifications'];

      setState(() {});
    } else {
      setState(() {
        _noInternetConnection = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      body: _noInternetConnection
          ? Center(
              child: Text('Connect to internet'),
            )
          : (_participants == null)
              ? Center(
                  child: LoadingBumpingLine.circle(
                  backgroundColor: Colors.yellow,
                ))
              : widget.isGroupChat
                  ? Center(
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                          Stack(
                              alignment: Alignment.bottomRight,
                              children: <Widget>[
                                Center(
                                    child: Container(
                                  constraints:
                                      BoxConstraints(maxHeight: height / 2),
                                  child: (_imagePath != null)
                                      ? Image(
                                          image: FileImage(File(_imagePath)))
                                      : widget.displayPictureUrl.isEmpty
                                          ? Container()
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  widget.displayPictureUrl),
                                )),
                                _uploading
                                    ? LoadingBumpingLine.circle(
                                        backgroundColor: Colors.yellow,
                                      )
                                    : Row(children: <Widget>[
                                        IconButton(
                                          onPressed: () async {
                                            FilePickerResult result;
                                            try {
                                              result = (await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                type: FileType.image,
                                              ))!;

                                              _imagePath =
                                                  result.files.single.path!;
                                              setState(() {
                                                _uploading = true;
                                              });
                                              final ref = FirebaseStorage
                                                  .instance
                                                  .ref();
                                              final fileName = DateTime.now()
                                                      .millisecondsSinceEpoch
                                                      .toString() +
                                                  'profilePic';
                                              final path = widget.user.userID +
                                                  '/' +
                                                  widget.conversationID +
                                                  '/profilePic/' +
                                                  fileName;
                                              final task = await (ref
                                                  .child(path)
                                                  .putFile(File(_imagePath)));
                                              final mediaUrl = await task.ref
                                                  .getDownloadURL();
                                              _updateAllDisplayPictureAppearences(
                                                  mediaUrl);
                                              final msgID = FirebaseFirestore
                                                  .instance
                                                  .collection('conversations')
                                                  .doc(widget.conversationID)
                                                  .collection('msgs')
                                                  .doc()
                                                  .id;
                                              final timestamp = DateTime.now()
                                                  .millisecondsSinceEpoch;
                                              FirebaseFirestore.instance
                                                  .collection('conversations')
                                                  .doc(widget.conversationID)
                                                  .collection('msgs')
                                                  .doc(msgID)
                                                  .set({
                                                'msgType': 'updateInfo',
                                                'info':
                                                    '${widget.user.userName} changed group icon',
                                                'timestamp': timestamp
                                              });
                                              setUnreadCount(
                                                  widget.conversationID,
                                                  msgID,
                                                  widget.user.userID,
                                                  timestamp,
                                                  widget.user,
                                                  isUpdateInfo: true);
                                              setState(() {
                                                _uploading = false;
                                              });
                                            } catch (e) {}
                                            // ignore: unnecessary_null_comparison
                                          },
                                          icon: Icon(Icons.photo),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            final picker = ImagePicker();
                                            PickedFile result;
                                            try {
                                              result = (await picker.pickImage(
                                                  source: ImageSource
                                                      .camera))! as PickedFile;
                                              _imagePath = result.path;
                                            } catch (e) {}
                                            setState(() {
                                              _uploading = true;
                                            });
                                            final ref =
                                                FirebaseStorage.instance.ref();
                                            final fileName = DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString() +
                                                'profilePic';
                                            final path = widget.user.userID +
                                                '/' +
                                                widget.conversationID +
                                                '/profilePic/' +
                                                fileName;
                                            final task = await (ref
                                                .child(path)
                                                .putFile(File(_imagePath)));
                                            final mediaUrl =
                                                await task.ref.getDownloadURL();
                                            _updateAllDisplayPictureAppearences(
                                                mediaUrl);
                                            final msgID = FirebaseFirestore
                                                .instance
                                                .collection('conversations')
                                                .doc(widget.conversationID)
                                                .collection('msgs')
                                                .doc()
                                                .id;
                                            final timestamp = DateTime.now()
                                                .millisecondsSinceEpoch;
                                            FirebaseFirestore.instance
                                                .collection('conversations')
                                                .doc(widget.conversationID)
                                                .collection('msgs')
                                                .doc(msgID)
                                                .set({
                                              'msgType': 'updateInfo',
                                              'info':
                                                  '${widget.user.userName} changed group icon',
                                              'timestamp': timestamp
                                            });
                                            setUnreadCount(
                                                widget.conversationID,
                                                msgID,
                                                widget.user.userID,
                                                timestamp,
                                                widget.user,
                                                isUpdateInfo: true);
                                            setState(() {
                                              _uploading = false;
                                            });
                                          },
                                          icon: Icon(Icons.camera),
                                        )
                                      ])
                              ]),
                          _editNameInProgress
                              ? LoadingBumpingLine.circle(
                                  backgroundColor: Colors.yellow,
                                )
                              : _editName
                                  ? TextField(
                                      onChanged: (str) {
                                        if (str.length > 30) {
                                          _controller.text = '';
                                        }
                                      },
                                      focusNode: _focusNode,
                                      controller: _controller,
                                      decoration: InputDecoration(
                                          hintText:
                                              'only 30 characters allowed',
                                          labelText: 'Enter group name here',
                                          suffix: IconButton(
                                            onPressed: () {
                                              if (_controller.text.isNotEmpty) {
                                                setState(() {
                                                  _editName = false;
                                                  _editNameInProgress = true;
                                                });
                                                if (_controller
                                                    .text.isNotEmpty) {
                                                  _updateAllNameAppearences(
                                                      _controller.text);
                                                  final msgID =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'conversations')
                                                          .doc(widget
                                                              .conversationID)
                                                          .collection('msgs')
                                                          .doc()
                                                          .id;
                                                  final timestamp = DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch;
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'conversations')
                                                      .doc(
                                                          widget.conversationID)
                                                      .collection('msgs')
                                                      .doc(msgID)
                                                      .set({
                                                    'msgType': 'updateInfo',
                                                    'info':
                                                        '${widget.user.userName} changed group name',
                                                    'timestamp': timestamp
                                                  });
                                                  setUnreadCount(
                                                      widget.conversationID,
                                                      msgID,
                                                      widget.user.userID,
                                                      timestamp,
                                                      widget.user,
                                                      isUpdateInfo: true);
                                                }
                                                setState(() {
                                                  _editNameInProgress = false;
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.check),
                                          )),
                                    )
                                  : Container(
                                      margin: EdgeInsets.all(3),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            _controller.text.isEmpty
                                                ? widget.name
                                                : _controller.text,
                                            style: TextStyle(fontSize: 30),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _editName = true;
                                              });
                                            },
                                            icon: Icon(Icons.edit),
                                          )
                                        ],
                                      )),
                          Container(
                              margin: EdgeInsets.all(3),
                              child: Text(
                                  '${_participants.docs.length} participants')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_sendNotifications) {
                                      _sendNotifications = false;
                                    } else {
                                      _sendNotifications = true;
                                    }
                                  });
                                  _onOrMuteNotifications();
                                },
                                child: Icon(!_sendNotifications
                                    ? Icons.notifications_active
                                    : Icons.notifications_off),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => HomeState(
                                          widget.user,
                                        ),
                                      ),
                                      (Route<dynamic> route) => false);

                                  _leftConversation();
                                },
                                child: Text('Left'),
                              ),
                              TextButton(
                                //color: Colors.yellow,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return Contacts(
                                      user: widget.user,
                                      sendGroupInvite: true,
                                      groupDisplayPicture:
                                          widget.displayPictureUrl,
                                      groupName: widget.name,
                                      displayPictureUrl:
                                          widget.displayPictureUrl,
                                      conversationID: widget.conversationID,
                                      fileName: '',
                                      fileSize: 0,
                                      fileUrl: '',
                                      forward: false,
                                      forwardMsgList: [],
                                    );
                                  }));
                                },
                                child: Text('Invite'),
                              )
                            ],
                          ),
                          (ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (_participants.docs.length),
                            itemBuilder: (BuildContext context, index) {
                              final participant = _participants.docs[index];
                              final String displayPictureUrl =
                                  participant['displayPictureUrl'] ?? '';
                              final name = participant['name'];
                              final phoneNumber = participant['phoneNumber'];
                              return (name != null)
                                  ? ListTile(
                                      leading: displayPictureUrl.isEmpty
                                          ? CircleAvatar()
                                          : CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      displayPictureUrl),
                                            ),
                                      title: Text(name),
                                      subtitle: Text(phoneNumber),
                                    )
                                  : Container();
                            },
                          ))
                        ])))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(maxHeight: height / 2),
                          child: widget.displayPictureUrl.isEmpty
                              ? Container()
                              : CachedNetworkImage(
                                  imageUrl: widget.displayPictureUrl),
                        ),
                        Text(
                          widget.name,
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(widget.phoneNumber,
                            style: TextStyle(fontSize: 25)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                              //color: Colors.yellow,
                              onPressed: () {
                                setState(() {
                                  if (_isBlocked) {
                                    _isBlocked = false;
                                  } else {
                                    _isBlocked = true;
                                  }
                                });
                                _blockOrUnblockConversation();
                              },
                              child: Text(_isBlocked ? 'Unblock' : 'Block'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_sendNotifications) {
                                    _sendNotifications = false;
                                  } else {
                                    _sendNotifications = true;
                                  }
                                });
                                _onOrMuteNotifications();
                              },
                              child: Icon(!_sendNotifications
                                  ? Icons.notifications_active
                                  : Icons.notifications_off),
                            ),
                          ],
                        )
                      ],
                    ),
    );
  }

  _updateAllDisplayPictureAppearences(String mediaUrl) {
    _participants.docs.forEach((participant) {
      final regionCode = participant['regionCode'];
      final userID = participant.id;
      FirebaseFirestore.instance
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(userID)
          .collection('conversations')
          .doc(widget.conversationID)
          .set({
        'displayPictureUrl': mediaUrl,
      }, SetOptions(merge: true));
    });
  }

  _updateAllNameAppearences(String name) {
    _participants.docs.forEach((participant) {
      final regionCode = participant['regionCode'];
      final userID = participant.id;
      FirebaseFirestore.instance
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(userID)
          .collection('conversations')
          .doc(widget.conversationID)
          .set({
        'conversationWith': name,
      }, SetOptions(merge: true));
    });
  }

  _onOrMuteNotifications() {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('participants')
        .doc(widget.user.userID)
        .set({'sendNotifications': _sendNotifications ? true : false},
            SetOptions(merge: true));
  }

  _leftConversation() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final msgID = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('msgs')
        .doc()
        .id;
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.regionCode)
        .collection('users')
        .doc(widget.user.userID)
        .collection('conversations')
        .doc(widget.conversationID)
        .delete();

    FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('participants')
        .doc(widget.user.userID)
        .delete();

    FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('msgs')
        .doc(msgID)
        .set({
      'msgType': 'updateInfo',
      'info': '${widget.user.userName} left ${widget.name}',
      'timestamp': timestamp
    }, SetOptions(merge: true));
    setUnreadCount(widget.conversationID, msgID, widget.user.userID, timestamp,
        widget.user,
        isUpdateInfo: true);
  }

  _blockOrUnblockConversation() async {
    final regionCodeSnapshot = await (FirebaseFirestore.instance
        .collection('userRegionCodes')
        .doc(widget.userIDconversationWith)
        .get());
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final msgID = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('msgs')
        .doc()
        .id;
    FirebaseFirestore.instance
        .collection('users')
        .doc(regionCodeSnapshot['regionCode'])
        .collection('users')
        .doc(widget.userIDconversationWith)
        .collection('conversations')
        .doc(widget.conversationID)
        .set({'blocked': _isBlocked ? true : false}, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationID)
        .collection('msgs')
        .doc(msgID)
        .set({
      'msgType': 'updateInfo',
      'info': _isBlocked ? 'blocked' : 'unblocked',
      'timestamp': timestamp,
      'userID': '${widget.user.userID}',
    }, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.regionCode)
        .collection('users')
        .doc(widget.user.userID)
        .collection('contacts')
        .doc(widget.userIDconversationWith)
        .set({'blocked': _isBlocked ? true : false}, SetOptions(merge: true));
    setUnreadCount(widget.conversationID, msgID, widget.user.userID, timestamp,
        widget.user,
        isUpdateInfo: true);
  }
}
