// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  int progress = 0;
  DownloadService();

  downloadRequest(url, filename, ext) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        fileName: filename + '.' + ext,
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
