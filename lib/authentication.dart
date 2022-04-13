import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactive_message/countrycodes.dart';
import 'package:interactive_message/help.dart';
import 'package:interactive_message/refreshcontacts.dart';
import 'package:interactive_message/user.dart' as local;
import 'package:loading_animations/loading_animations.dart';
import 'package:sim_info/sim_info.dart';

class Authentication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthenticationState();
  }
}

class AuthenticationState extends State<Authentication> {
  String _selectedRegionCode = 'IN';
  String _selectedCountryCode = '+91';
  String _verificationID;
  bool _codeAutoRetrievalTimeout = false;
  bool _autoOtpVerificationRunning = false;
  bool _manualOtpVerificationRunning = false;
  bool _autoFormat = true;
  bool _initialized = false;
  bool _hasInternetConnection;
  bool hide = false;
  final _autoOTPfocusNode = FocusNode();
  final _manualOTPfocusNode = FocusNode();
  final _phnNumberController = TextEditingController();
  final _otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _manualOTPfocusNode.addListener(() {
      setState(() {
        if (_manualOTPfocusNode.hasFocus) {
          hide = true;
        } else {
          hide = false;
        }
      });
    });
    _init();
  }

  _init() async {
    try {
      String isoCountryCode = await SimInfo.getIsoCountryCode;
      if (isoCountryCode != null) {
        _selectedRegionCode = isoCountryCode.toUpperCase();
        final temp = regionCodeCountryCode[isoCountryCode.toUpperCase()];
        if (temp != null) {
          _selectedCountryCode = temp;
        } else {
          _selectedRegionCode = 'IN';
          _selectedCountryCode = '+91';
        }
      }
    } catch (e) {}
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _hasInternetConnection = true;
        _initialized = true;
        setState(() {});
      }
    } catch (e) {
      _hasInternetConnection = false;
      _initialized = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _initialized
            ? !_hasInternetConnection
                ? Center(
                    child: Text('Connect to internet and restart app'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(5),
                              child: DropdownButton<String>(
                                value: _selectedRegionCode,
                                onChanged: (selected) {
                                  setState(() {
                                    _selectedRegionCode = selected;
                                    _selectedCountryCode =
                                        regionCodeCountryCode[selected];
                                  });
                                },
                                items: regionCodeCountryCode.keys.map((rgCode) {
                                  return DropdownMenuItem<String>(
                                      child: Text(rgCode), value: rgCode);
                                }).toList(),
                              )),
                          Container(
                              margin: EdgeInsets.all(5),
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                onChanged: (selected) {
                                  _selectedRegionCode = (selected == '+1809' ||
                                          selected == '+1829' ||
                                          selected == '+1849')
                                      ? 'DO'
                                      : regionCodeCountryCode.keys
                                          .firstWhere((rgCode) {
                                          return regionCodeCountryCode[
                                                  rgCode] ==
                                              selected;
                                        });
                                  setState(() {
                                    _selectedCountryCode = selected;
                                  });
                                },
                                items: countryCodesForDropDownMenu
                                    .map((countryCode) {
                                  return DropdownMenuItem<String>(
                                      child: Text(countryCode),
                                      value: countryCode);
                                }).toList(),
                              )),
                        ],
                      ),
                      hide
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                  Expanded(
                                      child: Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: (TextField(
                                            focusNode: _autoOTPfocusNode,
                                            onChanged: (value) {
                                              final nationalNumberLength =
                                                  regionCodeNationalNumberLength[
                                                      _selectedRegionCode];
                                              if (value.length >
                                                  nationalNumberLength) {
                                                final startIndex =
                                                    value.length -
                                                        nationalNumberLength;
                                                _phnNumberController.text =
                                                    value.substring(startIndex,
                                                        value.length);
                                              }
                                              setState(() {});
                                            },
                                            controller: _phnNumberController,
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Enter your phone number here',
                                                prefixText: _autoFormat
                                                    ? _selectedCountryCode
                                                    : '',
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                  const Radius.circular(25.0),
                                                ))),
                                          )))),
                                  Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (_autoFormat) {
                                              _autoFormat = false;
                                            } else {
                                              _autoFormat = true;
                                            }
                                          });
                                        },
                                        child: Column(children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(bottom: 2),
                                            height: 15,
                                            width: 15,
                                            decoration: BoxDecoration(
                                                color: _autoFormat
                                                    ? Colors.green
                                                    : Colors.white,
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          Text('  Auto\nformat')
                                        ]),
                                      )),
                                ]),
                      hide
                          ? Container()
                          : (_autoOtpVerificationRunning ||
                                  _manualOtpVerificationRunning)
                              ? LoadingBumpingLine.circle(
                                  backgroundColor: Colors.yellow,
                                )
                              : _phnNumberController.text.isNotEmpty
                                  ? FloatingActionButton.extended(
                                      backgroundColor: Colors.yellow,
                                      onPressed: () {
                                        _autoOtpVerification();
                                        _autoOTPfocusNode.unfocus();
                                      },
                                      label: Text(
                                        'Send code',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  : Container(),
                      _codeAutoRetrievalTimeout
                          ? Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              child: TextField(
                                focusNode: _manualOTPfocusNode,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                controller: _otpController,
                                decoration: InputDecoration(
                                    labelText:
                                        'Enter your verification code here',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                      const Radius.circular(25.0),
                                    ))),
                              ))
                          : Container(),
                      _codeAutoRetrievalTimeout
                          ? _manualOtpVerificationRunning
                              ? LoadingBumpingLine.circle(
                                  backgroundColor: Colors.yellow,
                                )
                              : _otpController.text.isNotEmpty
                                  ? FloatingActionButton.extended(
                                      backgroundColor: Colors.yellow,
                                      onPressed: () {
                                        _manualOtpVerification();
                                        _manualOTPfocusNode.unfocus();
                                      },
                                      label: Text(
                                        'Verify',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  : Container()
                          : Container()
                    ],
                  )
            : Center(
                child: LoadingBumpingLine.circle(
                backgroundColor: Colors.yellow,
              )));
  }

  Future<local.User> _initUser(User user) async {
    final FirebaseMessaging _fcm = FirebaseMessaging();
    final String fcmToken = await _fcm.getToken();
    FirebaseFirestore.instance
        .collection('userRegionCodes')
        .doc(user.uid)
        .set({'regionCode': _selectedRegionCode, 'token': fcmToken});
    FirebaseFirestore.instance
        .collection('users')
        .doc(_selectedRegionCode)
        .collection('users')
        .doc(user.uid)
        .set({
      'phoneNumber': user.phoneNumber,
      'countryCode': _selectedCountryCode,
      'regionCode': _selectedRegionCode,
      'name': '',
      'displayPictureUrl': '',
    });
    return local.User('', user.phoneNumber, _selectedCountryCode, user.uid,
        _selectedRegionCode, '', fcmToken);
  }

  _autoOtpVerification() async {
    setState(() {
      _autoOtpVerificationRunning = true;
    });
    String phoneNumber = _selectedCountryCode + _phnNumberController.text;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 10),
        verificationCompleted: (authCredential) async {
          _otpController.text = _verificationID;
          final result = await (_auth.signInWithCredential(authCredential));
          if (result.user != null) {
            final user = await _initUser(result.user);
            refreshContacts(user);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return Help(
                user: user,
              );
            }));
          } else {
            setState(() {
              _autoOtpVerificationRunning = false;
              _codeAutoRetrievalTimeout = false;
            });
          }
        },
        verificationFailed: (authException) {
          setState(() {
            _autoOtpVerificationRunning = false;
            _codeAutoRetrievalTimeout = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationID) {
          _verificationID = verificationID;
          setState(() {
            _codeAutoRetrievalTimeout = true;
            _autoOtpVerificationRunning = false;
          });
        },
        codeSent: (verificationId, [forceResendingToken]) {
          _verificationID = verificationId;
        },
      );
    } catch (e) {}
  }

  _manualOtpVerification() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    setState(() {
      _manualOtpVerificationRunning = true;
    });
    try {
      final _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationID, smsCode: _otpController.text);
      final result = await _auth.signInWithCredential(_authCredential);
      if (result.user != null) {
        final user = await _initUser(result.user);
        refreshContacts(user);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Help(user: user);
        }));
      } else {
        setState(() {
          _autoOtpVerificationRunning = false;
          _codeAutoRetrievalTimeout = false;
        });
      }
    } catch (e) {}
  }
}
