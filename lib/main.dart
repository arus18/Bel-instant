import 'package:bel_instant/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'startupScreen.dart';

void main() async {
  print("start");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterDownloader.initialize();
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
      home: StartupScreen()));
}
