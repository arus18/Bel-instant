import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interactive_message/colors.dart';
import 'package:interactive_message/fonts.dart';
import 'package:interactive_message/selectColor.dart';
import 'package:interactive_message/selectFont.dart';
import 'package:interactive_message/user.dart';
import 'package:interactive_message/sendMsgs.dart';
import 'package:loading_animations/loading_animations.dart';

class ComposeMessage extends StatefulWidget {
  final User user;
  final String message;
  final String conversationID;
  const ComposeMessage({Key key, this.message, this.conversationID, this.user})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ComposeMessageState(message, conversationID, user);
  }
}

class ComposeMessageState extends State<ComposeMessage> {
  bool noInternetConnection;
  bool _initialized = false;
  bool _isBgColor = true;
  bool _showShades = false;
  final ColorsUtility _randFontColor = ColorsUtility();
  final ColorsUtility _randBgColor = ColorsUtility();
  final User user;
  String bgColor;
  int _colorCode;
  int _bgColorCode;
  String fontStyle;
  String fontColor;
  double fontSize;
  Color selectedColor;
  bool _autoSize = true;
  bool _customColor = false;
  bool _randomFont = true;
  PersistentBottomSheetController controller;
  final String message;
  final String conversationID;
  String bgImageUrl;
  final scaffoldState = GlobalKey<ScaffoldState>();
  ComposeMessageState(this.message, this.conversationID, this.user);
  @override
  void initState() {
    super.initState();
    init();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  init() async {
    final hasInternetConnection = await _hasInternetConnection();
    if (hasInternetConnection) {
      final conversationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.regionCode)
          .collection('users')
          .doc(user.userID)
          .collection('conversations')
          .doc(conversationID)
          .get();
      bgColor = conversationSnapshot.data()['bgColor'] ?? 'cyan';
      _bgColorCode = conversationSnapshot.data()['bgColorID'];
      _colorCode = conversationSnapshot.data()['fontColorID'];
      fontColor = conversationSnapshot.data()['fontColor'] ?? 'white';
      fontStyle = conversationSnapshot.data()['fontStyle'] ?? "ABeeZee";
      final lastSavedFontSize = conversationSnapshot.data()['fontSize'];
      if (lastSavedFontSize == null) {
        fontSize = 10.0;
      } else if (lastSavedFontSize == 0) {
        fontSize = 10.0;
      } else {
        fontSize = lastSavedFontSize;
        _autoSize = false;
      }
      setState(() {
        _initialized = true;
        noInternetConnection = false;
      });
    } else {
      setState(() {
        _initialized = true;
        noInternetConnection = true;
      });
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar:
          Container(height: 50, child: Center(child: Text('Ad'))),
      key: scaffoldState,
      backgroundColor: Colors.white,
      body: _initialized
          ? noInternetConnection
              ? Center(
                  child: Text('Connect to internet'),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    (bgImageUrl == null)
                        ? ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: 100, maxWidth: screenWidth - 50),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: _autoSize
                                  ? AutoSizeText(message,
                                      style: GoogleFonts.getFont(fontStyle,
                                          color: (_colorCode == null)
                                              ? ColorsUtility.getColorForString(
                                                  fontColor, 0)
                                              : ColorsUtility.getColorForString(
                                                  fontColor, _colorCode)))
                                  : Text(message, //autosizetext
                                      style: GoogleFonts.getFont(fontStyle,
                                          fontSize: fontSize,
                                          color: (_colorCode == null)
                                              ? ColorsUtility.getColorForString(
                                                  fontColor, 0)
                                              : ColorsUtility.getColorForString(
                                                  fontColor, _colorCode))),
                              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: (_bgColorCode == null)
                                      ? ColorsUtility.getColorForString(
                                          bgColor, 0)
                                      : ColorsUtility.getColorForString(
                                          bgColor, _bgColorCode)),
                            ))
                        : Container(
                            height: 100,
                            width: 200,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                CachedNetworkImage(
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(40)),
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  imageUrl: bgImageUrl,
                                ),
                                _autoSize
                                    ? AutoSizeText(message,
                                        style: GoogleFonts.getFont(fontStyle,
                                            color: (_colorCode == null)
                                                ? ColorsUtility.getColorForString(
                                                    fontColor, _colorCode)
                                                : ColorsUtility.getColorForString(
                                                    fontColor, _colorCode)))
                                    : Text(message,
                                        style: GoogleFonts.getFont(fontStyle,
                                            fontSize: fontSize,
                                            color: (_colorCode == null)
                                                ? ColorsUtility
                                                    .getColorForString(
                                                        fontColor, _colorCode)
                                                : ColorsUtility
                                                    .getColorForString(
                                                        fontColor, _colorCode)))
                              ],
                            )),
                    Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ToggleButton(
                                  btn1Selected: _autoSize,
                                  ontap: ((str) {
                                    setState(() {
                                      if (str == 'Auto') {
                                        _autoSize = true;
                                      } else {
                                        _autoSize = false;
                                      }
                                    });
                                  }),
                                  btnStringColor: Colors.white,
                                  activeBtnColor: Colors.black,
                                  inactiveBtnColor: Colors.orange[400],
                                  btnStr1: 'Auto',
                                  btnStr2: 'Custom',
                                )
                              ],
                            ),
                            (SizedBox(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.red[700],
                                  inactiveTrackColor: Colors.red[100],
                                  trackShape: RoundedRectSliderTrackShape(),
                                  trackHeight: 4.0,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 12.0),
                                  thumbColor: Colors.redAccent,
                                  overlayColor: Colors.red.withAlpha(32),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 28.0),
                                  tickMarkShape: RoundSliderTickMarkShape(),
                                  activeTickMarkColor: Colors.red[700],
                                  inactiveTickMarkColor: Colors.red[100],
                                  valueIndicatorShape:
                                      PaddleSliderValueIndicatorShape(),
                                  valueIndicatorColor: Colors.redAccent,
                                  valueIndicatorTextStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                child: Slider(
                                  value: fontSize,
                                  min: 10,
                                  max: 50,
                                  divisions: 10,
                                  onChanged: (value) {
                                    setState(() {
                                      fontSize = value;
                                    });
                                  },
                                ),
                              ),
                            ))
                          ],
                        ),
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(3.0, 3.0),
                                blurRadius: 5.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.orange[400])),
                    Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ToggleButton(
                                  ontap: ((str) {
                                    if (str == 'Custom') {
                                      _customColor = true;
                                      _randomFont = false;
                                    } else {
                                      _randomFont = true;
                                      _customColor = false;
                                    }
                                  }),
                                  btnStringColor: Colors.white,
                                  activeBtnColor: Colors.black,
                                  inactiveBtnColor: Colors.orange[400],
                                  btnStr1: 'Random',
                                  btnStr2: 'Custom',
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                    onTap: () {
                                      if (_customColor) {
                                        _isBgColor = false;
                                        slidupColors(context);
                                      } else {
                                        setState(() {
                                          _randFontColor.randomColor();
                                          fontColor =
                                              ColorsUtility.getStringForColor(
                                                  _randFontColor
                                                      .selectedRandColor);
                                          _colorCode =
                                              _randFontColor.selectedColorCode;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: (_colorCode == null)
                                              ? ColorsUtility.getColorForString(
                                                  fontColor, 0)
                                              : ColorsUtility.getColorForString(
                                                  fontColor, _colorCode),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    )),
                                GestureDetector(
                                    onTap: () {
                                      bgImageUrl = null;
                                      if (_customColor) {
                                        _isBgColor = true;
                                        slidupColors(context);
                                      } else {
                                        setState(() {
                                          _randBgColor.randomColor();
                                          bgColor =
                                              ColorsUtility.getStringForColor(
                                                  _randBgColor
                                                      .selectedRandColor);

                                          _bgColorCode =
                                              _randBgColor.selectedColorCode;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: (_bgColorCode == null)
                                              ? ColorsUtility.getColorForString(
                                                  bgColor, 0)
                                              : ColorsUtility.getColorForString(
                                                  bgColor, _bgColorCode),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    )),
                                GestureDetector(
                                    onTap: () {
                                      if (_randomFont) {
                                        setState(() {
                                          fontStyle = randomFont();
                                        });
                                      } else {
                                        slidupFonts(context);
                                      }
                                    },
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          'F',
                                          style: GoogleFonts.getFont(fontStyle,
                                              fontSize: 50,
                                              color: (_colorCode == null)
                                                  ? ColorsUtility
                                                      .getColorForString(
                                                          fontColor, 0)
                                                  : ColorsUtility
                                                      .getColorForString(
                                                          fontColor,
                                                          _colorCode)),
                                        ),
                                      ),
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    ))
                              ],
                            )
                          ],
                        ),
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(3.0, 3.0),
                                blurRadius: 5.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.orange[400])),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FloatingActionButton.extended(
                            heroTag: 'send',
                            label: Icon(Icons.send),
                            onPressed: () {
                              Navigator.pop(context);
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.regionCode)
                                  .collection('users')
                                  .doc(user.userID)
                                  .collection('conversations')
                                  .doc(conversationID)
                                  .set({
                                'bgColor': bgColor,
                                'bgColorID': _bgColorCode ?? 0,
                                'fontColorID': _colorCode ?? 0,
                                'fontColor': fontColor,
                                'fontStyle': fontStyle,
                                'fontSize': _autoSize ? 0.0 : fontSize,
                              }, SetOptions(merge: true));
                              final msgs = FirebaseFirestore.instance
                                  .collection('conversations')
                                  .doc(conversationID)
                                  .collection('msgs');
                              final timestamp =
                                  DateTime.now().millisecondsSinceEpoch;
                              final msgID = msgs.doc().id;
                              msgs.doc(msgID).set({
                                'isCustom': true,
                                'msgType': 'text',
                                'msg': message,
                                'bgColor': bgColor,
                                'bgColorID': _bgColorCode ?? 0,
                                'fontColorID': _colorCode ?? 0,
                                'fontColor': fontColor,
                                'fontStyle': fontStyle,
                                'fontSize': _autoSize ? 0.0 : fontSize,
                                'bgImageUrl':
                                    (bgImageUrl == null) ? '' : bgImageUrl,
                                'userID': user.userID,
                                'timestamp': timestamp,
                                'name': user.userName
                              });
                              setUnreadCount(
                                conversationID,
                                msgID,
                                user.userID,
                                timestamp,
                                user,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                )
          : Center(
              child: LoadingBouncingLine.circle(
                backgroundColor: Colors.yellow,
              ),
            ),
    );
  }

  slidupColors(BuildContext context) {
    final query = MediaQuery.of(context);
    final height = query.size.height - 200;
    controller = scaffoldState.currentState.showBottomSheet((context) {
      return Container(
          height: height,
          child: _showShades
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_isBgColor) {
                            controller.setState(() {
                              _showShades = false;
                              _isBgColor = true;
                            });
                          } else {
                            controller.setState(() {
                              _showShades = false;
                              _isBgColor = false;
                            });
                          }
                        },
                      ),
                      SelectColorShades(
                        ontap: (color, colorCode) {
                          setState(() {
                            if (_isBgColor) {
                              _bgColorCode = null;
                              bgColor = ColorsUtility.getStringForColor(color);
                              _bgColorCode = colorCode;
                            } else {
                              _colorCode = null;
                              fontColor =
                                  ColorsUtility.getStringForColor(color);
                              _colorCode = colorCode;
                            }
                          });
                        },
                        color: selectedColor,
                      )
                    ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                      Text('Double tap to shades'),
                      SelectColor(
                        ontap: (color) {
                          setState(() {
                            if (_isBgColor) {
                              _bgColorCode = null;
                              bgColor = ColorsUtility.getStringForColor(color);
                            } else {
                              _colorCode = null;
                              fontColor =
                                  ColorsUtility.getStringForColor(color);
                            }
                          });
                        },
                        controller: controller,
                        onDoubletap: (Color color) {
                          selectedColor = color;
                          if (_isBgColor) {
                            controller.setState(() {
                              _showShades = true;
                              _isBgColor = true;
                            });
                          } else {
                            controller.setState(() {
                              _showShades = true;
                              _isBgColor = false;
                            });
                          }
                        },
                      )
                    ]));
    });
  }

  slidupFonts(BuildContext context) {
    final query = MediaQuery.of(context);
    final height = query.size.height - 200;
    scaffoldState.currentState.showBottomSheet((context) {
      return Container(
        height: height,
        child: SelectFont(
          ontap: (font) {
            setState(() {
              fontStyle = font;
            });
          },
        ),
      );
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}

class ToggleButton extends StatefulWidget {
  final String btnStr1;
  final String btnStr2;
  final Color activeBtnColor;
  final Color inactiveBtnColor;
  final Color btnStringColor;
  final bool btn1Selected;
  final void Function(String) ontap;
  const ToggleButton(
      {Key key,
      this.btn1Selected: true,
      this.ontap,
      this.btnStr1,
      this.btnStr2,
      this.activeBtnColor,
      this.inactiveBtnColor,
      this.btnStringColor})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ToggleButtonState(btn1Selected, ontap, btnStr1, btnStr2,
        activeBtnColor, inactiveBtnColor, btnStringColor);
  }
}

class ToggleButtonState extends State<ToggleButton> {
  final String btnStr1;
  final String btnStr2;
  final Color activeBtnColor;
  final Color inactiveBtnColor;
  final Color btnStringColor;
  Color btn1Color;
  Color btn2Color;
  bool btn1Selected;
  final void Function(String) ontap;
  ToggleButtonState(this.btn1Selected, this.ontap, this.btnStr1, this.btnStr2,
      this.activeBtnColor, this.inactiveBtnColor, this.btnStringColor);
  @override
  void initState() {
    super.initState();
    if (btn1Selected) {
      btn1Color = activeBtnColor;
      btn2Color = inactiveBtnColor;
    } else {
      btn1Color = inactiveBtnColor;
      btn2Color = activeBtnColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (!btn1Selected) {
              setState(() {
                btn1Selected = true;
                btn1Color = activeBtnColor;
                btn2Color = inactiveBtnColor;
              });
              ontap(btnStr1);
            }
          },
          child: Container(
            padding: EdgeInsets.all(5),
            child: Center(
              child: Text(btnStr1,
                  style: TextStyle(color: btnStringColor, fontSize: 20)),
            ),
            decoration: BoxDecoration(
                color: btn1Color, border: Border.all(color: Colors.black)),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (btn1Selected) {
              setState(() {
                btn1Selected = false;
                btn1Color = inactiveBtnColor;
                btn2Color = activeBtnColor;
              });
              ontap(btnStr2);
            }
          },
          child: Container(
            padding: EdgeInsets.all(5),
            child: Center(
              child: Text(
                btnStr2,
                style: TextStyle(color: btnStringColor, fontSize: 20),
              ),
            ),
            decoration: BoxDecoration(
                color: btn2Color, border: Border.all(color: Colors.black)),
          ),
        )
      ],
    );
  }
}
