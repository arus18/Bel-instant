import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class SelectColor extends StatelessWidget {
  final PersistentBottomSheetController controller;
  final void Function(Color) onDoubletap;
  final void Function(Color) ontap;
  const SelectColor({Key key, this.onDoubletap, this.controller,this.ontap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.builder(
      itemCount: colors.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.all(10),
          child: GestureDetector(
            onTap: (){
              ontap(colors[index]);
            },
            onDoubleTap: () {
              controller.setState(() {
                onDoubletap(colors[index]);
              });
            },
          ),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: colors[index]),
        );
      },
    ));
  }
}

class SelectColorShades extends StatelessWidget {
  final MaterialColor color;
  final void Function(MaterialColor,int) ontap;
  const SelectColorShades({
    Key key,
    this.color,
    this.ontap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.builder(
      itemCount: colorCodes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.all(10),
          child: GestureDetector(onTap: (){
            ontap(color,colorCodes[index]);
          },),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              shape: BoxShape.circle,
              color: color[colorCodes[index]]),
        );
      },
    ));
  }
}
