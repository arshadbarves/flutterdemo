import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:videodown/Models/ydMReponse.dart';
import 'package:videodown/Services/downloadService.dart';
import 'package:videodown/Services/youtubeService.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var result;
  bool isLoading = false;
  late YouTubeService youTubeService;
  late DownloadService downloadService;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    youTubeService = YouTubeService();
    downloadService = DownloadService();
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  // @override
  // void initState() {
  //   youTubeService = YouTubeService();
  //   downloadService = DownloadService();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
            child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Search"),
              onSubmitted: (value) => setState(() {
                _showSheetWithoutList(value);
              }),
            ),
          ],
        )),
      ),
    );
  }

  void _showSheetWithoutList(url) {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      bounce: true,
      closeProgressThreshold: 0.5,
      builder: (context) => Column(
        children: [
          Container(
            margin: EdgeInsets.all(30),
            child: Text(
              "Download Options",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
            ),
          ),
          Container(
            child: FutureBuilder(
              future: youTubeService.getRequest(url),
              builder: (BuildContext context,
                  AsyncSnapshot<List<VideoList>> snapshot) {
                if (snapshot.data == null) {
                  return Container(child: CircularProgressIndicator());
                } else {
                  return Expanded(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          var video = snapshot.data![index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                  //   backgroundImage:
                                  //       NetworkImage(snapshot.data[index].picture),
                                  ),
                              title: Wrap(
                                spacing: 10.0,
                                children: [
                                  Text(video.format.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(video.ext.toString(),
                                      style: TextStyle(
                                          // fontWeight: FontWeight.w300

                                          )),
                                ],
                              ),
                              subtitle: Text(filesize(video.filesize.toInt())),
                              onTap: () {
                                downloadService.downloadRequest(video.url);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
