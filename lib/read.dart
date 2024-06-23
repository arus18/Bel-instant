import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Read extends StatelessWidget {
  final String userIDwhoCreatedThisMsg;
  final String conversationID;

  final String msgID;
  final String userID;
  const Read(
      {Key? key,
      required this.userIDwhoCreatedThisMsg,
      required this.conversationID,
      required this.msgID,
      required this.userID})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    CollectionReference _readBy = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .doc(msgID)
        .collection('readBy');
    return StreamBuilder<QuerySnapshot>(
      stream: _readBy.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final readBy = snapshot.data!.docs;
          final read = readBy.any((readBy) {
            return (readBy.id != userIDwhoCreatedThisMsg);
          });
          if (read && userID == userIDwhoCreatedThisMsg) {
            return Icon(
              Icons.check_circle,
              color: Colors.yellow,
              size: 10,
            );
          }
        }
        return Container();
      },
    );
  }
}
