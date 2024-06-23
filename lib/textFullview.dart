import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextFullView extends StatelessWidget {
  final String msg;
  const TextFullView(
    this.msg, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.yellow,
          ),
          child: SingleChildScrollView(
            child: Text(
              msg,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
