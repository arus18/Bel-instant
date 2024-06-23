import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authentication.dart';
import 'home.dart';
import 'user.dart' as localuser;
import 'package:loading_animations/loading_animations.dart';
import 'package:permission_handler/permission_handler.dart';

class StartupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StartupScreenState();
  }
}

class StartupScreenState extends State<StartupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = true;
  localuser.User user = localuser.User("", "", "", "", "", "", "");
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  _initUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      //set user status online in every conversation
      final snapshot = await (FirebaseFirestore.instance
          .collection('userRegionCodes')
          .doc(currentUser.uid)
          .get());
      final token = snapshot['token'];
      final regionCode = snapshot['regionCode'];
      _setUserOnline(currentUser, regionCode);
      final userSnapshot = await (FirebaseFirestore.instance
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(currentUser.uid)
          .get());
      final name = userSnapshot['name'];
      final profilePictureUrl = userSnapshot['displayPictureUrl'];
      final phoneNumber = userSnapshot['phoneNumber'];
      final countryCode = userSnapshot['countryCode'];
      user = localuser.User(name, phoneNumber, countryCode, currentUser.uid,
          regionCode, profilePictureUrl, token);
    }
  }

  _setUserOnline(User user, String regionCode) async {
    FirebaseDatabase.instance.ref().child('status/${user.uid}').set('online');
    FirebaseDatabase.instance
        .ref()
        .child('status/${user.uid}')
        .onDisconnect()
        .set('offline');
    final conversations = await (FirebaseFirestore.instance
        .collection('users')
        .doc(regionCode)
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .get());
    if (conversations.docs.isNotEmpty) {
      conversations.docs.forEach((docSnapshot) async {
        final participantSnapshot = await FirebaseFirestore.instance
            .collection('conversations')
            .doc(docSnapshot.id)
            .collection('participants')
            .doc(user.uid)
            .get();
        if (participantSnapshot.exists) {
          FirebaseFirestore.instance
              .collection('conversations')
              .doc(docSnapshot.id)
              .collection('participants')
              .doc(user.uid)
              .set({'status': 'online'}, SetOptions(merge: true));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Scaffold(
            body: Center(
            child: BelInstant(),
          ))
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Permissions'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.camera),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Camera', style: TextStyle(fontSize: 20)),
                    ])),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.contacts),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Contacts', style: TextStyle(fontSize: 20))
                    ])),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.mic),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Microphone', style: TextStyle(fontSize: 20))
                    ])),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.notifications),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Notification', style: TextStyle(fontSize: 20))
                    ])),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.sms),
                      SizedBox(
                        width: 20,
                      ),
                      Text('SMS', style: TextStyle(fontSize: 20))
                    ])),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(children: <Widget>[
                      Icon(Icons.storage),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Storage', style: TextStyle(fontSize: 20))
                    ]))
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.yellow,
              label: Text('Allow All',
                  style: TextStyle(
                    color: Colors.black,
                  )),
              onPressed: () {
                setState(() {
                  _loading = true;
                });
                _askPermissions();
              },
            ),
          );
  }

  _checkPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    permission = await Permission.notification.status;
    if (permission != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    await _initUser();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      if (user.userName.isNotEmpty) {
        return HomeState(
          user,
        );
      }
      return Authentication();
    }));
  }

  _askPermissions() async {
    Map<Permission, PermissionStatus> permissionStatus =
        await [Permission.contacts].request();
    if (permissionStatus[Permission.contacts] != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    permissionStatus = await [Permission.camera].request();
    if (permissionStatus[Permission.camera] != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    permissionStatus = await [Permission.microphone].request();
    if (permissionStatus[Permission.microphone] != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    permissionStatus = await [Permission.notification].request();
    if (permissionStatus[Permission.notification] != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    permissionStatus = await [Permission.storage].request();
    if (permissionStatus[Permission.storage] != PermissionStatus.granted) {
      setState(() {
        _loading = false;
      });
      return;
    }
    _checkPermissions();
  }
}

class BelInstant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: EdgeInsets.all(10),
              child: Text('Bel instant',
                  style:
                      TextStyle(fontFamily: 'BarlowCondensed', fontSize: 50))),
          LoadingBouncingGrid.square(
            backgroundColor: Colors.black,
          )
        ]));
  }
}
