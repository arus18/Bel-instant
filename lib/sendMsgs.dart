import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:interactive_message/contacts.dart';
import 'package:interactive_message/conversation.dart';
import 'package:interactive_message/user.dart';
import 'package:dart_date/dart_date.dart';

forwardText(
  Map<String, dynamic> map,
  User user,
) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  DocumentSnapshot msgSnapshot = map['msgSnapshot'];
  List<String> conversationID = map['conversationID'];
  String userID = user.userID;
  conversationID.forEach((conversationID) async {
    final msgs = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs');
    final msgID = msgs.doc().id;
    await (msgs.doc(msgID).set({
      'msgType': 'text',
      'msg': msgSnapshot.data()['msg'],
      'userID': userID,
      'timestamp': timestamp,
      'name': user.userName
    }, SetOptions(merge: true)));
    setUnreadCount(
      conversationID,
      msgID,
      userID,
      timestamp,
      user,
    );
  });
}

forwardImage(
  Map<String, dynamic> map,
  User user,
) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  DocumentSnapshot msgSnapshot = map['msgSnapshot'];
  List<String> conversationID = map['conversationID'];
  String userID = user.userID;
  conversationID.forEach((conversationID) async {
    final urls = msgSnapshot.data()['urls'];
    final msgs = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs');
    final msgID = msgs.doc().id;
    if (urls != null) {
      await (msgs.doc(msgID).set({
        'msgType': 'image',
        'urls': urls,
        'userID': userID,
        'timestamp': timestamp,
        'name': user.userName,
        'fileSize': msgSnapshot.data()['fileSize']
      }, SetOptions(merge: true)));
      setUnreadCount(
        conversationID,
        msgID,
        userID,
        timestamp,
        user,
      );
    } else {
      await (msgs.doc(msgID).set({
        'msgType': 'image',
        'url': msgSnapshot.data()['url'],
        'fileName': msgSnapshot.data()['fileName'],
        'userID': userID,
        'timestamp': timestamp,
        'name': user.userName,
        'fileSize': msgSnapshot.data()['fileSize']
      }, SetOptions(merge: true)));
      setUnreadCount(
        conversationID,
        msgID,
        userID,
        timestamp,
        user,
      );
    }
  });
}

forwardAudio(
  Map<String, dynamic> map,
  User user,
) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  DocumentSnapshot msgSnapshot = map['msgSnapshot'];
  List<String> conversationID = map['conversationID'];
  String userID = user.userID;
  conversationID.forEach((conversationID) async {
    final msgs = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs');
    final msgID = msgs.doc().id;
    await (msgs.doc(msgID).set({
      'msgType': 'audio',
      'url': msgSnapshot.data()['url'],
      'fileName': msgSnapshot.data()['fileName'],
      'userID': userID,
      'timestamp': timestamp,
      'name': user.userName,
      'fileSize': msgSnapshot.data()['fileSize'],
      'duration': msgSnapshot.data()['duration']
    }, SetOptions(merge: true)));
    setUnreadCount(
      conversationID,
      msgID,
      userID,
      timestamp,
      user,
    );
  });
}

sendText(
  Map<String, dynamic> map,
  User user,
) async {
  bool reply = map['reply'];
  final conversationID = map['conversationID'];
  String msgIDreplied = map['msgIDreplied'];
  String msg = map['msg'];
  String userID = user.userID;
  final ref = FirebaseFirestore.instance;
  final msgs =
      ref.collection('conversations').doc(conversationID).collection('msgs');
  final msgID = msgs.doc().id;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  if (reply) {
    await (msgs.doc(msgID).set({
      'msgIDreplied': msgIDreplied,
      'typeOfReplyMsg': 'text',
      'msgType': 'reply',
      'msg': msg,
      'userID': userID,
      'timestamp': timestamp,
      'name': user.userName
    }, SetOptions(merge: true)));
  } else {
    await (msgs.doc(msgID).set({
      'msgType': 'text',
      'msg': msg,
      'userID': userID,
      'timestamp': timestamp,
      'name': user.userName
    }, SetOptions(merge: true)));
  }
  setUnreadCount(
    conversationID,
    msgID,
    userID,
    timestamp,
    user,
  );
}

sendImage(
  Map<String, dynamic> detailsMap,
  ValueNotifier<bool> newUploadAdded,
  User user,
) async {
  final conversationID = detailsMap['conversationID'];
  Map<String, String> files = detailsMap['files'];
  ConversationState conversationState = detailsMap['conversationState'];
  String userID = user.userID;
  Map<String, dynamic> fileSizeMap = Map<String, dynamic>();
  final map = Map<dynamic, String>();
  final msgs = FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs');
  final ref = FirebaseStorage.instance.ref();
  final Map<StorageUploadTask, String> tasks = Map<StorageUploadTask, String>();
  for (final name in files.keys) {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + name;
    fileName = fileName.replaceAll('/', '');
    final path = conversationID + '/' + fileName;
    final task = ref.child(path).putFile(File(files[name]));
    tasks[task] = fileName;
    conversationState.uploadProgress.add(task);
    newUploadAdded.value = true;
    task.onComplete.whenComplete(() {
      conversationState.uploadProgress.remove(task);
      newUploadAdded.value = false;
    });
    fileSizeMap[fileName] = await File(files[name]).length();
  }
  await Future.forEach(tasks.keys, (StorageUploadTask task) async {
    if (task.isCanceled) {
      return;
    } else {
      try {
        final taskSnapshot = await task.onComplete;
        final mediaUrl = await taskSnapshot.ref.getDownloadURL();
        map[mediaUrl] = tasks[task];
      } catch (e) {}
    }
  });
  if (map.length == files.length) {
    //if upload canceled
    if (map.length >= 4) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final msgID = msgs.doc().id;
      await (msgs.doc(msgID).set({
        'msgType': 'image',
        'urls': map,
        'userID': userID,
        'timestamp': timestamp,
        'fileSize': fileSizeMap,
        'name': user.userName
      }, SetOptions(merge: true)));
      setUnreadCount(
        conversationID,
        msgID,
        userID,
        timestamp,
        user,
      );
    } else {
      for (final url in map.keys) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = map[url];
        final msgID = msgs.doc().id;
        await (msgs.doc(msgID).set({
          'msgType': 'image',
          'url': url,
          'fileName': fileName,
          'userID': userID,
          'timestamp': timestamp,
          'fileSize': fileSizeMap[fileName],
          'name': user.userName
        }, SetOptions(merge: true)));
        setUnreadCount(
          conversationID,
          msgID,
          userID,
          timestamp,
          user,
        );
      }
    }
  }
}

sendAudio(
  Map<String, dynamic> map,
  ValueNotifier<bool> newUploadAdded,
  User user,
  int duration,
) async {
  final conversationID = map['conversationID'];
  Map<String, String> files = map['files'];
  ConversationState conversationState = map['conversationState'];
  String userID = user.userID;
  final fileSizeMap = Map<String, dynamic>();
  final msgs = FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs');
  final ref = FirebaseStorage.instance.ref();
  files.keys.forEach((name) async {
    String fileName = name;
    fileName = fileName.replaceAll('/', '');
    final path = conversationID + '/' + fileName;
    final task = ref.child(path).putFile(File(files[name]));
    conversationState.uploadProgress.add(task);
    newUploadAdded.value = true;
    task.onComplete.whenComplete(() {
      conversationState.uploadProgress.remove(task);
      newUploadAdded.value = false;
    });
    fileSizeMap[fileName] = await File(files[name]).length();
    if (task.isCanceled) {
      return;
    } else {
      try {
        final taskSnapshot = await task.onComplete;
        final mediaUrl = await taskSnapshot.ref.getDownloadURL();
        final msgID = msgs.doc().id;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await (msgs.doc(msgID).set({
          'msgType': 'audio',
          'url': mediaUrl,
          'fileName': fileName,
          'userID': userID,
          'timestamp': timestamp,
          'fileSize': fileSizeMap[fileName],
          'name': user.userName,
          'duration': duration
        }, SetOptions(merge: true)));
        setUnreadCount(
          conversationID,
          msgID,
          userID,
          timestamp,
          user,
        );
      } catch (e) {}
    }
  });
}

setUnreadCount(String conversationID, String msgID, String userID,
    int dateUpdate, User user,
    {bool isUpdateInfo: false}) async {
  final ref = FirebaseFirestore.instance;
  final conversationSnapshot =
      await ref.collection('conversations').doc(conversationID).get();
  final timestamp = conversationSnapshot.data()['timestamp'];
  _updateTimeInfo(
    timestamp,
    conversationID,
    userID,
    user,
  );
  final participants = await ref
      .collection('conversations')
      .doc(conversationID)
      .collection('participants')
      .get();
  for (final participant in participants.docs) {
    final String status = participant.data()['status'];
    final regionCode = participant.data()['regionCode'] ?? user.userID;
    ref
        .collection('users')
        .doc(regionCode)
        .collection('users')
        .doc(participant.id)
        .collection('conversations')
        .doc(conversationID)
        .collection('updates')
        .doc(conversationID)
        .set({
      'timestamp': dateUpdate,
    }, SetOptions(merge: true));
    _setTimestampDelay(participant.id, regionCode, conversationID, dateUpdate);
    if ((status == 'online' || status == 'offline') &&
        userID != participant.id) {
      ref
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(participant.id)
          .collection('conversations')
          .doc(conversationID)
          .collection('updates')
          .doc(conversationID)
          .set({'unreadCount': FieldValue.increment(1)},
              SetOptions(merge: true));
    } else {
      if (!isUpdateInfo) {
        ref
            .collection('conversations')
            .doc(conversationID)
            .collection('msgs')
            .doc(msgID)
            .collection('readBy')
            .doc(participant.id)
            .set({
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'displayPictureUrl': participant.data()['displayPictureUrl'],
          'name': participant.data()['name']
        });
      }
      _setLastReadMsgTimestamp(
          conversationID, dateUpdate, regionCode, participant.id);
    }
  }
}

_setTimestampDelay(String userID, String regionCode, String conversationID,
    int timestamp) async {
  final delayedTimestamp = (await FirebaseFirestore.instance
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(userID)
          .collection('conversations')
          .doc(conversationID)
          .get())
      .data()['timeDelayTimestamp'];
  if ((timestamp - delayedTimestamp) > 120000) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(regionCode)
        .collection('users')
        .doc(userID)
        .collection('conversations')
        .doc(conversationID)
        .set({
      'timeDelayTimestamp': timestamp,
    }, SetOptions(merge: true));
  }
}

_setLastReadMsgTimestamp(String conversationID, int lastReadMsgTimestamp,
    String regionCode, String userID) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs')
      .where('timestamp', isLessThanOrEqualTo: lastReadMsgTimestamp)
      .orderBy('timestamp', descending: true)
      .limit(10)
      .get();
  if (snapshot.docs.isNotEmpty) {
    final timestamp = snapshot.docs.last.data()['timestamp'];

    if (timestamp != lastReadMsgTimestamp) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(regionCode)
          .collection('users')
          .doc(userID)
          .collection('conversations')
          .doc(conversationID)
          .set({
        'lastReadMsgTimestamp': timestamp,
      }, SetOptions(merge: true));
    }
  }
}

_updateTimeInfo(
  int timestamp,
  String conversationID,
  String userID,
  User user,
) async {
  DateTime lastUpdatedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  DateTime now = DateTime.now();
  bool isSameDay = now.isSameDay(lastUpdatedTime);
  final String month = numberToMonth(now.month);
  final msgID = FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs')
      .doc()
      .id;
  if (!isSameDay) {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .doc(msgID)
        .set({
      'msgType': 'dateInfo',
      'info': month + ' ${now.day}',
      'timestamp': DateTime.now().startOfDay.millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .set({'timestamp': DateTime.now().millisecondsSinceEpoch},
            SetOptions(merge: true));
    setUnreadCount(
      conversationID,
      msgID,
      userID,
      DateTime.now().millisecondsSinceEpoch,
      user,
    );
  }
}
