import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:interactive_message/contacts.dart';
import 'package:interactive_message/conversation.dart';
import 'package:interactive_message/downloadTask.dart';
import 'package:interactive_message/user.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class ProfileImageView extends StatefulWidget {
  final String mediaUrl;
  final String name;
  final String phoneNumber;
  const ProfileImageView(
    this.mediaUrl,
    this.name,
    this.phoneNumber, {
    Key key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ProfileImageViewState(mediaUrl, name, phoneNumber);
  }
}

class ProfileImageViewState extends State<ProfileImageView> {
  final String mediaUrl;
  final String name;
  final String phoneNumber;
  ProfileImageViewState(
    this.mediaUrl,
    this.name,
    this.phoneNumber,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar:
            Container(height: 50, child: Center(child: Text('Ad'))),
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(name),
              phoneNumber.isEmpty ? Container() : Text(phoneNumber)
            ],
          ),
        ),
        body: Center(child: PhotoView(imageProvider: NetworkImage(mediaUrl))));
  }
}

class ImageView extends StatefulWidget {
  final String fileName;
  final String mediaUrl;
  final int fileSize;
  final User user;
  final String msgID;
  final String conversationID;
  final String userIDwhoCreatedMsg;
  final int timestamp;
  final int twentiethMsgTimestamp;
  final bool forwardSingleImagefile;
  const ImageView(
    this.fileName,
    this.mediaUrl,
    this.user, {
    Key key,
    this.fileSize,
    this.conversationID,
    this.msgID,
    this.userIDwhoCreatedMsg,
    this.timestamp,
    this.twentiethMsgTimestamp,
    this.forwardSingleImagefile: false,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ImageViewState(fileName, mediaUrl);
  }
}

class ImageViewState extends State<ImageView> {
  Task _task;
  ReceivePort _port = ReceivePort();
  final String fileName;
  final String mediaUrl;
  String _path;
  bool _fileExists;
  bool _initialized = false;
  ImageViewState(this.fileName, this.mediaUrl);
  @override
  void initState() {
    super.initState();
    _init();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_task != null) {
        setState(() {
          if (status == DownloadTaskStatus.complete) {
            _fileExists = true;
          }
          _task.status = status;
          _task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  _init() async {
    try {
      final dir = await getExternalStorageDirectory();
      _path = '${dir.path}/Belinstant/' + fileName;
      _fileExists = await File(_path).exists();
      _initialized = true;
      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? Scaffold(
            bottomNavigationBar:
                Container(height: 50, child: Center(child: Text('Ad'))),
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.forward),
                  onPressed: () {
                    final forwardsnap = ForwardSnap(
                        widget.msgID,
                        widget.conversationID,
                        'image',
                        widget.userIDwhoCreatedMsg,
                        widget.timestamp,
                        widget.twentiethMsgTimestamp);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return widget.forwardSingleImagefile
                          ? Contacts(
                              user: widget.user,
                              newBroadCast: true,
                              forwardMsgList: [forwardsnap],
                              forward: true,
                              forwardSingleImage: true,
                              fileName: fileName,
                              fileUrl: mediaUrl,
                              fileSize: widget.fileSize,
                            )
                          : Contacts(
                              user: widget.user,
                              newBroadCast: true,
                              forwardMsgList: [forwardsnap],
                              forward: true,
                            );
                    }));
                  },
                ),
                _fileExists
                    ? Container()
                    : FloatingActionButton.extended(
                        backgroundColor: Colors.red,
                        label: Text('Download'),
                        onPressed: () {
                          _download();
                        },
                      ),
              ],
            ),
            body: Center(
              child: Stack(alignment: Alignment.bottomLeft, children: <Widget>[
                PhotoView(
                    imageProvider: _fileExists
                        ? FileImage(File(_path))
                        : NetworkImage(mediaUrl)),
                (_task != null && _task.status == DownloadTaskStatus.running)
                    ? Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              FlutterDownloader.cancel(taskId: _task.taskID);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.yellow,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          LoadingBumpingLine.circle(
                            backgroundColor: Colors.yellow,
                          )
                        ],
                      )
                    : Text('${widget.fileSize / 1000} kb',
                        style: TextStyle(color: Colors.yellow, fontSize: 20)),
              ]),
            ))
        : Center(
            child: LoadingBumpingLine.circle(
            backgroundColor: Colors.yellow,
          ));
  }

  _download() async {
    try {
      final dir = await getExternalStorageDirectory();
      var knockDir =
          await Directory('${dir.path}/Belinstant').create(recursive: true);
      final _fileName = fileName.replaceAll('/', '');
      final taskID = await FlutterDownloader.enqueue(
        showNotification: false,
        fileName: _fileName,
        url: mediaUrl,
        savedDir: knockDir.path,
      );
      setState(() {
        final task = Task();
        task.taskID = taskID;
        _task = task;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
}

class MultipleImageView extends StatefulWidget {
  final Map<String, dynamic> mediaList;
  final Map<String, dynamic> fileSizeMap;
  final User user;
  const MultipleImageView(this.user,
      {Key key, this.mediaList, this.fileSizeMap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MultipleImageViewState();
  }
}

class MultipleImageViewState extends State<MultipleImageView> {
  bool _initialized = false;
  Map<String, String> _imgPathList = Map<String, String>();
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      body: _initialized
          ? Swiper(
              itemCount: widget.mediaList.length,
              itemBuilder: (BuildContext context, int index) {
                final imgUrl = widget.mediaList.keys.elementAt(index);
                final fileName = widget.mediaList[imgUrl];
                final fileSize = widget.fileSizeMap[fileName];
                final exists = (_imgPathList[imgUrl] != null);
                if (exists) {
                  final path = _imgPathList[imgUrl];
                  return (Image.file(File(path)));
                } else {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ImageView(
                            fileName,
                            imgUrl,
                            widget.user,
                            fileSize: fileSize,
                            forwardSingleImagefile: true,
                          );
                        }));
                      },
                      child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: LoadingBumpingLine.circle(
                                    backgroundColor: Colors.yellow,
                                  )),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error)));
                }
              },
            )
          : Center(
              child: LoadingBumpingLine.circle(
              backgroundColor: Colors.yellow,
            )),
    );
  }

  _initialize() async {
    try {
      for (final key in widget.mediaList.keys) {
        final fileName = widget.mediaList[key];
        final dir = await getExternalStorageDirectory();
        final path = '${dir.path}/Belinstant/' + fileName;
        final fileExists = await File(path).exists();
        if (fileExists) {
          _imgPathList[key] = path;
        }
      }
      setState(() {
        _initialized = true;
      });
    } catch (e) {}
  }
}
