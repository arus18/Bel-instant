import 'package:flutter/material.dart';
import 'package:interactive_message/displayPictureAndName.dart';
import 'package:interactive_message/user.dart';

class Help extends StatelessWidget {
  final User user;
  const Help({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          height: 50,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return InitializeDisplayPictureName(user: user);
            }));
          },
          child: Icon(Icons.arrow_right),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    '1.Yellow tick indicates reciever has seen the message',
                    style: TextStyle(fontSize: 20),
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Text('2.Double tap on message to reply',
                      style: TextStyle(fontSize: 20)))
            ]));
  }
}