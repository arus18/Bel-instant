import 'dart:async';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'audioPlayer.dart';
import 'compose_message.dart';
import 'conversation.dart';
import 'sendMsgs.dart';
import 'user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:path/path.dart';

class TextInput extends StatefulWidget {
  final ValueNotifier<bool> newUploadAdded;
  final ValueNotifier<bool> isEmojiKeyBoardVisible;
  final ItemScrollController scrollController;
  final ConversationState conversationState;
  final String msgIDreplied;
  final String conversationID;
  final BuildContext context;
  final bool reply;
  final User user;
  final bool isGroupChat;
  const TextInput(
    this.user,
    this.conversationState, {
    Key? key,
    required this.context,
    required this.conversationID,
    this.reply = false,
    required this.msgIDreplied,
    required this.isGroupChat,
    required this.scrollController,
    required this.isEmojiKeyBoardVisible,
    required this.newUploadAdded,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TextInputState(context, conversationID, reply, msgIDreplied, user,
        conversationState, isGroupChat);
  }
}

class TextInputState extends State<TextInput> {
  late String _fileName;
  final ConversationState conversationState;
  final User user;
  final String msgIDreplied;
  final bool reply;
  final String conversationID;
  final BuildContext contxt;
  final msgController = TextEditingController();
  final bool isGroupChat;
  late FlutterAudioRecorder2 _recorder;
  late Recording _result;
  bool _isRecorderinitialized = false;
  bool _isRecordingStarted = false;
  bool _isRecordingComplete = false;
  Color _recordBtnColor = Colors.yellow;
  int _seconds = 1;
  final _focusNode = FocusNode();
  late KeyboardVisibilityController _keyboardVisibilityController;

  TextInputState(
    this.contxt,
    this.conversationID,
    this.reply,
    this.msgIDreplied,
    this.user,
    this.conversationState,
    this.isGroupChat,
  );
  @override
  void initState() {
    super.initState();
    _init();
    _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardVisibilityController.onChange.listen((bool visible) {
      final scrollCount = conversationState.scrollCount;
      final controller = widget.scrollController;
      try {
        controller.jumpTo(index: scrollCount);
      } catch (e) {}
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .doc(user.userID)
          .update(
              {'status': (visible && _focusNode.hasFocus) ? 'typing' : 'live'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ((_isRecordingComplete
        ? Row(
            children: <Widget>[
              Expanded(
                  child: AudioPlayerForPreview(
                _result.duration!.inMilliseconds,
                url: _result.path.toString(),
              )),
              Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: FloatingActionButton.extended(
                    heroTag: 'cancel',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      setState(() {
                        _isRecordingComplete = false;
                        _seconds = 0;
                      });
                    },
                    label: Icon(Icons.cancel),
                  )),
              Container(
                  margin: EdgeInsets.only(right: 5),
                  child: FloatingActionButton.extended(
                    heroTag: 'send',
                    backgroundColor: Colors.blue,
                    label: Icon(Icons.send),
                    onPressed: () {
                      Map<String, dynamic> map = {
                        'conversationID': conversationID,
                        'files': {_fileName + '.wav': _result.path},
                        'conversationState': conversationState,
                      };
                      sendAudio(
                        map,
                        widget.newUploadAdded,
                        user,
                        _result.duration!.inMilliseconds,
                      );
                      setState(() {
                        _isRecordingComplete = false;
                        _seconds = 0;
                      });
                    },
                  ))
            ],
          )
        : Row(children: <Widget>[
            IconButton(
              onPressed: () async {
                if (!_isRecordingStarted) {
                  Map<String, String> files = Map<String, String>();
                  FilePickerResult result;
                  try {
                    result = (await FilePicker.platform
                        .pickFiles(type: FileType.image, allowMultiple: true))!;
                    result.files.forEach((file) {
                      files[file.name] = file.path!;
                    });
                  } catch (e) {}

                  if (files != null) {
                    Map<String, dynamic> map = {
                      'conversationID': conversationID,
                      'files': files,
                      'conversationState': conversationState,
                    };
                    sendImage(
                      map,
                      widget.newUploadAdded,
                      user,
                    );
                  }
                }
              },
              icon: Icon(Icons.image),
            ),
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () async {
                Map<String, String> files = Map<String, String>();
                final picker = ImagePicker();
                PickedFile result;
                try {
                  result = (await picker.pickImage(source: ImageSource.camera))!
                      as PickedFile;
                  final fileName = basename(result.path.toString());
                  files[fileName] = result.path;
                  if (files != null) {
                    Map<String, dynamic> map = {
                      'conversationID': conversationID,
                      'files': files,
                      'conversationState': conversationState,
                    };
                    sendImage(
                      map,
                      widget.newUploadAdded,
                      user,
                    );
                  }
                } catch (e) {}
              },
            ),
            IconButton(
              onPressed: () {
                if (!_isRecordingStarted) {
                  String msg = msgController.text;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ComposeMessage(
                      message: msg,
                      conversationID: conversationID,
                      user: user,
                      key: Key(""),
                    );
                  }));
                  msgController.clear();
                }
              },
              icon: Icon(Icons.color_lens),
            ),
            Expanded(
                child: Container(
              child: _isRecordingStarted
                  ? Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '$_seconds milliseconds',
                        style: TextStyle(fontSize: 10),
                      ),
                    )
                  : (TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      focusNode: _focusNode,
                      controller: msgController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            onPressed: () {
                              Map<String, dynamic> map = {
                                'reply': reply,
                                'conversationID': conversationID,
                                'msgIDreplied': msgIDreplied,
                                'msg': msgController.text,
                              };
                              final scrollCount = conversationState.scrollCount;
                              try {
                                widget.scrollController
                                    .jumpTo(index: scrollCount);
                              } catch (e) {}
                              sendText(
                                map,
                                user,
                              );
                              msgController.clear();
                            },
                            icon: Icon(Icons.send),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ))),
                    )),
            )),
            reply
                ? Container()
                : GestureDetector(
                    onTap: () async {
                      if (!_isRecordingStarted) {
                        if (_isRecorderinitialized) {
                          try {
                            await _recorder.start();
                          } catch (e) {
                            FirebaseFirestore.instance
                                .collection('conversations')
                                .doc(conversationID)
                                .collection('participants')
                                .doc(user.userID)
                                .update({'status': 'live'});
                          }
                          FirebaseFirestore.instance
                              .collection('conversations')
                              .doc(conversationID)
                              .collection('participants')
                              .doc(user.userID)
                              .update({'status': 'recording audio'});

                          setState(() {
                            _isRecordingStarted = true;
                            _recordBtnColor = Colors.red;
                            _timer();
                          });
                        }
                      } else {
                        FirebaseFirestore.instance
                            .collection('conversations')
                            .doc(conversationID)
                            .collection('participants')
                            .doc(user.userID)
                            .update({'status': 'live'});
                        _result = (await _recorder.stop())!;
                        setState(() {
                          _isRecordingStarted = false;
                          _recordBtnColor = Colors.yellow;
                          _isRecordingComplete = true;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _recordBtnColor),
                      child: Center(
                        child: Icon(Icons.mic),
                      ),
                    ),
                  )
          ])));
  }

  _init() async {
    try {
      String customPath = '/Belinstant';
      io.Directory appDocDirectory;

      appDocDirectory = (await getExternalStorageDirectory())!;
      _fileName = DateTime.now().millisecondsSinceEpoch.toString();
      customPath = appDocDirectory.path + customPath + _fileName;

      _recorder =
          FlutterAudioRecorder2(customPath, audioFormat: AudioFormat.WAV);

      await _recorder.initialized;
      setState(() {
        _isRecorderinitialized = true;
      });
    } catch (e) {}
  }

  _timer() {
    const tick = const Duration(milliseconds: 50);
    Timer.periodic(tick, (Timer t) async {
      if (_isRecordingComplete) {
        t.cancel();
      } else if (mounted) {
        setState(() {
          _seconds += 50;
        });
        if (_seconds > 300000) {
          _result = (await _recorder.stop())!;
          setState(() {
            _isRecordingStarted = false;
            _recordBtnColor = Colors.yellow;
            _isRecordingComplete = true;
          });
        }
      }
    });
  }
}
