import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:interactive_message/contacts.dart';
import 'package:interactive_message/user.dart';

class ReadBy extends StatelessWidget {
  
  final String conversationID;
  final String msgID;
  final User user;
  const ReadBy({Key key, this.conversationID, this.msgID, this.user})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final CollectionReference _readBy = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationID)
        .collection('msgs')
        .doc(msgID)
        .collection('readBy');
    return Scaffold(
      bottomNavigationBar: Container(height: 50,child: Center(child: Text('Ad'))),
      body: StreamBuilder(
        stream: _readBy.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, index) {
                final readBySnapshot = snapshot.data.docs[index];
                if (readBySnapshot.id != user.userID) {
                  final String displayPictureUrl =
                      readBySnapshot.data()['displayPictureUrl'] ?? '';
                  final name = readBySnapshot.data()['name'];
                  final time = readBySnapshot.data()['timestamp'];
                  final DateTime timeRead =
                      DateTime.fromMillisecondsSinceEpoch(time);
                  String mins = '${timeRead.minute}'.length < 2
                      ? '0${timeRead.minute}'
                      : '${timeRead.minute}';
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('${timeRead.year} ' +
                        '${numberToMonth(timeRead.month)} ' +
                        '${timeRead.day}'),
                    leading: displayPictureUrl.isEmpty
                        ? CircleAvatar()
                        : CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(displayPictureUrl),
                          ),
                    trailing: Text('${timeRead.hour}:' + mins),
                  );
                }
                return Container();
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
