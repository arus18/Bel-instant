import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'updateFunctions.dart';
import 'user.dart';
import 'package:loading_animations/loading_animations.dart';

class ProfileView extends StatefulWidget {
  final User user;
  const ProfileView({Key? key, required this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ProfileViewState(user);
  }
}

class ProfileViewState extends State<ProfileView> {
  final User user;
  late String _imagePath = "";
  bool _uploading = false;
  bool _editName = false;
  bool _editNameInProgress = false;
  FocusNode _focusNode = FocusNode();
  final _controller = TextEditingController();
  ProfileViewState(this.user);
  bool _keyBoardVisible() {
    final b = MediaQuery.of(context).viewInsets.bottom;
    return b != 0;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      body: SizedBox(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Center(
                  child: _keyBoardVisible()
                      ? Container()
                      : SizedBox(
                          height: height / 2,
                          child: (_imagePath.isNotEmpty)
                              ? user.profilePhotUrl.isEmpty
                                  ? Container()
                                  : CachedNetworkImage(
                                      imageUrl: user.profilePhotUrl)
                              : Image(image: FileImage(File(_imagePath))))),
              _uploading
                  ? LoadingBumpingLine.circle(
                      backgroundColor: Colors.yellow,
                    )
                  : Row(children: <Widget>[
                      IconButton(
                        onPressed: () async {
                          FilePickerResult result;
                          try {
                            result = (await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            ))!;
                            _imagePath = result.files.single.path!;
                          } catch (e) {}

                          setState(() {
                            _uploading = true;
                          });
                          final ref = FirebaseStorage.instance.ref();
                          final fileName =
                              DateTime.now().millisecondsSinceEpoch.toString() +
                                  'profilePic';
                          final path = user.userID + '/profilePic/' + fileName;
                          final task =
                              await (ref.child(path).putFile(File(_imagePath)));
                          final mediaUrl = await task.ref.getDownloadURL();
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.regionCode)
                              .collection('users')
                              .doc('${user.userID}')
                              .set({'displayPictureUrl': mediaUrl},
                                  SetOptions(merge: true));
                          user.profilePhotUrl = mediaUrl;
                          updateAllDisplayPictureAppearences(user, mediaUrl);
                          setState(() {
                            _uploading = false;
                          });
                        },
                        icon: Icon(Icons.photo),
                      ),
                      IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          PickedFile result;
                          try {
                            result = (await picker.pickImage(
                                source: ImageSource.camera))! as PickedFile;
                            _imagePath = result.path;
                          } catch (e) {}
                          setState(() {
                            _uploading = true;
                          });
                          final ref = FirebaseStorage.instance.ref();
                          final fileName =
                              DateTime.now().millisecondsSinceEpoch.toString() +
                                  'profilePic';
                          final path = user.userID + '/profilePic/' + fileName;
                          final task =
                              await (ref.child(path).putFile(File(_imagePath)));
                          final mediaUrl = await task.ref.getDownloadURL();
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.regionCode)
                              .collection('users')
                              .doc('${user.userID}')
                              .set({'displayPictureUrl': mediaUrl},
                                  SetOptions(merge: true));
                          user.profilePhotUrl = mediaUrl;
                          updateAllDisplayPictureAppearences(user, mediaUrl);
                          setState(() {
                            _uploading = false;
                          });
                        },
                        icon: Icon(Icons.camera),
                      )
                    ])
            ],
          ),
          SizedBox(
            height: 5,
          ),
          _editNameInProgress
              ? LoadingBumpingLine.circle(
                  backgroundColor: Colors.yellow,
                )
              : _editName
                  ? TextField(
                      onChanged: (str) {
                        if (str.length > 15) {
                          _controller.text = '';
                        }
                      },
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                          hintText: 'only 15 characters allowed',
                          labelText: 'Enter your name here',
                          suffix: IconButton(
                            onPressed: () async {
                              if (_controller.text.isNotEmpty) {
                                setState(() {
                                  _editName = false;
                                  _editNameInProgress = true;
                                });
                                if (_controller.text.isNotEmpty) {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.regionCode)
                                      .collection('users')
                                      .doc('${user.userID}')
                                      .set({'name': _controller.text},
                                          SetOptions(merge: true));
                                }
                                setState(() {
                                  _editNameInProgress = false;
                                });
                                user.userName = _controller.text;
                                updateAllNameAppearences(
                                    user, _controller.text);
                              }
                            },
                            icon: Icon(Icons.check),
                          )),
                    )
                  : Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            user.userName,
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
          SizedBox(
            height: 10,
          ),
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(user.phoneNumber, style: TextStyle(fontSize: 30)))
        ],
      )),
    );
  }
}
