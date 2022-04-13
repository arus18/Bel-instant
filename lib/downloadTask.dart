import 'package:flutter_downloader/flutter_downloader.dart';

class Task {
  String taskID;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;
}