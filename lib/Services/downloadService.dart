import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  int progress = 0;

  ReceivePort _receivePort = ReceivePort();

  DownloadService() {}

  downloadRequest(url) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        fileName: "demoDownload",
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else {
      print("Permission deined");
    }
  }
}
