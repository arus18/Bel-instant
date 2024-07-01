import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

setMsgsRead(
  int lastReadMsgTimestamp,
  String conversationID,
  User user,
) async {
  final msgsToUpdate = await (FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs')
      .where('timestamp', isGreaterThan: lastReadMsgTimestamp)
      .get());
  msgsToUpdate.docs.forEach((msgDoc) {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .doc(msgDoc.id)
        .collection('readBy')
        .doc(user.userID)
        .set({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'displayPictureUrl': user.profilePhotUrl,
      'name': user.userName
    });
  });
}

setUserLive(String conversationID, User user) {
  FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('participants')
      .doc(user.userID)
      .set({'status': 'live'}, SetOptions(merge: true));
}

setUnreadCountToZero(String conversationID, User user) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('conversations')
      .doc(conversationID)
      .collection('updates')
      .doc(conversationID)
      .set({'unreadCount': 0}, SetOptions(merge: true));
}

Future<bool> conversationHasData(
  String conversationID,
  User user,
) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs')
      .limit(1)
      .get();
  return (snapshot.docs.isNotEmpty);
}

setlastReadMsgTimestamp(String conversationID, User user) async {
  final lastsnapshot = await FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationID)
      .collection('msgs')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();
  if (lastsnapshot.docs.isNotEmpty) {
    final msgSnapShot = lastsnapshot.docs.last;
    final lastReadMsgTimestamp = msgSnapShot['timestamp'];
    final snapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .where('timestamp', isLessThanOrEqualTo: lastReadMsgTimestamp)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final timestamp = snapshot.docs.last['timestamp'];
      if (timestamp != lastReadMsgTimestamp) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.regionCode)
            .collection('users')
            .doc(user.userID)
            .collection('conversations')
            .doc(conversationID)
            .set({'lastReadMsgTimestamp': timestamp}, SetOptions(merge: true));
      }
    }
  }
}

updateAllNameAppearences(User user, String name) async {
  final ref = FirebaseFirestore.instance;
  final conversations = await (ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('conversations')
      .get());
  conversations.docs.forEach((conversation) async {
    final conversationID = conversation.id;
    final participantSnapshot = await ref
        .collection('conversations')
        .doc(conversationID)
        .collection('participants')
        .doc(user.userID)
        .get();
    if (participantSnapshot.exists) {
      ref
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .doc(user.userID)
          .set({'name': name, 'token': user.token}, SetOptions(merge: true));
    }
  });
  final contacts = await (ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('contacts')
      .get());
  contacts.docs.forEach((contact) async {
    ref
        .collection('users')
        .doc(contact['regionCode'])
        .collection('users')
        .doc(contact.id)
        .collection('contacts')
        .doc(user.userID)
        .set({'contactName': name}, SetOptions(merge: true));
    final contactSnapshot = await (ref
        .collection('users')
        .doc(contact['regionCode'])
        .collection('users')
        .doc(contact.id)
        .collection('contacts')
        .doc(user.userID)
        .get());
    final conversationID =
        contactSnapshot.data().toString().contains('conversationID')
            ? contactSnapshot.get('conversationID')
            : '';
    if (conversationID.toString().isNotEmpty) {
      ref
          .collection('users')
          .doc(contact['regionCode'])
          .collection('users')
          .doc(contact.id)
          .collection('conversations')
          .doc(contactSnapshot['conversationID'])
          .set({
        'conversationWith': name,
      }, SetOptions(merge: true));
    }
  });
}

updateAllDisplayPictureAppearences(User user, String displayPictureUrl) async {
  final ref = FirebaseFirestore.instance;
  final conversations = await (ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('conversations')
      .get());
  conversations.docs.forEach((conversation) async {
    final conversationID = conversation.id;
    final participantSnapshot = await ref
        .collection('conversations')
        .doc(conversationID)
        .collection('participants')
        .doc(user.userID)
        .get();
    if (participantSnapshot.exists) {
      ref
          .collection('conversations')
          .doc(conversationID)
          .collection('participants')
          .doc(user.userID)
          .set({'displayPictureUrl': displayPictureUrl},
              SetOptions(merge: true));
    }
  });
  final contacts = await (ref
      .collection('users')
      .doc(user.regionCode)
      .collection('users')
      .doc(user.userID)
      .collection('contacts')
      .get());
  contacts.docs.forEach((contact) async {
    ref
        .collection('users')
        .doc(contact['regionCode'])
        .collection('users')
        .doc(contact.id)
        .collection('contacts')
        .doc(user.userID)
        .set({'displayPictureUrl': displayPictureUrl}, SetOptions(merge: true));
    final contactSnapshot = await (ref
        .collection('users')
        .doc(contact['regionCode'])
        .collection('users')
        .doc(contact.id)
        .collection('contacts')
        .doc(user.userID)
        .get());
    final conversationID =
        contactSnapshot.data().toString().contains('conversationID')
            ? contactSnapshot.get('conversationID')
            : '';
    if (conversationID.toString().isNotEmpty) {
      ref
          .collection('users')
          .doc(contact['regionCode'])
          .collection('users')
          .doc(contact.id)
          .collection('conversations')
          .doc(contactSnapshot['conversationID'])
          .set({
        'displayPictureUrl': displayPictureUrl,
      }, SetOptions(merge: true));
    }
  });
}
