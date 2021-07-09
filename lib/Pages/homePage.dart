import 'dart:isolate';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:videodown/Models/yDMVideoResponse.dart';
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
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Search"),
              onSubmitted: (value) => setState(() {
                _showSheetWithoutList(value);
              }),
            ),
          ],
        ),
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
      builder: (context) => Expanded(
        child: Column(
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
                    AsyncSnapshot<List<VideoDetails>> snapshot) {
                  if (snapshot.data == null) {
                    return Container(child: CircularProgressIndicator());
                  } else if (snapshot.data![0].status == false) {
                    return Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(snapshot.data![0].message),
                            SizedBox(height: 50),
                            OutlineButton(
                              child: Text(
                                "Close",
                              ),
                              highlightedBorderColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ]),
                    );
                  } else {
                    return Wrap(
                      // shrinkWrap: true,
                      children: [
                        Text('Audio'),
                        SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data![0].audioFormat.length,
                            itemBuilder: (BuildContext context, int index) {
                              var video = snapshot.data![0].audioFormat[index];
                              return Card(
                                child: ListTile(
                                  title: Wrap(
                                    spacing: 10.0,
                                    children: [
                                      Text(video.quality.toString(),
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold
                                              )),
                                      Text(video.ext.toString(),
                                          style: TextStyle(
                                              // fontWeight: FontWeight.w300

                                              )),
                                    ],
                                  ),
                                  subtitle: Text(filesize(video.size)),
                                  onTap: () {
                                    downloadService.downloadRequest(video.url,
                                        snapshot.data![0].title, video.ext);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Text('Video'),
                        SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data![0].videoFormat.length,
                            itemBuilder: (BuildContext context, int index) {
                              var video = snapshot.data![0].videoFormat[index];
                              return Card(
                                child: ListTile(
                                  title: Wrap(
                                    spacing: 10.0,
                                    children: [
                                      Text(video.quality.toString(),
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold
                                              )),
                                      Text(video.ext.toString(),
                                          style: TextStyle(
                                              // fontWeight: FontWeight.w300

                                              )),
                                    ],
                                  ),
                                  subtitle: Text(filesize(video.size)),
                                  onTap: () {
                                    downloadService.downloadRequest(
                                        video.url,
                                        snapshot.data![0].title + video.quality,
                                        video.ext);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
