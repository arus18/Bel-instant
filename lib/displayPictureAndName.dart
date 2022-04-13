import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interactive_message/contacts.dart';
import 'package:interactive_message/home.dart';
import 'package:interactive_message/updateFunctions.dart';
import 'package:interactive_message/user.dart';
import 'package:loading_animations/loading_animations.dart';

class InitializeDisplayPictureName extends StatefulWidget {
  final User user;
  final bool forNewGroup;
  const InitializeDisplayPictureName(
      {Key key, this.forNewGroup: false, this.user})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return InitializeDisplayPictureNameState(forNewGroup, user);
  }
}

class InitializeDisplayPictureNameState
    extends State<InitializeDisplayPictureName> {
  bool _uploading = false;
  final User user;
  final bool forNewGroup;
  String _imagePath = '';
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  InitializeDisplayPictureNameState(this.forNewGroup, this.user);
  bool _keyBoardVisible() {
    final b = MediaQuery.of(context).viewInsets.bottom;
    return b != 0;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: Container(height: 50,child: Center(child: Text('Ad'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Center(
                  child: _keyBoardVisible()
                      ? Container()
                      : SizedBox(
                          height: height / 2,
                          child: (_imagePath.isEmpty)
                              ? Container()
                              : Image(image: FileImage(File(_imagePath))))),
              Row(children: <Widget>[
                IconButton(
                  onPressed: () async {
                    try {
                      FilePickerResult result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null) {
                        _imagePath = result.files.single.path;
                      }
                    } catch (e) {}
                    setState(() {});
                  },
                  icon: Icon(Icons.photo),
                ),
                IconButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    try {
                      final result =
                          await picker.getImage(source: ImageSource.camera);
                      if (result != null) {
                        _imagePath = result.path;
                      }
                    } catch (e) {}
                    setState(() {});
                  },
                  icon: Icon(Icons.camera),
                )
              ])
            ],
          ),
          TextField(
            decoration: InputDecoration(
                hintText: forNewGroup
                    ? 'only 30 characters allowed'
                    : 'only 15 characters allowed',
                labelText: forNewGroup
                    ? 'Enter your group name here'
                    : 'Enter your name here'),
            focusNode: _focusNode,
            onChanged: (str) {
              setState(() {
                if (str.length > 15 && !forNewGroup) {
                  _controller.text = '';
                } else if (str.length > 30) {
                  _controller.text = '';
                }
              });
            },
            controller: _controller,
          )
        ],
      ),
      floatingActionButton: _uploading
          ? LoadingDoubleFlipping.circle(
              backgroundColor: Colors.yellow,
            )
          : (_controller.text.isNotEmpty)
              ? FloatingActionButton(
                  child: Icon(Icons.arrow_right),
                  backgroundColor: Colors.yellow,
                  onPressed: () async {
                    if (forNewGroup) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Contacts(
                                    user: user,
                                    newGroupInvite: true,
                                    groupDisplayPicture: _imagePath,
                                    groupName: _controller.text,
                                  )));
                    } else {
                      _focusNode.unfocus();
                      setState(() {
                        _uploading = true;
                      });
                      String mediaUrl = '';
                      if (_imagePath.isNotEmpty) {
                        final ref = FirebaseStorage.instance.ref();
                        final fileName =
                            DateTime.now().millisecondsSinceEpoch.toString() +
                                'profilePic';
                        final path = user.userID + '/profilePic/' + fileName;
                        final task =
                            await (ref.child(path).putFile(File(_imagePath)))
                                .onComplete;
                        mediaUrl = await task.ref.getDownloadURL();
                      }
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.regionCode)
                          .collection('users')
                          .doc('${user.userID}')
                          .set({'displayPictureUrl': mediaUrl},
                              SetOptions(merge:true));
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.regionCode)
                          .collection('users')
                          .doc('${user.userID}')
                          .set({'name': _controller.text}, SetOptions(merge:true));
                      user.userName = _controller.text;
                      user.profilePhotUrl = mediaUrl;
                      updateAllNameAppearences(user, _controller.text);
                      updateAllDisplayPictureAppearences(user, mediaUrl);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return Home(
                          user: user,
                        );
                      }));
                    }
                  },
                )
              : Container(),
    );
  }
}
