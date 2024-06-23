import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fonts.dart';

class SelectFont extends StatefulWidget {
  final void Function(String) ontap;
  const SelectFont({Key? key, required this.ontap}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SelectFontState(ontap);
  }
}

class SelectFontState extends State<SelectFont> {
  final void Function(String) ontap;
  double _scroll = 0;
  ScrollController _controller = ScrollController();
  SelectFontState(this.ontap);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: () {
                if (_scroll <= _controller.position.maxScrollExtent) {
                  final maxScrollExtent = _controller.position.maxScrollExtent;
                  _scroll += maxScrollExtent / 20;
                  _controller.animateTo(_scroll,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                }
              },
            ),
            SizedBox(
              width: 5,
            ),
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: () {
                if (_scroll > _controller.position.minScrollExtent) {
                  _scroll -= 10000;
                }
                _controller.animateTo(_scroll,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn);
              },
            )
          ],
        ),
        body: GridView.builder(
          controller: _controller,
          itemCount: fontNames.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          itemBuilder: (BuildContext context, int index) {
            print('$index');
            return GestureDetector(
                onTap: () {
                  ontap(fontNames[index]);
                },
                child: Center(
                    child: Text(
                  'Font',
                  style: getFont(index),
                )));
          },
        ));
  }

  TextStyle getFont(int index) {
    TextStyle style = TextStyle();
    try {
      style = GoogleFonts.getFont(fontNames[index], fontSize: 30);
    } catch (e) {}
    return style;
  }
}
