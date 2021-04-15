import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:interactive_message/startupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterDownloader.initialize();
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
      home: StartupScreen()));
}
